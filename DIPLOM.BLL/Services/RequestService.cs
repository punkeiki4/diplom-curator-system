using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using DIPLOM.DAL.Context;
using DIPLOM.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace DIPLOM.BLL.Services;

public class RequestService : IRequestService
{
    private readonly AppDbContext _context;

    public RequestService(AppDbContext context) => _context = context;

    public async Task<IEnumerable<RequestDto>> GetAllAsync() =>
        await QueryWithIncludes().Select(r => ToDto(r)).ToListAsync();

    public async Task<IEnumerable<RequestDto>> GetByStudentAsync(int studentId) =>
        await QueryWithIncludes().Where(r => r.StudentId == studentId).Select(r => ToDto(r)).ToListAsync();

    public async Task<RequestDto?> GetByIdAsync(int id)
    {
        var r = await QueryWithIncludes().FirstOrDefaultAsync(r => r.Id == id);
        return r == null ? null : ToDto(r);
    }

    public async Task<RequestDto> CreateAsync(CreateRequestDto dto)
    {
        var entity = new Request
        {
            StudentId = dto.StudentId,
            Title = dto.Title,
            Description = dto.Description,
            Status = "В обработке"
        };
        _context.Requests.Add(entity);
        await _context.SaveChangesAsync();
        return await GetByIdAsync(entity.Id) ?? ToDto(entity);
    }

    public async Task<RequestDto?> ReviewAsync(int id, ReviewRequestDto dto)
    {
        var entity = await _context.Requests.FindAsync(id);
        if (entity == null) return null;
        entity.ReviewedBy = dto.ReviewedBy;
        entity.Status = dto.Status;
        entity.ReviewComment = dto.ReviewComment;
        entity.ReviewedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();
        return await GetByIdAsync(id);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _context.Requests.FindAsync(id);
        if (entity == null) return false;
        _context.Requests.Remove(entity);
        await _context.SaveChangesAsync();
        return true;
    }

    private IQueryable<Request> QueryWithIncludes() =>
        _context.Requests
            .Include(r => r.Student).ThenInclude(s => s!.User)
            .Include(r => r.Reviewer);

    private static RequestDto ToDto(Request r) => new()
    {
        Id = r.Id,
        StudentId = r.StudentId,
        StudentName = r.Student?.User?.FullName,
        Title = r.Title,
        Description = r.Description,
        Status = r.Status,
        CreatedAt = r.CreatedAt,
        ReviewedBy = r.ReviewedBy,
        ReviewedByName = r.Reviewer?.FullName,
        ReviewedAt = r.ReviewedAt,
        ReviewComment = r.ReviewComment
    };
}
