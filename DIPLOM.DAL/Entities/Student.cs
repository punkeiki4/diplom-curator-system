namespace DIPLOM.DAL.Entities;

public class Student
{
    public int Id { get; set; }
    public int? GroupId { get; set; }

    public User User { get; set; } = null!;
    public Group? Group { get; set; }
    public ICollection<Attendance> Attendances { get; set; } = new List<Attendance>();
    public ICollection<Grade> Grades { get; set; } = new List<Grade>();
    public ICollection<AcademicDebt> AcademicDebts { get; set; } = new List<AcademicDebt>();
    public ICollection<Request> Requests { get; set; } = new List<Request>();
    public ICollection<SurveyAnswer> SurveyAnswers { get; set; } = new List<SurveyAnswer>();
}
