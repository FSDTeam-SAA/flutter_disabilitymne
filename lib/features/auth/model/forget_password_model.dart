class ForgetPasswordModel {
  final String email;
  ForgetPasswordModel(this.email);
  Map<String, dynamic> toJson() {
    return {
      "email": email,
    };
  }
}