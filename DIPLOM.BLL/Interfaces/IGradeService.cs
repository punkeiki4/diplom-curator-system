using DIPLOM.BLL.DTOs;

namespace DIPLOM.BLL.Interfaces;

public interface IGradeService
{
    Task<IEnumerable<GradeDto>> GetByStudentAsync(int studentId);
    Task<GradeDto?> GetByIdAsync(int id);
    Task<GradeDto> CreateAsync(CreateGradeDto dto);
    Task<GradeDto?> UpdateAsync(int id, UpdateGradeDto dto);
    Task<bool> DeleteAsync(int id);
}
