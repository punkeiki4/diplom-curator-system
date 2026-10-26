using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using DIPLOM.DAL.Context;
using DIPLOM.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace DIPLOM.BLL.Services;

public class DocumentService : IDocumentService
{
    private readonly AppDbContext _context;

    public DocumentService(AppDbContext context) => _context = context;

    public async Task<IEnumerable<DocumentDto>> GetAllAsync() =>
        await _context.Documents.Include(d => d.Uploader)
            .Select(d => ToDto(d)).ToListAsync();

    public async Task<IEnumerable<DocumentDto>> GetByCategoryAsync(string category) =>
        await _context.Documents.Include(d => d.Uploader)
            .Where(d => d.Category == category)
            .Select(d => ToDto(d)).ToListAsync();

    public async Task<DocumentDto?> GetByIdAsync(int id)
    {
        var d = await _context.Documents.Include(d => d.Uploader)
            .FirstOrDefaultAsync(d => d.Id == id);
        return d == null ? null : ToDto(d);
    }

    public async Task<DocumentDto> CreateAsync(CreateDocumentDto dto)
    {
        var entity = new Document
        {
            FileName = dto.FileName,
            FilePath = dto.FilePath,
            Category = dto.Category,
            UploadedBy = dto.UploadedBy
        };
        _context.Documents.Add(entity);
        await _context.SaveChangesAsync();
        return await GetByIdAsync(entity.Id) ?? ToDto(entity);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _context.Documents.FindAsync(id);
        if (entity == null) return false;
        _context.Documents.Remove(entity);
        await _context.SaveChangesAsync();
        return true;
    }

    private static DocumentDto ToDto(Document d) => new()
    {
        Id = d.Id,
        FileName = d.FileName,
        FilePath = d.FilePath,
        Category = d.Category,
        UploadedBy = d.UploadedBy,
        UploadedByName = d.Uploader?.FullName,
        UploadedAt = d.UploadedAt
    };
}
