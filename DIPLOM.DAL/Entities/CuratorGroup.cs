namespace DIPLOM.DAL.Entities;

public class CuratorGroup
{
    public int CuratorId { get; set; }
    public int GroupId { get; set; }

    public Curator Curator { get; set; } = null!;
    public Group Group { get; set; } = null!;
}
