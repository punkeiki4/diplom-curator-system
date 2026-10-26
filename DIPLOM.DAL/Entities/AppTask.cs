namespace DIPLOM.DAL.Entities;

public class AppTask
{
    public int Id { get; set; }
    public string? Title { get; set; }
    public string? Description { get; set; }
    public int? AssignedTo { get; set; }
    public int? AssignedBy { get; set; }
    public DateTime? Deadline { get; set; }
    public string? Priority { get; set; }
    public string? Status { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Curator? Curator { get; set; }
    public ViceDean? ViceDean { get; set; }
    public ICollection<CuratorReport> Reports { get; set; } = new List<CuratorReport>();
}
