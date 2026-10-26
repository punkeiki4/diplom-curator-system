namespace DIPLOM.DAL.Entities;

public class SurveyAnswer
{
    public int Id { get; set; }
    public int? SurveyId { get; set; }
    public int? StudentId { get; set; }
    public string? Answer { get; set; }
    public DateTime AnsweredAt { get; set; } = DateTime.UtcNow;

    public Survey? Survey { get; set; }
    public Student? Student { get; set; }
}
