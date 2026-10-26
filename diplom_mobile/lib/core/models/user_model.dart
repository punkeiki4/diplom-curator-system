class UserModel {
  final int id;
  final String? fullName;
  final String? email;
  final int roleId;
  final String? roleName;

  UserModel({
    required this.id,
    this.fullName,
    this.email,
    required this.roleId,
    this.roleName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        fullName: json['fullName'],
        email: json['email'],
        roleId: json['roleId'],
        roleName: json['roleName'],
      );
}
