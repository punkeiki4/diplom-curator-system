using DIPLOM.BLL.DTOs;
using DIPLOM.BLL.Services;
using DIPLOM.DAL.Context;
using DIPLOM.DAL.Entities;
using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace DIPLOM.Tests.UnitTests;

public class AttendanceServiceTests
{
    private AppDbContext CreateContext()
    {
        var opts = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        var ctx = new AppDbContext(opts);

        ctx.Roles.Add(new Role { Id = 1, Name = "Student" });
        ctx.Users.AddRange(
            new User { Id = 2, FullName = "Студент Один", Email = "s1@t.ru", PasswordHash = "x", RoleId = 1 },
            new User { Id = 3, FullName = "Студент Два",  Email = "s2@t.ru", PasswordHash = "x", RoleId = 1 }
        );
        ctx.Groups.Add(new Group { Id = 1, Name = "ИС-301" });
        ctx.Students.AddRange(
            new Student { Id = 2, GroupId = 1 },
            new Student { Id = 3, GroupId = 1 }
        );
        ctx.Schedules.AddRange(
            new Schedule { Id = 1, GroupId = 1, Subject = "Математика",       LessonDate = new DateTime(2025, 9, 2) },
            new Schedule { Id = 2, GroupId = 1, Subject = "Программирование", LessonDate = new DateTime(2025, 9, 3) }
        );
        ctx.Attendances.AddRange(
            new Attendance { Id = 1, StudentId = 2, ScheduleId = 1, Status = "Присутствовал" },
            new Attendance { Id = 2, StudentId = 3, ScheduleId = 1, Status = "Отсутствовал"  },
            new Attendance { Id = 3, StudentId = 2, ScheduleId = 2, Status = "Присутствовал" },
            new Attendance { Id = 4, StudentId = 3, ScheduleId = 2, Status = "Присутствовал" }
        );
        ctx.SaveChanges();
        return ctx;
    }

    
    [Fact]
    public async Task GetByStudent_ReturnsCorrectCount()
    {
        var ctx = CreateContext();
        var svc = new AttendanceService(ctx);

        var result = await svc.GetByStudentAsync(2);

        result.Should().HaveCount(2);
    }

     
    [Fact]
    public async Task GetByStudent_UnknownStudent_ReturnsEmpty()
    {
        var ctx = CreateContext();
        var svc = new AttendanceService(ctx);

        var result = await svc.GetByStudentAsync(999);

        result.Should().BeEmpty();
    }

    
    [Fact]
    public async Task CreateAttendance_ValidData_ReturnsSavedRecord()
    {
        var ctx = CreateContext();
        var svc = new AttendanceService(ctx);

        var dto = new CreateAttendanceDto
        {
            StudentId  = 2,
            ScheduleId = 1,
            Status     = "Присутствовал"
        };

         
        var existing = ctx.Attendances.First(a => a.StudentId == 2 && a.ScheduleId == 1);
        ctx.Attendances.Remove(existing);
        ctx.SaveChanges();

        var result = await svc.CreateAsync(dto);

        result.Should().NotBeNull();
        result.StudentId.Should().Be(2);
        result.Status.Should().Be("Присутствовал");
    }

     
    [Fact]
    public async Task GetBySchedule_ReturnsAllStudentsForLesson()
    {
        var ctx = CreateContext();
        var svc = new AttendanceService(ctx);

        var result = await svc.GetByScheduleAsync(1);

        result.Should().HaveCount(2);
    }

    
    [Fact]
    public async Task UpdateAttendance_ChangesStatus()
    {
        var ctx = CreateContext();
        var svc = new AttendanceService(ctx);

        var updated = await svc.UpdateAsync(2, new UpdateAttendanceDto { Status = "Присутствовал" });

        updated.Should().NotBeNull();
        updated!.Status.Should().Be("Присутствовал");
    }
}
