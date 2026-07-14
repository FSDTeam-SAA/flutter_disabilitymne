import 'package:disabilitymne/core/common/widget/coustm_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/features/onboarding/choose_plan_screen.dart';
import 'package:disabilitymne/features/onboarding/controller/onboarding_controller.dart';

/// Step 8 of 8: Fitness experience — Beginner / Intermediate / Advanced cards.
class FitnessExperienceScreen extends StatefulWidget {
  const FitnessExperienceScreen({super.key});

  @override
  State<FitnessExperienceScreen> createState() => _FitnessExperienceScreenState();
}

class _FitnessExperienceScreenState extends State<FitnessExperienceScreen> {
  static const int _totalSteps = 8;
  static const int _currentStep = 8;

  int? _selectedIndex;

  /// Match image: dark blue background (#1A2B3A).
  static const Color _darkBlue = Color(0xFF1A2B3A);
  /// Light blue for progress bar and back chevron.
  static const Color _accentBlue = Color(0xFF4FC3F7);
  static const Color _trackInactive = Color(0xFF6B7280);

  static const List<({String title, String subtitle})> _options = [
    (title: 'Beginner', subtitle: "New to exercise let's start gently"),
    (title: 'Intermediate', subtitle: 'Some experience - ready to level up'),
    (title: 'Advanced', subtitle: 'Regular exerciser - push the limits'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBlue,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chevron_left, color: _accentBlue, size: 28),
                            const SizedBox(width: 4),
                            Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: _accentBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Step $_currentStep of $_totalSteps',
                        style: TextStyle(
                          fontSize: 14,
                          color: _accentBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _currentStep / _totalSteps,
                      minHeight: 6,
                      backgroundColor: _trackInactive.withValues(alpha: 0.5),
                      valueColor: const AlwaysStoppedAnimation<Color>(_accentBlue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Fitness experience',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Selection cards
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ...List.generate(_options.length, (index) {
                    final option = _options[index];
                    final isSelected = _selectedIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FitnessExperienceCard(
                        title: option.title,
                        subtitle: option.subtitle,
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedIndex = index),
                      ),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 24),
              child: CustomButton(
                onPressed: () async {
                  if (_selectedIndex == null) return;
                  final c = Get.find<OnboardingController>();
                  c.setFitnessExperience(_selectedIndex);
                  final ok = await c.submitOnboarding();
                  if (ok) Get.to(() => const ChoosePlanScreen());
                },
                text: 'Continue',
              ),
            ),
       
          ],
        ),
      ),
    );
  }
}

class _FitnessExperienceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _FitnessExperienceCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  /// Selected: 20% fill #34C759 (hex #34C75933 = 0x33 alpha + 0x34C759).
  static const Color _selectedFill = Color(0x3334C759);
  /// Selected: 100% border #34C759.
  static const Color _selectedBorder = Color(0xFF34C759);

  /// Unselected: dark blue-gray / slate blue with subtle depth.
  static const Color _unselectedTop = Color(0xFF2C3E50);
  static const Color _unselectedBottom = Color(0xFF1E2A38);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? _selectedFill : null,
          gradient: isSelected
              ? null
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_unselectedTop, _unselectedBottom],
                ),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: _selectedBorder, width: 1.0)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.25 : 0.15),
              blurRadius: isSelected ? 8 : 4,
              offset: Offset(0, isSelected ? 3 : 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
