namespace DIPLOM.DAL.Entities;

public class Group
{
    public int Id { get; set; }
    public string? Name { get; set; }

    public ICollection<Student> Students { get; set; } = new List<Student>();
    public ICollection<CuratorGroup> CuratorGroups { get; set; } = new List<CuratorGroup>();
    public ICollection<Schedule> Schedules { get; set; } = new List<Schedule>();
}
