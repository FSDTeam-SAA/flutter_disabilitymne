import 'dart:math' as math;
import 'package:disabilitymne/features/onboarding/controller/onboarding_controller.dart';
import 'package:disabilitymne/features/onboarding/fitness_goals_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/common/widget/coustm_button.dart';

/// Step 3 of 8: How Much Do You Weight? — Dark blue screen with arc gauge,
/// kg/lbs toggle, highlighted value in white box, triangular needle, Continue button.
class WeightSelectionScreen extends StatefulWidget {
  const WeightSelectionScreen({super.key});

  @override
  State<WeightSelectionScreen> createState() => _WeightSelectionScreenState();
}

class _WeightSelectionScreenState extends State<WeightSelectionScreen> {
  static const int _totalSteps = 8;
  static const int _currentStep = 3;

  double _weightKg = 72.0;
  bool _isKg = true;

  static const double _minKg = 30;
  static const double _maxKg = 200;
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

  static const Color _darkBlue = Color(0xFF1A233D);
  static const Color _accentBlue = Color(0xFF5C9DEC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBlue,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAppBar(),
            const SizedBox(height: 24),
            // Title — left-aligned
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'How Much Do You Weight?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildUnitToggle(),
            const SizedBox(height: 24),
            Expanded(
              child: _WeightGauge(
                valueKg: _weightKg,
                minKg: _minKg,
                maxKg: _maxKg,
                isKg: _isKg,
                accentBlue: _accentBlue,
                onWeightChanged: _setWeight,
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
                  Get.find<OnboardingController>().setWeight(_weightKg, _isKg ? 'kg' : 'lbs');
                  Get.to(() => FitnessGoals());
                },
                text: 'Continue',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _currentStep / _totalSteps,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(_accentBlue),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Step $_currentStep of $_totalSteps',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _toggleOption('kg', _isKg),
          const SizedBox(width: 8),
          _toggleOption('lbs', !_isKg),
        ],
      ),
    );
  }

  Widget _toggleOption(String label, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _isKg = (label == 'kg')),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _accentBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: selected ? null : Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white,
            fontSize: 16,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Arc-shaped gauge: light blue arc, weight labels along top, highlighted value in white box,
/// white triangular needle, white circle with value below.
class _WeightGauge extends StatefulWidget {
  final double valueKg;
  final double minKg;
  final double maxKg;
  final bool isKg;
  final Color accentBlue;
  final ValueChanged<double> onWeightChanged;

  const _WeightGauge({
    required this.valueKg,
    required this.minKg,
    required this.maxKg,
    required this.isKg,
    required this.accentBlue,
    required this.onWeightChanged,
  });

  @override
  State<_WeightGauge> createState() => _WeightGaugeState();
}

