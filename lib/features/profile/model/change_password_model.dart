class ChangePasswordModel {
  String currentPassword;
  String newPassword;
  String confirmPassword;

  ChangePasswordModel({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      "current_password": currentPassword,
      "new_password": newPassword,
      "confirm_password": confirmPassword,
    };
  }
}