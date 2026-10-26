using DIPLOM.BLL.DTOs;

namespace DIPLOM.BLL.Interfaces;

public interface IGroupService
{
    Task<IEnumerable<GroupDto>> GetAllAsync();
    Task<GroupDto?> GetByIdAsync(int id);
    Task<GroupDto> CreateAsync(CreateGroupDto dto);
    Task<bool> DeleteAsync(int id);
    Task<bool> AssignCuratorAsync(int groupId, int curatorId);
    Task<bool> RemoveCuratorAsync(int groupId, int curatorId);
}
