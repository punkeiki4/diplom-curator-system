using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace DIPLOM.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class CuratorReportsController : ControllerBase
{
    private readonly ICuratorReportService _reportService;

    public CuratorReportsController(ICuratorReportService reportService) =>
        _reportService = reportService;

    private int CurrentUserId =>
        int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    
    [HttpGet("my")]
    public async Task<IActionResult> GetMy() =>
        Ok(await _reportService.GetByCuratorAsync(CurrentUserId));

    
    [HttpGet]
    public async Task<IActionResult> GetAll() =>
        Ok(await _reportService.GetAllAsync());

    [HttpGet("task/{taskId}")]
    public async Task<IActionResult> GetByTask(int taskId) =>
        Ok(await _reportService.GetByTaskAsync(taskId));

    [HttpGet("curator/{curatorId}")]
    public async Task<IActionResult> GetByCurator(int curatorId) =>
        Ok(await _reportService.GetByCuratorAsync(curatorId));

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var r = await _reportService.GetByIdAsync(id);
        return r == null ? NotFound() : Ok(r);
    }

    
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateCuratorReportDto dto)
    {
        if (dto.CuratorId == 0) dto.CuratorId = CurrentUserId;
        var r = await _reportService.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = r.Id }, r);
    }

    
    [HttpPut("{id}/review")]
    public async Task<IActionResult> Review(int id, [FromBody] ReviewReportDto dto)
    {
        var r = await _reportService.ReviewAsync(id, dto);
        return r == null ? NotFound() : Ok(r);
    }
}
