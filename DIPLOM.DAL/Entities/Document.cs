namespace DIPLOM.DAL.Entities;

public class Document
{
    public int Id { get; set; }
    public string? FileName { get; set; }
    public string? FilePath { get; set; }
    public string? Category { get; set; }
    public int? UploadedBy { get; set; }
    public DateTime UploadedAt { get; set; } = DateTime.UtcNow;

    public User? Uploader { get; set; }
}
