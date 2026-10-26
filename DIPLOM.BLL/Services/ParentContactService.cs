using DIPLOM.BLL.DTOs;
using DIPLOM.DAL.Context;
using DIPLOM.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace DIPLOM.BLL.Services;

public class ParentContactService
{
    private readonly AppDbContext _ctx;
    public ParentContactService(AppDbContext ctx) => _ctx = ctx;

    
    public async Task<IEnumerable<ParentContactDto>> GetByCuratorAsync(int curatorId)
    {
        var groups = await _ctx.CuratorGroups
            .Where(cg => cg.CuratorId == curatorId)
            .Select(cg => cg.GroupId)
            .ToListAsync();

        return await _ctx.ParentContacts
            .Include(pc => pc.Student).ThenInclude(s => s.User)
            .Include(pc => pc.Conversations).ThenInclude(c => c.Curator).ThenInclude(cu => cu.User)
            .Where(pc => groups.Contains(pc.Student.GroupId!.Value))
            .Select(pc => ToDto(pc))
            .ToListAsync();
    }


    public async Task<IEnumerable<ParentContactDto>> GetByStudentAsync(int studentId) =>
        await _ctx.ParentContacts
            .Include(pc => pc.Student).ThenInclude(s => s.User)
            .Include(pc => pc.Conversations).ThenInclude(c => c.Curator).ThenInclude(cu => cu.User)
            .Where(pc => pc.StudentId == studentId)
            .Select(pc => ToDto(pc))
            .ToListAsync();

    public async Task<ParentContactDto> CreateContactAsync(CreateParentContactDto dto)
    {
        var entity = new ParentContact
        {
            StudentId = dto.StudentId,
            ParentName = dto.ParentName,
            Phone = dto.Phone,
            Relation = dto.Relation
        };
        _ctx.ParentContacts.Add(entity);
        await _ctx.SaveChangesAsync();
        return await GetContactByIdAsync(entity.Id) ?? ToDto(entity);
    }

    public async Task<ParentContactDto?> UpdateContactAsync(int id, UpdateParentContactDto dto)
    {
        var entity = await _ctx.ParentContacts.FindAsync(id);
        if (entity == null) return null;
        if (dto.ParentName != null) entity.ParentName = dto.ParentName;
        if (dto.Phone != null) entity.Phone = dto.Phone;
        if (dto.Relation != null) entity.Relation = dto.Relation;
        await _ctx.SaveChangesAsync();
        return await GetContactByIdAsync(id);
    }

    public async Task<bool> DeleteContactAsync(int id)
    {
        var entity = await _ctx.ParentContacts.FindAsync(id);
        if (entity == null) return false;
        _ctx.ParentContacts.Remove(entity);
        await _ctx.SaveChangesAsync();
        return true;
    }

    public async Task<ParentConversationDto> AddConversationAsync(int curatorId, CreateParentConversationDto dto)
    {
        var entity = new ParentConversation
        {
            ParentContactId = dto.ParentContactId,
            CuratorId = curatorId,
            ConversationDate = dto.ConversationDate,
            Notes = dto.Notes
        };
        _ctx.ParentConversations.Add(entity);
        await _ctx.SaveChangesAsync();
        return ToConvDto(entity);
    }

    public async Task<bool> DeleteConversationAsync(int id)
    {
        var entity = await _ctx.ParentConversations.FindAsync(id);
        if (entity == null) return false;
        _ctx.ParentConversations.Remove(entity);
        await _ctx.SaveChangesAsync();
        return true;
    }

    private async Task<ParentContactDto?> GetContactByIdAsync(int id)
    {
        var e = await _ctx.ParentContacts
            .Include(pc => pc.Student).ThenInclude(s => s.User)
            .Include(pc => pc.Conversations).ThenInclude(c => c.Curator).ThenInclude(cu => cu.User)
            .FirstOrDefaultAsync(pc => pc.Id == id);
        return e == null ? null : ToDto(e);
    }

    private static ParentContactDto ToDto(ParentContact pc) => new()
    {
        Id = pc.Id,
        StudentId = pc.StudentId,
        StudentName = pc.Student?.User?.FullName,
        ParentName = pc.ParentName,
        Phone = pc.Phone,
        Relation = pc.Relation,
        Conversations = pc.Conversations
            .OrderByDescending(c => c.ConversationDate)
            .Select(c => ToConvDto(c))
            .ToList()
    };

    private static ParentConversationDto ToConvDto(ParentConversation c) => new()
    {
        Id = c.Id,
        ParentContactId = c.ParentContactId,
        CuratorId = c.CuratorId,
        CuratorName = c.Curator?.User?.FullName,
        ConversationDate = c.ConversationDate,
        Notes = c.Notes
    };
}
