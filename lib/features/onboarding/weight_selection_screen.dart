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
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'How Much Do You Weight?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(child: _UnitToggle(isKg: _isKg, onChanged: (v) => setState(() => _isKg = v))),
            const SizedBox(height: 12),
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
              padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 20),
              child: CustomButton(onPressed: () {
                  Get.to(FitnessGoals());


              }, text: 'Continue'),
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
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _currentStep / _totalSteps,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4D7EA9)),
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

  static const Color _blue = Color(0xFF4D7EA9);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
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
        width: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF2C5282),
            fontSize: 16,
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

  void _onPanUpdate(DragUpdateDetails d, Size size, double centerX, double centerY, double radius) {
    if (_dragValueKg == null) return;
    final dx = d.localPosition.dx - centerX;
    final dy = centerY - d.localPosition.dy;
    double angle = math.atan2(dy, dx);
    if (angle < 0) angle += 2 * math.pi;
    const radPerKg = math.pi / 10;
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
                        final centerY = h;
                        _onPanStart(d, centerX, centerY);
                      },
                      onPanUpdate: (d) {
                        final centerX = w / 2;
                        final centerY = h;
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
                  // Smaller bottom capsule (110×110) with _ValueDisplay as child
                  Positioned(
                    left: w / 2 - 55,
                    bottom: -55,
                    width: 110,
                    height: 110,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isDark ? Colors.white : Colors.grey.shade100,
                        border: Border.all(
                          color: widget.isDark ? Colors.black26 : Colors.grey.shade600,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: _ValueDisplay(
                        value: widget.isKg ? _effectiveValue : _effectiveValue * 2.20462,
                        unit: widget._unit,
                        isDark: widget.isDark,
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

/// Large value display (48–72pt equivalent).
class _ValueDisplay extends StatelessWidget {
  final double value;
  final String unit;
  final bool isDark;

  const _ValueDisplay({required this.value, required this.unit, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final display = value >= 100
        ? value.toStringAsFixed(1)
        : value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        // color: isDark ? Colors.white : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        // border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withValues(alpha: 0.1),
        //     blurRadius: 12,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            display,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.black87 : Colors.grey.shade900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              unit,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.black54 : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlusMinusButtons extends StatelessWidget {
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final bool isDark;

  const _PlusMinusButtons({required this.onMinus, required this.onPlus, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RoundButton(icon: Icons.remove, onPressed: onMinus, isDark: isDark),
        const SizedBox(width: 32),
        _RoundButton(icon: Icons.add, onPressed: onPlus, isDark: isDark),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDark;

  const _RoundButton({required this.icon, required this.onPressed, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(icon, color: isDark ? Colors.white : Colors.grey.shade800, size: 28),
        ),
      ),
    );
  }
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

  static const double _pi = math.pi;

  /// Full-scale angle (used only for any full-scale logic).
  double _valueToAngle(double kg) {
    final t = (kg - minKg) / (maxKg - minKg);
    return _pi * (1 - t);
  }

  /// Arc: higher values left, lower right (swipe left = increase, swipe right = decrease).
  /// More spacing (π/10) so labels don’t overlap the center pill.
  static const double _radPerKg = _pi / 10;
  double _labelAngle(double kg, double centerKg) {
    return _pi / 2 + _radPerKg * (kg - centerKg);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h;
    final radius = (w / 2) * 0.92;

    final arcColor = const Color(0xFF5D9FD9);
    final trackStroke = const Color(0xFF4A7BA8);
    final needleColor = Colors.white;
    final needleOutline = Colors.black26;
    final textColor = Colors.white;
    final textColorDim = const Color(0xFF9CA3AF);

    final arcRect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    final arcPath = Path()
      ..moveTo(cx - radius, cy)
      ..arcTo(arcRect, _pi, -_pi, false)
      ..lineTo(cx + radius, cy)
      ..close();
    canvas.drawPath(arcPath, Paint()..color = arcColor..style = PaintingStyle.fill);
    canvas.drawPath(arcPath, Paint()..color = trackStroke..style = PaintingStyle.stroke..strokeWidth = 2);

    // Optional: filled “progress” from left (min) to current value
    // final fillPath = Path()
    //   ..moveTo(cx - radius, cy)
    //   ..arcTo(arcRect, _pi, -(valueKg - minKg) / (maxKg - minKg) * _pi, false)
    //   ..lineTo(cx, cy)
    //   ..close();
    // final fillPaint = Paint()
    //   ..shader = LinearGradient(
    //     begin: Alignment.centerLeft,
    //     end: Alignment.centerRight,
    //     colors: [arcColor.withValues(alpha: 0.5), arcColor],
    //   ).createShader(Rect.fromLTWH(0, 0, w, h))
    //   ..style = PaintingStyle.fill;
    // canvas.drawPath(fillPath, fillPaint);

    // Major (every 5) and minor (every 1) ticks
    final majorPaint = Paint()
      ..color = trackStroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final minorPaint = Paint()
      ..color = trackStroke.withValues(alpha: 0.7)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final tickLengthMajor = 12.0;
    final tickLengthMinor = 6.0;
    final labelRadius = radius + 48;

    // for (double kg = minKg; kg <= maxKg; kg += 1) {
    //   final angle = _valueToAngle(kg);
    //   final cos = math.cos(angle);
    //   final sin = math.sin(angle);
    //   final isMajor = (kg - minKg).abs() % 5 < 0.5;
    //   final len = isMajor ? tickLengthMajor : tickLengthMinor;
    //   final paint = isMajor ? majorPaint : minorPaint;
    //   canvas.drawLine(
    //     Offset(cx + (radius - len) * cos, cy - (radius - len) * sin),
    //     Offset(cx + radius * cos, cy - radius * sin),
    //     paint,
    //   );
    // }

    // Labels along a proper circular arc (same radius) so they don’t stack — like reference
    final textStyle = TextStyle(
      color: textColor,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    );
    final textStyleDim = textStyle.copyWith(color: textColorDim, fontWeight: FontWeight.w500, fontSize: 18.0);

    final centerKg = valueKg.roundToDouble().clamp(minKg, maxKg);
    final visibleKg = <double>[];
    for (int i = -3; i <= 3; i++) {
      final k = centerKg + i;
      if (k >= minKg && k <= maxKg) visibleKg.add(k);
    }

    final labelRadiusWithGap = labelRadius + 20;
    // Single radius = labels on a circular arc (not oval), evenly spaced along the curve
    final labelR = labelRadiusWithGap;

    // Center position for selected kg (90° = top of circle)
    final centerX = cx;
    final centerY = cy - labelR;

    // Draw pill first so arc labels are drawn on top and never appear behind it
    final selectedLabel = isKg ? '${valueKg.toStringAsFixed(valueKg.truncateToDouble() == valueKg ? 0 : 1)} kg' : '${(valueKg * 2.20462).toStringAsFixed(1)} lbs';
    final selectedSpan = TextSpan(text: selectedLabel, style: textStyle.copyWith(color: const Color(0xFF1a1a2e)));
    final selectedTp = TextPainter(text: selectedSpan, textDirection: TextDirection.ltr)..layout();
    const padH = 20.0;
    const padV = 8.0;
    final rect = Rect.fromCenter(center: Offset.zero, width: selectedTp.width + padH * 2, height: selectedTp.height + padV * 2);
    final pillRadius = rect.height / 2;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(pillRadius));
    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.save();
    canvas.translate(2, 2);
    canvas.drawRRect(rrect, Paint()..color = Colors.black.withValues(alpha: 0.08));
    canvas.restore();
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFE5E7EB));
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFD1D5DB)..style = PaintingStyle.stroke..strokeWidth = 1);
    selectedTp.paint(canvas, Offset(-selectedTp.width / 2, -selectedTp.height / 2));
    canvas.restore();

    // Arc labels on top so they’re visible; spread across left/right (radPerKg = π/15)
    for (final kg in visibleKg) {
      final isSelected = (kg - valueKg).abs() < 0.6;
      if (isSelected) continue;
      final angle = _labelAngle(kg, valueKg);
      final cos = math.cos(angle);
      final sin = math.sin(angle);
      final x = cx + labelR * cos;
      final y = cy - labelR * sin;
      final label = '${kg.toInt()}';
      final dist = (kg - valueKg).abs();
      final isNear = dist <= 2;
      final span = TextSpan(
        text: label,
        style: isNear ? textStyle : textStyleDim.copyWith(color: textColorDim.withValues(alpha: 0.6)),
      );
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
      final radAngle = -angle + _pi / 2;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(radAngle);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // Needle: fixed at 90° (straight up, center-aligned), not movable
    final needleAngle = _pi / 2;
    final needleLength = radius * 0.88;
    const pivotRadius = 55.0;

    // Needle shadow
    canvas.save();
    canvas.translate(2, 2);
    _drawNeedle(canvas, cx, cy, needleAngle, needleLength, needleOutline.withValues(alpha: 0.4), pivotRadius);
    canvas.restore();

    _drawNeedle(canvas, cx, cy, needleAngle, needleLength, needleColor, pivotRadius);

    // Outline for visibility
    final outlinePaint = Paint()
      ..color = needleOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    _drawNeedlePath(canvas, cx, cy, needleAngle, needleLength, outlinePaint);

    // Pivot circle is drawn as a widget with _ValueDisplay as child (see Stack below)
  }

  void _drawNeedle(Canvas canvas, double cx, double cy, double angle, double length, Color color, double pivotRadius) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    _drawNeedlePath(canvas, cx, cy, angle, length, paint);
  }

  void _drawNeedlePath(Canvas canvas, double cx, double cy, double angle, double length, Paint paint) {
    final cos = math.cos(angle);
    final sin = math.sin(angle);
    final tipX = cx + length * cos;
    final tipY = cy - length * sin;
    // Wider base for easier drag at pivot
    const baseWidth = 48.0;
    final perpX = -sin * baseWidth / 2;
    final perpY = -cos * baseWidth / 2;
    final path = Path()
      ..moveTo(tipX, tipY)
      ..lineTo(cx + perpX, cy + perpY)
      ..lineTo(cx - perpX, cy - perpY)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SemicircularGaugePainter old) =>
      old.valueKg != valueKg || old.minKg != minKg || old.maxKg != maxKg || old.isKg != isKg || old.isDark != isDark;
}

/// Alias for navigation from gender selection (Step 1 → Step 3).
typedef GoalWeightScreen = WeightSelectionScreen;
