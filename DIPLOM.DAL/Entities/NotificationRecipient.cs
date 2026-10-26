namespace DIPLOM.DAL.Entities;

public class NotificationRecipient
{
    public int NotificationId { get; set; }
    public int UserId { get; set; }
    public bool IsRead { get; set; } = false;

    public Notification Notification { get; set; } = null!;
    public User User { get; set; } = null!;
}
