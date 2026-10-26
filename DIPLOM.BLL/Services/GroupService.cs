using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using DIPLOM.DAL.Context;
using DIPLOM.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace DIPLOM.BLL.Services;

public class GroupService : IGroupService
{
    private readonly AppDbContext _context;

    public GroupService(AppDbContext context) => _context = context;

    public async Task<IEnumerable<GroupDto>> GetAllAsync() =>
        await _context.Groups.Select(g => new GroupDto { Id = g.Id, Name = g.Name }).ToListAsync();

    public async Task<GroupDto?> GetByIdAsync(int id)
    {
        var g = await _context.Groups.FindAsync(id);
        return g == null ? null : new GroupDto { Id = g.Id, Name = g.Name };
    }

    public async Task<GroupDto> CreateAsync(CreateGroupDto dto)
    {
        var group = new Group { Name = dto.Name };
        _context.Groups.Add(group);
        await _context.SaveChangesAsync();
        return new GroupDto { Id = group.Id, Name = group.Name };
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var group = await _context.Groups.FindAsync(id);
        if (group == null) return false;
        _context.Groups.Remove(group);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<bool> AssignCuratorAsync(int groupId, int curatorId)
    {
        if (await _context.CuratorGroups.AnyAsync(cg => cg.GroupId == groupId && cg.CuratorId == curatorId))
            return false;
        _context.CuratorGroups.Add(new CuratorGroup { GroupId = groupId, CuratorId = curatorId });
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<bool> RemoveCuratorAsync(int groupId, int curatorId)
    {
        var cg = await _context.CuratorGroups.FindAsync(curatorId, groupId);
        if (cg == null) return false;
        _context.CuratorGroups.Remove(cg);
        await _context.SaveChangesAsync();
        return true;
    }
}
