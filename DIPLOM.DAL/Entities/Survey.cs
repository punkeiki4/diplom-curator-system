namespace DIPLOM.DAL.Entities;

public class Survey
{
    public int Id { get; set; }
    public string? Title { get; set; }
    public string? Description { get; set; }
    public int? CreatedBy { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? Deadline { get; set; }
    public string? TargetRole { get; set; }

    public User? Creator { get; set; }
    public ICollection<SurveyAnswer> Answers { get; set; } = new List<SurveyAnswer>();
}
