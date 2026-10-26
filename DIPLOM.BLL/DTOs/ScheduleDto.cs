namespace DIPLOM.BLL.DTOs;

public class ScheduleDto
{
    public int Id { get; set; }
    public int? GroupId { get; set; }
    public string? GroupName { get; set; }
    public string? Subject { get; set; }
    public DateTime? LessonDate { get; set; }
    public string? Date => LessonDate?.ToString("dd.MM.yyyy");
    public string? StartTime => LessonDate?.ToString("HH:mm");
}

public class CreateScheduleDto
{
    public int GroupId { get; set; }
    public string Subject { get; set; } = null!;
    public DateTime LessonDate { get; set; }
}

public class UpdateScheduleDto
{
    public string? Subject { get; set; }
    public DateTime? LessonDate { get; set; }
}
