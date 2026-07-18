import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/helpers/app_snackbar.dart';
import 'package:disabilitymne/features/auth/model/forget_password_model.dart';
import 'package:disabilitymne/features/auth/services/auth_interface.dart';

class ForgetPasswordController extends GetxController {
  final AuthInterface authInterface;

  ForgetPasswordController(this.authInterface);

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  var isLoading = false.obs;

  Future<void> sendOtp(VoidCallback onSuccess) async {
    if (!formKey.currentState!.validate()) return;

    final model = ForgetPasswordModel(emailController.text.trim());

    try {
      isLoading.value = true;

      final result = await authInterface.forgetPassword(model);

      // unwrap Either<DataCRUDFailure, Success>
      result.fold(
        (failure) {
          AppSnackbar.show(
            "Failed",
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
      AppSnackbar.show("Error", e.toString(), snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
