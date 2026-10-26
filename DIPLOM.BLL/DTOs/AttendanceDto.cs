namespace DIPLOM.BLL.DTOs;

public class AttendanceDto
{
    public int Id { get; set; }
    public int? StudentId { get; set; }
    public string? StudentName { get; set; }
    public int? ScheduleId { get; set; }
    public string? Subject { get; set; }
    public DateTime? LessonDate { get; set; }
    public string? Status { get; set; }
    public bool IsPresent => Status == "Присутствовал";
    public string? Date => LessonDate?.ToString("dd.MM.yyyy");
}

public class CreateAttendanceDto
{
    public int StudentId { get; set; }
    public int ScheduleId { get; set; }
    public string? Status { get; set; }
    public bool? IsPresent { get; set; }

    public string ResolvedStatus =>
        Status ?? (IsPresent == true ? "Присутствовал" : "Отсутствовал");
}

public class UpdateAttendanceDto
{
    public string Status { get; set; } = null!;
}
