namespace DIPLOM.BLL.DTOs;

public class RequestDto
{
    public int Id { get; set; }
    public int? StudentId { get; set; }
    public string? StudentName { get; set; }
    public string? Title { get; set; }
    public string? Description { get; set; }
    public string? Status { get; set; }
    public DateTime CreatedAt { get; set; }
    public int? ReviewedBy { get; set; }
    public string? ReviewedByName { get; set; }
    public DateTime? ReviewedAt { get; set; }
    public string? ReviewComment { get; set; }
    public string? RequestType => Title;
    public string? StatusNormalized => Status?.ToLower() switch {
        "одобрено" => "approved",
        "отклонено" => "rejected",
        _ => "pending"
    };
}

public class CreateRequestDto
{
    public int StudentId { get; set; }
    public string Title { get; set; } = null!;
    public string? Description { get; set; }
}

public class ReviewRequestDto
{
    public int ReviewedBy { get; set; }
    public string Status { get; set; } = null!;
    public string? ReviewComment { get; set; }
}
