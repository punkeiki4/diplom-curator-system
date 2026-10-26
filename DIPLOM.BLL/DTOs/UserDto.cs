namespace DIPLOM.BLL.DTOs;

public class UserDto
{
    public int Id { get; set; }
    public string? FullName { get; set; }
    public string? Email { get; set; }
    public int RoleId { get; set; }
    public string? RoleName { get; set; }
    public int? GroupId { get; set; }
    public string? GroupName { get; set; }
}

public class CreateUserDto
{
    public string FullName { get; set; } = null!;
    public string Email { get; set; } = null!;
    public string Password { get; set; } = null!;
    public int RoleId { get; set; }
    public int? GroupId { get; set; }
}

public class UpdateUserDto
{
    public string? FullName { get; set; }
    public string? Email { get; set; }
    public int? RoleId { get; set; }
    public int? GroupId { get; set; }
}

public class LoginDto
{
    public string Email { get; set; } = null!;
    public string Password { get; set; } = null!;
}

public class LoginResponseDto
{
    public string Token { get; set; } = null!;
    public UserDto User { get; set; } = null!;
}
