import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/common/widget/coustm_button.dart';
import 'package:disabilitymne/core/image_path.dart';
import 'package:disabilitymne/features/onboarding/age_selection_screen.dart';

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

  static const Color _darkBlue = Color(0xFF0D1B2A);
  static const Color _radioSelected = Color(0xFF89C9E6);
  static const Color _radioUnselected = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBlue,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Navigation: Back | progress bar (center) | Step 1 of 8
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _currentStep / _totalSteps,
                        minHeight: 6,
                        backgroundColor: _radioUnselected.withValues(alpha: 0.5),
                        valueColor: const AlwaysStoppedAnimation<Color>(_radioSelected),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Step $_currentStep of $_totalSteps',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Title — centered
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
            // Gender cards — two large cards almost filling width
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 120),
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
                    const SizedBox(width: 16),
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
            // Continue button
          const SizedBox(height: 44),
          
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 24),
              child: CustomButton(
                onPressed: () => Get.to(() => const AgeSelectionScreen()),
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

  static const Color _cardBorder = Color(0xFF4A5568);
  static const Color _selectedBorder = Color(0xFF89C9E6);
  static const Color _selectedFill = Color(0xFF1A2A3D);
  static const Color _radioSelected = Color(0xFF89C9E6);
  static const Color _radioUnselected = Color(0xFF6B7280);

  static const Color _radioInnerUnselected = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? _selectedFill : const Color(0xFF0D1B2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _selectedBorder : _cardBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            // Radio at top-right: selected = blue outline + solid blue inner; unselected = grey outline + solid light grey inner
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 22,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? _radioSelected : _radioUnselected,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? _radioSelected : _radioInnerUnselected,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Image.asset(
                  assetPath,

                  height: 100,
                  width: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(Icons.person, size: 80, color: Colors.white54),
                ),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
