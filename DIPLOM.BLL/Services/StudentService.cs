using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using DIPLOM.DAL.Context;
using DIPLOM.DAL.Entities;
using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography;
using System.Text;

namespace DIPLOM.BLL.Services;

public class StudentService : IStudentService
{
    private readonly AppDbContext _context;

    public StudentService(AppDbContext context) => _context = context;

    public async Task<IEnumerable<StudentDto>> GetAllAsync() =>
        await _context.Students
            .Include(s => s.User)
            .Include(s => s.Group)
            .Select(s => ToDto(s))
            .ToListAsync();

    public async Task<IEnumerable<StudentDto>> GetByGroupAsync(int groupId) =>
        await _context.Students
            .Include(s => s.User)
            .Include(s => s.Group)
            .Where(s => s.GroupId == groupId)
            .Select(s => ToDto(s))
            .ToListAsync();

    public async Task<StudentDto?> GetByIdAsync(int id)
    {
        var s = await _context.Students.Include(s => s.User).Include(s => s.Group)
            .FirstOrDefaultAsync(s => s.Id == id);
        return s == null ? null : ToDto(s);
    }

    public async Task<StudentDto> CreateAsync(CreateStudentDto dto)
    {
        var user = new User
        {
            FullName = dto.FullName,
            Email = dto.Email,
            PasswordHash = HashPassword(dto.Password),
            RoleId = 4
        };
        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        var student = new Student { Id = user.Id, GroupId = dto.GroupId };
        _context.Students.Add(student);
        await _context.SaveChangesAsync();

        return await GetByIdAsync(student.Id) ?? ToDto(student);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var student = await _context.Students.FindAsync(id);
        if (student == null) return false;
        _context.Students.Remove(student);
        var user = await _context.Users.FindAsync(id);
        if (user != null) _context.Users.Remove(user);
        await _context.SaveChangesAsync();
        return true;
    }

    private static string HashPassword(string password)
    {
        using var sha = SHA256.Create();
        return Convert.ToBase64String(sha.ComputeHash(Encoding.UTF8.GetBytes(password)));
    }

    private static StudentDto ToDto(Student s) => new()
    {
        Id = s.Id,
        FullName = s.User?.FullName,
        Email = s.User?.Email,
        GroupId = s.GroupId,
        GroupName = s.Group?.Name
    };
}
