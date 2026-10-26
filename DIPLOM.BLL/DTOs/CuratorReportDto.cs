namespace DIPLOM.BLL.DTOs;

public class CuratorReportDto
{
    public int Id { get; set; }
    public int? TaskId { get; set; }
    public string? TaskTitle { get; set; }
    public int? CuratorId { get; set; }
    public string? CuratorName { get; set; }
    public string? CustomTitle { get; set; }
    public string? ReportText { get; set; }
    public DateTime SubmittedAt { get; set; }
    public string? ReviewStatus { get; set; }
    public string? ReviewComment { get; set; }
    public string? Title => CustomTitle ?? TaskTitle ?? $"Отчёт #{Id}";
    public string? Content => ReportText;
    public bool IsReviewed => ReviewStatus == "Принят" || ReviewStatus == "Утверждён";
    public string? SubmittedAtStr => SubmittedAt.ToString("dd.MM.yyyy");
}

public class CreateCuratorReportDto
{
    public int? TaskId { get; set; }
    public int CuratorId { get; set; }
    public string? CustomTitle { get; set; }
    public string ReportText { get; set; } = null!;
}

public class ReviewReportDto
{
    public string? ReviewStatus { get; set; }
    public bool? IsApproved { get; set; }
    public string? ReviewComment { get; set; }
    public string ResolvedStatus => ReviewStatus ?? (IsApproved == true ? "Принят" : "Возвращён");
}
