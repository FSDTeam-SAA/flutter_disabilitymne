import 'package:flutter/material.dart';

class CalculatorsScreen extends StatelessWidget {
  const CalculatorsScreen({super.key});

  // Linear gradient: #70A9D2 → #4888B5 → #1A273D (image design)
  static const Color _screenBgTop = Color(0xFF70A9D2);
  static const Color _screenBgMid = Color(0xFF4888B5);
  static const Color _screenBgBottom = Color(0xFF1A273D);
  // Card/entry background (image: #20324E)
  static const Color _cardBg = Color(0xFF20324E);
  static const Color _macroBg = Color(0xFF20324E);
  static const Color _chipBg = Color(0xFF20324E);
  // Progress bar track, add button, nav (image)
  static const Color _progressBarBg = Color(0xFF384C6A);
  static const Color _addButtonBg = Color(0xFF2C4263);
  static const Color _subText = Color(0xFFA3A9B6);
  static const Color _cardBorder = Color(0x3385C4E2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _screenBgTop,
              _screenBgMid,
              _screenBgBottom,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCard(),
                      const SizedBox(height: 18),
                      _buildMacroRow(),
                      const SizedBox(height: 22),
                      _buildMealsLoggedHeader(),
                      const SizedBox(height: 12),
                      _buildMealCard(
                        title: 'Breakfast',
                        subtitle: 'Recommended: 656 - 918 kcal',
                      ),
                      const SizedBox(height: 10),
                      _buildMealCard(
                        title: 'Lunch',
                        subtitle: 'Recommended: 787 - 1049 kcal',
                      ),
                      const SizedBox(height: 10),
                      _buildMealCard(
                        title: 'Dinner',
                        subtitle: 'Recommended: 1023 - 1338 kcal',
                      ),
                      const SizedBox(height: 10),
                      _buildMealCard(
                        title: 'Snack',
                        subtitle: 'Recommended: 656 - 918 kcal',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'TODAY, 23 FEB',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Calories Calculator',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    // Image: track #A3A9B6, fill #76C1E7
    const Color trackColor = Color(0xFFA3A9B6);
    const Color progressBlue = Color(0xFF76C1E7);
    const double goalKcal = 1792;
    const double eaten = 72;
    const double burned = 0;
    final double remaining = (goalKcal - eaten + burned).clamp(0, double.infinity);
    final double progressValue = goalKcal > 0 ? eaten / goalKcal : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Eaten
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Eaten',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                eaten.toInt().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Center: Circular progress + Remaining, 1720, Goal 1792 Kcal
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Track (light gray) + progress arc (light blue)
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CustomPaint(
                    painter: _CircleProgressPainter(
                      progress: progressValue,
                      trackColor: trackColor,
                      progressColor: progressBlue,
                      strokeWidth: 12,
                    ),
                  ),
                ),
                // Center text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Remaining',
                      style: TextStyle(
                        color: _subText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      remaining.toInt().toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Goal ${goalKcal.toInt()} Kcal',
                      style: const TextStyle(
                        color: _subText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Right: Burned
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Burned',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                burned.toInt().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMacroCard(
            title: 'Carbs',
            consumed: 17,
            total: 328,
            barColor: const Color(0xFF76C1E7),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMacroCard(
            title: 'Protein',
            consumed: 1,
            total: 131,
            barColor: const Color(0xFF30C66B),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMacroCard(
            title: 'Fat',
            consumed: 0,
            total: 87,
            barColor: const Color(0xFF3096E8),
          ),
        ),
      ],
    );
  }

  Widget _buildMacroCard({
    required String title,
    required int consumed,
    required int total,
    required Color barColor,
  }) {
    final progress = total == 0 ? 0.0 : consumed / total;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: _macroBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$consumed / ${total}g',
            style: const TextStyle(
              color: _subText,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: _progressBarBg,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsLoggedHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meals Logged',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _chipBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _cardBorder, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.local_fire_department_outlined,
                color: Colors.orangeAccent,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'Stay within your daily calorie goal',
                style: TextStyle(
                  color: _subText,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard({
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.4),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _subText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _addButtonBg,
              border: Border.all(color: _cardBorder, width: 1),
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a full circle track (light gray) and a progress arc (light blue) from top clockwise.
class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _CircleProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    // 1) Full track circle – light gray
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // 2) Progress arc – light blue, from top (-π/2) clockwise
    if (progress > 0) {
      final sweepAngle = 2 * 3.14159265359 * progress.clamp(0.0, 1.0);
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159265359 / 2, // start from top
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

