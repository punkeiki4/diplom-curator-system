using DIPLOM.DAL.Entities;
using Microsoft.EntityFrameworkCore;

namespace DIPLOM.DAL.Context;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<Role> Roles { get; set; }
    public DbSet<User> Users { get; set; }
    public DbSet<Group> Groups { get; set; }
    public DbSet<Curator> Curators { get; set; }
    public DbSet<ViceDean> ViceDeans { get; set; }
    public DbSet<Student> Students { get; set; }
    public DbSet<CuratorGroup> CuratorGroups { get; set; }
    public DbSet<Schedule> Schedules { get; set; }
    public DbSet<Attendance> Attendances { get; set; }
    public DbSet<Grade> Grades { get; set; }
    public DbSet<AcademicDebt> AcademicDebts { get; set; }
    public DbSet<AppTask> Tasks { get; set; }
    public DbSet<CuratorReport> CuratorReports { get; set; }
    public DbSet<Notification> Notifications { get; set; }
    public DbSet<NotificationRecipient> NotificationRecipients { get; set; }
    public DbSet<Request> Requests { get; set; }
    public DbSet<Survey> Surveys { get; set; }
    public DbSet<SurveyAnswer> SurveyAnswers { get; set; }
    public DbSet<Document> Documents { get; set; }
    public DbSet<CuratorHourPlan> CuratorHourPlans { get; set; }
    public DbSet<AppEvent> Events { get; set; }
    public DbSet<ParentContact> ParentContacts { get; set; }
    public DbSet<ParentConversation> ParentConversations { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

      
        modelBuilder.Entity<CuratorGroup>()
            .HasKey(cg => new { cg.CuratorId, cg.GroupId });

        modelBuilder.Entity<NotificationRecipient>()
            .HasKey(nr => new { nr.NotificationId, nr.UserId });

      
        modelBuilder.Entity<User>()
            .HasOne(u => u.Role)
            .WithMany(r => r.Users)
            .HasForeignKey(u => u.RoleId);

     
        modelBuilder.Entity<Curator>()
            .HasOne(c => c.User)
            .WithOne(u => u.Curator)
            .HasForeignKey<Curator>(c => c.Id);


        modelBuilder.Entity<ViceDean>()
            .HasOne(v => v.User)
            .WithOne(u => u.ViceDean)
            .HasForeignKey<ViceDean>(v => v.Id);

        
        modelBuilder.Entity<Student>()
            .HasOne(s => s.User)
            .WithOne(u => u.Student)
            .HasForeignKey<Student>(s => s.Id);

     
        modelBuilder.Entity<Student>()
            .HasOne(s => s.Group)
            .WithMany(g => g.Students)
            .HasForeignKey(s => s.GroupId);

        
        modelBuilder.Entity<CuratorGroup>()
            .HasOne(cg => cg.Curator)
            .WithMany(c => c.CuratorGroups)
            .HasForeignKey(cg => cg.CuratorId);

       
        modelBuilder.Entity<CuratorGroup>()
            .HasOne(cg => cg.Group)
            .WithMany(g => g.CuratorGroups)
            .HasForeignKey(cg => cg.GroupId);

        
        modelBuilder.Entity<AppTask>()
            .HasOne(t => t.Curator)
            .WithMany(c => c.AssignedTasks)
            .HasForeignKey(t => t.AssignedTo)
            .OnDelete(DeleteBehavior.Restrict);

        
        modelBuilder.Entity<AppTask>()
            .HasOne(t => t.ViceDean)
            .WithMany(v => v.CreatedTasks)
            .HasForeignKey(t => t.AssignedBy)
            .OnDelete(DeleteBehavior.Restrict);

       
        modelBuilder.Entity<CuratorReport>()
            .HasOne(r => r.Task)
            .WithMany(t => t.Reports)
            .HasForeignKey(r => r.TaskId);

       
        modelBuilder.Entity<CuratorReport>()
            .HasOne(r => r.Curator)
            .WithMany(c => c.Reports)
            .HasForeignKey(r => r.CuratorId)
            .OnDelete(DeleteBehavior.Restrict);

       
        modelBuilder.Entity<Notification>()
            .HasOne(n => n.Creator)
            .WithMany(u => u.CreatedNotifications)
            .HasForeignKey(n => n.CreatedBy)
            .OnDelete(DeleteBehavior.Restrict);

       
        modelBuilder.Entity<NotificationRecipient>()
            .HasOne(nr => nr.Notification)
            .WithMany(n => n.Recipients)
            .HasForeignKey(nr => nr.NotificationId);

      
        modelBuilder.Entity<NotificationRecipient>()
            .HasOne(nr => nr.User)
            .WithMany(u => u.NotificationRecipients)
            .HasForeignKey(nr => nr.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        
        modelBuilder.Entity<Request>()
            .HasOne(r => r.Student)
            .WithMany(s => s.Requests)
            .HasForeignKey(r => r.StudentId);

        
        modelBuilder.Entity<Request>()
            .HasOne(r => r.Reviewer)
            .WithMany(u => u.ReviewedRequests)
            .HasForeignKey(r => r.ReviewedBy)
            .OnDelete(DeleteBehavior.Restrict);

        
        modelBuilder.Entity<Survey>()
            .HasOne(s => s.Creator)
            .WithMany(u => u.CreatedSurveys)
            .HasForeignKey(s => s.CreatedBy)
            .OnDelete(DeleteBehavior.Restrict);

        
        modelBuilder.Entity<SurveyAnswer>()
            .HasOne(a => a.Survey)
            .WithMany(s => s.Answers)
            .HasForeignKey(a => a.SurveyId);

       
        modelBuilder.Entity<SurveyAnswer>()
            .HasOne(a => a.Student)
            .WithMany(s => s.SurveyAnswers)
            .HasForeignKey(a => a.StudentId)
            .OnDelete(DeleteBehavior.Restrict);

       
        modelBuilder.Entity<Document>()
            .HasOne(d => d.Uploader)
            .WithMany(u => u.UploadedDocuments)
            .HasForeignKey(d => d.UploadedBy)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<Group>().ToTable("Groups");
        modelBuilder.Entity<AppTask>().ToTable("Tasks");
        modelBuilder.Entity<AppEvent>().ToTable("Events");

        
        modelBuilder.Entity<CuratorHourPlan>()
            .HasOne(p => p.Curator)
            .WithMany()
            .HasForeignKey(p => p.CuratorId)
            .OnDelete(DeleteBehavior.Restrict);

       
        modelBuilder.Entity<CuratorHourPlan>()
            .HasOne(p => p.Group)
            .WithMany()
            .HasForeignKey(p => p.GroupId)
            .OnDelete(DeleteBehavior.SetNull);

       
        modelBuilder.Entity<AppEvent>()
            .HasOne(e => e.Group)
            .WithMany()
            .HasForeignKey(e => e.GroupId)
            .OnDelete(DeleteBehavior.SetNull);

      
        modelBuilder.Entity<AppEvent>()
            .HasOne(e => e.Creator)
            .WithMany()
            .HasForeignKey(e => e.CreatedBy)
            .OnDelete(DeleteBehavior.Restrict);

        
        modelBuilder.Entity<ParentContact>()
            .HasOne(pc => pc.Student)
            .WithMany()
            .HasForeignKey(pc => pc.StudentId)
            .OnDelete(DeleteBehavior.Cascade);

         
        modelBuilder.Entity<ParentConversation>()
            .HasOne(pv => pv.ParentContact)
            .WithMany(pc => pc.Conversations)
            .HasForeignKey(pv => pv.ParentContactId)
            .OnDelete(DeleteBehavior.Cascade);

        
        modelBuilder.Entity<ParentConversation>()
            .HasOne(pv => pv.Curator)
            .WithMany()
            .HasForeignKey(pv => pv.CuratorId)
            .OnDelete(DeleteBehavior.Restrict);

        SeedData(modelBuilder);
    }

    private static void SeedData(ModelBuilder modelBuilder)
    {
        var now = new DateTime(2025, 9, 1, 0, 0, 0, DateTimeKind.Utc);

         
        modelBuilder.Entity<Role>().HasData(
            new Role { Id = 1, Name = "Admin" },
            new Role { Id = 2, Name = "ViceDean" },
            new Role { Id = 3, Name = "Curator" },
            new Role { Id = 4, Name = "Student" }
        );

         
        modelBuilder.Entity<User>().HasData(
            new User { Id = 1,  FullName = "Администратор Системы",      Email = "admin@diplom.ru",      PasswordHash = "PrP+ZrMeO00Q+nC1ytSccRIpSvauTkdqHEBRVdRaoSE=", RoleId = 1 },
            new User { Id = 2,  FullName = "Петрова Наталья Сергеевна",  Email = "vicedean1@diplom.ru",  PasswordHash = "WE3I4kUIvglhMrBEtVhSCGuLNh1aODRoFjevI05Gxo0=", RoleId = 2 },
            new User { Id = 3,  FullName = "Смирнов Алексей Владимирович",Email = "vicedean2@diplom.ru", PasswordHash = "3/RAyPNOl/UH8uR+ZC/gixD21SC2IsXsjBaygWUbCao=", RoleId = 2 },
            new User { Id = 4,  FullName = "Иванов Дмитрий Петрович",    Email = "curator1@diplom.ru",   PasswordHash = "TKvKQH1QG8ziF1x9gRI35BEcYpdHwYqpKXwO7NTk03k=", RoleId = 3 },
            new User { Id = 5,  FullName = "Козлова Марина Александровна",Email = "curator2@diplom.ru",  PasswordHash = "ck+FgplPstOiPOeDmXrDDW8J6jS2p7ZlMc/8shk5gsE=", RoleId = 3 },
            new User { Id = 6,  FullName = "Новиков Сергей Игоревич",    Email = "curator3@diplom.ru",   PasswordHash = "DaH8OPZpdBRL5jmf+k0eBFidzY3JMpfwWkCmqPnJstE=", RoleId = 3 },
            new User { Id = 7,  FullName = "Морозов Иван Андреевич",     Email = "student1@diplom.ru",   PasswordHash = "2mi3JpyHvnez3aSZzJzvZ7pc3XDDkJVFiv9eYwQOZMs=", RoleId = 4 },
            new User { Id = 8,  FullName = "Волкова Анна Дмитриевна",    Email = "student2@diplom.ru",   PasswordHash = "yBS+CgNJ31F84n5XShc2kLDW6Mg1PrigP2Y3ZwjfA7A=", RoleId = 4 },
            new User { Id = 9,  FullName = "Соколов Кирилл Евгеньевич",  Email = "student3@diplom.ru",   PasswordHash = "RRFfY41e9Hqkf7+zwmUSS6HIE7yyjm+DV3THjaWeNCo=", RoleId = 4 },
            new User { Id = 10, FullName = "Лебедева Ольга Николаевна",  Email = "student4@diplom.ru",   PasswordHash = "aluC/hOV4PrqfBB/yfRM/H8ASAyO3wSo2MeZrZ7IKsM=", RoleId = 4 },
            new User { Id = 11, FullName = "Федоров Антон Сергеевич",    Email = "student5@diplom.ru",   PasswordHash = "ocE5GzJ+YjhdsX/zPE/7Wn8HLBOmk5FLxS376VizagY=", RoleId = 4 },
            new User { Id = 12, FullName = "Михайлова Екатерина Олеговна",Email = "student6@diplom.ru",  PasswordHash = "BPbyrv/3h9nrMOvRWyk2Af7rzqZxN05K5F6yVuH7MyM=", RoleId = 4 }
        );

        
        modelBuilder.Entity<ViceDean>().HasData(
            new ViceDean { Id = 2 },
            new ViceDean { Id = 3 }
        );

         
        modelBuilder.Entity<Curator>().HasData(
            new Curator { Id = 4 },
            new Curator { Id = 5 },
            new Curator { Id = 6 }
        );

         
        modelBuilder.Entity<Group>().HasData(
            new Group { Id = 1, Name = "ИС-301" },
            new Group { Id = 2, Name = "ИС-302" },
            new Group { Id = 3, Name = "ПИ-401" }
        );

         
        modelBuilder.Entity<Student>().HasData(
            new Student { Id = 7,  GroupId = 1 },
            new Student { Id = 8,  GroupId = 1 },
            new Student { Id = 9,  GroupId = 2 },
            new Student { Id = 10, GroupId = 2 },
            new Student { Id = 11, GroupId = 3 },
            new Student { Id = 12, GroupId = 3 }
        );

         
        modelBuilder.Entity<CuratorGroup>().HasData(
            new CuratorGroup { CuratorId = 4, GroupId = 1 },
            new CuratorGroup { CuratorId = 5, GroupId = 2 },
            new CuratorGroup { CuratorId = 6, GroupId = 3 }
        );

         
        modelBuilder.Entity<Schedule>().HasData(
            new Schedule { Id = 1, GroupId = 1, Subject = "Математика",             LessonDate = now.AddDays(1).AddHours(8) },
            new Schedule { Id = 2, GroupId = 1, Subject = "Программирование",       LessonDate = now.AddDays(1).AddHours(10) },
            new Schedule { Id = 3, GroupId = 1, Subject = "База данных",            LessonDate = now.AddDays(2).AddHours(8) },
            new Schedule { Id = 4, GroupId = 2, Subject = "Физика",                 LessonDate = now.AddDays(1).AddHours(8) },
            new Schedule { Id = 5, GroupId = 2, Subject = "Алгоритмы",             LessonDate = now.AddDays(1).AddHours(12) },
            new Schedule { Id = 6, GroupId = 3, Subject = "Проектирование ПО",      LessonDate = now.AddDays(2).AddHours(10) },
            new Schedule { Id = 7, GroupId = 3, Subject = "Сети и телекоммуникации",LessonDate = now.AddDays(3).AddHours(8) }
        );
 

        modelBuilder.Entity<Attendance>().HasData(
            new Attendance { Id = 1,  StudentId = 7,  ScheduleId = 1, Status = "Присутствовал" },
            new Attendance { Id = 2,  StudentId = 8,  ScheduleId = 1, Status = "Отсутствовал" },
            new Attendance { Id = 3,  StudentId = 7,  ScheduleId = 2, Status = "Присутствовал" },
            new Attendance { Id = 4,  StudentId = 8,  ScheduleId = 2, Status = "Присутствовал" },
            new Attendance { Id = 5,  StudentId = 7,  ScheduleId = 3, Status = "Отсутствовал" },
            new Attendance { Id = 6,  StudentId = 9,  ScheduleId = 4, Status = "Присутствовал" },
            new Attendance { Id = 7,  StudentId = 10, ScheduleId = 4, Status = "Присутствовал" },
            new Attendance { Id = 8,  StudentId = 9,  ScheduleId = 5, Status = "Отсутствовал" },
            new Attendance { Id = 9,  StudentId = 11, ScheduleId = 6, Status = "Присутствовал" },
            new Attendance { Id = 10, StudentId = 12, ScheduleId = 6, Status = "Присутствовал" },
            new Attendance { Id = 11, StudentId = 11, ScheduleId = 7, Status = "Отсутствовал" },
            new Attendance { Id = 12, StudentId = 12, ScheduleId = 7, Status = "Присутствовал" }
        );

        
        modelBuilder.Entity<Grade>().HasData(
            new Grade { Id = 1,  StudentId = 7,  Subject = "Математика",       Value = 5, Date = now.AddDays(-30) },
            new Grade { Id = 2,  StudentId = 7,  Subject = "Программирование", Value = 4, Date = now.AddDays(-20) },
            new Grade { Id = 3,  StudentId = 8,  Subject = "Математика",       Value = 3, Date = now.AddDays(-30) },
            new Grade { Id = 4,  StudentId = 8,  Subject = "База данных",      Value = 4, Date = now.AddDays(-15) },
            new Grade { Id = 5,  StudentId = 9,  Subject = "Физика",           Value = 5, Date = now.AddDays(-25) },
            new Grade { Id = 6,  StudentId = 9,  Subject = "Алгоритмы",       Value = 4, Date = now.AddDays(-10) },
            new Grade { Id = 7,  StudentId = 10, Subject = "Физика",           Value = 2, Date = now.AddDays(-25) },
            new Grade { Id = 8,  StudentId = 10, Subject = "Алгоритмы",       Value = 3, Date = now.AddDays(-10) },
            new Grade { Id = 9,  StudentId = 11, Subject = "Проектирование ПО",Value = 5, Date = now.AddDays(-20) },
            new Grade { Id = 10, StudentId = 12, Subject = "Сети",             Value = 4, Date = now.AddDays(-18) }
        );

         
        modelBuilder.Entity<AcademicDebt>().HasData(
            new AcademicDebt { Id = 1, StudentId = 8,  Subject = "Математика",  DebtType = "Экзамен", Deadline = now.AddDays(30), Status = "Активна",  CreatedAt = now },
            new AcademicDebt { Id = 2, StudentId = 10, Subject = "Физика",      DebtType = "Зачёт",   Deadline = now.AddDays(14), Status = "Активна",  CreatedAt = now },
            new AcademicDebt { Id = 3, StudentId = 11, Subject = "Алгоритмы",   DebtType = "Экзамен", Deadline = now.AddDays(20), Status = "Погашена", CreatedAt = now.AddDays(-60) }
        );


        modelBuilder.Entity<AppTask>().HasData(
            new AppTask { Id = 1, Title = "Провести родительское собрание",   Description = "Собрание для группы ИС-301 по итогам семестра", AssignedTo = 4, AssignedBy = 2, Deadline = now.AddDays(7),  Priority = "Высокий", Status = "Новое",     CreatedAt = now },
            new AppTask { Id = 2, Title = "Подать отчёт по посещаемости",    Description = "Сдать отчёт за октябрь по группе ИС-302",         AssignedTo = 5, AssignedBy = 2, Deadline = now.AddDays(3),  Priority = "Средний", Status = "В работе",  CreatedAt = now },
            new AppTask { Id = 3, Title = "Организовать встречу со студентами",Description = "Провести беседу о дисциплине в группе ПИ-401",   AssignedTo = 6, AssignedBy = 3, Deadline = now.AddDays(10), Priority = "Низкий",  Status = "Выполнено", CreatedAt = now.AddDays(-5) }
        );
         

        modelBuilder.Entity<CuratorReport>().HasData(
            new CuratorReport { Id = 1, TaskId = 3, CuratorId = 6, ReportText = "Встреча проведена 05.09. Присутствовало 12 студентов. Обсудили вопросы дисциплины и посещаемости.", SubmittedAt = now.AddDays(-1), ReviewStatus = "Принят",      ReviewComment = "Отчёт принят, работа выполнена качественно." },
            new CuratorReport { Id = 2, TaskId = 2, CuratorId = 5, ReportText = "Отчёт по посещаемости за октябрь подготовлен. Средняя посещаемость 87%.",                         SubmittedAt = now,             ReviewStatus = "На проверке", ReviewComment = null }
        );

       
        modelBuilder.Entity<Notification>().HasData(
            new Notification { Id = 1, Title = "Начало учебного года",         Message = "Уважаемые студенты! Учебный год начинается 1 сентября. Расписание доступно в системе.",          CreatedAt = now,              CreatedBy = 2 },
            new Notification { Id = 2, Title = "Собрание кураторов",           Message = "Уважаемые кураторы! Собрание состоится 10 сентября в 14:00 в ауд. 305.",                         CreatedAt = now.AddDays(1),   CreatedBy = 2 },
            new Notification { Id = 3, Title = "Сдача отчётов по посещаемости",Message = "Напоминаем: срок сдачи отчётов по посещаемости за сентябрь — 5 октября.",                        CreatedAt = now.AddDays(2),   CreatedBy = 3 }
        );

        
        modelBuilder.Entity<NotificationRecipient>().HasData(
           
            new NotificationRecipient { NotificationId = 1, UserId = 7,  IsRead = true  },
            new NotificationRecipient { NotificationId = 1, UserId = 8,  IsRead = false },
            new NotificationRecipient { NotificationId = 1, UserId = 9,  IsRead = true  },
            new NotificationRecipient { NotificationId = 1, UserId = 10, IsRead = false },
            new NotificationRecipient { NotificationId = 1, UserId = 11, IsRead = true  },
            new NotificationRecipient { NotificationId = 1, UserId = 12, IsRead = false },
            
            new NotificationRecipient { NotificationId = 2, UserId = 4, IsRead = true  },
            new NotificationRecipient { NotificationId = 2, UserId = 5, IsRead = false },
            new NotificationRecipient { NotificationId = 2, UserId = 6, IsRead = true  },
           
            new NotificationRecipient { NotificationId = 3, UserId = 4, IsRead = false },
            new NotificationRecipient { NotificationId = 3, UserId = 5, IsRead = true  },
            new NotificationRecipient { NotificationId = 3, UserId = 6, IsRead = false }
        );

        
        modelBuilder.Entity<Request>().HasData(
            new Request { Id = 1, StudentId = 7,  Title = "Справка об обучении",     Description = "Прошу выдать справку об обучении для военкомата.",       Status = "Одобрено",    CreatedAt = now.AddDays(-10), ReviewedBy = 2, ReviewedAt = now.AddDays(-8), ReviewComment = "Справка готова, обратитесь в деканат." },
            new Request { Id = 2, StudentId = 9,  Title = "Перевод в другую группу", Description = "Прошу рассмотреть возможность перевода из ИС-302 в ИС-301.", Status = "На согласовании", CreatedAt = now.AddDays(-3), ReviewedBy = null, ReviewedAt = null, ReviewComment = null },
            new Request { Id = 3, StudentId = 10, Title = "Академический отпуск",    Description = "Прошу предоставить академический отпуск по состоянию здоровья.", Status = "В обработке", CreatedAt = now.AddDays(-1), ReviewedBy = null, ReviewedAt = null, ReviewComment = null },
            new Request { Id = 4, StudentId = 12, Title = "Пересдача экзамена",      Description = "Прошу назначить дату пересдачи экзамена по физике.",       Status = "Отклонено",   CreatedAt = now.AddDays(-15), ReviewedBy = 3, ReviewedAt = now.AddDays(-13), ReviewComment = "Пересдача возможна только после ликвидации всех задолженностей." }
        );

        
        modelBuilder.Entity<Survey>().HasData(
            new Survey { Id = 1, Title = "Качество преподавания",          Description = "Оцените качество преподавания дисциплин в этом семестре.", CreatedBy = 2, CreatedAt = now,              Deadline = now.AddDays(14), TargetRole = "Студенты" },
            new Survey { Id = 2, Title = "Удовлетворённость учёбой",       Description = "Насколько вы удовлетворены организацией учебного процесса?",CreatedBy = 3, CreatedAt = now.AddDays(1),  Deadline = now.AddDays(21), TargetRole = "Студенты" },
            new Survey { Id = 3, Title = "Отчётность кураторов",           Description = "Оцените удобство текущей системы отчётности.",             CreatedBy = 2, CreatedAt = now.AddDays(2),  Deadline = now.AddDays(10), TargetRole = "Кураторы" }
        );

       
        modelBuilder.Entity<SurveyAnswer>().HasData(
            new SurveyAnswer { Id = 1, SurveyId = 1, StudentId = 7,  Answer = "Преподавание на высоком уровне, особенно математика. Оценка 5/5.",    AnsweredAt = now.AddDays(1) },
            new SurveyAnswer { Id = 2, SurveyId = 1, StudentId = 8,  Answer = "В целом хорошо, но хотелось бы больше практики по программированию.", AnsweredAt = now.AddDays(1) },
            new SurveyAnswer { Id = 3, SurveyId = 1, StudentId = 9,  Answer = "Удовлетворён. Преподаватели отзывчивы и доступно объясняют материал.", AnsweredAt = now.AddDays(2) },
            new SurveyAnswer { Id = 4, SurveyId = 2, StudentId = 10, Answer = "Расписание неудобное, слишком много окон между парами.",               AnsweredAt = now.AddDays(2) },
            new SurveyAnswer { Id = 5, SurveyId = 2, StudentId = 11, Answer = "Всё устраивает, хорошая организация.",                                AnsweredAt = now.AddDays(3) }
        );

         
        modelBuilder.Entity<Document>().HasData(
            new Document { Id = 1, FileName = "Расписание_осень_2025.pdf",      FilePath = "/documents/schedule_autumn_2025.pdf",      Category = "Расписание",  UploadedBy = 2, UploadedAt = now },
            new Document { Id = 2, FileName = "Приказ_01_зачисление.pdf",       FilePath = "/documents/order_01_enrollment.pdf",        Category = "Приказ",      UploadedBy = 1, UploadedAt = now },
            new Document { Id = 3, FileName = "Инструкция_куратора.docx",       FilePath = "/documents/curator_manual.docx",            Category = "Инструкция",  UploadedBy = 2, UploadedAt = now.AddDays(1) },
            new Document { Id = 4, FileName = "Отчёт_посещаемость_сентябрь.xlsx",FilePath = "/documents/attendance_report_sept.xlsx",  Category = "Отчёт",       UploadedBy = 4, UploadedAt = now.AddDays(5) },
            new Document { Id = 5, FileName = "Положение_об_академотпуске.pdf", FilePath = "/documents/academic_leave_policy.pdf",      Category = "Инструкция",  UploadedBy = 1, UploadedAt = now.AddDays(1) }
        );
    }
}
