using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using DIPLOM.DAL.Context;
using DIPLOM.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace DIPLOM.BLL.Services;

public class AttendanceService : IAttendanceService
{
    private readonly AppDbContext _context;

    public AttendanceService(AppDbContext context) => _context = context;

    public async Task<IEnumerable<AttendanceDto>> GetByStudentAsync(int studentId) =>
        await _context.Attendances
            .Include(a => a.Student).ThenInclude(s => s!.User)
            .Include(a => a.Schedule)
            .Where(a => a.StudentId == studentId)
            .Select(a => ToDto(a)).ToListAsync();

    public async Task<IEnumerable<AttendanceDto>> GetByScheduleAsync(int scheduleId) =>
        await _context.Attendances
            .Include(a => a.Student).ThenInclude(s => s!.User)
            .Include(a => a.Schedule)
            .Where(a => a.ScheduleId == scheduleId)
            .Select(a => ToDto(a)).ToListAsync();

    public async Task<AttendanceDto?> GetByIdAsync(int id)
    {
        var a = await _context.Attendances
            .Include(a => a.Student).ThenInclude(s => s!.User)
            .Include(a => a.Schedule)
            .FirstOrDefaultAsync(a => a.Id == id);
        return a == null ? null : ToDto(a);
    }

    public async Task<AttendanceDto> CreateAsync(CreateAttendanceDto dto)
    {
        var entity = new Attendance
        {
            StudentId = dto.StudentId,
            ScheduleId = dto.ScheduleId,
            Status = dto.ResolvedStatus
        };
        _context.Attendances.Add(entity);
        await _context.SaveChangesAsync();
        return await GetByIdAsync(entity.Id) ?? ToDto(entity);
    }

    public async Task<AttendanceDto?> UpdateAsync(int id, UpdateAttendanceDto dto)
    {
        var entity = await _context.Attendances.FindAsync(id);
        if (entity == null) return null;
        entity.Status = dto.Status;
        await _context.SaveChangesAsync();
        return await GetByIdAsync(id);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var entity = await _context.Attendances.FindAsync(id);
        if (entity == null) return false;
        _context.Attendances.Remove(entity);
        await _context.SaveChangesAsync();
        return true;
    }

    private static AttendanceDto ToDto(Attendance a) => new()
    {
        Id = a.Id,
        StudentId = a.StudentId,
        StudentName = a.Student?.User?.FullName,
        ScheduleId = a.ScheduleId,
        Subject = a.Schedule?.Subject,
        LessonDate = a.Schedule?.LessonDate,
        Status = a.Status
    };
}
