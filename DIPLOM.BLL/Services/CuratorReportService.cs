using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using DIPLOM.DAL.Context;
using DIPLOM.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace DIPLOM.BLL.Services;

public class CuratorReportService : ICuratorReportService
{
    private readonly AppDbContext _context;

    public CuratorReportService(AppDbContext context) => _context = context;

    public async Task<IEnumerable<CuratorReportDto>> GetAllAsync() =>
        await QueryWithIncludes().Select(r => ToDto(r)).ToListAsync();

    public async Task<IEnumerable<CuratorReportDto>> GetByTaskAsync(int taskId) =>
        await QueryWithIncludes().Where(r => r.TaskId == taskId).Select(r => ToDto(r)).ToListAsync();

    public async Task<IEnumerable<CuratorReportDto>> GetByCuratorAsync(int curatorId) =>
        await QueryWithIncludes().Where(r => r.CuratorId == curatorId).Select(r => ToDto(r)).ToListAsync();

    public async Task<CuratorReportDto?> GetByIdAsync(int id)
    {
        var r = await QueryWithIncludes().FirstOrDefaultAsync(r => r.Id == id);
        return r == null ? null : ToDto(r);
    }

    public async Task<CuratorReportDto> CreateAsync(CreateCuratorReportDto dto)
    {
        var entity = new CuratorReport
        {
            TaskId = dto.TaskId,
            CuratorId = dto.CuratorId,
            CustomTitle = dto.CustomTitle,
            ReportText = dto.ReportText,
            ReviewStatus = "На проверке"
        };
        _context.CuratorReports.Add(entity);
        await _context.SaveChangesAsync();
        return await GetByIdAsync(entity.Id) ?? ToDto(entity);
    }

    public async Task<CuratorReportDto?> ReviewAsync(int id, ReviewReportDto dto)
    {
        var entity = await _context.CuratorReports.FindAsync(id);
        if (entity == null) return null;
        entity.ReviewStatus = dto.ResolvedStatus;
        entity.ReviewComment = dto.ReviewComment;
        await _context.SaveChangesAsync();
        return await GetByIdAsync(id);
    }

    private IQueryable<CuratorReport> QueryWithIncludes() =>
        _context.CuratorReports
            .Include(r => r.Task)
            .Include(r => r.Curator).ThenInclude(c => c!.User);

    private static CuratorReportDto ToDto(CuratorReport r) => new()
    {
        Id = r.Id,
        TaskId = r.TaskId,
        TaskTitle = r.Task?.Title,
        CuratorId = r.CuratorId,
        CuratorName = r.Curator?.User?.FullName,
        CustomTitle = r.CustomTitle,
        ReportText = r.ReportText,
        SubmittedAt = r.SubmittedAt,
        ReviewStatus = r.ReviewStatus,
        ReviewComment = r.ReviewComment
    };
}
