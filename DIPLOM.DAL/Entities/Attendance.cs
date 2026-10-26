namespace DIPLOM.DAL.Entities;

public class Attendance
{
    public int Id { get; set; }
    public int? StudentId { get; set; }
    public int? ScheduleId { get; set; }
    public string? Status { get; set; }

    public Student? Student { get; set; }
    public Schedule? Schedule { get; set; }
}
