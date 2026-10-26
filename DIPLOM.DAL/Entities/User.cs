namespace DIPLOM.DAL.Entities;

public class User
{
    public int Id { get; set; }
    public string? FullName { get; set; }
    public string? Email { get; set; }
    public string? PasswordHash { get; set; }
    public int RoleId { get; set; }

    public Role Role { get; set; } = null!;
    public Curator? Curator { get; set; }
    public ViceDean? ViceDean { get; set; }
    public Student? Student { get; set; }
    public ICollection<Notification> CreatedNotifications { get; set; } = new List<Notification>();
    public ICollection<NotificationRecipient> NotificationRecipients { get; set; } = new List<NotificationRecipient>();
    public ICollection<Request> ReviewedRequests { get; set; } = new List<Request>();
    public ICollection<Survey> CreatedSurveys { get; set; } = new List<Survey>();
    public ICollection<Document> UploadedDocuments { get; set; } = new List<Document>();
}
