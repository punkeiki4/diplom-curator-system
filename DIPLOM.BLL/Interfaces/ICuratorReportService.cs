using DIPLOM.BLL.DTOs;

namespace DIPLOM.BLL.Interfaces;

public interface ICuratorReportService
{
    Task<IEnumerable<CuratorReportDto>> GetAllAsync();
    Task<IEnumerable<CuratorReportDto>> GetByTaskAsync(int taskId);
    Task<IEnumerable<CuratorReportDto>> GetByCuratorAsync(int curatorId);
    Task<CuratorReportDto?> GetByIdAsync(int id);
    Task<CuratorReportDto> CreateAsync(CreateCuratorReportDto dto);
    Task<CuratorReportDto?> ReviewAsync(int id, ReviewReportDto dto);
}
