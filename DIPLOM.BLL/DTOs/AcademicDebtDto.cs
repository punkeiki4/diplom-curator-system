namespace DIPLOM.BLL.DTOs;

public class AcademicDebtDto
{
    public int Id { get; set; }
    public int? StudentId { get; set; }
    public string? StudentName { get; set; }
    public int? GroupId { get; set; }
    public string? GroupName { get; set; }
    public string? Subject { get; set; }
    public string? DebtType { get; set; }
    public DateTime? Deadline { get; set; }
    public string? Status { get; set; }
    public DateTime CreatedAt { get; set; }
    public bool IsEliminated => Status == "Погашена";
    public string? DeadlineStr => Deadline?.ToString("dd.MM.yyyy");
}

public class CreateAcademicDebtDto
{
    public int StudentId { get; set; }
    public string Subject { get; set; } = null!;
    public string DebtType { get; set; } = null!;
    public DateTime? Deadline { get; set; }
}

public class UpdateAcademicDebtDto
{
    public string? Status { get; set; }
    public DateTime? Deadline { get; set; }
    public bool? IsEliminated { get; set; }
}
