using DIPLOM.BLL.DTOs;

namespace DIPLOM.BLL.Interfaces;

public interface IAttendanceService
{
    Task<IEnumerable<AttendanceDto>> GetByStudentAsync(int studentId);
    Task<IEnumerable<AttendanceDto>> GetByScheduleAsync(int scheduleId);
    Task<AttendanceDto?> GetByIdAsync(int id);
    Task<AttendanceDto> CreateAsync(CreateAttendanceDto dto);
    Task<AttendanceDto?> UpdateAsync(int id, UpdateAttendanceDto dto);
    Task<bool> DeleteAsync(int id);
}
