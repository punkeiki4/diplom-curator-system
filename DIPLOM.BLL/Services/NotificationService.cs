using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using DIPLOM.DAL.Context;
using DIPLOM.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace DIPLOM.BLL.Services;

public class NotificationService : INotificationService
{
    private readonly AppDbContext _context;

    public NotificationService(AppDbContext context) => _context = context;

    public async Task<IEnumerable<NotificationDto>> GetByUserAsync(int userId) =>
        await _context.NotificationRecipients
            .Include(nr => nr.Notification).ThenInclude(n => n!.Creator)
            .Where(nr => nr.UserId == userId)
            .Select(nr => new NotificationDto
            {
                Id = nr.Notification.Id,
                Title = nr.Notification.Title,
                Message = nr.Notification.Message,
                CreatedAt = nr.Notification.CreatedAt,
                CreatedBy = nr.Notification.CreatedBy,
                CreatedByName = nr.Notification.Creator != null ? nr.Notification.Creator.FullName : null,
                IsRead = nr.IsRead
            }).ToListAsync();

    public async Task<NotificationDto?> GetByIdAsync(int id)
    {
        var n = await _context.Notifications.Include(n => n.Creator)
            .FirstOrDefaultAsync(n => n.Id == id);
        return n == null ? null : new NotificationDto
        {
            Id = n.Id, Title = n.Title, Message = n.Message,
            CreatedAt = n.CreatedAt, CreatedBy = n.CreatedBy,
            CreatedByName = n.Creator?.FullName
        };
    }

    public async Task<NotificationDto> CreateAsync(CreateNotificationDto dto)
    {
        var notification = new Notification
        {
            Title = dto.Title,
            Message = dto.Message,
            CreatedBy = dto.CreatedBy
        };
        _context.Notifications.Add(notification);
        await _context.SaveChangesAsync();

        foreach (var userId in dto.RecipientIds)
        {
            _context.NotificationRecipients.Add(new NotificationRecipient
            {
                NotificationId = notification.Id,
                UserId = userId
            });
        }
        await _context.SaveChangesAsync();
        return await GetByIdAsync(notification.Id) ?? new NotificationDto();
    }

    public async Task<bool> MarkAsReadAsync(int notificationId, int userId)
    {
        var nr = await _context.NotificationRecipients
            .FindAsync(notificationId, userId);
        if (nr == null) return false;
        nr.IsRead = true;
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _context.Notifications.FindAsync(id);
        if (entity == null) return false;
        _context.Notifications.Remove(entity);
        await _context.SaveChangesAsync();
        return true;
    }
}
