namespace DIPLOM.BLL.DTOs;

public class ParentContactDto
{
    public int Id { get; set; }
    public int StudentId { get; set; }
    public string? StudentName { get; set; }
    public string ParentName { get; set; } = null!;
    public string Phone { get; set; } = null!;
    public string? Relation { get; set; }
    public List<ParentConversationDto> Conversations { get; set; } = new();
    public string? LastConversationDateStr => Conversations.Count > 0
        ? Conversations.OrderByDescending(c => c.ConversationDate).First().ConversationDateStr
        : null;
}

public class CreateParentContactDto
{
    public int StudentId { get; set; }
    public string ParentName { get; set; } = null!;
    public string Phone { get; set; } = null!;
    public string? Relation { get; set; }
}

public class UpdateParentContactDto
{
    public string? ParentName { get; set; }
    public string? Phone { get; set; }
    public string? Relation { get; set; }
}

public class ParentConversationDto
{
    public int Id { get; set; }
    public int ParentContactId { get; set; }
    public int CuratorId { get; set; }
    public string? CuratorName { get; set; }
    public DateTime ConversationDate { get; set; }
    public string Notes { get; set; } = null!;
    public string? ConversationDateStr => ConversationDate.ToString("dd.MM.yyyy");
}

public class CreateParentConversationDto
{
    public int ParentContactId { get; set; }
    public DateTime ConversationDate { get; set; }
    public string Notes { get; set; } = null!;
}
