namespace DIPLOM.BLL.DTOs;

public class EventDto
{
    public int Id { get; set; }
    public string Title { get; set; } = null!;
    public string? Description { get; set; }
    public DateTime EventDate { get; set; }
    public string EventType { get; set; } = "Плановое";
    public string? Location { get; set; }
    public int? GroupId { get; set; }
    public string? GroupName { get; set; }
    public int? AssignedCuratorId { get; set; }
    public string? AssignedCuratorName { get; set; }
    public int CreatedBy { get; set; }
    public string? CreatorName { get; set; }
    public DateTime CreatedAt { get; set; }
    public string? EventDateStr => EventDate.ToString("dd.MM.yyyy HH:mm");
    public bool IsUnplanned => EventType == "Внеплановое";
    public bool IsUpcoming => EventDate > DateTime.UtcNow;
}

public class CreateEventDto
{
    public string Title { get; set; } = null!;
    public string? Description { get; set; }
    public DateTime EventDate { get; set; }
    public string EventType { get; set; } = "Плановое";
    public string? Location { get; set; }
    public int? GroupId { get; set; }
    public int? AssignedCuratorId { get; set; }
}
