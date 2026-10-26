using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using DIPLOM.DAL.Context;
using DIPLOM.DAL.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace DIPLOM.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class AttendancesController : ControllerBase
{
    private readonly IAttendanceService _attendanceService;
    private readonly AppDbContext _context;

    public AttendancesController(IAttendanceService attendanceService, AppDbContext context)
    {
        _attendanceService = attendanceService;
        _context = context;
    }

    private int CurrentUserId =>
        int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);


    [HttpGet("my-group")]
    public async Task<IActionResult> GetMyGroup([FromQuery] int? month, [FromQuery] int? year)
    {
        var groups = await _context.CuratorGroups
            .Where(cg => cg.CuratorId == CurrentUserId)
            .Select(cg => cg.GroupId)
            .ToListAsync();

        var studentIds = await _context.Students
            .Where(s => s.GroupId.HasValue && groups.Contains(s.GroupId!.Value))
            .Select(s => s.Id)
            .ToListAsync();

        var query = _context.Attendances
            .Include(a => a.Student).ThenInclude(s => s!.User)
            .Include(a => a.Schedule)
            .Where(a => a.StudentId.HasValue && studentIds.Contains(a.StudentId.Value));

        if (month.HasValue && year.HasValue)
            query = query.Where(a => a.Schedule!.LessonDate.Value.Month == month.Value
                                  && a.Schedule!.LessonDate.Value.Year == year.Value);

        var result = await query.Select(a => new {
            a.StudentId,
            StudentName = a.Student!.User!.FullName,
            a.Schedule!.Subject,
            LessonDate = a.Schedule.LessonDate,
            a.Status,
            IsPresent = a.Status == "Присутствовал"
        }).ToListAsync();

        return Ok(result);
    }

   
    [HttpGet("my")]
    public async Task<IActionResult> GetMy()
    {
        var student = await _context.Students.FindAsync(CurrentUserId);
        if (student == null) return NotFound("Студент не найден");
        return Ok(await _attendanceService.GetByStudentAsync(CurrentUserId));
    }

    
    [HttpPost("batch")]
    public async Task<IActionResult> CreateBatch([FromBody] List<CreateAttendanceDto> dtos)
    {
        var results = new List<AttendanceDto>();
        foreach (var dto in dtos)
        {
          
            var existing = await _context.Attendances
                .FirstOrDefaultAsync(a => a.StudentId == dto.StudentId && a.ScheduleId == dto.ScheduleId);
            if (existing != null)
            {
                existing.Status = dto.IsPresent == true ? "Присутствовал" : "Отсутствовал";
                await _context.SaveChangesAsync();
            }
            else
            {
                var created = await _attendanceService.CreateAsync(dto);
                results.Add(created);
            }
        }
        return Ok(results);
    }

    [HttpGet("student/{studentId}")]
    public async Task<IActionResult> GetByStudent(int studentId) =>
        Ok(await _attendanceService.GetByStudentAsync(studentId));

    [HttpGet("schedule/{scheduleId}")]
    public async Task<IActionResult> GetBySchedule(int scheduleId) =>
        Ok(await _attendanceService.GetByScheduleAsync(scheduleId));

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var a = await _attendanceService.GetByIdAsync(id);
        return a == null ? NotFound() : Ok(a);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateAttendanceDto dto)
    {
        var a = await _attendanceService.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = a.Id }, a);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateAttendanceDto dto)
    {
        var a = await _attendanceService.UpdateAsync(id, dto);
        return a == null ? NotFound() : Ok(a);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _attendanceService.DeleteAsync(id);
        return result ? NoContent() : NotFound();
    }
}
