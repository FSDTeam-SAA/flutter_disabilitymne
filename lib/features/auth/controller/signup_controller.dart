import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/helpers/app_snackbar.dart';
import 'package:disabilitymne/features/auth/model/signup_model.dart';
import 'package:disabilitymne/features/auth/services/auth_interface.dart';

class SignupController extends GetxController {
  final AuthInterface authInterface;

  SignupController(this.authInterface);

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;
  var isLoading = false.obs;

  void togglePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPassword() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> signUp(VoidCallback onSuccess) async {
    if (!formKey.currentState!.validate()) return;

    SignupModel model = SignupModel(
      firstName: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      password: passwordController.text.trim(),
      confirmPassword: confirmPasswordController.text.trim(),
    );

    try {
      isLoading.value = true;

      final result = await authInterface.signup(model);

      result.fold(
        (failure) {
          AppSnackbar.show(
            "Signup Failed",
            failure.uiMessage,
            snackPosition: SnackPosition.TOP,
          );
        },
        (success) {
          AppSnackbar.show(
            "Success",
            success.message,
            snackPosition: SnackPosition.TOP,
          );
          onSuccess();
        },
      );
    } catch (e) {
      AppSnackbar.show(
        "Signup Failed",
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
