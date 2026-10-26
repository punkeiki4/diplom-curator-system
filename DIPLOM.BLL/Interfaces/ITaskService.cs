using DIPLOM.BLL.DTOs;

namespace DIPLOM.BLL.Interfaces;

public interface ITaskService
{
    Task<IEnumerable<TaskDto>> GetAllAsync();
    Task<IEnumerable<TaskDto>> GetByCuratorAsync(int curatorId);
    Task<IEnumerable<TaskDto>> GetByViceDeanAsync(int viceDeanId);
    Task<TaskDto?> GetByIdAsync(int id);
    Task<TaskDto> CreateAsync(CreateTaskDto dto);
    Task<TaskDto?> UpdateAsync(int id, UpdateTaskDto dto);
    Task<bool> DeleteAsync(int id);
}
