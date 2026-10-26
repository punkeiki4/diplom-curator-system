namespace DIPLOM.BLL.DTOs;

public class TaskDto
{
    public int Id { get; set; }
    public string? Title { get; set; }
    public string? Description { get; set; }
    public int? AssignedTo { get; set; }
    public string? AssignedToName { get; set; }
    public int? AssignedBy { get; set; }
    public string? AssignedByName { get; set; }
    public DateTime? Deadline { get; set; }
    public string? Priority { get; set; }
    public string? Status { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class CreateTaskDto
{
    public string Title { get; set; } = null!;
    public string? Description { get; set; }
    public int AssignedTo { get; set; }
    public int AssignedBy { get; set; }
    public DateTime? Deadline { get; set; }
    public string Priority { get; set; } = "Средний";
}

public class UpdateTaskDto
{
    public string? Title { get; set; }
    public string? Description { get; set; }
    public DateTime? Deadline { get; set; }
    public string? Priority { get; set; }
    public string? Status { get; set; }
}
