namespace DIPLOM.DAL.Entities;

public class CuratorReport
{
    public int Id { get; set; }
    public int? TaskId { get; set; }
    public int? CuratorId { get; set; }
    public string? CustomTitle { get; set; }
    public string? ReportText { get; set; }
    public DateTime SubmittedAt { get; set; } = DateTime.UtcNow;
    public string? ReviewStatus { get; set; }
    public string? ReviewComment { get; set; }

    public AppTask? Task { get; set; }
    public Curator? Curator { get; set; }
}