class _WeightGaugeState extends State<_WeightGauge> {
  double? _dragValueKg;
  double get _effectiveValue => _dragValueKg ?? widget.valueKg;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: h),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _GaugeContent(
                valueKg: _effectiveValue,
                minKg: widget.minKg,
                maxKg: widget.maxKg,
                isKg: widget.isKg,
                accentBlue: widget.accentBlue,
                width: w - 32,
                onPanStart: () => setState(() => _dragValueKg = widget.valueKg),
                onPanUpdate: (kg) => setState(() => _dragValueKg = kg),
                onPanEnd: () {
                  if (_dragValueKg != null) {
                    widget.onWeightChanged(_dragValueKg!);
                    setState(() => _dragValueKg = null);
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GaugeContent extends StatelessWidget {
  final double valueKg;
  final double minKg;
  final double maxKg;
  final bool isKg;
  final Color accentBlue;
  final double width;
  final VoidCallback onPanStart;
  final ValueChanged<double> onPanUpdate;
  final VoidCallback onPanEnd;

  const _GaugeContent({
    required this.valueKg,
    required this.minKg,
    required this.maxKg,
    required this.isKg,
    required this.accentBlue,
    required this.width,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  double get _displayValue => isKg ? valueKg : valueKg * 2.20462;
  double get _displayMin => isKg ? minKg : minKg * 2.20462;
  double get _displayMax => isKg ? maxKg : maxKg * 2.20462;
  String get _unit => isKg ? 'kg' : 'lbs';

  @override
  Widget build(BuildContext context) {
    final rounded = _displayValue.roundToDouble().clamp(_displayMin, _displayMax);
    final radius = width * 0.45;
    final centerX = width / 2;
    final centerY = width * 0.68;
    const startAngle = math.pi;
    const sweepAngle = math.pi;

    return GestureDetector(
      onPanStart: (_) => onPanStart(),
      onPanUpdate: (d) {
        final dx = d.localPosition.dx - centerX;
        final dy = centerY - d.localPosition.dy;
        double angle = math.atan2(dy, dx);
        if (angle < 0) angle += 2 * math.pi;
        // Screen: right=0, top=pi/2, left=pi. Arc: left=0, top=0.5, right=1.
        double t = 1 - (angle / math.pi);
        t = t.clamp(0.0, 1.0);
        final displayVal = _displayMin + t * (_displayMax - _displayMin);
        final kg = isKg ? displayVal : displayVal / 2.20462;
        onPanUpdate(kg.clamp(minKg, maxKg));
      },
      onPanEnd: (_) => onPanEnd(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: Size(width, width * 1.05),
        painter: _ArcGaugePainter(
          valueKg: valueKg,
          minKg: minKg,
          maxKg: maxKg,
          isKg: isKg,
          accentBlue: accentBlue,
          centerX: centerX,
          centerY: centerY,
          radius: radius,
          startAngle: startAngle,
          sweepAngle: sweepAngle,
        ),
          ),
          Positioned(
            left: centerX - (width * 0.38) / 2,
            top: centerY - (width * 0.38) / 2,
            child: Container(
              width: width * 0.38,
              height: width * 0.38,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '${rounded.toInt()} $_unit',
                style: const TextStyle(
                  color: Color(0xFF1D2D44),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcGaugePainter extends CustomPainter {
  final double valueKg;
  final double minKg;
  final double maxKg;
  final bool isKg;
  final Color accentBlue;
  final double centerX;
  final double centerY;
  final double radius;
  final double startAngle;
  final double sweepAngle;

  _ArcGaugePainter({
    required this.valueKg,
    required this.minKg,
    required this.maxKg,
    required this.isKg,
    required this.accentBlue,
    required this.centerX,
    required this.centerY,
    required this.radius,
    required this.startAngle,
    required this.sweepAngle,
  });

  double get _displayValue => isKg ? valueKg : valueKg * 2.20462;
  double get _displayMin => isKg ? minKg : minKg * 2.20462;
  double get _displayMax => isKg ? maxKg : maxKg * 2.20462;
  String get _unit => isKg ? 'kg' : 'lbs';

  @override
  void paint(Canvas canvas, Size size) {
    // Arc background (light blue semicircle)
    final arcRect = Rect.fromCircle(center: Offset(centerX, centerY), radius: radius);
    final arcPaint = Paint()
      ..color = accentBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arcRect, startAngle, sweepAngle, false, arcPaint);

    // Weight labels along the top of the arc (69–75 range around current)
    final centerDisplay = _displayValue.roundToDouble();
    final low = (centerDisplay - 3).toInt().clamp(_displayMin.toInt(), _displayMax.toInt());
    final high = (centerDisplay + 3).toInt().clamp(_displayMin.toInt(), _displayMax.toInt());
    final labelRadius = radius + size.width * 0.06;

    for (int v = low; v <= high; v++) {
      final val = v.toDouble();
      final t = (val - _displayMin) / (_displayMax - _displayMin);
      final angle = startAngle + t * sweepAngle;
      final x = centerX + labelRadius * math.cos(angle);
      final y = centerY + labelRadius * math.sin(angle);
      final isHighlight = (v - _displayValue).abs() < 0.5;
      final text = isHighlight ? '$v $_unit' : '$v';
      final textStyle = TextStyle(
        color: isHighlight ? const Color(0xFF1D2D44) : Colors.white,
        fontSize: isHighlight ? 16 : 14,
        fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
      );
      final tp = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      if (isHighlight) {
        // Selected value: horizontal white box with drop shadow (like reference image)
        final boxW = tp.width + 24;
        final boxH = tp.height + 12;
        final boxR = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: boxW, height: boxH),
          const Radius.circular(10),
        );
        final boxPath = Path()..addRRect(boxR);
        canvas.drawShadow(
          boxPath,
          Colors.black38,
          8,
          true,
        );
        canvas.drawRRect(
          boxR,
          Paint()..color = Colors.white,
        );
        canvas.drawRRect(
          boxR,
          Paint()
            ..color = Colors.black12
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
        tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
      } else {
        // Other labels: rotated 90° tangent to the arc
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(angle + math.pi / 2);
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
        canvas.restore();
      }
    }

    // White triangular needle from arc center to tip on arc
    final needleAngle = startAngle + ((_displayValue - _displayMin) / (_displayMax - _displayMin)) * sweepAngle;
    final needleLength = radius * 0.92;
    final needleTipX = centerX + needleLength * math.cos(needleAngle);
    final needleTipY = centerY + needleLength * math.sin(needleAngle);
    const needleWidth = 32.0;
    final perp = needleAngle + math.pi / 2;
    final path = Path()
      ..moveTo(needleTipX, needleTipY)
      ..lineTo(
        centerX + needleWidth / 2 * math.cos(perp),
        centerY + needleWidth / 2 * math.sin(perp),
      )
      ..lineTo(
        centerX - needleWidth / 2 * math.cos(perp),
        centerY - needleWidth / 2 * math.sin(perp),
      )
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _ArcGaugePainter old) =>
      old.valueKg != valueKg || old.isKg != isKg;
}

typedef GoalWeightScreen = WeightSelectionScreen;
