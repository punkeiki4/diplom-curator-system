using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using DIPLOM.DAL.Context;
using DIPLOM.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace DIPLOM.BLL.Services;

public class SurveyService : ISurveyService
{
    private readonly AppDbContext _context;

    public SurveyService(AppDbContext context) => _context = context;

    public async Task<IEnumerable<SurveyDto>> GetAllAsync() =>
        await _context.Surveys
            .Include(s => s.Creator)
            .Include(s => s.Answers)
            .Select(s => ToDto(s)).ToListAsync();

    public async Task<SurveyDto?> GetByIdAsync(int id)
    {
        var s = await _context.Surveys.Include(s => s.Creator).Include(s => s.Answers)
            .FirstOrDefaultAsync(s => s.Id == id);
        return s == null ? null : ToDto(s);
    }

    public async Task<SurveyDto> CreateAsync(CreateSurveyDto dto)
    {
        var entity = new Survey
        {
            Title = dto.Title,
            Description = dto.Description,
            CreatedBy = dto.CreatedBy,
            Deadline = dto.Deadline,
            TargetRole = dto.TargetRole
        };
        _context.Surveys.Add(entity);
        await _context.SaveChangesAsync();
        return await GetByIdAsync(entity.Id) ?? ToDto(entity);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _context.Surveys.FindAsync(id);
        if (entity == null) return false;
        _context.Surveys.Remove(entity);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<IEnumerable<SurveyAnswerDto>> GetAnswersAsync(int surveyId) =>
        await _context.SurveyAnswers
            .Include(a => a.Student).ThenInclude(s => s!.User)
            .Where(a => a.SurveyId == surveyId)
            .Select(a => new SurveyAnswerDto
            {
                Id = a.Id,
                SurveyId = a.SurveyId,
                StudentId = a.StudentId,
                StudentName = a.Student != null && a.Student.User != null ? a.Student.User.FullName : null,
                Answer = a.Answer,
                AnsweredAt = a.AnsweredAt
            }).ToListAsync();

    public async Task<SurveyAnswerDto> SubmitAnswerAsync(CreateSurveyAnswerDto dto)
    {
        var entity = new SurveyAnswer
        {
            SurveyId = dto.SurveyId,
            StudentId = dto.StudentId,
            Answer = dto.Answer
        };
        _context.SurveyAnswers.Add(entity);
        await _context.SaveChangesAsync();
        return new SurveyAnswerDto
        {
            Id = entity.Id,
            SurveyId = entity.SurveyId,
            StudentId = entity.StudentId,
            Answer = entity.Answer,
            AnsweredAt = entity.AnsweredAt
        };
    }

    private static SurveyDto ToDto(Survey s) => new()
    {
        Id = s.Id,
        Title = s.Title,
        Description = s.Description,
        CreatedBy = s.CreatedBy,
        CreatedByName = s.Creator?.FullName,
        CreatedAt = s.CreatedAt,
        Deadline = s.Deadline,
        TargetRole = s.TargetRole,
        AnswerCount = s.Answers?.Count ?? 0
    };
}
