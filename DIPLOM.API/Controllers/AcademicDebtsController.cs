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
public class AcademicDebtsController : ControllerBase
{
    private readonly IAcademicDebtService _debtService;
    private readonly AppDbContext _context;

    public AcademicDebtsController(IAcademicDebtService debtService, AppDbContext context)
    {
        _debtService = debtService;
        _context = context;
    }

    private int CurrentUserId =>
        int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

   
    [HttpGet("my")]
    public async Task<IActionResult> GetMy() =>
        Ok(await _debtService.GetByStudentAsync(CurrentUserId));

    [HttpGet]
    public async Task<IActionResult> GetAll() =>
        Ok(await _debtService.GetAllAsync());

    [HttpGet("student/{studentId}")]
    public async Task<IActionResult> GetByStudent(int studentId) =>
        Ok(await _debtService.GetByStudentAsync(studentId));

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var d = await _debtService.GetByIdAsync(id);
        return d == null ? NotFound() : Ok(d);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateAcademicDebtDto dto)
    {
        var d = await _debtService.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = d.Id }, d);
    }

    
    [HttpPut("{id}/eliminate")]
    public async Task<IActionResult> Eliminate(int id)
    {
        var dto = new UpdateAcademicDebtDto { Status = "Погашена", IsEliminated = true };
        var d = await _debtService.UpdateAsync(id, dto);
        return d == null ? NotFound() : Ok(d);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateAcademicDebtDto dto)
    {
        var d = await _debtService.UpdateAsync(id, dto);
        return d == null ? NotFound() : Ok(d);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _debtService.DeleteAsync(id);
        return result ? NoContent() : NotFound();
    }
}
