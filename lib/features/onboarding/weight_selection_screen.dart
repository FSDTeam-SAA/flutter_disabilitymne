import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/common/widget/coustm_button.dart';

/// Step 3 of 8: How Much Do You Weight? — Container + Stack design per image.
class GoalWeightScreen extends StatefulWidget {
  const GoalWeightScreen({super.key});

  @override
  State<GoalWeightScreen> createState() => _GoalWeightScreenState();
}

class _GoalWeightScreenState extends State<GoalWeightScreen> {
  static const int _totalSteps = 8;
  static const int _currentStep = 3;

  int _weightKg = 72;
  bool _isKg = true;

  static const Color _darkNavy = Color(0xFF0D1B2A);
  static const Color _accentBlue = Color(0xFF89C9E6);
  static const Color _trackGrey = Color(0xFF6B7280);

  String get _unit => _isKg ? 'kg' : 'lbs';

  double get _displayed =>
      _isKg ? _weightKg.toDouble() : (_weightKg * 2.20462).roundToDouble();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkNavy,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App bar: Back (left) | Step 3 of 8 (right)
            Padding(
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
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
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
                      backgroundColor: _trackGrey.withValues(alpha: 0.5),
                      valueColor: const AlwaysStoppedAnimation<Color>(_accentBlue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'How Much Do You Weight?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // kg / lbs toggle — custom pill (Container + border)
            Center(
              child: _UnitToggle(
                isKg: _isKg,
                onChanged: (kg) => setState(() => _isKg = kg),
              ),
            ),
            const SizedBox(height: 24),
            // Weight selector: Stack with arc, labels, white box, pointer, circle
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _WeightSelector(
                  weightKg: _weightKg,
                  isKg: _isKg,
                  displayText: '${_displayed.toStringAsFixed(0)} $_unit',
                  onWeightChanged: (v) =>
                      setState(() => _weightKg = v.clamp(30, 200)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 24),
              child: CustomButton(
                onPressed: () {},
                text: 'Continue',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom kg/lbs toggle — elongated oval track, blue thumb (Container border).
class _UnitToggle extends StatelessWidget {
  final bool isKg;
  final ValueChanged<bool> onChanged;

  const _UnitToggle({required this.isKg, required this.onChanged});

  static const Color _thumbBlue = Color(0xFF5D9FD9);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => onChanged(true),
            child: Container(
              width: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isKg ? _thumbBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'kg',
                style: TextStyle(
                  color: isKg ? Colors.white : Colors.white70,
                  fontSize: 16,
                  fontWeight: isKg ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(false),
            child: Container(
              width: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: !isKg ? _thumbBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'lbs',
                style: TextStyle(
                  color: !isKg ? Colors.white : Colors.white70,
                  fontSize: 16,
                  fontWeight: !isKg ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stack: blue arc, number labels, white "72 kg" box, white triangle, white circle.
class _WeightSelector extends StatelessWidget {
  final int weightKg;
  final bool isKg;
  final String displayText;
  final ValueChanged<int> onWeightChanged;

  const _WeightSelector({
    required this.weightKg,
    required this.isKg,
    required this.displayText,
    required this.onWeightChanged,
  });

  static const Color _arcBlue = Color(0xFF5D9FD9);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            // 1. Light blue semi-circular arc (Container uses CustomPaint)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CustomPaint(
                  size: Size(w, h),
                  painter: _ArcBackgroundPainter(color: _arcBlue),
                ),
              ),
            ),
            // 2. Number labels along upper curve (69–75)
            Positioned(
              left: 12,
              right: 12,
              top: 16,
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  final value = weightKg - 3 + i;
                  if (value < 30 || value > 200) return const SizedBox.shrink();
                  final isSelected = value == weightKg;
                  return GestureDetector(
                    onTap: () => onWeightChanged(value),
                    child: Text(
                      value == weightKg && isKg ? '$value kg' : '$value',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // 3. White Container — "72 kg" highlight (rounded, border)
            Positioned(
              top: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.08),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  displayText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            // 4. White triangle pointer
            Positioned(
              bottom: 78,
              child: CustomPaint(
                size: const Size(44, 42),
                painter: _TrianglePointerPainter(),
              ),
            ),
            // 5. White circular Container — "72 kg" (border + shadow)
            Positioned(
              bottom: 0,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: _arcBlue.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  displayText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Light blue arc: curved top, flat bottom.
class _ArcBackgroundPainter extends CustomPainter {
  final Color color;

  _ArcBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    path.moveTo(w * 0.05, h);
    path.lineTo(w * 0.05, h * 0.28);
    path.quadraticBezierTo(w * 0.5, -h * 0.02, w * 0.95, h * 0.28);
    path.lineTo(w * 0.95, h);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrianglePointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
