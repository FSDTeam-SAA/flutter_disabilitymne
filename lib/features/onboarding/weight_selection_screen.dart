import 'dart:math' as math;
import 'package:disabilitymne/features/onboarding/fitness_goals_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/common/widget/coustm_button.dart';

/// Step 3 of 8: How Much Do You Weight? — Blue semicircular gauge design.
/// Configurable min/max, drag needle, snap to 0.1 kg, +/- buttons, haptic, light/dark.
class WeightSelectionScreen extends StatefulWidget {
  const WeightSelectionScreen({super.key});

  @override
  State<WeightSelectionScreen> createState() => _WeightSelectionScreenState();
}

class _WeightSelectionScreenState extends State<WeightSelectionScreen> {
  static const int _totalSteps = 8;
  static const int _currentStep = 3;

  /// Weight in kg (internal); display in kg or lbs.
  double _weightKg = 72.0;
  bool _isKg = true;

  /// Configurable range (kg).
  static const double _minKg = 30;
  static const double _maxKg = 200;

  /// Snap step and last snapped value for haptic.
  static const double _snapStepKg = 0.5;
  double _lastSnappedKg = 72.0;

  void _setWeight(double kg) {
    final clamped = kg.clamp(_minKg, _maxKg);
    if ((clamped - _lastSnappedKg).abs() >= _snapStepKg) {
      HapticFeedback.selectionClick();
      _lastSnappedKg = (clamped / _snapStepKg).round() * _snapStepKg;
    }
    setState(() => _weightKg = clamped);
  }

