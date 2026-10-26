namespace DIPLOM.BLL.DTOs;

public class SurveyDto
{
    public int Id { get; set; }
    public string? Title { get; set; }
    public string? Description { get; set; }
    public int? CreatedBy { get; set; }
    public string? CreatedByName { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? Deadline { get; set; }
    public string? TargetRole { get; set; }
    public int AnswerCount { get; set; }
}

public class CreateSurveyDto
{
    public string Title { get; set; } = null!;
    public string? Description { get; set; }
    public int CreatedBy { get; set; }
    public DateTime? Deadline { get; set; }
    public string? TargetRole { get; set; }
}

public class SurveyAnswerDto
{
    public int Id { get; set; }
    public int? SurveyId { get; set; }
    public int? StudentId { get; set; }
    public string? StudentName { get; set; }
    public string? Answer { get; set; }
    public DateTime AnsweredAt { get; set; }
}

public class CreateSurveyAnswerDto
{
    public int SurveyId { get; set; }
    public int StudentId { get; set; }
    public string Answer { get; set; } = null!;
}
