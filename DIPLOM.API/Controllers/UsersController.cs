using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DIPLOM.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService) => _userService = userService;

    [HttpGet]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetAll([FromQuery] string? role = null)
    {
        var users = await _userService.GetAllAsync();
        if (!string.IsNullOrEmpty(role))
            users = users.Where(u => u.RoleName != null &&
                u.RoleName.ToLower().Contains(role.ToLower()));
        return Ok(users);
    }

    [HttpGet("curators")]
    [Authorize(Roles = "Admin,ViceDean")]
    public async Task<IActionResult> GetCurators()
    {
        var users = await _userService.GetAllAsync();
        var curators = users
            .Where(u => u.RoleName == "Curator")
            .Select(u => new { id = u.Id, fullName = u.FullName })
            .ToList();
        return Ok(curators);
    }

    [HttpGet("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetById(int id)
    {
        var user = await _userService.GetByIdAsync(id);
        return user == null ? NotFound() : Ok(user);
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create([FromBody] CreateUserDto dto)
    {
        var user = await _userService.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = user.Id }, user);
    }

    [HttpPut("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateUserDto dto)
    {
        var user = await _userService.UpdateAsync(id, dto);
        return user == null ? NotFound() : Ok(user);
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _userService.DeleteAsync(id);
        return result ? NoContent() : NotFound();
    }
}
