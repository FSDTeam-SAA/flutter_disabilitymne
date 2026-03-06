import 'package:disabilitymne/features/profile/model/change_password_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordController extends GetxController {

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isLoading = false.obs;

  void changePassword() async {

    final model = ChangePasswordModel(
      currentPassword: currentPasswordController.text,
      newPassword: newPasswordController.text,
      confirmPassword: confirmPasswordController.text,
    );

    if (!_validate(model)) return;

    isLoading.value = true;

    await Future.delayed(const Duration(seconds: 2)); // simulate API

    isLoading.value = false;

    Get.snackbar(
      "Success",
      "Password changed successfully",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  bool _validate(ChangePasswordModel model) {

    if (model.currentPassword.isEmpty ||
        model.newPassword.isEmpty ||
        model.confirmPassword.isEmpty) {

      Get.snackbar("Error", "All fields are required");
      return false;
    }

    if (model.newPassword != model.confirmPassword) {
      Get.snackbar("Error", "Passwords do not match");
      return false;
    }

    return true;
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}