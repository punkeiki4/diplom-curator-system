using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using DIPLOM.DAL.Context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace DIPLOM.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class SchedulesController : ControllerBase
{
    private readonly IScheduleService _scheduleService;
    private readonly AppDbContext _context;

    public SchedulesController(IScheduleService scheduleService, AppDbContext context)
    {
        _scheduleService = scheduleService;
        _context = context;
    }

    private int CurrentUserId =>
        int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    
    [HttpGet("my")]
    public async Task<IActionResult> GetMy()
    {
        var student = await _context.Students.FindAsync(CurrentUserId);
        if (student == null) return NotFound("Студент не найден");
        return Ok(await _scheduleService.GetByGroupAsync(student.GroupId ?? 0));
    }

   
    [HttpGet("my-group/today")]
    public async Task<IActionResult> GetMyGroupToday()
    {
        var curatorGroup = await _context.CuratorGroups
            .FirstOrDefaultAsync(cg => cg.CuratorId == CurrentUserId);
        if (curatorGroup == null) return Ok(new List<object>());
        var all = await _scheduleService.GetByGroupAsync(curatorGroup.GroupId);
        return Ok(all);
    }

    [HttpGet("group/{groupId}")]
    public async Task<IActionResult> GetByGroup(int groupId) =>
        Ok(await _scheduleService.GetByGroupAsync(groupId));

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var s = await _scheduleService.GetByIdAsync(id);
        return s == null ? NotFound() : Ok(s);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateScheduleDto dto)
    {
        var s = await _scheduleService.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = s.Id }, s);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateScheduleDto dto)
    {
        var s = await _scheduleService.UpdateAsync(id, dto);
        return s == null ? NotFound() : Ok(s);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _scheduleService.DeleteAsync(id);
        return result ? NoContent() : NotFound();
    }
}
