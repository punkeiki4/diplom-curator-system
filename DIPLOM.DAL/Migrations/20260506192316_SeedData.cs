using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814  

namespace DIPLOM.DAL.Migrations
{
    /// <inheritdoc />
    public partial class SeedData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Groups",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "ИС-301" },
                    { 2, "ИС-302" },
                    { 3, "ПИ-401" }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "Name" },
                values: new object[,]
                {
                    { 1, "Admin" },
                    { 2, "ЗамДекана" },
                    { 3, "Куратор" },
                    { 4, "Студент" }
                });

            migrationBuilder.InsertData(
                table: "Schedules",
                columns: new[] { "Id", "GroupId", "LessonDate", "Subject" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2025, 9, 2, 8, 0, 0, 0, DateTimeKind.Utc), "Математика" },
                    { 2, 1, new DateTime(2025, 9, 2, 10, 0, 0, 0, DateTimeKind.Utc), "Программирование" },
                    { 3, 1, new DateTime(2025, 9, 3, 8, 0, 0, 0, DateTimeKind.Utc), "База данных" },
                    { 4, 2, new DateTime(2025, 9, 2, 8, 0, 0, 0, DateTimeKind.Utc), "Физика" },
                    { 5, 2, new DateTime(2025, 9, 2, 12, 0, 0, 0, DateTimeKind.Utc), "Алгоритмы" },
                    { 6, 3, new DateTime(2025, 9, 3, 10, 0, 0, 0, DateTimeKind.Utc), "Проектирование ПО" },
                    { 7, 3, new DateTime(2025, 9, 4, 8, 0, 0, 0, DateTimeKind.Utc), "Сети и телекоммуникации" }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "Email", "FullName", "PasswordHash", "RoleId" },
                values: new object[,]
                {
                    { 1, "admin@diplom.ru", "Администратор Системы", "PrP+ZrMeO00Q+nC1ytSccRIpSvauTkdqHEBRVdRaoSE=", 1 },
                    { 2, "vicedean1@diplom.ru", "Петрова Наталья Сергеевна", "WE3I4kUIvglhMrBEtVhSCGuLNh1aODRoFjevI05Gxo0=", 2 },
                    { 3, "vicedean2@diplom.ru", "Смирнов Алексей Владимирович", "3/RAyPNOl/UH8uR+ZC/gixD21SC2IsXsjBaygWUbCao=", 2 },
                    { 4, "curator1@diplom.ru", "Иванов Дмитрий Петрович", "TKvKQH1QG8ziF1x9gRI35BEcYpdHwYqpKXwO7NTk03k=", 3 },
                    { 5, "curator2@diplom.ru", "Козлова Марина Александровна", "ck+FgplPstOiPOeDmXrDDW8J6jS2p7ZlMc/8shk5gsE=", 3 },
                    { 6, "curator3@diplom.ru", "Новиков Сергей Игоревич", "DaH8OPZpdBRL5jmf+k0eBFidzY3JMpfwWkCmqPnJstE=", 3 },
                    { 7, "student1@diplom.ru", "Морозов Иван Андреевич", "2mi3JpyHvnez3aSZzJzvZ7pc3XDDkJVFiv9eYwQOZMs=", 4 },
                    { 8, "student2@diplom.ru", "Волкова Анна Дмитриевна", "yBS+CgNJ31F84n5XShc2kLDW6Mg1PrigP2Y3ZwjfA7A=", 4 },
                    { 9, "student3@diplom.ru", "Соколов Кирилл Евгеньевич", "RRFfY41e9Hqkf7+zwmUSS6HIE7yyjm+DV3THjaWeNCo=", 4 },
                    { 10, "student4@diplom.ru", "Лебедева Ольга Николаевна", "aluC/hOV4PrqfBB/yfRM/H8ASAyO3wSo2MeZrZ7IKsM=", 4 },
                    { 11, "student5@diplom.ru", "Федоров Антон Сергеевич", "ocE5GzJ+YjhdsX/zPE/7Wn8HLBOmk5FLxS376VizagY=", 4 },
                    { 12, "student6@diplom.ru", "Михайлова Екатерина Олеговна", "BPbyrv/3h9nrMOvRWyk2Af7rzqZxN05K5F6yVuH7MyM=", 4 }
                });

            migrationBuilder.InsertData(
                table: "Curators",
                column: "Id",
                values: new object[]
                {
                    4,
                    5,
                    6
                });

            migrationBuilder.InsertData(
                table: "Documents",
                columns: new[] { "Id", "Category", "FileName", "FilePath", "UploadedAt", "UploadedBy" },
                values: new object[,]
                {
                    { 1, "Расписание", "Расписание_осень_2025.pdf", "/documents/schedule_autumn_2025.pdf", new DateTime(2025, 9, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { 2, "Приказ", "Приказ_01_зачисление.pdf", "/documents/order_01_enrollment.pdf", new DateTime(2025, 9, 1, 0, 0, 0, 0, DateTimeKind.Utc), 1 },
                    { 3, "Инструкция", "Инструкция_куратора.docx", "/documents/curator_manual.docx", new DateTime(2025, 9, 2, 0, 0, 0, 0, DateTimeKind.Utc), 2 },
                    { 4, "Отчёт", "Отчёт_посещаемость_сентябрь.xlsx", "/documents/attendance_report_sept.xlsx", new DateTime(2025, 9, 6, 0, 0, 0, 0, DateTimeKind.Utc), 4 },
                    { 5, "Инструкция", "Положение_об_академотпуске.pdf", "/documents/academic_leave_policy.pdf", new DateTime(2025, 9, 2, 0, 0, 0, 0, DateTimeKind.Utc), 1 }
                });

            migrationBuilder.InsertData(
                table: "Notifications",
                columns: new[] { "Id", "CreatedAt", "CreatedBy", "Message", "Title" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 9, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, "Уважаемые студенты! Учебный год начинается 1 сентября. Расписание доступно в системе.", "Начало учебного года" },
                    { 2, new DateTime(2025, 9, 2, 0, 0, 0, 0, DateTimeKind.Utc), 2, "Уважаемые кураторы! Собрание состоится 10 сентября в 14:00 в ауд. 305.", "Собрание кураторов" },
                    { 3, new DateTime(2025, 9, 3, 0, 0, 0, 0, DateTimeKind.Utc), 3, "Напоминаем: срок сдачи отчётов по посещаемости за сентябрь — 5 октября.", "Сдача отчётов по посещаемости" }
                });

            migrationBuilder.InsertData(
                table: "Students",
                columns: new[] { "Id", "GroupId" },
                values: new object[,]
                {
                    { 7, 1 },
                    { 8, 1 },
                    { 9, 2 },
                    { 10, 2 },
                    { 11, 3 },
                    { 12, 3 }
                });

            migrationBuilder.InsertData(
                table: "Surveys",
                columns: new[] { "Id", "CreatedAt", "CreatedBy", "Deadline", "Description", "TargetRole", "Title" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 9, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, new DateTime(2025, 9, 15, 0, 0, 0, 0, DateTimeKind.Utc), "Оцените качество преподавания дисциплин в этом семестре.", "Студенты", "Качество преподавания" },
                    { 2, new DateTime(2025, 9, 2, 0, 0, 0, 0, DateTimeKind.Utc), 3, new DateTime(2025, 9, 22, 0, 0, 0, 0, DateTimeKind.Utc), "Насколько вы удовлетворены организацией учебного процесса?", "Студенты", "Удовлетворённость учёбой" },
                    { 3, new DateTime(2025, 9, 3, 0, 0, 0, 0, DateTimeKind.Utc), 2, new DateTime(2025, 9, 11, 0, 0, 0, 0, DateTimeKind.Utc), "Оцените удобство текущей системы отчётности.", "Кураторы", "Отчётность кураторов" }
                });

            migrationBuilder.InsertData(
                table: "ViceDeans",
                column: "Id",
                values: new object[]
                {
                    2,
                    3
                });

            migrationBuilder.InsertData(
                table: "AcademicDebts",
                columns: new[] { "Id", "CreatedAt", "Deadline", "DebtType", "Status", "StudentId", "Subject" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 9, 1, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 10, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Экзамен", "Активна", 8, "Математика" },
                    { 2, new DateTime(2025, 9, 1, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 15, 0, 0, 0, 0, DateTimeKind.Utc), "Зачёт", "Активна", 10, "Физика" },
                    { 3, new DateTime(2025, 7, 3, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 21, 0, 0, 0, 0, DateTimeKind.Utc), "Экзамен", "Погашена", 11, "Алгоритмы" }
                });

            migrationBuilder.InsertData(
                table: "Attendances",
                columns: new[] { "Id", "ScheduleId", "Status", "StudentId" },
                values: new object[,]
                {
                    { 1, 1, "Присутствовал", 7 },
                    { 2, 1, "Отсутствовал", 8 },
                    { 3, 2, "Присутствовал", 7 },
                    { 4, 2, "Присутствовал", 8 },
                    { 5, 3, "Отсутствовал", 7 },
                    { 6, 4, "Присутствовал", 9 },
                    { 7, 4, "Присутствовал", 10 },
                    { 8, 5, "Отсутствовал", 9 },
                    { 9, 6, "Присутствовал", 11 },
                    { 10, 6, "Присутствовал", 12 },
                    { 11, 7, "Отсутствовал", 11 },
                    { 12, 7, "Присутствовал", 12 }
                });

            migrationBuilder.InsertData(
                table: "CuratorGroups",
                columns: new[] { "CuratorId", "GroupId" },
                values: new object[,]
                {
                    { 4, 1 },
                    { 5, 2 },
                    { 6, 3 }
                });

            migrationBuilder.InsertData(
                table: "Grades",
                columns: new[] { "Id", "Date", "StudentId", "Subject", "Value" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 8, 2, 0, 0, 0, 0, DateTimeKind.Utc), 7, "Математика", 5 },
                    { 2, new DateTime(2025, 8, 12, 0, 0, 0, 0, DateTimeKind.Utc), 7, "Программирование", 4 },
                    { 3, new DateTime(2025, 8, 2, 0, 0, 0, 0, DateTimeKind.Utc), 8, "Математика", 3 },
                    { 4, new DateTime(2025, 8, 17, 0, 0, 0, 0, DateTimeKind.Utc), 8, "База данных", 4 },
                    { 5, new DateTime(2025, 8, 7, 0, 0, 0, 0, DateTimeKind.Utc), 9, "Физика", 5 },
                    { 6, new DateTime(2025, 8, 22, 0, 0, 0, 0, DateTimeKind.Utc), 9, "Алгоритмы", 4 },
                    { 7, new DateTime(2025, 8, 7, 0, 0, 0, 0, DateTimeKind.Utc), 10, "Физика", 2 },
                    { 8, new DateTime(2025, 8, 22, 0, 0, 0, 0, DateTimeKind.Utc), 10, "Алгоритмы", 3 },
                    { 9, new DateTime(2025, 8, 12, 0, 0, 0, 0, DateTimeKind.Utc), 11, "Проектирование ПО", 5 },
                    { 10, new DateTime(2025, 8, 14, 0, 0, 0, 0, DateTimeKind.Utc), 12, "Сети", 4 }
                });

            migrationBuilder.InsertData(
                table: "NotificationRecipients",
                columns: new[] { "NotificationId", "UserId", "IsRead" },
                values: new object[,]
                {
                    { 1, 7, true },
                    { 1, 8, false },
                    { 1, 9, true },
                    { 1, 10, false },
                    { 1, 11, true },
                    { 1, 12, false },
                    { 2, 4, true },
                    { 2, 5, false },
                    { 2, 6, true },
                    { 3, 4, false },
                    { 3, 5, true },
                    { 3, 6, false }
                });

            migrationBuilder.InsertData(
                table: "Requests",
                columns: new[] { "Id", "CreatedAt", "Description", "ReviewComment", "ReviewedAt", "ReviewedBy", "Status", "StudentId", "Title" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 8, 22, 0, 0, 0, 0, DateTimeKind.Utc), "Прошу выдать справку об обучении для военкомата.", "Справка готова, обратитесь в деканат.", new DateTime(2025, 8, 24, 0, 0, 0, 0, DateTimeKind.Utc), 2, "Одобрено", 7, "Справка об обучении" },
                    { 2, new DateTime(2025, 8, 29, 0, 0, 0, 0, DateTimeKind.Utc), "Прошу рассмотреть возможность перевода из ИС-302 в ИС-301.", null, null, null, "На согласовании", 9, "Перевод в другую группу" },
                    { 3, new DateTime(2025, 8, 31, 0, 0, 0, 0, DateTimeKind.Utc), "Прошу предоставить академический отпуск по состоянию здоровья.", null, null, null, "В обработке", 10, "Академический отпуск" },
                    { 4, new DateTime(2025, 8, 17, 0, 0, 0, 0, DateTimeKind.Utc), "Прошу назначить дату пересдачи экзамена по физике.", "Пересдача возможна только после ликвидации всех задолженностей.", new DateTime(2025, 8, 19, 0, 0, 0, 0, DateTimeKind.Utc), 3, "Отклонено", 12, "Пересдача экзамена" }
                });

            migrationBuilder.InsertData(
                table: "SurveyAnswers",
                columns: new[] { "Id", "Answer", "AnsweredAt", "StudentId", "SurveyId" },
                values: new object[,]
                {
                    { 1, "Преподавание на высоком уровне, особенно математика. Оценка 5/5.", new DateTime(2025, 9, 2, 0, 0, 0, 0, DateTimeKind.Utc), 7, 1 },
                    { 2, "В целом хорошо, но хотелось бы больше практики по программированию.", new DateTime(2025, 9, 2, 0, 0, 0, 0, DateTimeKind.Utc), 8, 1 },
                    { 3, "Удовлетворён. Преподаватели отзывчивы и доступно объясняют материал.", new DateTime(2025, 9, 3, 0, 0, 0, 0, DateTimeKind.Utc), 9, 1 },
                    { 4, "Расписание неудобное, слишком много окон между парами.", new DateTime(2025, 9, 3, 0, 0, 0, 0, DateTimeKind.Utc), 10, 2 },
                    { 5, "Всё устраивает, хорошая организация.", new DateTime(2025, 9, 4, 0, 0, 0, 0, DateTimeKind.Utc), 11, 2 }
                });

            migrationBuilder.InsertData(
                table: "Tasks",
                columns: new[] { "Id", "AssignedBy", "AssignedTo", "CreatedAt", "Deadline", "Description", "Priority", "Status", "Title" },
                values: new object[,]
                {
                    { 1, 2, 4, new DateTime(2025, 9, 1, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 8, 0, 0, 0, 0, DateTimeKind.Utc), "Собрание для группы ИС-301 по итогам семестра", "Высокий", "Новое", "Провести родительское собрание" },
                    { 2, 2, 5, new DateTime(2025, 9, 1, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 4, 0, 0, 0, 0, DateTimeKind.Utc), "Сдать отчёт за октябрь по группе ИС-302", "Средний", "В работе", "Подать отчёт по посещаемости" },
                    { 3, 3, 6, new DateTime(2025, 8, 27, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 9, 11, 0, 0, 0, 0, DateTimeKind.Utc), "Провести беседу о дисциплине в группе ПИ-401", "Низкий", "Выполнено", "Организовать встречу со студентами" }
                });

            migrationBuilder.InsertData(
                table: "CuratorReports",
                columns: new[] { "Id", "CuratorId", "ReportText", "ReviewComment", "ReviewStatus", "SubmittedAt", "TaskId" },
                values: new object[,]
                {
                    { 1, 6, "Встреча проведена 05.09. Присутствовало 12 студентов. Обсудили вопросы дисциплины и посещаемости.", "Отчёт принят, работа выполнена качественно.", "Принят", new DateTime(2025, 8, 31, 0, 0, 0, 0, DateTimeKind.Utc), 3 },
                    { 2, 5, "Отчёт по посещаемости за октябрь подготовлен. Средняя посещаемость 87%.", null, "На проверке", new DateTime(2025, 9, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2 }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "AcademicDebts",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "AcademicDebts",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "AcademicDebts",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Attendances",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Attendances",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Attendances",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Attendances",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Attendances",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Attendances",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Attendances",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Attendances",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Attendances",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Attendances",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Attendances",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Attendances",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "CuratorGroups",
                keyColumns: new[] { "CuratorId", "GroupId" },
                keyValues: new object[] { 4, 1 });

            migrationBuilder.DeleteData(
                table: "CuratorGroups",
                keyColumns: new[] { "CuratorId", "GroupId" },
                keyValues: new object[] { 5, 2 });

            migrationBuilder.DeleteData(
                table: "CuratorGroups",
                keyColumns: new[] { "CuratorId", "GroupId" },
                keyValues: new object[] { 6, 3 });

            migrationBuilder.DeleteData(
                table: "CuratorReports",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "CuratorReports",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Documents",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Documents",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Documents",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Documents",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Documents",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Grades",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Grades",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Grades",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Grades",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Grades",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Grades",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Grades",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Grades",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Grades",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Grades",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "NotificationRecipients",
                keyColumns: new[] { "NotificationId", "UserId" },
                keyValues: new object[] { 1, 7 });

            migrationBuilder.DeleteData(
                table: "NotificationRecipients",
                keyColumns: new[] { "NotificationId", "UserId" },
                keyValues: new object[] { 1, 8 });

            migrationBuilder.DeleteData(
                table: "NotificationRecipients",
                keyColumns: new[] { "NotificationId", "UserId" },
                keyValues: new object[] { 1, 9 });

            migrationBuilder.DeleteData(
                table: "NotificationRecipients",
                keyColumns: new[] { "NotificationId", "UserId" },
                keyValues: new object[] { 1, 10 });

            migrationBuilder.DeleteData(
                table: "NotificationRecipients",
                keyColumns: new[] { "NotificationId", "UserId" },
                keyValues: new object[] { 1, 11 });

            migrationBuilder.DeleteData(
                table: "NotificationRecipients",
                keyColumns: new[] { "NotificationId", "UserId" },
                keyValues: new object[] { 1, 12 });

            migrationBuilder.DeleteData(
                table: "NotificationRecipients",
                keyColumns: new[] { "NotificationId", "UserId" },
                keyValues: new object[] { 2, 4 });

            migrationBuilder.DeleteData(
                table: "NotificationRecipients",
                keyColumns: new[] { "NotificationId", "UserId" },
                keyValues: new object[] { 2, 5 });

            migrationBuilder.DeleteData(
                table: "NotificationRecipients",
                keyColumns: new[] { "NotificationId", "UserId" },
                keyValues: new object[] { 2, 6 });

            migrationBuilder.DeleteData(
                table: "NotificationRecipients",
                keyColumns: new[] { "NotificationId", "UserId" },
                keyValues: new object[] { 3, 4 });

            migrationBuilder.DeleteData(
                table: "NotificationRecipients",
                keyColumns: new[] { "NotificationId", "UserId" },
                keyValues: new object[] { 3, 5 });

            migrationBuilder.DeleteData(
                table: "NotificationRecipients",
                keyColumns: new[] { "NotificationId", "UserId" },
                keyValues: new object[] { 3, 6 });

            migrationBuilder.DeleteData(
                table: "Requests",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Requests",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Requests",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Requests",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "SurveyAnswers",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "SurveyAnswers",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "SurveyAnswers",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "SurveyAnswers",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "SurveyAnswers",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Surveys",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Tasks",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Curators",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Schedules",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Schedules",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Schedules",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Schedules",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Schedules",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Schedules",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Schedules",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Students",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Students",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Students",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Students",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Students",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Students",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Surveys",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Surveys",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Tasks",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Tasks",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Curators",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Curators",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Groups",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Groups",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Groups",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "ViceDeans",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "ViceDeans",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: 3);
        }
    }
}
