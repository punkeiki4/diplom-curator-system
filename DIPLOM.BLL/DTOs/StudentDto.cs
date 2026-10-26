namespace DIPLOM.BLL.DTOs;

public class StudentDto
{
    public int Id { get; set; }
    public string? FullName { get; set; }
    public string? Email { get; set; }
    public int? GroupId { get; set; }
    public string? GroupName { get; set; }
}

public class CreateStudentDto
{
    public string FullName { get; set; } = null!;
    public string Email { get; set; } = null!;
    public string Password { get; set; } = null!;
    public int? GroupId { get; set; }
}
