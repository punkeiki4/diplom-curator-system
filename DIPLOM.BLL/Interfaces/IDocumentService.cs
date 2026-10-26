using DIPLOM.BLL.DTOs;

namespace DIPLOM.BLL.Interfaces;

public interface IDocumentService
{
    Task<IEnumerable<DocumentDto>> GetAllAsync();
    Task<IEnumerable<DocumentDto>> GetByCategoryAsync(string category);
    Task<DocumentDto?> GetByIdAsync(int id);
    Task<DocumentDto> CreateAsync(CreateDocumentDto dto);
    Task<bool> DeleteAsync(int id);
}
