import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/image_path.dart';
import 'package:disabilitymne/core/common/widget/app_text_field.dart';
import 'package:disabilitymne/features/auth/controller/forget_password_controller.dart';
import 'package:disabilitymne/features/auth/presentation/screens/otp_verify_screen.dart';
import 'package:disabilitymne/features/auth/services/auth_interface.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final ForgetPasswordController controller = Get.put(
    ForgetPasswordController(Get.find<AuthInterface>()),
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
            child: Form(
              key: controller.formKey,
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
                    'Reset password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your email to receive the OTP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha:  0.8),
                    ),
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    label: 'Your Email',
                    hint: 'Enter your Email',
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    controller: controller.emailController,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter your email' : null,
                  ),
                  const SizedBox(height: 28),
                  Obx(
                    () => GestureDetector(
                      onTap: controller.isLoading.value
                          ? null
                          : () {
                              controller.sendOtp(() {
                                Get.to(
                                  () => OtpVerifyScreen(
                                    email: controller.emailController.text
                                        .trim(),
                                  ),
                                );
                              });
                            },
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF89C9E6), Color(0xFF4D7EA9)],
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
                                'SEND OTP',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
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
      ),
    );
  }
}
