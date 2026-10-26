using System.Security.Cryptography;
using System.Text;
using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Services;
using DIPLOM.DAL.Context;
using DIPLOM.DAL.Entities;
using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Xunit;

namespace DIPLOM.Tests.UnitTests;

public class AuthServiceTests
{
    private AppDbContext CreateInMemoryContext()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        return new AppDbContext(options);
    }

    private IConfiguration CreateConfig() =>
        new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["Jwt:Key"]     = "super_secret_key_for_testing_1234567890",
                ["Jwt:Issuer"]  = "DIPLOM",
                ["Jwt:Audience"]= "DIPLOM",
                ["Jwt:ExpireHours"] = "24"
            })
            .Build();

    private static string Sha256(string s)
    {
        using var sha = SHA256.Create();
        return Convert.ToBase64String(sha.ComputeHash(Encoding.UTF8.GetBytes(s)));
    }

    private void SeedUser(AppDbContext ctx, string email, string password, string role)
    {
        var r = new Role { Id = 10, Name = role };
        ctx.Roles.Add(r);
        var u = new User
        {
            Id           = 100,
            FullName     = "Тестовый Пользователь",
            Email        = email,
            PasswordHash = Sha256(password),
            RoleId       = 10
        };
        ctx.Users.Add(u);
        ctx.SaveChanges();
    }
 

    [Fact]
    public async Task Login_ValidCredentials_ReturnsToken()
    {
        var ctx = CreateInMemoryContext();
        SeedUser(ctx, "test@diplom.ru", "Password1!", "Curator");
        var svc = new UserService(ctx, CreateConfig());

        var result = await svc.LoginAsync(new LoginDto
        {
            Email    = "test@diplom.ru",
            Password = "Password1!"
        });

        result.Should().NotBeNull();
        result!.Token.Should().NotBeNullOrEmpty();
        result.User.Email.Should().Be("test@diplom.ru");
    }

     
    [Fact]
    public async Task Login_WrongPassword_ReturnsNull()
    {
        var ctx = CreateInMemoryContext();
        SeedUser(ctx, "test@diplom.ru", "Password1!", "Curator");
        var svc = new UserService(ctx, CreateConfig());

        var result = await svc.LoginAsync(new LoginDto
        {
            Email    = "test@diplom.ru",
            Password = "wrongpassword"
        });

        result.Should().BeNull();
    }

     
    [Fact]
    public async Task Login_UnknownEmail_ReturnsNull()
    {
        var ctx = CreateInMemoryContext();
        var svc = new UserService(ctx, CreateConfig());

        var result = await svc.LoginAsync(new LoginDto
        {
            Email    = "nobody@diplom.ru",
            Password = "Password1!"
        });

        result.Should().BeNull();
    }

    
    [Fact]
    public async Task Login_ValidCredentials_TokenContainsRole()
    {
        var ctx = CreateInMemoryContext();
        SeedUser(ctx, "curator@diplom.ru", "CurPass1!", "Curator");
        var svc = new UserService(ctx, CreateConfig());

        var result = await svc.LoginAsync(new LoginDto
        {
            Email    = "curator@diplom.ru",
            Password = "CurPass1!"
        });

        result.Should().NotBeNull();
        result!.User.RoleName.Should().Be("Curator");

 
        var parts = result.Token.Split('.');
        parts.Should().HaveCount(3, "JWT должен состоять из 3 частей");
         
        var b64 = parts[1].Replace('-', '+').Replace('_', '/');
        b64 = b64.PadRight(b64.Length + (4 - b64.Length % 4) % 4, '=');
        var payload = Encoding.UTF8.GetString(Convert.FromBase64String(b64));
        payload.Should().Contain("Curator");
    }
}
