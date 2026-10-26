namespace DIPLOM.DAL.Entities;

public class Request
{
    public int Id { get; set; }
    public int? StudentId { get; set; }
    public string? Title { get; set; }
    public string? Description { get; set; }
    public string? Status { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public int? ReviewedBy { get; set; }
    public DateTime? ReviewedAt { get; set; }
    public string? ReviewComment { get; set; }

    public Student? Student { get; set; }
    public User? Reviewer { get; set; }
}
