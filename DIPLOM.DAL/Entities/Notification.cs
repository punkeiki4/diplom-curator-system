namespace DIPLOM.DAL.Entities;

public class Notification
{
    public int Id { get; set; }
    public string? Title { get; set; }
    public string? Message { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public int? CreatedBy { get; set; }

    public User? Creator { get; set; }
    public ICollection<NotificationRecipient> Recipients { get; set; } = new List<NotificationRecipient>();
}
