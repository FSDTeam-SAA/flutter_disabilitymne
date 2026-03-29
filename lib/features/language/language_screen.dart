import 'package:disabilitymne/core/common/widget/coustm_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/app/controller/language_controller.dart';
import 'package:disabilitymne/features/onboarding/onboarding_screen.dart';
import 'package:disabilitymne/core/theme/app_colors.dart';
import 'package:disabilitymne/core/image_path.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LanguageController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset(
                ImagePath.languageIcon,
                height: 64,
                width: 64,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose Language',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your preferred language',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 40),
              Obx(
                () => _LanguageCard(
                  flag: '🇬🇧',
                  title: 'English',
                  subtitle: 'Continue in English',
                  isSelected: controller.isSelected(AppLanguage.english),
                  onTap: () => controller.selectLanguage(AppLanguage.english),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => _LanguageCard(
                  flag: '🇷🇸',
                  title: 'Serbian',
                  subtitle: 'Continue in Serbian',
                  isSelected: controller.isSelected(AppLanguage.serbian),
                  onTap: () => controller.selectLanguage(AppLanguage.serbian),
                ),
              ),
              const Spacer(),
              CustomButton(
                text: 'Next',
                onPressed: () => Get.offAll(() => const OnboardingScreen()),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String flag;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.flag,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2C3D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.gradientButtonStart
                : Colors.white.withValues(alpha:  0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.gradientButtonStart
                      : Colors.white.withOpacity(0.5),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF89C9E6) : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
