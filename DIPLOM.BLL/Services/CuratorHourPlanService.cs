using DIPLOM.BLL.DTOs;
using DIPLOM.DAL.Context;
using DIPLOM.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace DIPLOM.BLL.Services;

public class CuratorHourPlanService
{
    private readonly AppDbContext _ctx;
    public CuratorHourPlanService(AppDbContext ctx) => _ctx = ctx;

    public async Task<IEnumerable<CuratorHourPlanDto>> GetByCuratorAsync(int curatorId) =>
        await _ctx.CuratorHourPlans
            .Include(p => p.Curator).ThenInclude(c => c.User)
            .Include(p => p.Group)
            .Where(p => p.CuratorId == curatorId)
            .OrderBy(p => p.PlannedDate)
            .Select(p => ToDto(p))
            .ToListAsync();

    public async Task<IEnumerable<CuratorHourPlanDto>> GetAllAsync() =>
        await _ctx.CuratorHourPlans
            .Include(p => p.Curator).ThenInclude(c => c.User)
            .Include(p => p.Group)
            .OrderBy(p => p.PlannedDate)
            .Select(p => ToDto(p))
            .ToListAsync();

    public async Task<CuratorHourPlanDto> CreateAsync(int curatorId, CreateCuratorHourPlanDto dto)
    {
     
        int? groupId = dto.GroupId;
        if (!groupId.HasValue)
        {
            var cg = await _ctx.CuratorGroups.FirstOrDefaultAsync(g => g.CuratorId == curatorId);
            groupId = cg?.GroupId;
        }

        var entity = new CuratorHourPlan
        {
            CuratorId = curatorId,
            GroupId = groupId,
            Title = dto.Title,
            Topic = dto.Topic,
            Description = dto.Description,
            PlannedDate = dto.PlannedDate,
            Status = "Запланировано",
            CreatedAt = DateTime.UtcNow
        };
        _ctx.CuratorHourPlans.Add(entity);
        await _ctx.SaveChangesAsync();
        return await GetByIdAsync(entity.Id) ?? ToDto(entity);
    }

    public async Task<CuratorHourPlanDto?> UpdateAsync(int id, UpdateCuratorHourPlanDto dto)
    {
        var entity = await _ctx.CuratorHourPlans.FindAsync(id);
        if (entity == null) return null;
        if (dto.Title != null) entity.Title = dto.Title;
        if (dto.Topic != null) entity.Topic = dto.Topic;
        if (dto.Description != null) entity.Description = dto.Description;
        if (dto.PlannedDate.HasValue) entity.PlannedDate = dto.PlannedDate.Value;
        if (dto.Status != null) entity.Status = dto.Status;
        if (dto.Notes != null) entity.Notes = dto.Notes;
        await _ctx.SaveChangesAsync();
        return await GetByIdAsync(id);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _ctx.CuratorHourPlans.FindAsync(id);
        if (entity == null) return false;
        _ctx.CuratorHourPlans.Remove(entity);
        await _ctx.SaveChangesAsync();
        return true;
    }

    private async Task<CuratorHourPlanDto?> GetByIdAsync(int id)
    {
        var e = await _ctx.CuratorHourPlans
            .Include(p => p.Curator).ThenInclude(c => c.User)
            .Include(p => p.Group)
            .FirstOrDefaultAsync(p => p.Id == id);
        return e == null ? null : ToDto(e);
    }

    private static CuratorHourPlanDto ToDto(CuratorHourPlan p) => new()
    {
        Id = p.Id,
        CuratorId = p.CuratorId,
        CuratorName = p.Curator?.User?.FullName,
        GroupId = p.GroupId,
        GroupName = p.Group?.Name,
        Title = p.Title,
        Topic = p.Topic,
        Description = p.Description,
        PlannedDate = p.PlannedDate,
        Status = p.Status,
        Notes = p.Notes,
        CreatedAt = p.CreatedAt
    };
}
