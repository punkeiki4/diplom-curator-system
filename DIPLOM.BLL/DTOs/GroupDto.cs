namespace DIPLOM.BLL.DTOs;

public class GroupDto
{
    public int Id { get; set; }
    public string? Name { get; set; }
}

public class CreateGroupDto
{
    public string Name { get; set; } = null!;
}
