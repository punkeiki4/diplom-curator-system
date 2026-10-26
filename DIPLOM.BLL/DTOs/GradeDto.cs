namespace DIPLOM.BLL.DTOs;

public class GradeDto
{
    public int Id { get; set; }
    public int? StudentId { get; set; }
    public string? StudentName { get; set; }
    public string? Subject { get; set; }
    public int? Value { get; set; }
    public DateTime? Date { get; set; }
    public string? DateStr => Date?.ToString("dd.MM.yyyy");
}

public class CreateGradeDto
{
    public int StudentId { get; set; }
    public string Subject { get; set; } = null!;
    public int Value { get; set; }
    public DateTime Date { get; set; }
}

public class UpdateGradeDto
{
    public int? Value { get; set; }
    public string? Subject { get; set; }
}
