using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DIPLOM.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class SurveysController : ControllerBase
{
    private readonly ISurveyService _surveyService;

    public SurveysController(ISurveyService surveyService) => _surveyService = surveyService;

    [HttpGet]
    public async Task<IActionResult> GetAll() => Ok(await _surveyService.GetAllAsync());

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var s = await _surveyService.GetByIdAsync(id);
        return s == null ? NotFound() : Ok(s);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateSurveyDto dto)
    {
        var s = await _surveyService.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = s.Id }, s);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var result = await _surveyService.DeleteAsync(id);
        return result ? NoContent() : NotFound();
    }

    [HttpGet("{surveyId}/answers")]
    public async Task<IActionResult> GetAnswers(int surveyId) =>
        Ok(await _surveyService.GetAnswersAsync(surveyId));

    [HttpPost("answers")]
    public async Task<IActionResult> SubmitAnswer([FromBody] CreateSurveyAnswerDto dto)
    {
        var a = await _surveyService.SubmitAnswerAsync(dto);
        return Ok(a);
    }
}
