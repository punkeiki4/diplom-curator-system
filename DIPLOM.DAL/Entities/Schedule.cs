namespace DIPLOM.DAL.Entities;

public class Schedule
{
    public int Id { get; set; }
    public int? GroupId { get; set; }
    public string? Subject { get; set; }
    public DateTime? LessonDate { get; set; }

    public Group? Group { get; set; }
    public ICollection<Attendance> Attendances { get; set; } = new List<Attendance>();
}
