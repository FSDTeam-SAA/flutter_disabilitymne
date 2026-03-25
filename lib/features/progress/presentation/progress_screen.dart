import 'dart:math' as math;

import 'package:disabilitymne/features/progress/controller/progress_controller.dart';
import 'package:disabilitymne/features/progress/model/progress_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Progress screen: summary cards, bar chart, weekly calorie chart, body activity.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late final ProgressController controller;

  static const Color _screenBg = Color(0xFF0B1A2A);
  static const Color _summaryCardBg = Color(0xFF223650);
  static const Color _borderColor = Color(0xFF4B7FA8);
  static const Color _green = Color(0xFF27BE69);
  static const Color _orange = Color(0xFFE67E22);
  static const Color _blue = Color(0xFF4B7FA8);
  static const Color _bodyActivityDivider = Color(0xFF696D73);

  double _resolveAxisMax(List<double> values, {required double minMax}) {
    final highestValue = values.fold<double>(0.0, math.max);
    final rawMax = math.max(highestValue, minMax);
    if (rawMax <= 0) {
      return minMax;
    }

    final exponent = math.pow(10, (math.log(rawMax) / math.ln10).floor()).toDouble();
    for (final multiplier in const [1.0, 2.0, 5.0, 10.0]) {
      final candidate = multiplier * exponent;
      if (candidate >= rawMax) {
        return candidate;
      }
    }

    return 10 * exponent;
  }

  List<double> _buildAxisTicks(double axisMax) =>
      List<double>.generate(6, (index) => axisMax - ((axisMax / 5) * index));

  String _formatAxisLabel(double value) {
    if (value == value.roundToDouble() || value >= 100) {
      return value.round().toString();
    }

    return value.toStringAsFixed(1);
  }

  String _titleCase(String value) {
    if (value.trim().isEmpty) {
      return value;
    }

    return value
        .split(RegExp(r'[_\s]+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    controller = Get.put(
      ProgressController(Get.find()),
      permanent: false,
    );

    return Scaffold(
      backgroundColor: _screenBg,
      appBar: AppBar(
        backgroundColor: _screenBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Progress',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          return RefreshIndicator(
            onRefresh: controller.fetchProgress,
            color: Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.errorMessage.value != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        controller.errorMessage.value!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  Text(
                    'Your fitness journey at a glance',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSummaryCards(controller.stats),
                  const SizedBox(height: 24),
                  _buildProgressBarChart(controller.charts.weeklyProgress),
                  const SizedBox(height: 24),
                  _buildWeeklyCalorieChart(controller.charts.weeklyCalories),
                  const SizedBox(height: 24),
                  _buildBodyActivity(controller.bodyMetrics),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  static const List<String> _summaryIconPaths = [
    'assets/image/progress_icon_day_streak.png',
    'assets/image/progress_icon_workouts.png',
    'assets/image/progress_icon_calories_burned.png',
    'assets/image/progress_icon_period.png',
  ];

  Widget _buildSummaryCards(ProgressStats stats) {
    final items = [
      ('${stats.streakDays}', 'Day Streak', Icons.local_fire_department),
      ('${stats.totalWorkouts}', 'Total Workouts', Icons.fitness_center),
      ('${stats.caloriesPercent.toStringAsFixed(0)}%', 'Weekly Goal',
          Icons.whatshot),
      (
        '${stats.activityPeriodWeeks} week${stats.activityPeriodWeeks == 1 ? '' : 's'}',
        'Activity Period',
        Icons.calendar_today
      ),
    ];
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _summaryCard(items[0].$1, items[0].$2, _summaryIconPaths[0], items[0].$3),
              const SizedBox(height: 12),
              _summaryCard(items[2].$1, items[2].$2, _summaryIconPaths[2], items[2].$3),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              _summaryCard(items[1].$1, items[1].$2, _summaryIconPaths[1], items[1].$3),
              const SizedBox(height: 12),
              _summaryCard(items[3].$1, items[3].$2, _summaryIconPaths[3], items[3].$3),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(String value, String label, String iconPath, IconData fallbackIcon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: _summaryCardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 22,
                height: 22,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    iconPath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Icon(
                      fallbackIcon,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBarChart(List<ChartPoint> weeklyProgress) {
    final points = weeklyProgress.isNotEmpty
        ? weeklyProgress
        : [
            ChartPoint(label: 'Sat', value: 0),
            ChartPoint(label: 'Sun', value: 0),
            ChartPoint(label: 'Mon', value: 0),
            ChartPoint(label: 'Tue', value: 0),
            ChartPoint(label: 'Wed', value: 0),
            ChartPoint(label: 'Thu', value: 0),
            ChartPoint(label: 'Fri', value: 0),
          ];
    final days = points.map((e) => e.label).toList();
    final values = points.map((e) => e.value).toList();
    final yAxisMax = _resolveAxisMax(values, minMax: 5);
    final yAxisTicks = _buildAxisTicks(yAxisMax);
    final barColors = [
      const Color(0xFFE67E22), // Sat - orange
      const Color(0xFFE9967A), // Sun - light red/salmon
      const Color(0xFF87CEEB), // Mon - light blue
      const Color(0xFFFFD700), // Tue - yellow
      const Color(0xFF2E3A7E), // Wed - dark blue
      const Color(0xFFB39DDB), // Thu - light purple
      const Color(0xFF81C784), // Fri - green
    ];
    const chartHeight = 200.0;
    const barMaxHeight = 160.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SizedBox(
            height: chartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildProgressYAxis(yAxisTicks),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ProgressGridPainter(
                            gridColor: Colors.grey.shade300,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(days.length, (i) {
                          final h = yAxisMax > 0
                              ? (values[i] / yAxisMax).clamp(0.0, 1.0).toDouble()
                              : 0.0;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 26,
                                height: barMaxHeight * h,
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: barColors[i],
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                              Text(
                                days[i],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressYAxis(List<double> yAxisTicks) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: yAxisTicks
          .map((v) => Text(
                _formatAxisLabel(v),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade700,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildWeeklyCalorieChart(List<ChartPoint> weeklyCalories) {
    final points = weeklyCalories.isNotEmpty
        ? weeklyCalories
        : [
            ChartPoint(label: 'Sat', value: 0),
            ChartPoint(label: 'Sun', value: 0),
            ChartPoint(label: 'Mon', value: 0),
            ChartPoint(label: 'Tue', value: 0),
            ChartPoint(label: 'Wed', value: 0),
            ChartPoint(label: 'Thu', value: 0),
            ChartPoint(label: 'Fri', value: 0),
          ];
    final days = points.map((e) => e.label).toList();
    final values = points.map((e) => e.value).toList();
    final yAxisMax = _resolveAxisMax(values, minMax: 100);
    final yAxisTicks = _buildAxisTicks(yAxisMax);
    const chartHeight = 220.0;
    const leftPadding = 32.0;
    const bottomPadding = 24.0;
    const topPadding = 8.0;
    const rightPadding = 8.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Calories',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SizedBox(
            height: chartHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      top: topPadding,
                      bottom: bottomPadding,
                      width: leftPadding - 8,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: yAxisTicks
                            .map((v) => Text(
                                  _formatAxisLabel(v),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade700,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    Positioned(
                      left: leftPadding,
                      top: topPadding,
                      right: rightPadding,
                      bottom: bottomPadding,
                      child: CustomPaint(
                        painter: _WeeklyCaloriePainter(
                          values: values,
                          maxValue: yAxisMax,
                          lineColor: const Color(0xFF9B8AFE),
                          fillColor: const Color(0x409B8AFE),
                          gridColor: Colors.grey.shade300,
                        ),
                      ),
                    ),
                    Positioned(
                      left: leftPadding,
                      right: rightPadding,
                      bottom: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: days
                            .map((d) => Text(
                                  d,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade700,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBodyActivity(BodyMetrics bodyMetrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Body Activity',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2B42),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Body Metrics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              _buildWeightRow(bodyMetrics),
              const SizedBox(height: 16),
              Divider(height: 1, thickness: 1, color: _bodyActivityDivider),
              const SizedBox(height: 16),
              _bodyMetricRow(
                label: 'BMI',
                value: Text(
                  bodyMetrics.bmi?.toStringAsFixed(1) ?? '--',
                  style: const TextStyle(
                    color: _blue,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  bodyMetrics.bmiStatus,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
              Divider(height: 1, thickness: 1, color: _bodyActivityDivider),
              const SizedBox(height: 16),
              _bodyMetricRow(
                label: 'Activity Level',
                value: Text(
                  _titleCase(bodyMetrics.activityLevel ?? 'Unknown'),
                  style: const TextStyle(
                    color: _orange,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  'From your profile',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeightRow(BodyMetrics bodyMetrics) {
    final hasWeights = bodyMetrics.weightKg != null && bodyMetrics.goalWeightKg != null;

    final weightText = hasWeights
        ? '${bodyMetrics.weightKg!.toStringAsFixed(1)}kg'
        : 'No data';
    final goalText = hasWeights ? '${bodyMetrics.goalWeightKg!.toStringAsFixed(1)}kg' : '';

    final change = bodyMetrics.weightChangeThisMonthKg;
    final hasChange = change != 0;
    final changeColor = change < 0 ? _green : _orange;
    final changeLabel = hasChange
        ? '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)} kg this month'
        : 'No change this month';

    return _bodyMetricRow(
      label: 'Weight',
      value: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            weightText,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          if (hasWeights) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '->',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
            Text(
              goalText,
              style: const TextStyle(
                color: _green,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        changeLabel,
        style: TextStyle(color: hasChange ? changeColor : Colors.white, fontSize: 13),
      ),
    );
  }

  Widget _bodyMetricRow({
    required String label,
    required Widget value,
    Widget? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            value,
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          subtitle,
        ],
      ],
    );
  }
}

class _WeeklyCaloriePainter extends CustomPainter {
  final List<double> values;
  final double maxValue;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;

  _WeeklyCaloriePainter({
    required this.values,
    required this.maxValue,
    required this.lineColor,
    required this.fillColor,
    this.gridColor = Colors.white24,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.width <= 0 || size.height <= 0) return;
    final w = size.width;
    final h = size.height;
    final yMax = maxValue <= 0 ? 100.0 : maxValue;

    // Dotted grid: 5 equal horizontal sections.
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var step = 0; step <= 5; step++) {
      final y = h - ((step / 5) * h);
      _drawDottedLine(canvas, Offset(0, y), Offset(w, y), gridPaint);
    }
    // Vertical grid: 7 lines (one per day)
    final stepX = w / (values.length - 1);
    for (var i = 0; i < values.length; i++) {
      final x = i * stepX;
      _drawDottedLine(canvas, Offset(x, 0), Offset(x, h), gridPaint);
    }

    // Data points scale to the dynamic Y axis max.
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = h - (values[i] / yMax) * h;
      points.add(Offset(x, y));
    }

    // Smooth curve using cubicTo
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final dx = p1.dx - p0.dx;
      path.cubicTo(
        p0.dx + dx * 0.4,
        p0.dy,
        p1.dx - dx * 0.4,
        p1.dy,
        p1.dx,
        p1.dy,
      );
    }

    // Fill area under curve
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, h)
      ..lineTo(points.first.dx, h)
      ..close();
    canvas.drawPath(fillPath, Paint()..color = fillColor);

    // Line on top
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);
  }

  void _drawDottedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    var distance = (end - start).distance;
    var dashCount = (distance / (dashWidth + dashSpace)).floor();
    if (dashCount < 1) return;
    var unit = (end - start) / distance;
    var pos = 0.0;
    for (var i = 0; i < dashCount; i++) {
      final p1 = start + unit * pos;
      pos += dashWidth;
      final p2 = start + unit * (pos < distance ? pos : distance);
      canvas.drawLine(p1, p2, paint);
      pos += dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProgressGridPainter extends CustomPainter {
  final Color gridColor;

  _ProgressGridPainter({this.gridColor = Colors.grey});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final chartH = size.height - 22;
    if (chartH <= 0) return;
    final gridPaint = Paint()..color = gridColor..strokeWidth = 1;
    for (var yVal = 0; yVal <= 100; yVal += 20) {
      final y = chartH - (yVal / 100) * chartH;
      _drawDashedLine(canvas, Offset(0, y), Offset(w, y), gridPaint);
    }
    for (var i = 0; i <= 7; i++) {
      final x = (w * i) / 7;
      _drawDashedLine(canvas, Offset(x, 0), Offset(x, chartH), gridPaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    final distance = (end - start).distance;
    if (distance < 1) return;
    final dashCount = (distance / (dashWidth + dashSpace)).floor();
    if (dashCount < 1) return;
    final unit = (end - start) / distance;
    var pos = 0.0;
    for (var i = 0; i < dashCount; i++) {
      final p1 = start + unit * pos;
      pos += dashWidth;
      final p2 = start + unit * (pos < distance ? pos : distance);
      canvas.drawLine(p1, p2, paint);
      pos += dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
