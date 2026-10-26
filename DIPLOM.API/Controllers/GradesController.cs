using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using DIPLOM.DAL.Context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace DIPLOM.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class GradesController : ControllerBase
{
    private readonly IGradeService _gradeService;
    private readonly AppDbContext _context;

    public GradesController(IGradeService gradeService, AppDbContext context)
    {
        _gradeService = gradeService;
        _context = context;
    }

    private int CurrentUserId =>
        int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

  
    [HttpGet("my")]
    public async Task<IActionResult> GetMy()
    {
        var student = await _context.Students.FindAsync(CurrentUserId);
        if (student == null) return NotFound("Студент не найден");
        return Ok(await _gradeService.GetByStudentAsync(CurrentUserId));
    }

    [HttpGet("student/{studentId}")]
    public async Task<IActionResult> GetByStudent(int studentId) =>
        Ok(await _gradeService.GetByStudentAsync(studentId));

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var g = await _gradeService.GetByIdAsync(id);
        return g == null ? NotFound() : Ok(g);  
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateGradeDto dto)
    {
        var g = await _gradeService.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = g.Id }, g);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateGradeDto dto)
    {
        var g = await _gradeService.UpdateAsync(id, dto);
        return g == null ? NotFound() : Ok(g);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _gradeService.DeleteAsync(id);
        return result ? NoContent() : NotFound();
    }
}
