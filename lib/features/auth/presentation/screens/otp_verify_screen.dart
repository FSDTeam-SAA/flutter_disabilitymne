import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/helpers/app_snackbar.dart';
import 'package:disabilitymne/core/image_path.dart';
import 'package:disabilitymne/core/common/widget/otp_input.dart';
import 'package:disabilitymne/features/auth/controller/verify_otp_controller.dart';
import 'package:disabilitymne/features/auth/services/auth_interface.dart';

class OtpVerifyScreen extends StatelessWidget {
  final String email;

  OtpVerifyScreen({super.key, required this.email});

  // Initialize controller
  late final VerifyOtpController controller = Get.put(
    VerifyOtpController(authInterface: Get.find<AuthInterface>(), email: email),
  );

  static const Color _darkBlue = Color(0xFF1E253F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Row(
                    children: [
                      Icon(Icons.chevron_left, color: Colors.white, size: 28),
                      SizedBox(width: 4),
                      Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Image.asset(
                    ImagePath.appLogo,
                    height: 70,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Enter OTP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                OtpInput(
                  onChanged: (v) => controller.otp.value = v,
                  onCompleted: (v) => controller.otp.value = v,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't Receive OTP? ",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Currently do nothing
                        AppSnackbar.show('Info', 'Resend OTP not implemented yet.');
                      },
                      child: const Text(
                        'RESEND OTP',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF89C9E6),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                // Only wrap in Obx when reading observable
                Obx(
                  () => GestureDetector(
                    onTap: controller.isLoading.value
                        ? null
                        : controller.verifyOtp,
                    child: Opacity(
                      opacity: controller.isLoading.value ? 0.5 : 1,
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: controller.isLoading.value
                                ? [Colors.grey, Colors.grey.shade700]
                                : const [Color(0xFF89C9E6), Color(0xFF4D7EA9)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Verify Now',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
