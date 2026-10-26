using DIPLOM.BLL.DTOs;

namespace DIPLOM.BLL.Interfaces;

public interface IRequestService
{
    Task<IEnumerable<RequestDto>> GetAllAsync();
    Task<IEnumerable<RequestDto>> GetByStudentAsync(int studentId);
    Task<RequestDto?> GetByIdAsync(int id);
    Task<RequestDto> CreateAsync(CreateRequestDto dto);
    Task<RequestDto?> ReviewAsync(int id, ReviewRequestDto dto);
    Task<bool> DeleteAsync(int id);
}
