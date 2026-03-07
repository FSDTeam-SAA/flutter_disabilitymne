// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:disabilitymne/features/auth/model/verify_otp_model.dart';
// import 'package:disabilitymne/features/auth/services/auth_interface.dart';

// class VerifyOtpController extends GetxController {
//   final AuthInterface authInterface;
//   final String email;

//   VerifyOtpController({required this.authInterface, required this.email});

//   var otp = ''.obs;
//   var isLoading = false.obs;

//   Future<void> verifyOtp(VoidCallback onSuccess) async {
//     if (otp.value.length != 6) {
//       Get.snackbar("Error", "Enter a valid 6-digit OTP",
//           snackPosition: SnackPosition.BOTTOM);
//       return;
//     }

//     final model = VerifyOtpModel(email, otp.value);

//     try {
//       isLoading.value = true;

//       final result = await authInterface.verifyOtp(model);

//       result.fold(
//         (failure) {
//           Get.snackbar("Error", failure.uiMessage,
//               snackPosition: SnackPosition.BOTTOM);
//         },
//         (success) {
//           Get.snackbar("Success", success.message,
//               snackPosition: SnackPosition.BOTTOM);
//           onSuccess();
//         },
//       );
//     } catch (e) {
//       Get.snackbar("Error", e.toString(),
//           snackPosition: SnackPosition.BOTTOM);
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }

import 'package:get/get.dart';
import 'package:disabilitymne/features/auth/services/auth_interface.dart';
import 'package:disabilitymne/features/auth/model/verify_otp_model.dart';
import 'package:disabilitymne/features/auth/presentation/screens/new_password_screen.dart';

class VerifyOtpController extends GetxController {
  final AuthInterface authInterface;
  final String email;

  VerifyOtpController({required this.authInterface, required this.email});

  var otp = ''.obs;
  var isLoading = false.obs;

  /// Verify OTP
  Future<void> verifyOtp() async {
    if (otp.value.length != 6) {
      Get.snackbar(
        "Error",
        "Enter a valid 6-digit OTP",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final model = VerifyOtpModel(email, otp.value);

    try {
      isLoading.value = true;

      final result = await authInterface.verifyOtp(model);

      result.fold(
        (failure) => Get.snackbar(
          "Error",
          failure.uiMessage,
          snackPosition: SnackPosition.BOTTOM,
        ),
        (success) {
          Get.snackbar(
            "Success",
            success.message,
            snackPosition: SnackPosition.BOTTOM,
          );

          // Navigate to New Password Screen
          Get.to(() => NewPasswordScreen(email: email, otp: otp.value));
        },
      );
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
