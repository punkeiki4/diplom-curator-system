namespace DIPLOM.DAL.Entities;

public class CuratorHourPlan
{
    public int Id { get; set; }
    public int CuratorId { get; set; }
    public int? GroupId { get; set; }
    public string Title { get; set; } = null!;
    public string? Topic { get; set; }
    public string? Description { get; set; }
    public DateTime PlannedDate { get; set; }
    public string Status { get; set; } = "Запланировано";  
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Curator Curator { get; set; } = null!;
    public Group? Group { get; set; }
}
