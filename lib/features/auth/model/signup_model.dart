class SignupModel {
  final String firstName;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;

  SignupModel({
    required this.firstName,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      "firstName": firstName,
      "email": email,
      "phone": phone,
      "password": password,
      "confirmPassword": confirmPassword,
    };
  }
}