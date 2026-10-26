namespace DIPLOM.BLL.DTOs;

public class NotificationDto
{
    public int Id { get; set; }
    public string? Title { get; set; }
    public string? Message { get; set; }
    public DateTime CreatedAt { get; set; }
    public int? CreatedBy { get; set; }
    public string? CreatedByName { get; set; }
    public bool IsRead { get; set; }
}

public class CreateNotificationDto
{
    public string Title { get; set; } = null!;
    public string Message { get; set; } = null!;
    public int CreatedBy { get; set; }
    public List<int> RecipientIds { get; set; } = new();
}
