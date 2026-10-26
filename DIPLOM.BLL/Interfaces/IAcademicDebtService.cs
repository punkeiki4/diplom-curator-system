using DIPLOM.BLL.DTOs;

namespace DIPLOM.BLL.Interfaces;

public interface IAcademicDebtService
{
    Task<IEnumerable<AcademicDebtDto>> GetAllAsync();
    Task<IEnumerable<AcademicDebtDto>> GetByStudentAsync(int studentId);
    Task<AcademicDebtDto?> GetByIdAsync(int id);
    Task<AcademicDebtDto> CreateAsync(CreateAcademicDebtDto dto);
    Task<AcademicDebtDto?> UpdateAsync(int id, UpdateAcademicDebtDto dto);
    Task<bool> DeleteAsync(int id);
}
