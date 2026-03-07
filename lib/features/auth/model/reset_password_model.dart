class ResetPasswordModel {
  final String email;
  final String otp;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordModel(
    this.email,
    this.otp,
    this.newPassword,
    this.confirmPassword,
  );

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "otp": otp,
      "newPassword": newPassword,
      "confirmPassword": confirmPassword,
    };
  }
}
