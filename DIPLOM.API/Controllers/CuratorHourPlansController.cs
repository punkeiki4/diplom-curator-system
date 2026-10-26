using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace DIPLOM.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class CuratorHourPlansController : ControllerBase
{
    private readonly CuratorHourPlanService _service;
    public CuratorHourPlansController(CuratorHourPlanService service) => _service = service;

    private int CurrentUserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    
    [HttpGet("my")]
    public async Task<IActionResult> GetMy() =>
        Ok(await _service.GetByCuratorAsync(CurrentUserId));

    
    [HttpGet]
    public async Task<IActionResult> GetAll() =>
        Ok(await _service.GetAllAsync());

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateCuratorHourPlanDto dto)
    {
        var plan = await _service.CreateAsync(CurrentUserId, dto);
        return Ok(plan);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateCuratorHourPlanDto dto)
    {
        var plan = await _service.UpdateAsync(id, dto);
        return plan == null ? NotFound() : Ok(plan);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _service.DeleteAsync(id);
        return result ? NoContent() : NotFound();
    }
}
