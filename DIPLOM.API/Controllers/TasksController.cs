using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace DIPLOM.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TasksController : ControllerBase
{
    private readonly ITaskService _taskService;

    public TasksController(ITaskService taskService) => _taskService = taskService;

    private int CurrentUserId =>
        int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    [HttpGet("my")]
    public async Task<IActionResult> GetMy() =>
        Ok(await _taskService.GetByCuratorAsync(CurrentUserId));

    [HttpGet]
    public async Task<IActionResult> GetAll() =>
        Ok(await _taskService.GetAllAsync());

    [HttpGet("curator/{curatorId}")]
    public async Task<IActionResult> GetByCurator(int curatorId) =>
        Ok(await _taskService.GetByCuratorAsync(curatorId));

    [HttpGet("vicedean/{viceDeanId}")]
    public async Task<IActionResult> GetByViceDean(int viceDeanId) =>
        Ok(await _taskService.GetByViceDeanAsync(viceDeanId));

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var t = await _taskService.GetByIdAsync(id);
        return t == null ? NotFound() : Ok(t);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateTaskDto dto)
    {
        if (dto.AssignedBy == 0) dto.AssignedBy = CurrentUserId;
        var t = await _taskService.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = t.Id }, t);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateTaskDto dto)
    {
        var t = await _taskService.UpdateAsync(id, dto);
        return t == null ? NotFound() : Ok(t);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _taskService.DeleteAsync(id);
        return result ? NoContent() : NotFound();
    }
}
