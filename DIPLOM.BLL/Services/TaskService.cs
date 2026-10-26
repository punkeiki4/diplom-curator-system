using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using DIPLOM.DAL.Context;
using DIPLOM.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace DIPLOM.BLL.Services;

public class TaskService : ITaskService
{
    private readonly AppDbContext _context;

    public TaskService(AppDbContext context) => _context = context;

    public async Task<IEnumerable<TaskDto>> GetAllAsync() =>
        await QueryWithIncludes().Select(t => ToDto(t)).ToListAsync();

    public async Task<IEnumerable<TaskDto>> GetByCuratorAsync(int curatorId) =>
        await QueryWithIncludes().Where(t => t.AssignedTo == curatorId).Select(t => ToDto(t)).ToListAsync();

    public async Task<IEnumerable<TaskDto>> GetByViceDeanAsync(int viceDeanId) =>
        await QueryWithIncludes().Where(t => t.AssignedBy == viceDeanId).Select(t => ToDto(t)).ToListAsync();

    public async Task<TaskDto?> GetByIdAsync(int id)
    {
        var t = await QueryWithIncludes().FirstOrDefaultAsync(t => t.Id == id);
        return t == null ? null : ToDto(t);
    }

    public async Task<TaskDto> CreateAsync(CreateTaskDto dto)
    {
        var entity = new AppTask
        {
            Title = dto.Title,
            Description = dto.Description,
            AssignedTo = dto.AssignedTo,
            AssignedBy = dto.AssignedBy,
            Deadline = dto.Deadline,
            Priority = dto.Priority,
            Status = "Новое"
        };
        _context.Tasks.Add(entity);
        await _context.SaveChangesAsync();
        return await GetByIdAsync(entity.Id) ?? ToDto(entity);
    }

    public async Task<TaskDto?> UpdateAsync(int id, UpdateTaskDto dto)
    {
        var entity = await _context.Tasks.FindAsync(id);
        if (entity == null) return null;
        if (dto.Title != null) entity.Title = dto.Title;
        if (dto.Description != null) entity.Description = dto.Description;
        if (dto.Deadline.HasValue) entity.Deadline = dto.Deadline;
        if (dto.Priority != null) entity.Priority = dto.Priority;
        if (dto.Status != null) entity.Status = dto.Status;
        await _context.SaveChangesAsync();
        return await GetByIdAsync(id);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _context.Tasks.FindAsync(id);
        if (entity == null) return false;
        _context.Tasks.Remove(entity);
        await _context.SaveChangesAsync();
        return true;
    }

    private IQueryable<AppTask> QueryWithIncludes() =>
        _context.Tasks
            .Include(t => t.Curator).ThenInclude(c => c!.User)
            .Include(t => t.ViceDean).ThenInclude(v => v!.User);

    private static TaskDto ToDto(AppTask t) => new()
    {
        Id = t.Id,
        Title = t.Title,
        Description = t.Description,
        AssignedTo = t.AssignedTo,
        AssignedToName = t.Curator?.User?.FullName,
        AssignedBy = t.AssignedBy,
        AssignedByName = t.ViceDean?.User?.FullName,
        Deadline = t.Deadline,
        Priority = t.Priority,
        Status = t.Status,
        CreatedAt = t.CreatedAt
    };
}
