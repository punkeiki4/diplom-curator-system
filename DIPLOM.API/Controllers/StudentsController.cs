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
public class StudentsController : ControllerBase
{
    private readonly IStudentService _studentService;
    private readonly AppDbContext _context;

    public StudentsController(IStudentService studentService, AppDbContext context)
    {
        _studentService = studentService;
        _context = context;
    }

    private int CurrentUserId =>
        int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

   
    [HttpGet("my-group")]
    public async Task<IActionResult> GetMyGroup()
    {
        var curatorGroup = await _context.CuratorGroups
            .FirstOrDefaultAsync(cg => cg.CuratorId == CurrentUserId);
        if (curatorGroup == null) return Ok(new List<object>());
        return Ok(await _studentService.GetByGroupAsync(curatorGroup.GroupId));
    }

    [HttpGet]
    public async Task<IActionResult> GetAll() =>
        Ok(await _studentService.GetAllAsync());

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var student = await _studentService.GetByIdAsync(id);
        return student == null ? NotFound() : Ok(student);
    }

    [HttpGet("group/{groupId}")]
    public async Task<IActionResult> GetByGroup(int groupId) =>
        Ok(await _studentService.GetByGroupAsync(groupId));

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateStudentDto dto)
    {
        var student = await _studentService.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = student.Id }, student);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _studentService.DeleteAsync(id);
        return result ? NoContent() : NotFound();
    }
}
