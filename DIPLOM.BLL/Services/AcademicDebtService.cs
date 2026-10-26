using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using DIPLOM.DAL.Context;
using DIPLOM.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace DIPLOM.BLL.Services;

public class AcademicDebtService : IAcademicDebtService
{
    private readonly AppDbContext _context;

    public AcademicDebtService(AppDbContext context) => _context = context;

    public async Task<IEnumerable<AcademicDebtDto>> GetAllAsync() =>
        await _context.AcademicDebts
            .Include(d => d.Student).ThenInclude(s => s!.User)
            .Include(d => d.Student).ThenInclude(s => s!.Group)
            .Select(d => ToDto(d)).ToListAsync();

    public async Task<IEnumerable<AcademicDebtDto>> GetByStudentAsync(int studentId) =>
        await _context.AcademicDebts
            .Include(d => d.Student).ThenInclude(s => s!.User)
            .Where(d => d.StudentId == studentId)
            .Select(d => ToDto(d)).ToListAsync();

    public async Task<AcademicDebtDto?> GetByIdAsync(int id)
    {
        var d = await _context.AcademicDebts.Include(d => d.Student).ThenInclude(s => s!.User)
            .FirstOrDefaultAsync(d => d.Id == id);
        return d == null ? null : ToDto(d);
    }

    public async Task<AcademicDebtDto> CreateAsync(CreateAcademicDebtDto dto)
    {
        var entity = new AcademicDebt
        {
            StudentId = dto.StudentId,
            Subject = dto.Subject,
            DebtType = dto.DebtType,
            Deadline = dto.Deadline,
            Status = "Активна"
        };
        _context.AcademicDebts.Add(entity);
        await _context.SaveChangesAsync();
        return await GetByIdAsync(entity.Id) ?? ToDto(entity);
    }

    public async Task<AcademicDebtDto?> UpdateAsync(int id, UpdateAcademicDebtDto dto)
    {
        var entity = await _context.AcademicDebts.FindAsync(id);
        if (entity == null) return null;
        if (dto.Status != null) entity.Status = dto.Status;
        if (dto.Deadline.HasValue) entity.Deadline = dto.Deadline;
        await _context.SaveChangesAsync();
        return await GetByIdAsync(id);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _context.AcademicDebts.FindAsync(id);
        if (entity == null) return false;
        _context.AcademicDebts.Remove(entity);
        await _context.SaveChangesAsync();
        return true;
    }

    private static AcademicDebtDto ToDto(AcademicDebt d) => new()
    {
        Id = d.Id,
        StudentId = d.StudentId,
        StudentName = d.Student?.User?.FullName,
        GroupId = d.Student?.GroupId,
        GroupName = d.Student?.Group?.Name,
        Subject = d.Subject,
        DebtType = d.DebtType,
        Deadline = d.Deadline,
        Status = d.Status,
        CreatedAt = d.CreatedAt
    };
}
