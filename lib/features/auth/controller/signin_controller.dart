import 'package:disabilitymne/core/api_handler/failure.dart';
import 'package:disabilitymne/core/helpers/handle_fold.dart';
import 'package:disabilitymne/core/helpers/validation.dart';
import 'package:disabilitymne/features/auth/model/signin_model.dart';
import 'package:disabilitymne/features/auth/services/auth_interface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/notifiers/button_status_notifier.dart';
import '../../../core/notifiers/snackbar_notifier.dart';

class LoginController extends GetxController {
  final ProcessStatusNotifier processStatusNotifier = ProcessStatusNotifier(
    initialStatus: DisabledStatus(),
  );
  final SnackbarNotifier snackbarNotifier;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordVisible = false.obs;
  final keepSignedIn = false.obs;
  final isLoading = false.obs;

  String _email = '';
  String get email => _email;

  String _password = '';
  String get password => _password;

  LoginController(this.snackbarNotifier);

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(() {
      debugPrint("Email: ${emailController.text}");
      email = emailController.text.trim();
    });
    passwordController.addListener(() {
      debugPrint("password: ${passwordController.text}");
      password = passwordController.text.trim();
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  set email(String value) {
    if (value != _email) {
      _email = value;
      canLogin();
    }
  }

  set password(String value) {
    if (value != _password) {
      _password = value;
      canLogin();
    }
  }

  void canLogin() {
    if (_email.isNotEmpty && isEmail(_email) && _password.isNotEmpty) {
      processStatusNotifier.setEnabled();
    } else {
      processStatusNotifier.setDisabled();
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleKeepSignedIn(bool value) {
    keepSignedIn.value = value;
  }

  Future<void> login({
    required VoidCallback onSuccess,
    required VoidCallback needVerifyAccount,
  }) async {
    if (!formKey.currentState!.validate()) return;

    processStatusNotifier.setLoading();

    final result = await Get.find<AuthInterface>().login(
      SigninModel(email: email, password: password),
    );

    handleFold(
      either: result,
      processStatusNotifier: processStatusNotifier,
      successSnackbarNotifier: snackbarNotifier,
      errorSnackbarNotifier: snackbarNotifier,
      onError: (error) {
        if (error.failure == Failure.forbidden) {
          needVerifyAccount();
        }
      },
      onSuccess: (_) {
        onSuccess(); // ✅ NAVIGATE ONLY HERE
      },
    );
  }
}
