import 'package:disabilitymne/core/common/widget/coustm_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/image_path.dart';
import 'package:disabilitymne/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:disabilitymne/features/auth/presentation/screens/sign_up_screen.dart';

/// Welcome / landing screen after onboarding - Create Account & Sign in.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color _darkBlue = Color(0xFF0D1B2A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Image.asset(
                ImagePath.appLogo,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                'Your Personalized adaptive fitness companion',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
              const Spacer(flex: 3),
              CustomButton(
                onPressed: () => Get.to(() => SignUpScreen()),
                text: 'Create Account',
              ),
              const SizedBox(height: 16),
              _SignInButton(
                onPressed: () => Get.to(() => const SignInScreen()),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
            ],
          ),
        ),
      ),
    );
  }
}


class _SignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SignInButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 2),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Sign in',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
