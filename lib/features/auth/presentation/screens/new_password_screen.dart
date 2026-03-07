import 'package:disabilitymne/features/auth/controller/create_new_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/image_path.dart';
import 'package:disabilitymne/core/common/widget/app_text_field.dart';
import 'package:disabilitymne/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:disabilitymne/features/auth/services/auth_interface.dart';

class NewPasswordScreen extends StatelessWidget {
  final String email;
  final String otp;

  NewPasswordScreen({super.key, required this.email, required this.otp});

  final _formKey = GlobalKey<FormState>();

  late final ResetPasswordController controller = Get.put(
    ResetPasswordController(
      authInterface: Get.find<AuthInterface>(),
      email: email,
      otp: otp,
    ),
  );

  static const Color _darkBlue = Color(0xFF1E253F);
  static const Color _linkBlue = Color(0xFF89C9E6);

  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirm = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
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
                    'New password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Enter your new password and confirm password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Obx(() => AppTextField(
                        label: 'New Password',
                        hint: 'Enter your New Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: obscurePassword.value,
                        controller: controller.passwordController,
                        suffix: IconButton(
                          icon: Icon(
                            obscurePassword.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: _linkBlue,
                          ),
                          onPressed: () =>
                              obscurePassword.value = !obscurePassword.value,
                        ),
                      )),

                  const SizedBox(height: 20),

                  Obx(() => AppTextField(
                        label: 'Confirm Password',
                        hint: 'Enter your Confirm Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: obscureConfirm.value,
                        controller: controller.confirmPasswordController,
                        suffix: IconButton(
                          icon: Icon(
                            obscureConfirm.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: _linkBlue,
                          ),
                          onPressed: () =>
                              obscureConfirm.value = !obscureConfirm.value,
                        ),
                      )),

                  const SizedBox(height: 28),

                  Obx(
                    () => GestureDetector(
                      onTap: controller.isLoading.value
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                controller.resetPassword(() {
                                  Get.offAll(() => const SignInScreen());
                                });
                              }
                            },
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF89C9E6), Color(0xFF4D7EA9)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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