using DIPLOM.BLL.DTOs;

namespace DIPLOM.BLL.Interfaces;

public interface INotificationService
{
    Task<IEnumerable<NotificationDto>> GetByUserAsync(int userId);
    Task<NotificationDto?> GetByIdAsync(int id);
    Task<NotificationDto> CreateAsync(CreateNotificationDto dto);
    Task<bool> MarkAsReadAsync(int notificationId, int userId);
    Task<bool> DeleteAsync(int id);
}
