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
public class RequestsController : ControllerBase
{
    private readonly IRequestService _requestService;
    private readonly AppDbContext _context;

    public RequestsController(IRequestService requestService, AppDbContext context)
    {
        _requestService = requestService;
        _context = context;
    }

    private int CurrentUserId =>
        int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

   
    [HttpGet("my")]
    public async Task<IActionResult> GetMy() =>
        Ok(await _requestService.GetByStudentAsync(CurrentUserId));

    
    [HttpGet]
    public async Task<IActionResult> GetAll() =>
        Ok(await _requestService.GetAllAsync());

    [HttpGet("student/{studentId}")]
    public async Task<IActionResult> GetByStudent(int studentId) =>
        Ok(await _requestService.GetByStudentAsync(studentId));

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var r = await _requestService.GetByIdAsync(id);
        return r == null ? NotFound() : Ok(r);
    }

    
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateRequestDto dto)
    {
        
        if (dto.StudentId == 0) dto.StudentId = CurrentUserId;
        var r = await _requestService.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = r.Id }, r);
    }

    
    [HttpPut("{id}/review")]
    public async Task<IActionResult> Review(int id, [FromBody] ReviewRequestDto dto)
    {
        if (dto.ReviewedBy == 0) dto.ReviewedBy = CurrentUserId;
        dto.Status = dto.Status?.ToLower() switch {
            "approved" => "Одобрено",
            "rejected" => "Отклонено",
            "pending" => "В обработке",
            _ => dto.Status ?? "В обработке"
        };
        var r = await _requestService.ReviewAsync(id, dto);
        return r == null ? NotFound() : Ok(r);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _requestService.DeleteAsync(id);
        return result ? NoContent() : NotFound();
    }
}
