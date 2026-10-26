using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using DIPLOM.DAL.Context;
using DIPLOM.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace DIPLOM.BLL.Services;

public class GradeService : IGradeService
{
    private readonly AppDbContext _context;

    public GradeService(AppDbContext context) => _context = context;

    public async Task<IEnumerable<GradeDto>> GetByStudentAsync(int studentId) =>
        await _context.Grades
            .Include(g => g.Student).ThenInclude(s => s!.User)
            .Where(g => g.StudentId == studentId)
            .Select(g => ToDto(g)).ToListAsync();

    public async Task<GradeDto?> GetByIdAsync(int id)
    {
        var g = await _context.Grades.Include(g => g.Student).ThenInclude(s => s!.User)
            .FirstOrDefaultAsync(g => g.Id == id);
        return g == null ? null : ToDto(g);
    }

    public async Task<GradeDto> CreateAsync(CreateGradeDto dto)
    {
        var entity = new Grade
        {
            StudentId = dto.StudentId,
            Subject = dto.Subject,
            Value = dto.Value,
            Date = dto.Date
        };
        _context.Grades.Add(entity);
        await _context.SaveChangesAsync();
        return await GetByIdAsync(entity.Id) ?? ToDto(entity);
    }

    public async Task<GradeDto?> UpdateAsync(int id, UpdateGradeDto dto)
    {
        var entity = await _context.Grades.FindAsync(id);
        if (entity == null) return null;
        if (dto.Value.HasValue) entity.Value = dto.Value;
        if (dto.Subject != null) entity.Subject = dto.Subject;
        await _context.SaveChangesAsync();
        return await GetByIdAsync(id);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _context.Grades.FindAsync(id);
        if (entity == null) return false;
        _context.Grades.Remove(entity);
        await _context.SaveChangesAsync();
        return true;
    }

    private static GradeDto ToDto(Grade g) => new()
    {
        Id = g.Id,
        StudentId = g.StudentId,
        StudentName = g.Student?.User?.FullName,
        Subject = g.Subject,
        Value = g.Value,
        Date = g.Date
    };
}
