using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using DIPLOM.DAL.Context;
using DIPLOM.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace DIPLOM.BLL.Services;

public class ScheduleService : IScheduleService
{
    private readonly AppDbContext _context;

    public ScheduleService(AppDbContext context) => _context = context;

    public async Task<IEnumerable<ScheduleDto>> GetByGroupAsync(int groupId) =>
        await _context.Schedules.Include(s => s.Group)
            .Where(s => s.GroupId == groupId)
            .Select(s => ToDto(s)).ToListAsync();

    public async Task<ScheduleDto?> GetByIdAsync(int id)
    {
        var s = await _context.Schedules.Include(s => s.Group)
            .FirstOrDefaultAsync(s => s.Id == id);
        return s == null ? null : ToDto(s);
    }

    public async Task<ScheduleDto> CreateAsync(CreateScheduleDto dto)
    {
        var entity = new Schedule
        {
            GroupId = dto.GroupId,
            Subject = dto.Subject,
            LessonDate = dto.LessonDate
        };
        _context.Schedules.Add(entity);
        await _context.SaveChangesAsync();
        return await GetByIdAsync(entity.Id) ?? ToDto(entity);
    }

    public async Task<ScheduleDto?> UpdateAsync(int id, UpdateScheduleDto dto)
    {
        var entity = await _context.Schedules.FindAsync(id);
        if (entity == null) return null;
        if (dto.Subject != null) entity.Subject = dto.Subject;
        if (dto.LessonDate.HasValue) entity.LessonDate = dto.LessonDate;
        await _context.SaveChangesAsync();
        return await GetByIdAsync(id);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _context.Schedules.FindAsync(id);
        if (entity == null) return false;
        _context.Schedules.Remove(entity);
        await _context.SaveChangesAsync();
        return true;
    }

    private static ScheduleDto ToDto(Schedule s) => new()
    {
        Id = s.Id,
        GroupId = s.GroupId,
        GroupName = s.Group?.Name,
        Subject = s.Subject,
        LessonDate = s.LessonDate
    };
}
