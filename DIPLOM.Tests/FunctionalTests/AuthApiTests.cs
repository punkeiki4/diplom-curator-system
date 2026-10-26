using System.Net;
using System.Net.Http.Json;
using DIPLOM.BLL.DTOs;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace DIPLOM.Tests.FunctionalTests;

public class AuthApiTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public AuthApiTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    
    [Fact]
    public async Task Login_ValidCurator_Returns200WithToken()
    {
        var resp = await _client.PostAsJsonAsync("/api/auth/login", new LoginDto
        {
            Email    = "curator1@diplom.ru",
            Password = "Curator1!"
        });

        resp.StatusCode.Should().Be(HttpStatusCode.OK);
        var body = await resp.Content.ReadFromJsonAsync<LoginResponseDto>();
        body!.Token.Should().NotBeNullOrEmpty();
        body.User.RoleName.Should().Be("Curator");
    }

     
    [Fact]
    public async Task Login_WrongPassword_Returns401()
    {
        var resp = await _client.PostAsJsonAsync("/api/auth/login", new LoginDto
        {
            Email    = "curator1@diplom.ru",
            Password = "wrongpassword"
        });

        resp.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    
    [Fact]
    public async Task Login_UnknownEmail_Returns401()
    {
        var resp = await _client.PostAsJsonAsync("/api/auth/login", new LoginDto
        {
            Email    = "nobody@diplom.ru",
            Password = "Password1!"
        });

        resp.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    
    [Fact]
    public async Task ProtectedEndpoint_NoToken_Returns401()
    {
        var resp = await _client.GetAsync("/api/students/my-group");
        resp.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }
     

    [Fact]
    public async Task UsersEndpoint_CuratorRole_Returns403()
    {
         
        var loginResp = await _client.PostAsJsonAsync("/api/auth/login", new LoginDto
        {
            Email    = "curator1@diplom.ru",
            Password = "Curator1!"
        });
        var loginData = await loginResp.Content.ReadFromJsonAsync<LoginResponseDto>();

        _client.DefaultRequestHeaders.Authorization =
            new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", loginData!.Token);

        var resp = await _client.GetAsync("/api/users");

        resp.StatusCode.Should().Be(HttpStatusCode.Forbidden);
        _client.DefaultRequestHeaders.Authorization = null;
    }

    
    [Theory]
    [InlineData("admin@diplom.ru",      "Admin123!",    "Admin")]
    [InlineData("vicedean1@diplom.ru",  "ViceDean1!",   "ViceDean")]
    [InlineData("curator1@diplom.ru",   "Curator1!",    "Curator")]
    [InlineData("student1@diplom.ru",   "Student1!",    "Student")]
    public async Task Login_AllRoles_ReturnCorrectRole(string email, string password, string expectedRole)
    {
        var resp = await _client.PostAsJsonAsync("/api/auth/login", new LoginDto
        {
            Email    = email,
            Password = password
        });

        resp.StatusCode.Should().Be(HttpStatusCode.OK);
        var body = await resp.Content.ReadFromJsonAsync<LoginResponseDto>();
        body!.User.RoleName.Should().Be(expectedRole);
    }
}
