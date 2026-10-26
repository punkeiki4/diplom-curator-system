using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Services;
using DIPLOM.DAL.Context;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace DIPLOM.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class EventsController : ControllerBase
{
    private readonly EventService _service;
    private readonly AppDbContext _context;

    public EventsController(EventService service, AppDbContext context)
    {
        _service = service;
        _context = context;
    }

    private int CurrentUserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    [HttpGet]
    public async Task<IActionResult> GetAll() =>
        Ok(await _service.GetAllAsync());

    
    [HttpGet("my")]
    public async Task<IActionResult> GetMy()
    {
        var student = await _context.Students.FindAsync(CurrentUserId);
        if (student != null)
            return Ok(await _service.GetForGroupAsync(student.GroupId ?? 0));

       
        return Ok(await _service.GetByCuratorAsync(CurrentUserId));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateEventDto dto)
    {
        var ev = await _service.CreateAsync(CurrentUserId, dto);
        return Ok(ev);
    }


    [HttpPost("{id}/notify")]
    public async Task<IActionResult> Notify(int id)
    {
        var result = await _service.NotifyAsync(id);
        return result ? Ok(new { message = "Уведомления отправлены" }) : NotFound();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _service.DeleteAsync(id);
        return result ? NoContent() : NotFound();
    }
}
