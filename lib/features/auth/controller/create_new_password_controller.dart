import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:disabilitymne/core/api_handler/success.dart';
import 'package:disabilitymne/features/auth/model/reset_password_model.dart';
import 'package:disabilitymne/features/auth/services/auth_interface.dart';

class ResetPasswordController extends GetxController {
  final AuthInterface authInterface;
  final String email;
  final String otp;

  ResetPasswordController({
    required this.authInterface,
    required this.email,
    required this.otp,
  });

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  RxBool isLoading = false.obs;

  Future<void> resetPassword(VoidCallback onSuccess) async {
    if (passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar("Error", "Please enter password");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    try {
      isLoading.value = true;

      final result = await authInterface.resetPassword(
        ResetPasswordModel(
          email,
          otp,
          passwordController.text.trim(),
          confirmPasswordController.text.trim(),
        ),
      );

      result.fold(
        (failure) {
          Get.snackbar("Failed", failure.uiMessage);
        },
        (Success success) {
          Get.snackbar("Success", success.message);
          onSuccess();
        },
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
