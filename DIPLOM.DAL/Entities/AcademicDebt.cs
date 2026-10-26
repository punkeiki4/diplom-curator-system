namespace DIPLOM.DAL.Entities;

public class AcademicDebt
{
    public int Id { get; set; }
    public int? StudentId { get; set; }
    public string? Subject { get; set; }
    public string? DebtType { get; set; }
    public DateTime? Deadline { get; set; }
    public string? Status { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Student? Student { get; set; }
}
