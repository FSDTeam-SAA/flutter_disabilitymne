import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/api_handler/success.dart';
import 'package:disabilitymne/core/auth/access_token_holder.dart';
import 'package:disabilitymne/core/auth/onboarding_state_holder.dart';
import 'package:disabilitymne/core/constants/api_endpoints.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/auth/model/forget_password_model.dart';
import 'package:disabilitymne/features/auth/model/reset_password_model.dart';
import 'package:disabilitymne/features/auth/model/signin_model.dart';
import 'package:disabilitymne/features/auth/model/signup_model.dart';
import 'package:disabilitymne/features/auth/model/verify_otp_model.dart';
import 'package:disabilitymne/features/auth/services/auth_interface.dart';
import 'package:disabilitymne/features/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class AuthInterfaceImpl extends AuthInterface {
  final AuthorizedPigeon appPigeon;
  AuthInterfaceImpl(this.appPigeon);

  Stream<AuthStatus> authStream() {
    return appPigeon.authStream;
  }

  @override
  FutureRequest<Success> login(SigninModel params) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.post(
          ApiEndpoints.login,
          data: params.toJson(),
        );
        debugPrint("login response: ${response.data}");
        final body = response.data;
        final loginResponse = SigninResponseModel.fromJson(body);
        if (loginResponse.success != true || loginResponse.data == null) {
          throw Exception("Login failed");
        }
        final loginData = loginResponse.data!;
        final userId = loginData.user?.id?.trim();

        if (Get.isRegistered<OnboardingStateHolder>() && loginData.user != null) {
          Get.find<OnboardingStateHolder>().saveFromLogin(loginData.user);
        }
        if (loginData.user != null) {
          Get.find<ProfileController>().user.value = loginData.user;
        }
        if (Get.isRegistered<AccessTokenHolder>() && loginData.accessToken != null) {
          Get.find<AccessTokenHolder>().setToken(loginData.accessToken);
        }

        await appPigeon.saveNewAuth(
          saveAuthParams: SaveNewAuthParams(
            uid: userId,
            accessToken: loginData.accessToken,
            refreshToken: loginData.refreshToken,
            data: {
              "userId": userId,
              "name":
                  "${loginData.user?.firstName ?? ""} ${loginData.user?.lastName ?? ""}",
              "email": loginData.user?.email,
              "role": loginData.user?.role,
            },
          ),
        );

        return Success(message: loginResponse.message ?? "Login successful");
      },
    );
  }

  @override
  FutureRequest<Success<dynamic>> signup(SignupModel params) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.post(
          ApiEndpoints.signup,
          data: params.toJson(),
        );
        debugPrint("signup response: ${response.data}");
        final body = response.data;
        final signupResponse = SigninResponseModel.fromJson(body);
        if (signupResponse.success != true || signupResponse.data == null) {
          throw Exception("Signup failed");
        }
        return Success(message: signupResponse.message ?? "Signup successful");
      },
    );
  }

  @override
  FutureRequest<Success<dynamic>> forgetPassword(
    ForgetPasswordModel params,
  ) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.post(
          ApiEndpoints.forgetPassword,
          data: params.toJson(),
        );
        debugPrint('FORGET PASSWORD RESPONSE => ${response.data}');
        return Success(message: extractSuccessMessage(response));
      },
    );
  }

  @override
  FutureRequest<Success> logout() async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.post(ApiEndpoints.logout);
        debugPrint('LOGOUT RESPONSE => ${response.data}');
        appPigeon.disconnectSocket();
        await appPigeon.logOut();
        if (Get.isRegistered<AccessTokenHolder>()) {
          Get.find<AccessTokenHolder>().clear();
        }
        if (Get.isRegistered<OnboardingStateHolder>()) {
          Get.find<OnboardingStateHolder>().clear();
        }
        return Success(message: extractSuccessMessage(response));
      },
    );
  }

  @override
  FutureRequest<Success<dynamic>> resetPassword(
    ResetPasswordModel params,
  ) async {
    return await asyncTryCatch(tryFunc: () async {
      final response = await appPigeon.post(
        ApiEndpoints.createNewPassword,
        data: params.toJson(),
      );
      debugPrint('RESET PASSWORD RESPONSE => ${response.data}');
      return Success(message: extractSuccessMessage(response));
    });
  }

  @override
  FutureRequest<Success<dynamic>> verifyOtp(VerifyOtpModel params) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.post(
          ApiEndpoints.verifyCode,
          data: params.toJson(),
        );
        debugPrint('VERIFY CODE RESPONSE => ${response.data}');
        return Success(message: extractSuccessMessage(response));
      },
    );
  }

  @override
  FutureRequest<Success> deleteAccount() async {
    return asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.delete(ApiEndpoints.deleteAccount);
        appPigeon.disconnectSocket();
        await appPigeon.logOut();
        if (Get.isRegistered<AccessTokenHolder>()) {
          Get.find<AccessTokenHolder>().clear();
        }
        if (Get.isRegistered<OnboardingStateHolder>()) {
          Get.find<OnboardingStateHolder>().clear();
        }
        return Success(message: extractSuccessMessage(response));
      },
    );
  }
}
