using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace DIPLOM.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class NotificationsController : ControllerBase
{
    private readonly INotificationService _notificationService;

    public NotificationsController(INotificationService notificationService) =>
        _notificationService = notificationService;

    private int CurrentUserId =>
        int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

  
    [HttpGet("my")]
    public async Task<IActionResult> GetMy() =>
        Ok(await _notificationService.GetByUserAsync(CurrentUserId));

   
    [HttpPut("{notificationId}/read")]
    public async Task<IActionResult> MarkAsRead(int notificationId)
    {
        var result = await _notificationService.MarkAsReadAsync(notificationId, CurrentUserId);
        return result ? Ok() : NotFound();
    }

    [HttpGet("user/{userId}")]
    public async Task<IActionResult> GetByUser(int userId) =>
        Ok(await _notificationService.GetByUserAsync(userId));

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var n = await _notificationService.GetByIdAsync(id);
        return n == null ? NotFound() : Ok(n);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateNotificationDto dto)
    {
        var n = await _notificationService.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = n.Id }, n);
    }

    [HttpPut("{notificationId}/read/{userId}")]
    public async Task<IActionResult> MarkAsReadForUser(int notificationId, int userId)
    {
        var result = await _notificationService.MarkAsReadAsync(notificationId, userId);
        return result ? Ok() : NotFound();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _notificationService.DeleteAsync(id);
        return result ? NoContent() : NotFound();
    }
}
