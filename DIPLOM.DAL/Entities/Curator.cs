namespace DIPLOM.DAL.Entities;

public class Curator
{
    public int Id { get; set; }

    public User User { get; set; } = null!;
    public ICollection<CuratorGroup> CuratorGroups { get; set; } = new List<CuratorGroup>();
    public ICollection<AppTask> AssignedTasks { get; set; } = new List<AppTask>();
    public ICollection<CuratorReport> Reports { get; set; } = new List<CuratorReport>();
}
