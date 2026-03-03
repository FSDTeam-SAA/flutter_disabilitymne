import 'package:disabilitymne/features/auth/model/user_model.dart';

class SigninModel {
  final String email;
  final String password;

  SigninModel({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "password": password,
    };
  }
}

class SigninResponseModel {
  final bool? success;
  final String? message;
  final SigninData? data;

  SigninResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory SigninResponseModel.fromJson(Map<String, dynamic> json) {
    return SigninResponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? SigninData.fromJson(json['data'])
          : null,
    );
  }
}

class SigninData {
  final String? token;
  final String? accessToken;
  final String? refreshToken;
  final UserModel? user;

  SigninData({
    this.token,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory SigninData.fromJson(Map<String, dynamic> json) {
    return SigninData(
      token: json['token'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      user: json['user'] != null
          ? UserModel.fromJson(json['user'])
          : null,
    );
  }
}
