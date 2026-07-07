import 'package:disabilitymne/core/common/widget/coustm_button.dart';
import 'package:disabilitymne/core/image_path.dart';
import 'package:disabilitymne/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:disabilitymne/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:disabilitymne/features/profile/presentation/help_support_screen.dart';
import 'package:disabilitymne/features/profile/presentation/privacy_legal_screen.dart';
import 'package:disabilitymne/features/profile/presentation/terms_condition_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Profile tab for guest users — sign in / sign up without forcing registration.
class GuestProfileScreen extends StatelessWidget {
  const GuestProfileScreen({super.key});

  static const Color _cardBlue = Color(0xFF1A233A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundImage(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Image.asset(
                  ImagePath.appLogo,
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Browse as Guest',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore programs, recipes, and calculators for free. Sign in anytime for personalized workouts and progress tracking.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Create Account',
                  onPressed: () => Get.to(() => SignUpScreen()),
                ),
                const SizedBox(height: 14),
                _OutlinedButton(
                  text: 'Sign in',
                  onPressed: () => Get.to(() => const SignInScreen()),
                ),
                const SizedBox(height: 32),
                _GuestMenuTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () => Get.to(() => HelpSupportScreen()),
                ),
                _GuestMenuTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => Get.to(() => PrivacyLegalScreen()),
                ),
                _GuestMenuTile(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: () => Get.to(() => TermsConditionScreen()),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 120),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _OutlinedButton({required this.text, required this.onPressed});

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
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _GuestMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _GuestMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: GuestProfileScreen._cardBlue,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white70, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white54),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
