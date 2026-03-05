import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:disabilitymne/core/common/widget/coustm_button.dart';

/// Goal weight selection — SleekCircularSlider, kg/lbs toggle, Step 3 of 8.
class GoalWeightSelectionScreen extends StatefulWidget {
  const GoalWeightSelectionScreen({super.key});

  @override
  State<GoalWeightSelectionScreen> createState() => _GoalWeightSelectionScreenState();
}

class _GoalWeightSelectionScreenState extends State<GoalWeightSelectionScreen> {
  static const int _totalSteps = 8;
  static const int _currentStep = 3;

  double _currentWeight = 72;
  bool _isKg = true;

  static const double minWeight = 40;
  static const double maxWeight = 150;

  static const Color _darkBlue = Color(0xFF0D1B2A);
  static const Color _accentBlue = Color(0xFF89C9E6);
  static const Color _trackInactive = Color(0xFF6B7280);

  String get unit => _isKg ? 'kg' : 'lbs';

  double get displayValue =>
      _isKg ? _currentWeight : (_currentWeight * 2.20462).roundToDouble();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBlue,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Back (left) | Step 3 of 8 (right) — then progress bar below
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
                      backgroundColor: _trackInactive,
                      valueColor: const AlwaysStoppedAnimation<Color>(_accentBlue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'What is your Goal weight?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // kg / lbs toggle (same style as weight screen)
            Center(
              child: _UnitToggle(
                useKg: _isKg,
                onChanged: (useKg) => setState(() => _isKg = useKg),
              ),
            ),
            const Spacer(),
            // SleekCircularSlider
            SizedBox(
              height: 320,
              child: SleekCircularSlider(
                min: minWeight,
                max: maxWeight,
                initialValue: _currentWeight,
                appearance: CircularSliderAppearance(
                  customWidths: CustomSliderWidths(
                    trackWidth: 18,
                    progressBarWidth: 24,
                    shadowWidth: 30,
                  ),
                  customColors: CustomSliderColors(
                    trackColor: const Color(0xFF1B263B),
                    progressBarColor: _accentBlue,
                    shadowColor: _accentBlue.withValues(alpha: 0.4),
                    dotColor: Colors.white,
                  ),
                  angleRange: 180,
                  startAngle: 180,
                  size: 280,
                  counterClockwise: false,
                ),
                onChange: (value) {
                  setState(() => _currentWeight = value.roundToDouble());
                },
                innerWidget: (value) {
                  final display =
                      _isKg ? value.roundToDouble() : (value * 2.20462).roundToDouble();
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${display.toStringAsFixed(0)} $unit',
                          style: const TextStyle(
                            fontSize: 42,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'goal',
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Scale labels 69–75 (or range around current)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  final val = (_currentWeight - 3 + i).clamp(minWeight, maxWeight).roundToDouble();
                  final isSelected = val.round() == _currentWeight.round();
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        val.toStringAsFixed(0),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white60,
                          fontSize: isSelected ? 18 : 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (i == 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _accentBlue.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${val.toStringAsFixed(0)} $unit',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 24),
              child: CustomButton(
                onPressed: () {
                  // Save goal weight and navigate
                  Get.back();
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

class _UnitToggle extends StatelessWidget {
  final bool useKg;
  final ValueChanged<bool> onChanged;

  const _UnitToggle({required this.useKg, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(label: 'kg', isSelected: useKg, onTap: () => onChanged(true)),
          _Segment(label: 'lbs', isSelected: !useKg, onTap: () => onChanged(false)),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Segment({required this.label, required this.isSelected, required this.onTap});

  static const Color _accentBlue = Color(0xFF89C9E6);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? _accentBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
