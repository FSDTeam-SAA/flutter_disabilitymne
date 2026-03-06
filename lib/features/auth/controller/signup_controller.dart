import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        Get.snackbar("Signup Failed", failure.uiMessage,
            snackPosition: SnackPosition.BOTTOM);
      },
      (success) {
        Get.snackbar("Success", success.message,
            snackPosition: SnackPosition.BOTTOM);
        onSuccess();
      },
    );

  } catch (e) {
    Get.snackbar("Signup Failed", e.toString(),
        snackPosition: SnackPosition.BOTTOM);
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