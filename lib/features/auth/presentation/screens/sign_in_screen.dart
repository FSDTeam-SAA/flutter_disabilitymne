import 'package:disabilitymne/core/common/widget/coustm_button.dart';
import 'package:disabilitymne/features/auth/controller/signin_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/image_path.dart';
import 'package:disabilitymne/core/common/widget/app_text_field.dart';
import 'package:disabilitymne/features/welcome/welcome_screen.dart';
import 'package:disabilitymne/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:disabilitymne/features/auth/presentation/screens/forgot_password_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late LoginController controller;

  static const Color _darkBlue = Color(0xFF0D1B2A);
  static const Color _linkBlue = Color(0xFF89C9E6);

  @override
  Widget build(BuildContext context) {
    controller = Get.find<LoginController>();
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

                  /// Back Button
                  GestureDetector(
                    onTap: () => Get.offAll(() => const WelcomeScreen()),
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

                  /// Logo
                  Center(
                    child: Image.asset(
                      ImagePath.appLogo,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// Email Field
                  AppTextField(
                    label: 'User Email',
                    hint: 'Enter your Email',
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    controller: controller.emailController,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter your email' : null,
                  ),

                  const SizedBox(height: 20),

                  /// Password Field
                  Obx(() {
                    return AppTextField(
                      label: 'Password',
                      hint: 'Enter your Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: !controller.isPasswordVisible.value,
                      controller: controller.passwordController,
                      textInputAction: TextInputAction.done,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Enter your password'
                          : null,
                      suffix: IconButton(
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _linkBlue,
                          size: 22,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  /// Remember Me & Forgot
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() {
                        return GestureDetector(
                          onTap: () => controller.toggleKeepSignedIn(
                            !controller.keepSignedIn.value,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: controller.keepSignedIn.value,
                                  onChanged: (v) =>
                                      controller.toggleKeepSignedIn(v ?? false),
                                  fillColor: WidgetStateProperty.resolveWith(
                                    (states) =>
                                        states.contains(WidgetState.selected)
                                        ? _linkBlue
                                        : Colors.transparent,
                                  ),
                                  checkColor: Colors.white,
                                  side: const BorderSide(color: Colors.white54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Remember me',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      GestureDetector(
                        onTap: () => Get.to(() => ForgotPasswordScreen()),
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _linkBlue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  /// Sign In Button
                  ListenableBuilder(
                    listenable: controller.processStatusNotifier,
                    builder: (context, _) {
                      return CustomButton(
                        onPressed: controller.processStatusNotifier.isLoading
                            ? () {}
                            : () {
                                controller.login(
                                  onSuccess: () {
                                    Get.offAll(() => Scaffold());
                                  },
                                  needVerifyAccount: () {
                                    Get.snackbar(
                                      "Verify Account",
                                      "Please verify your account first",
                                    );
                                  },
                                );
                              },
                        text: controller.processStatusNotifier.isLoading
                            ? "Signing In..."
                            : "Sign In",
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  /// Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.offAll(() => SignUpScreen()),
                        child: const Text(
                          'Sign Up Here',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _linkBlue,
                          ),
                        ),
                      ),
                    ],
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
