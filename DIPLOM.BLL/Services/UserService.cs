using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Interfaces;
using DIPLOM.DAL.Context;
using DIPLOM.DAL.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

namespace DIPLOM.BLL.Services;

public class UserService : IUserService
{
    private readonly AppDbContext _context;
    private readonly IConfiguration _configuration;

    public UserService(AppDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

    public async Task<IEnumerable<UserDto>> GetAllAsync()
    {
        var users = await _context.Users
            .Include(u => u.Role)
            .Include(u => u.Student).ThenInclude(s => s!.Group)
            .ToListAsync();
        return users.Select(ToDto);
    }

    public async Task<UserDto?> GetByIdAsync(int id)
    {
        var user = await _context.Users
            .Include(u => u.Role)
            .Include(u => u.Student).ThenInclude(s => s!.Group)
            .FirstOrDefaultAsync(u => u.Id == id);
        return user == null ? null : ToDto(user);
    }

    public async Task<UserDto> CreateAsync(CreateUserDto dto)
    {
        var user = new User
        {
            FullName = dto.FullName,
            Email = dto.Email,
            PasswordHash = HashPassword(dto.Password),
            RoleId = dto.RoleId
        };
        _context.Users.Add(user);
        await _context.SaveChangesAsync();

     
        var role = await _context.Roles.FindAsync(dto.RoleId);
        var roleName = role?.Name?.ToLower() ?? "";

        if (roleName == "student")
        {
            _context.Students.Add(new Student { Id = user.Id, GroupId = dto.GroupId });
            await _context.SaveChangesAsync();
        }
        else if (roleName == "curator")
        {
            _context.Set<Curator>().Add(new Curator { Id = user.Id });
            await _context.SaveChangesAsync();
        }

        return await GetByIdAsync(user.Id) ?? ToDto(user);
    }

    public async Task<UserDto?> UpdateAsync(int id, UpdateUserDto dto)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null) return null;

        if (dto.FullName != null) user.FullName = dto.FullName;
        if (dto.Email != null) user.Email = dto.Email;
        if (dto.RoleId.HasValue) user.RoleId = dto.RoleId.Value;

        await _context.SaveChangesAsync();

        
        if (dto.GroupId.HasValue)
        {
            var student = await _context.Students.FindAsync(id);
            if (student != null)
            {
                student.GroupId = dto.GroupId.Value == 0 ? null : dto.GroupId.Value;
                await _context.SaveChangesAsync();
            }
            else
            {
               
                var role = await _context.Roles.FindAsync(user.RoleId);
                if (role?.Name?.ToLower() == "student")
                {
                    _context.Students.Add(new Student { Id = id, GroupId = dto.GroupId.Value == 0 ? null : dto.GroupId.Value });
                    await _context.SaveChangesAsync();
                }
            }
        }

        return await GetByIdAsync(id);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null) return false;
        _context.Users.Remove(user);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<LoginResponseDto?> LoginAsync(LoginDto dto)
    {
        var user = await _context.Users
            .Include(u => u.Role)
            .Include(u => u.Student).ThenInclude(s => s!.Group)
            .FirstOrDefaultAsync(u => u.Email == dto.Email);

        if (user == null || !VerifyPassword(dto.Password, user.PasswordHash!))
            return null;

        var token = GenerateJwt(user);
        return new LoginResponseDto { Token = token, User = ToDto(user) };
    }

    private string GenerateJwt(User user)
    {
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(
            _configuration["Jwt:Key"] ?? "SuperSecretKey123456789012345678"));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Email, user.Email ?? ""),
            new Claim(ClaimTypes.Role, user.Role?.Name ?? ""),
            new Claim(ClaimTypes.Name, user.FullName ?? "")
        };

        var token = new JwtSecurityToken(
            issuer: _configuration["Jwt:Issuer"] ?? "DIPLOM",
            audience: _configuration["Jwt:Audience"] ?? "DIPLOM",
            claims: claims,
            expires: DateTime.UtcNow.AddDays(7),
            signingCredentials: creds);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    private static string HashPassword(string password)
    {
        using var sha = SHA256.Create();
        return Convert.ToBase64String(sha.ComputeHash(Encoding.UTF8.GetBytes(password)));
    }

    private static bool VerifyPassword(string password, string hash)
        => HashPassword(password) == hash;

    private static UserDto ToDto(User u) => new()
    {
        Id = u.Id,
        FullName = u.FullName,
        Email = u.Email,
        RoleId = u.RoleId,
        RoleName = u.Role?.Name,
        GroupId = u.Student?.GroupId,
        GroupName = u.Student?.Group?.Name
    };
}
