using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DIPLOM.DAL.Migrations
{
    /// <inheritdoc />
    public partial class AddEventCuratorAssignment : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "AssignedCuratorId",
                table: "Events",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Events_AssignedCuratorId",
                table: "Events",
                column: "AssignedCuratorId");

            migrationBuilder.AddForeignKey(
                name: "FK_Events_Users_AssignedCuratorId",
                table: "Events",
                column: "AssignedCuratorId",
                principalTable: "Users",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Events_Users_AssignedCuratorId",
                table: "Events");

            migrationBuilder.DropIndex(
                name: "IX_Events_AssignedCuratorId",
                table: "Events");

            migrationBuilder.DropColumn(
                name: "AssignedCuratorId",
                table: "Events");
        }
    }
}
