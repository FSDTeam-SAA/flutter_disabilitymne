import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/auth/onboarding_state_holder.dart';
import 'package:disabilitymne/core/image_path.dart';
import 'package:disabilitymne/core/common/widget/app_text_field.dart';
import 'package:disabilitymne/core/common/widget/coustm_button.dart';
import 'package:disabilitymne/features/auth/controller/signup_controller.dart';
import 'package:disabilitymne/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:disabilitymne/features/auth/services/auth_interface.dart';
import 'package:disabilitymne/features/onboarding/fitness_experience_screen.dart';
import 'package:disabilitymne/features/welcome/welcome_screen.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key, this.fromOnboarding = false});

  /// When true, this screen sits between Mobility and Fitness Experience.
  final bool fromOnboarding;

  final SignupController controller = Get.put(SignupController(Get.find()));

  static const Color _darkNavy = Color(0xFF1A2C46);
  static const Color _linkBlue = Color(0xFF89C9E6);

  void _onBack() {
    if (fromOnboarding) {
      Get.back();
    } else {
      Get.offAll(() => const WelcomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkNavy,
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
                    onTap: _onBack,
                    child: const Row(
                      children: [
                        Icon(Icons.chevron_left,color: Colors.white,size: 28),
                        SizedBox(width: 4),
                        Text(
                          'Back',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: Image.asset(
                      ImagePath.appLogo,
                      height: 70,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Let's Get Started!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Create an account',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15,color: Colors.white70),
                  ),

                  const SizedBox(height: 32),

                  AppTextField(
                    label: 'User Name',
                    hint: 'Enter your First Name',
                    prefixIcon: Icons.person_outline,
                    controller: controller.nameController,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter your name' : null,
                  ),

                  const SizedBox(height: 20),

                  AppTextField(
                    label: 'Your Email',
                    hint: 'Enter your Email',
                    prefixIcon: Icons.mail_outline,
                    controller: controller.emailController,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter your email' : null,
                  ),

                  const SizedBox(height: 20),

                  AppTextField(
                    label: 'Phone Number',
                    hint: 'Enter your phone number',
                    prefixIcon: Icons.phone_outlined,
                    controller: controller.phoneController,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter your phone' : null,
                  ),

                  const SizedBox(height: 20),

                  Obx(() => AppTextField(
                        label: 'Password',
                        hint: 'Enter your Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: controller.obscurePassword.value,
                        controller: controller.passwordController,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Enter your password'
                            : null,
                        suffix: IconButton(
                          icon: Icon(
                            controller.obscurePassword.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: _linkBlue,
                          ),
                          onPressed: controller.togglePassword,
                        ),
                      )),

                  const SizedBox(height: 20),

                  Obx(() => AppTextField(
                        label: 'Confirm Password',
                        hint: 'Enter Confirm Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText:
                            controller.obscureConfirmPassword.value,
                        controller: controller.confirmPasswordController,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Confirm your password';
                          }
                          if (v != controller.passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        suffix: IconButton(
                          icon: Icon(
                            controller.obscureConfirmPassword.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: _linkBlue,
                          ),
                          onPressed: controller.toggleConfirmPassword,
                        ),
                      )),

                  const SizedBox(height: 28),

                  Obx(() => CustomButton(
                        onPressed: controller.isLoading.value
                            ? () {}
                            : () {
                                if (Get.isRegistered<OnboardingStateHolder>()) {
                                  Get.find<OnboardingStateHolder>()
                                      .suppressAuthNavigation = true;
                                }
                                controller.signUp(() async {
                                  if (fromOnboarding) {
                                    Get.to(() => const FitnessExperienceScreen());
                                    return;
                                  }
                                  if (Get.isRegistered<OnboardingStateHolder>()) {
                                    Get.find<OnboardingStateHolder>()
                                        .routeToLoginOnLogout = true;
                                  }
                                  await Get.find<AuthInterface>().logout();
                                });
                              },
                        text: controller.isLoading.value
                            ? "Loading..."
                            : "Sign Up",
                      )),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Get.offAll(() => const SignInScreen()),
                        child: const Text(
                          'Sign In Here',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _linkBlue),
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