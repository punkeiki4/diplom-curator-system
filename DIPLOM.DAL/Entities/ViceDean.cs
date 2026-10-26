namespace DIPLOM.DAL.Entities;

public class ViceDean
{
    public int Id { get; set; }

    public User User { get; set; } = null!;
    public ICollection<AppTask> CreatedTasks { get; set; } = new List<AppTask>();
}
