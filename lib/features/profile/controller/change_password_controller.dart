import 'package:disabilitymne/features/profile/model/change_password_model.dart';
import 'package:disabilitymne/features/profile/services/profile_interface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/helpers/app_snackbar.dart';

class ChangePasswordController extends GetxController {
  ChangePasswordController({required this.profileInterface});

  final ProfileInterface profileInterface;

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isLoading = false.obs;

  Future<void> changePassword() async {
    final model = ChangePasswordModel(
      currentPassword: currentPasswordController.text,
      newPassword: newPasswordController.text,
      confirmNewPassword: confirmPasswordController.text,
    );

    if (!_validate(model)) return;

    isLoading.value = true;

    final response = await profileInterface.changePassword(model);

    isLoading.value = false;

    response.fold(
      (error) {
        AppSnackbar.show("Error", error.uiMessage);
      },
      (success) {
        AppSnackbar.show(
          "Success",
          success.message,
          snackPosition: SnackPosition.TOP,
        );

        Get.offAllNamed('/login');
      },
    );
  }

  bool _validate(ChangePasswordModel model) {
    if (model.currentPassword.isEmpty ||
        model.newPassword.isEmpty ||
        model.confirmNewPassword.isEmpty) {
      AppSnackbar.show("Error", "All fields are required");
      return false;
    }

    if (model.newPassword != model.confirmNewPassword) {
      AppSnackbar.show("Error", "Passwords do not match");
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