import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/common/widget/coustm_button.dart';

/// Step 3 of 8: How Much Do You Weigh? — kg/lbs toggle, weight ruler, pointer, white circle.
class WeightSelectionScreen extends StatefulWidget {
  const WeightSelectionScreen({super.key});

  @override
  State<WeightSelectionScreen> createState() => _WeightSelectionScreenState();
}

class _WeightSelectionScreenState extends State<WeightSelectionScreen> {
  static const int _totalSteps = 8;
  static const int _currentStep = 3;
  static const int _minWeightKg = 40;
  static const int _maxWeightKg = 150;

  int _weightKg = 72;
  bool _isKg = true;

  static const Color _darkBlue = Color(0xFF0D1B2A);
  static const Color _accentBlue = Color(0xFF89C9E6);
  static const Color _mediumBlue = Color(0xFF4D7EA9);
  static const Color _trackInactive = Color(0xFF6B7280);
  static const Color _selectedTextDark = Color(0xFF1A2A3D);
  static const Color _titleDarkBlue = Color(0xFF2C3E5A);
  static const Color _numberLightGrey = Color(0xFFB0B8C4);

  int get _weightLbs => (_weightKg * 2.205).round();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBlue,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Navigation: Back | progress bar (center) | Step 3 of 8
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
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
                  const SizedBox(width: 12),
                  Expanded(
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
                  const SizedBox(width: 12),
                  Text(
                    'Step $_currentStep of $_totalSteps',
                    style: TextStyle(
                      fontSize: 14,
                      color: _accentBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Title — dark blue, bold (match image)
            Center(
              child: Text(
                'How Much Do You Weight?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: _titleDarkBlue,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Unit toggle: kg (left) | blue oval covering selected | lbs (right)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _isKg = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: _isKg ? _accentBlue : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'kg',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _isKg ? Colors.white : _numberLightGrey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _isKg = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: !_isKg ? _accentBlue : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'lbs',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: !_isKg ? Colors.white : _numberLightGrey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Weight selector: semi-circular medium blue with dark cutout + arc numbers + pointer + circle
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Semi-circular medium blue area with curved bottom cutout (dark blue shows through)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 120,
                    child: CustomPaint(
                      painter: _SemiCircleCutoutPainter(
                        fillColor: _mediumBlue,
                        cutoutColor: _darkBlue,
                      ),
                    ),
                  ),
                  // Numbers along arc (light grey) + selected in white bubble + large triangle + white circle
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Numbers in arc (69, 70, 71, [72 kg], 73, 74, 75) — light grey along arc, center in white bubble
                      SizedBox(
                        height: 52,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: List.generate(7, (i) {
                            final v = _weightKg - 3 + i;
                            final isCenter = i == 3;
                            if (v < _minWeightKg || v > _maxWeightKg) return const SizedBox(width: 32);
                            final arcOffset = (i - 3) * (i - 3) * -3.0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Transform.translate(
                                offset: Offset(0, arcOffset),
                                child: isCenter
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.2),
                                              blurRadius: 10,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          _isKg ? '$v kg' : '${(v * 2.205).round()} lbs',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: _selectedTextDark,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        _isKg ? '$v' : '${(v * 2.205).round()}',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          color: _numberLightGrey,
                                        ),
                                      ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Large white triangle pointer (pointing up)
                      CustomPaint(
                        size: const Size(36, 22),
                        painter: _TrianglePointerPainter(),
                      ),
                      const SizedBox(height: 16),
                      // Large white circle with weight (dark blue text)
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _isKg ? '$_weightKg kg' : '$_weightLbs lbs',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: _selectedTextDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Slider to change weight
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: _accentBlue,
                            inactiveTrackColor: _trackInactive.withValues(alpha: 0.5),
                            thumbColor: Colors.white,
                            overlayColor: _accentBlue.withValues(alpha: 0.2),
                            trackHeight: 5,
                          ),
                          child: Slider(
                            value: _weightKg.toDouble(),
                            min: _minWeightKg.toDouble(),
                            max: _maxWeightKg.toDouble(),
                            divisions: _maxWeightKg - _minWeightKg,
                            onChanged: (v) => setState(() => _weightKg = v.round()),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ],
              ),
            ),
            // Continue button
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 24),
              child: CustomButton(
                onPressed: () {
                  // TODO: save weight and go to Step 4
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

/// Semi-circular medium blue area with curved bottom cutout (dark blue shows through).
class _SemiCircleCutoutPainter extends CustomPainter {
  final Color fillColor;
  final Color cutoutColor;

  _SemiCircleCutoutPainter({required this.fillColor, required this.cutoutColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.25)
      ..quadraticBezierTo(w * 0.5, -h * 0.15, w, h * 0.25)
      ..lineTo(w, h)
      ..quadraticBezierTo(w * 0.5, h * 0.75, 0, h)
      ..close();
    canvas.drawPath(path, Paint()..color = fillColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrianglePointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
