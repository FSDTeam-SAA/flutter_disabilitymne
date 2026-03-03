import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/common/widget/coustm_button.dart';
import 'package:disabilitymne/features/onboarding/weight_selection_screen.dart';

/// Step 2 of 8: How Old Are You? — age slider 13–90, matches design.
class AgeSelectionScreen extends StatefulWidget {
  const AgeSelectionScreen({super.key});

  @override
  State<AgeSelectionScreen> createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  static const int _totalSteps = 8;
  static const int _currentStep = 2;
  static const int _minAge = 13;
  static const int _maxAge = 90;

  double _age = 26;

  static const Color _darkBlue = Color(0xFF0D1B2A);
  static const Color _accentBlue = Color(0xFF89C9E6);
  static const Color _trackInactive = Color(0xFF6B7280);

  int get _ageInt => _age.round();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBlue,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Back + Step 2 of 8
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  Text(
                    'Step $_currentStep of $_totalSteps',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _currentStep / _totalSteps,
                  minHeight: 6,
                  backgroundColor: _trackInactive.withValues(alpha: 0.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(_accentBlue),
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'How Old Are You?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Selected age: "26" (blue) + "Years old" (gray)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$_ageInt',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _accentBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Years old',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _accentBlue,
                  inactiveTrackColor: _trackInactive.withValues(alpha: 0.5),
                  thumbColor: Colors.white,
                  overlayColor: _accentBlue.withValues(alpha: 0.2),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: _age,
                  min: _minAge.toDouble(),
                  max: _maxAge.toDouble(),
                  divisions: _maxAge - _minAge,
                  onChanged: (v) => setState(() => _age = v),
                ),
              ),
            ),
            // Min/Max labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_minAge Years',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    '$_maxAge Years',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Continue button
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 24),
              child: CustomButton(
                onPressed: () => Get.to(() => const WeightSelectionScreen()),
                text: 'Continue',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
