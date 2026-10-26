using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DIPLOM.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class DocumentsController : ControllerBase
{
    private readonly IDocumentService _documentService;

    public DocumentsController(IDocumentService documentService) => _documentService = documentService;

    [HttpGet]
    public async Task<IActionResult> GetAll() => Ok(await _documentService.GetAllAsync());

    [HttpGet("category/{category}")]
    public async Task<IActionResult> GetByCategory(string category) =>
        Ok(await _documentService.GetByCategoryAsync(category));

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var d = await _documentService.GetByIdAsync(id);
        return d == null ? NotFound() : Ok(d);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateDocumentDto dto)
    {
        var d = await _documentService.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = d.Id }, d);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _documentService.DeleteAsync(id);
        return result ? NoContent() : NotFound();
    }
}
