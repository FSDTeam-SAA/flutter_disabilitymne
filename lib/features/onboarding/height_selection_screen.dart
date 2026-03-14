import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:disabilitymne/core/common/widget/coustm_button.dart';
import 'package:disabilitymne/features/onboarding/controller/onboarding_controller.dart';

import 'mobility_type_selection_screen.dart';

/// Step 6 of 8: How Tall Are you? — Syncfusion SfLinearGauge vertical, cm/ft toggle.
class HeightSelectionScreen extends StatefulWidget {
  const HeightSelectionScreen({super.key});

  @override
  State<HeightSelectionScreen> createState() => _HeightSelectionScreenState();
}

class _HeightSelectionScreenState extends State<HeightSelectionScreen> {
  static const int _totalSteps = 8;
  static const int _currentStep = 6;
  static const double _minCm = 140;
  static const double _maxCm = 200;

  double _heightCm = 182;
  bool _useCm = true;

  static const Color _darkBlue = Color(0xFF0D1B2A);
  static const Color _accentBlue = Color(0xFF89C9E6);
  static const Color _trackInactive = Color(0xFF6B7280);

  /// Height in feet: e.g. 5.97 -> "5'11" or similar
  String get _heightFtDisplay {
    final totalInches = _heightCm / 2.54;
    final feet = (totalInches / 12).floor();
    final inches = (totalInches % 12).round();
    return "$feet'$inches\"";
  }

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
                  'How Tall Are you?',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _UnitToggle(
                  useCm: _useCm,
                  onChanged: (useCm) => setState(() => _useCm = useCm),
                  accentBlue: _accentBlue,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _HeightLinearGauge(
                    heightCm: _heightCm,
                    useCm: _useCm,
                    minCm: _minCm,
                    maxCm: _maxCm,
                    accentBlue: _accentBlue,
                    darkBlue: _darkBlue,
                    heightFtDisplay: _heightFtDisplay,
                    onHeightChanged: (v) => setState(() => _heightCm = v.clamp(_minCm, _maxCm)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 24),
              child: CustomButton(
                onPressed: () {
                  Get.find<OnboardingController>().setHeight(_heightCm, _useCm ? 'cm' : 'ft');
                  Get.to(() => const MobilityTypeSelectionScreen());
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
  final bool useCm;
  final ValueChanged<bool> onChanged;
  final Color accentBlue;

  const _UnitToggle({
    required this.useCm,
    required this.onChanged,
    required this.accentBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2638),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: 'cm',
            isSelected: useCm,
            accentBlue: accentBlue,
            onTap: () => onChanged(true),
          ),
          _Segment(
            label: 'ft',
            isSelected: !useCm,
            accentBlue: accentBlue,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color accentBlue;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.isSelected,
    required this.accentBlue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? accentBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }
}

/// Value bubble: light blue/teal background (matches toggle & ruler), white bold text.
class _HeightValueBubble extends StatelessWidget {
  final String text;
  final Color accentBlue;

  const _HeightValueBubble({required this.text, required this.accentBlue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        color: accentBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Vertical height ruler using SfLinearGauge — scale on right, value bubble on left.
class _HeightLinearGauge extends StatelessWidget {
  final double heightCm;
  final bool useCm;
  final double minCm;
  final double maxCm;
  final Color accentBlue;
  final Color darkBlue;
  final String heightFtDisplay;
  final ValueChanged<double> onHeightChanged;

  const _HeightLinearGauge({
    required this.heightCm,
    required this.useCm,
    required this.minCm,
    required this.maxCm,
    required this.accentBlue,
    required this.darkBlue,
    required this.heightFtDisplay,
    required this.onHeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = useCm ? '${heightCm.round()} cm' : heightFtDisplay;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SfLinearGauge(
        minimum: minCm,
        maximum: maxCm,
        interval: 5,
        minorTicksPerInterval: 4,
        orientation: LinearGaugeOrientation.vertical,
        showLabels: true,
        showTicks: true,
        showAxisTrack: false,
        animateAxis: false,
        maximumLabels: 20,
        labelPosition: LinearLabelPosition.outside,
        tickPosition: LinearElementPosition.outside,
        labelOffset: 8,
        axisLabelStyle: TextStyle(
          color: accentBlue,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        majorTickStyle: LinearTickStyle(
          color: accentBlue,
          length: 14,
          thickness: 2,
        ),
        minorTickStyle: LinearTickStyle(
          color: accentBlue.withValues(alpha: 0.5),
          length: 7,
          thickness: 1,
        ),
        markerPointers: <LinearMarkerPointer>[
          LinearWidgetPointer(
            value: heightCm,
            position: LinearElementPosition.outside,
            offset: 16,
            markerAlignment: LinearMarkerAlignment.center,
            enableAnimation: false,
            onChanged: (value) => onHeightChanged(value),
            child: _HeightValueBubble(text: displayText, accentBlue: accentBlue),
          ),
        ],
      ),
    );
  }
}
