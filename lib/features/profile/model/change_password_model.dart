class ChangePasswordModel {
  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;

  ChangePasswordModel({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      "currentPassword": currentPassword,
      "newPassword": newPassword,
      "confirmNewPassword": confirmNewPassword,
    };
  }

  factory ChangePasswordModel.fromJson(Map<String, dynamic> json) {
    return ChangePasswordModel(
      currentPassword: json['currentPassword'] ?? '',
      newPassword: json['newPassword'] ?? '',
      confirmNewPassword: json['confirmNewPassword'] ?? '',
    );
  }
}