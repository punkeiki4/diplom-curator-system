using DIPLOM.BLL.DTOs;
using DIPLOM.DAL.Context;
using DIPLOM.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace DIPLOM.BLL.Services;

public class EventService
{
    private readonly AppDbContext _ctx;
    public EventService(AppDbContext ctx) => _ctx = ctx;

  
    public async Task<IEnumerable<EventDto>> GetAllAsync() =>
        await _ctx.Events
            .Include(e => e.Group)
            .Include(e => e.Creator)
            .Include(e => e.AssignedCurator)
            .OrderBy(e => e.EventDate)
            .Select(e => ToDto(e))
            .ToListAsync();

  
    public async Task<IEnumerable<EventDto>> GetForGroupAsync(int groupId) =>
        await _ctx.Events
            .Include(e => e.Group)
            .Include(e => e.Creator)
            .Include(e => e.AssignedCurator)
            .Where(e => e.GroupId == null || e.GroupId == groupId)
            .OrderBy(e => e.EventDate)
            .Select(e => ToDto(e))
            .ToListAsync();

    public async Task<IEnumerable<EventDto>> GetByCuratorAsync(int curatorId)
    {
        var groups = await _ctx.CuratorGroups
            .Where(cg => cg.CuratorId == curatorId)
            .Select(cg => cg.GroupId)
            .ToListAsync();

        return await _ctx.Events
            .Include(e => e.Group)
            .Include(e => e.Creator)
            .Include(e => e.AssignedCurator)
            .Where(e => e.CreatedBy == curatorId
                     || e.AssignedCuratorId == curatorId
                     || (e.AssignedCuratorId == null && (e.GroupId == null || groups.Contains(e.GroupId!.Value))))
            .OrderBy(e => e.EventDate)
            .Select(e => ToDto(e))
            .ToListAsync();
    }

    public async Task<EventDto> CreateAsync(int createdBy, CreateEventDto dto)
    {
        var entity = new AppEvent
        {
            Title = dto.Title,
            Description = dto.Description,
            EventDate = dto.EventDate,
            EventType = dto.EventType,
            Location = dto.Location,
            GroupId = dto.GroupId,
            AssignedCuratorId = dto.AssignedCuratorId,
            CreatedBy = createdBy,
            CreatedAt = DateTime.UtcNow
        };
        _ctx.Events.Add(entity);
        await _ctx.SaveChangesAsync();

       
        await CreateNotificationsAsync(entity);

        return await GetByIdInternalAsync(entity.Id) ?? ToDto(entity);
    }

    public async Task<bool> NotifyAsync(int eventId)
    {
        var entity = await _ctx.Events.FindAsync(eventId);
        if (entity == null) return false;
        await CreateNotificationsAsync(entity);
        return true;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _ctx.Events.FindAsync(id);
        if (entity == null) return false;
        _ctx.Events.Remove(entity);
        await _ctx.SaveChangesAsync();
        return true;
    }

    private async Task CreateNotificationsAsync(AppEvent ev)
    {
     
        IQueryable<int> studentUserIds = ev.GroupId.HasValue
            ? _ctx.Students.Where(s => s.GroupId == ev.GroupId).Select(s => s.Id)
            : _ctx.Students.Select(s => s.Id);

        var userIds = await studentUserIds.ToListAsync();
        if (userIds.Count == 0) return;

        var prefix = ev.EventType == "Внеплановое" ? "Внеплановое мероприятие" : "Мероприятие";
        var notification = new Notification
        {
            Title = $"{prefix}: {ev.Title}",
            Message = $"{ev.Description ?? ""}\nДата: {ev.EventDate:dd.MM.yyyy HH:mm}{(ev.Location != null ? $"\nМесто: {ev.Location}" : "")}".Trim(),
            CreatedBy = ev.CreatedBy,
            CreatedAt = DateTime.UtcNow
        };
        _ctx.Notifications.Add(notification);
        await _ctx.SaveChangesAsync();

        foreach (var uid in userIds)
        {
            _ctx.NotificationRecipients.Add(new NotificationRecipient
            {
                NotificationId = notification.Id,
                UserId = uid,
                IsRead = false
            });
        }
        await _ctx.SaveChangesAsync();
    }

    private async Task<EventDto?> GetByIdInternalAsync(int id)
    {
        var e = await _ctx.Events
            .Include(ev => ev.Group)
            .Include(ev => ev.Creator)
            .FirstOrDefaultAsync(ev => ev.Id == id);
        return e == null ? null : ToDto(e);
    }

    private static EventDto ToDto(AppEvent e) => new()
    {
        Id = e.Id,
        Title = e.Title,
        Description = e.Description,
        EventDate = e.EventDate,
        EventType = e.EventType,
        Location = e.Location,
        GroupId = e.GroupId,
        GroupName = e.Group?.Name,
        AssignedCuratorId = e.AssignedCuratorId,
        AssignedCuratorName = e.AssignedCurator?.FullName,
        CreatedBy = e.CreatedBy,
        CreatorName = e.Creator?.FullName,
        CreatedAt = e.CreatedAt
    };
}
