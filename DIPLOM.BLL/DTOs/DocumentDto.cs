namespace DIPLOM.BLL.DTOs;

public class DocumentDto
{
    public int Id { get; set; }
    public string? FileName { get; set; }
    public string? FilePath { get; set; }
    public string? Category { get; set; }
    public int? UploadedBy { get; set; }
    public string? UploadedByName { get; set; }
    public DateTime UploadedAt { get; set; }
}

public class CreateDocumentDto
{
    public string FileName { get; set; } = null!;
    public string FilePath { get; set; } = null!;
    public string? Category { get; set; }
    public int UploadedBy { get; set; }
}
