using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace DIPLOM.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ParentContactsController : ControllerBase
{
    private readonly ParentContactService _service;
    public ParentContactsController(ParentContactService service) => _service = service;

    private int CurrentUserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    
    [HttpGet("my-group")]
    public async Task<IActionResult> GetMyGroup() =>
        Ok(await _service.GetByCuratorAsync(CurrentUserId));

    
    [HttpGet("student/{studentId}")]
    public async Task<IActionResult> GetByStudent(int studentId) =>
        Ok(await _service.GetByStudentAsync(studentId));

    
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateParentContactDto dto)
    {
        var contact = await _service.CreateContactAsync(dto);
        return Ok(contact);
    }

    
    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateParentContactDto dto)
    {
        var contact = await _service.UpdateContactAsync(id, dto);
        return contact == null ? NotFound() : Ok(contact);
    }

  
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _service.DeleteContactAsync(id);
        return result ? NoContent() : NotFound();
    }

    
    [HttpPost("conversations")]
    public async Task<IActionResult> AddConversation([FromBody] CreateParentConversationDto dto)
    {
        var conv = await _service.AddConversationAsync(CurrentUserId, dto);
        return Ok(conv);
    }

    
    [HttpDelete("conversations/{id}")]
    public async Task<IActionResult> DeleteConversation(int id)
    {
        var result = await _service.DeleteConversationAsync(id);
        return result ? NoContent() : NotFound();
    }
}
