using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DIPLOM.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class GroupsController : ControllerBase
{
    private readonly IGroupService _groupService;

    public GroupsController(IGroupService groupService) => _groupService = groupService;

    [HttpGet]
    public async Task<IActionResult> GetAll() => Ok(await _groupService.GetAllAsync());

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var group = await _groupService.GetByIdAsync(id);
        return group == null ? NotFound() : Ok(group);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateGroupDto dto)
    {
        var group = await _groupService.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = group.Id }, group);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _groupService.DeleteAsync(id);
        return result ? NoContent() : NotFound();
    }

    [HttpPost("{groupId}/curators/{curatorId}")]
    public async Task<IActionResult> AssignCurator(int groupId, int curatorId)
    {
        var result = await _groupService.AssignCuratorAsync(groupId, curatorId);
        return result ? Ok() : BadRequest(new { message = "Куратор уже назначен" });
    }

    [HttpDelete("{groupId}/curators/{curatorId}")]
    public async Task<IActionResult> RemoveCurator(int groupId, int curatorId)
    {
        var result = await _groupService.RemoveCuratorAsync(groupId, curatorId);
        return result ? NoContent() : NotFound();
    }
}
