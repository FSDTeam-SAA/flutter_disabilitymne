import 'package:disabilitymne/features/onboarding/age_selection_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/common/widget/coustm_button.dart';
import 'package:disabilitymne/core/image_path.dart';

/// Step 1 of 8: Choose Your Gender — matches design with Male/Female cards and illustrations.
class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  static const int _totalSteps = 8;
  static const int _currentStep = 1;

  String? _selectedGender; // 'male' | 'female'

  @override
  void initState() {
    super.initState();
    _selectedGender = 'male';
  }

  static const Color _accentBlue = Color(0xFF89C9E6);
  static const Color _radioUnselected = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff162135),
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
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Get.back(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.back, color: _accentBlue, size: 26),
                            const SizedBox(width: 6),
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
                      backgroundColor: _radioUnselected.withValues(alpha: 0.5),
                      valueColor: const AlwaysStoppedAnimation<Color>(_accentBlue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Choose Your Gender',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _GenderCard(
                        label: 'Male',
                        assetPath: ImagePath.genderMale,
                        isSelected: _selectedGender == 'male',
                        onTap: () => setState(() => _selectedGender = 'male'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GenderCard(
                        label: 'Female',
                        assetPath: ImagePath.genderFemale,
                        isSelected: _selectedGender == 'female',
                        onTap: () => setState(() => _selectedGender = 'female'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 24),
              child: CustomButton(
                onPressed: () => Get.to(() => const AgeSelectionScreen()),
                // onPressed: () =>Get.to( GoalWeightScreen()),
                // onPressed: () => Get.to(() => const MainShellScreen(initialIndex: 4)),
                text: 'Continue',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final String assetPath;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.assetPath,
    required this.isSelected,
    required this.onTap,
  });

  static const Color _accentBlue = Color(0xFF89C9E6);
  static const Color _selectedBorder = Color(0xFF89C9E6);
  static const Color _radioUnselectedOutline = Color(0xFF9CA3AF);

  static const double _radius = 16;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xff162135),
          borderRadius: BorderRadius.circular(_radius),
          border: isSelected ? Border.all(color: _selectedBorder, width: 2) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _accentBlue.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius - 1),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Illustration — no black; use card background behind image
              Positioned(
                left: 12,
                top: 40,
                right: 12,
                bottom: 52,
                child: Container(
                  color: Color(0xff162135),
                  alignment: Alignment.center,
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _,_) => Icon(Icons.person, size: 80, color: Colors.white54),
                  ),
                ),
              ),
              // Label at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Radio: selected = filled light blue circle; unselected = empty light grey outline
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? _accentBlue : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? _accentBlue : _radioUnselectedOutline,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