  static const Color _darkBlue = Color(0xFF0D1B2A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBlue,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'How Much Do You Weight?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: _UnitToggle(
                isKg: _isKg,
                onChanged: (v) => setState(() => _isKg = v),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final gaugeHeight = constraints.maxHeight * 0.58;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SemicircularGauge(
                      valueKg: _weightKg,
                      minKg: _minKg,
                      maxKg: _maxKg,
                      isKg: _isKg,
                      height: gaugeHeight,
                      isDark: true,
                      onWeightChanged: _setWeight,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).padding.bottom + 20,
              ),
              child: CustomButton(
                onPressed: () {
                  Get.to(FitnessGoals());
                },
                text: 'Continue',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    SizedBox(width: 6),
                    Text(
                      'Back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Step $_currentStep of $_totalSteps',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _currentStep / _totalSteps,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.8),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF8AC9E7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitToggle extends StatelessWidget {
  final bool isKg;
  final ValueChanged<bool> onChanged;

  const _UnitToggle({required this.isKg, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pill('kg', isKg, () => onChanged(true)),
          _pill('lbs', !isKg, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _pill(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? const Color(0xFF4D7EA9)
                : Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Semicircular gauge: 180° arc, needle from center bottom, ticks, curved labels, +/- buttons.
class _SemicircularGauge extends StatefulWidget {
  final double valueKg;
  final double minKg;
  final double maxKg;
  final bool isKg;
  final double height;
  final bool isDark;
  final ValueChanged<double> onWeightChanged;

  const _SemicircularGauge({
    required this.valueKg,
    required this.minKg,
    required this.maxKg,
    required this.isKg,
    required this.height,
    required this.isDark,
    required this.onWeightChanged,
  });

  @override
  State<_SemicircularGauge> createState() => _SemicircularGaugeState();
}

class _SemicircularGaugeState extends State<_SemicircularGauge> {
  double? _dragValueKg;

  double get _effectiveValue => _dragValueKg ?? widget.valueKg;

  static const double _pivotRadius = 55.0;

  void _onPanStart(DragStartDetails d, double centerX, double centerY) {
    final dx = d.localPosition.dx - centerX;
    final dy = d.localPosition.dy - centerY;
    if (dx * dx + dy * dy <= _pivotRadius * _pivotRadius) return;
    setState(() => _dragValueKg = widget.valueKg);
  }

  void _onPanUpdate(
    DragUpdateDetails d,
    Size size,
    double centerX,
    double centerY,
    double radius,
  ) {
    if (_dragValueKg == null) return;
    final dx = d.localPosition.dx - centerX;
    final dy = centerY - d.localPosition.dy;
    double angle = math.atan2(dy, dx);
    if (angle < 0) angle += 2 * math.pi;
    const radPerKg = math.pi / 20; // Synced with painter
    final centerKg = _effectiveValue;
    final kg = centerKg + (angle - math.pi / 2) / radPerKg;
    setState(() => _dragValueKg = kg.clamp(widget.minKg, widget.maxKg));
  }

  void _onPanEnd(DragEndDetails d) {
    if (_dragValueKg != null) {
      widget.onWeightChanged(_dragValueKg!);
      setState(() => _dragValueKg = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = widget.height;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: w,
              height: h,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onPanStart: (d) {
                        final centerX = w / 2;
                        final centerY = w * 0.75; // Align with painter
                        _onPanStart(d, centerX, centerY);
                      },
                      onPanUpdate: (d) {
                        final centerX = w / 2;
                        final centerY = w * 0.75; // Align with painter
                        final radius = (w / 2) * 0.92;
                        _onPanUpdate(d, Size(w, h), centerX, centerY, radius);
                      },
                      onPanEnd: _onPanEnd,
                      child: CustomPaint(
                        size: Size(w, h),
                        painter: _SemicircularGaugePainter(
                          valueKg: _effectiveValue,
                          minKg: widget.minKg,
                          maxKg: widget.maxKg,
                          isKg: widget.isKg,
                          isDark: widget.isDark,
                        ),
                      ),
                    ),
                  ),
                  Image.asset(
                    "assets/logo/11.png",
                    width: double.infinity,
                    height: h * 0.9,
                    fit: BoxFit.contain,
                  ),
                  // Central Value Circle
                  Positioned(
                    bottom: -90, // Adjust to overlap image correctly
                    left: w / 2 - 60,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${widget.isKg ? _effectiveValue.toStringAsFixed(0) : (_effectiveValue * 2.20462).toStringAsFixed(0)} ${widget._unit}',
                        style: const TextStyle(
                          color: Color(0xFF1D2D44),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 12),
            // _PlusMinusButtons(
            //   onMinus: () => widget.onWeightChanged((widget.valueKg - 0.5).clamp(widget.minKg, widget.maxKg)),
            //   onPlus: () => widget.onWeightChanged((widget.valueKg + 0.5).clamp(widget.minKg, widget.maxKg)),
            //   isDark: widget.isDark,
            // ),
          ],
        );
      },
    );
  }
}

extension on _SemicircularGauge {
  String get _unit => isKg ? 'kg' : 'lbs';
}

/// Paints: bottom-half semicircle arc, optional fill to needle, major/minor ticks, curved labels, needle + pivot.
class _SemicircularGaugePainter extends CustomPainter {
  final double valueKg;
  final double minKg;
  final double maxKg;
  final bool isKg;
  final bool isDark;

  _SemicircularGaugePainter({
    required this.valueKg,
    required this.minKg,
    required this.maxKg,
    required this.isKg,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cx = w / 2;
    final cy = w * 0.75; // Align with Gesture detector

    final textColor = Colors.white;
    final textColorDim = Colors.white.withOpacity(0.5);

    // Labels along the arc
    final textStyle = TextStyle(
      color: textColor,
      fontSize: 24,
      fontWeight: FontWeight.w500,
    );
    final textStyleDim = textStyle.copyWith(color: textColorDim, fontSize: 20);

    final centerValue = isKg ? valueKg : valueKg * 2.20462;
    final displayMin = isKg ? minKg : minKg * 2.20462;
    final displayMax = isKg ? maxKg : maxKg * 2.20462;

    final roundedCenter = centerValue.roundToDouble();

    // Draw numbers on the arc
    const labelRadius = 240.0; // Adjust to fit age.png arc

    for (int i = -3; i <= 3; i++) {
      final val = roundedCenter + i;
      if (val < displayMin || val > displayMax) continue;

      final diff = val - centerValue;
      // Rotation angle: center is vertically up (90 deg), each kg is some angle
      const anglePerUnit = math.pi / 20;
      final angle = math.pi / 2 + diff * anglePerUnit;

      final x = cx + labelRadius * math.cos(angle - math.pi);
      final y = cy + labelRadius * math.sin(angle - math.pi);

      final tp = TextPainter(
        text: TextSpan(
          text: val.toInt().toString(),
          style: (i == 0) ? textStyle : textStyleDim,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(x, y);
      // Rotate text to point outwards or keep upright? Image shows slightly tilted
      canvas.rotate(angle - math.pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // Needle: points to the center (which is the current weight)
    final needlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final needlePath = Path();
    const needleWidth = 60.0;
    const needleLength = 200.0;

    // Vertical needle pointing from cy towards 90 deg up
    needlePath.moveTo(cx, cy - needleLength); // Tip
    needlePath.lineTo(cx - needleWidth / 2, cy - 20); // Base left
    needlePath.lineTo(cx + needleWidth / 2, cy - 20); // Base right
    needlePath.close();

    canvas.drawPath(needlePath, needlePaint);
  }

  @override
  bool shouldRepaint(covariant _SemicircularGaugePainter old) =>
      old.valueKg != valueKg ||
      old.minKg != minKg ||
      old.maxKg != maxKg ||
      old.isKg != isKg ||
      old.isDark != isDark;
}

/// Alias for navigation from gender selection (Step 1 → Step 3).
typedef GoalWeightScreen = WeightSelectionScreen;
