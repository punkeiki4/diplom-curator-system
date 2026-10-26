namespace DIPLOM.DAL.Entities;

public class ParentContact
{
    public int Id { get; set; }
    public int StudentId { get; set; }
    public string ParentName { get; set; } = null!;
    public string Phone { get; set; } = null!;
    public string? Relation { get; set; }  

    public Student Student { get; set; } = null!;
    public ICollection<ParentConversation> Conversations { get; set; } = new List<ParentConversation>();
}

public class ParentConversation
{
    public int Id { get; set; }
    public int ParentContactId { get; set; }
    public int CuratorId { get; set; }
    public DateTime ConversationDate { get; set; }
    public string Notes { get; set; } = null!;

    public ParentContact ParentContact { get; set; } = null!;
    public Curator Curator { get; set; } = null!;
}
