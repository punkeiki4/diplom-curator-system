using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace DIPLOM.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IUserService _userService;

    public AuthController(IUserService userService) => _userService = userService;

    
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginDto dto)
    {
        var result = await _userService.LoginAsync(dto);
        if (result == null) return Unauthorized(new { message = "Неверный email или пароль" });
        return Ok(result);
    }
}
