using DIPLOM.BLL.DTOs;

namespace DIPLOM.BLL.Interfaces;

public interface IScheduleService
{
    Task<IEnumerable<ScheduleDto>> GetByGroupAsync(int groupId);
    Task<ScheduleDto?> GetByIdAsync(int id);
    Task<ScheduleDto> CreateAsync(CreateScheduleDto dto);
    Task<ScheduleDto?> UpdateAsync(int id, UpdateScheduleDto dto);
    Task<bool> DeleteAsync(int id);
}
