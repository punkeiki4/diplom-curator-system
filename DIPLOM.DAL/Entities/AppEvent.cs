namespace DIPLOM.DAL.Entities;

public class AppEvent
{
    public int Id { get; set; }
    public string Title { get; set; } = null!;
    public string? Description { get; set; }
    public DateTime EventDate { get; set; }
    public string EventType { get; set; } = "Плановое";  
    public string? Location { get; set; }
    public int? GroupId { get; set; }  
    public int? AssignedCuratorId { get; set; } 
    public int CreatedBy { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public Group? Group { get; set; }
    public User Creator { get; set; } = null!;
    public User? AssignedCurator { get; set; }
}
