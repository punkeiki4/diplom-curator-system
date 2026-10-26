namespace DIPLOM.BLL.DTOs;

public class CuratorHourPlanDto
{
    public int Id { get; set; }
    public int CuratorId { get; set; }
    public string? CuratorName { get; set; }
    public int? GroupId { get; set; }
    public string? GroupName { get; set; }
    public string Title { get; set; } = null!;
    public string? Topic { get; set; }
    public string? Description { get; set; }
    public DateTime PlannedDate { get; set; }
    public string Status { get; set; } = "Запланировано";
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; }
    public string? PlannedDateStr => PlannedDate.ToString("dd.MM.yyyy HH:mm");
    public bool IsUpcoming => PlannedDate > DateTime.UtcNow && Status == "Запланировано";
}

public class CreateCuratorHourPlanDto
{
    public int? GroupId { get; set; }
    public string Title { get; set; } = null!;
    public string? Topic { get; set; }
    public string? Description { get; set; }
    public DateTime PlannedDate { get; set; }
}

public class UpdateCuratorHourPlanDto
{
    public string? Title { get; set; }
    public string? Topic { get; set; }
    public string? Description { get; set; }
    public DateTime? PlannedDate { get; set; }
    public string? Status { get; set; }
    public string? Notes { get; set; }
}
