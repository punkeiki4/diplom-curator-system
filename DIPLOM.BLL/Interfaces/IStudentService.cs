using DIPLOM.BLL.DTOs;

namespace DIPLOM.BLL.Interfaces;

public interface IStudentService
{
    Task<IEnumerable<StudentDto>> GetAllAsync();
    Task<IEnumerable<StudentDto>> GetByGroupAsync(int groupId);
    Task<StudentDto?> GetByIdAsync(int id);
    Task<StudentDto> CreateAsync(CreateStudentDto dto);
    Task<bool> DeleteAsync(int id);
}
