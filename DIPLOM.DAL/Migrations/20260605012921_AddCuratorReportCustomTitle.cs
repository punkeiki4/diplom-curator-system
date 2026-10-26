using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DIPLOM.DAL.Migrations
{
    /// <inheritdoc />
    public partial class AddCuratorReportCustomTitle : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "CustomTitle",
                table: "CuratorReports",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "CuratorReports",
                keyColumn: "Id",
                keyValue: 1,
                column: "CustomTitle",
                value: null);

            migrationBuilder.UpdateData(
                table: "CuratorReports",
                keyColumn: "Id",
                keyValue: 2,
                column: "CustomTitle",
                value: null);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CustomTitle",
                table: "CuratorReports");
        }
    }
}
