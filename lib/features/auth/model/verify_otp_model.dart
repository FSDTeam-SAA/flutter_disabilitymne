class VerifyOtpModel {
  final String email;
  final String otp;

  VerifyOtpModel(this.email, this.otp);

  Map<String, dynamic> toJson() => {
        "email": email,
        "otp": otp,
      };
}