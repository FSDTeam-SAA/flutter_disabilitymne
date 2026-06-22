/// Models for Progress API (`GET /users/me/progress`).
library;

/// Root data object from `data` field.
class ProgressData {
  final ProgressStats stats;
  final ProgressCharts charts;
  final BodyMetrics bodyMetrics;

  ProgressData({
    required this.stats,
    required this.charts,
    required this.bodyMetrics,
  });

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    final chartsJson = _readMap(json, const ['charts']) ?? json;

    return ProgressData(
      stats: ProgressStats.fromJson(
        _readMap(json, const ['stats']) ?? const {},
      ),
      charts: ProgressCharts.fromJson(chartsJson),
      bodyMetrics: BodyMetrics.fromJson(
        _readMap(json, const ['bodyMetrics', 'body_metrics']) ?? const {},
      ),
    );
  }
}

class ProgressStats {
  final int streakDays;
  final int totalWorkouts;
  final double caloriesPercent;
  final int activityPeriodWeeks;
  final double weeklyCaloriesBurnedKcal;
  final double weeklyCalorieTargetKcal;

  ProgressStats({
    required this.streakDays,
    required this.totalWorkouts,
    required this.caloriesPercent,
    required this.activityPeriodWeeks,
    required this.weeklyCaloriesBurnedKcal,
    required this.weeklyCalorieTargetKcal,
  });

  factory ProgressStats.fromJson(Map<String, dynamic> json) {
    return ProgressStats(
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      totalWorkouts: (json['totalWorkouts'] as num?)?.toInt() ?? 0,
      caloriesPercent: (json['caloriesPercent'] as num?)?.toDouble() ?? 0,
      activityPeriodWeeks: (json['activityPeriodWeeks'] as num?)?.toInt() ?? 0,
      weeklyCaloriesBurnedKcal:
          (json['weeklyCaloriesBurnedKcal'] as num?)?.toDouble() ?? 0,
      weeklyCalorieTargetKcal:
          (json['weeklyCalorieTargetKcal'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ProgressCharts {
  final List<ChartPoint> weeklyProgress;
  final List<ChartPoint> weeklyCalories;

  ProgressCharts({required this.weeklyProgress, required this.weeklyCalories});

  factory ProgressCharts.fromJson(Map<String, dynamic> json) {
    return ProgressCharts(
      weeklyProgress: _readChartPoints(
        json,
        chartKeys: const [
          'weeklyProgress',
          'weekly_progress',
          'progress',
          'workouts',
        ],
        valueKeys: const [
          'value',
          'count',
          'workouts',
          'totalWorkouts',
          'completedWorkouts',
          'progress',
          'percentage',
        ],
      ),
      weeklyCalories: _readChartPoints(
        json,
        chartKeys: const [
          'weeklyCalories',
          'weekly_calories',
          'calories',
          'caloriesBurned',
        ],
        valueKeys: const [
          'value',
          'calories',
          'caloriesBurned',
          'caloriesBurnedKcal',
          'burnedKcal',
          'kcal',
          'totalCalories',
        ],
      ),
    );
  }
}

class ChartPoint {
  final String label;
  final double value;

  ChartPoint({required this.label, required this.value});

  factory ChartPoint.fromJson(
    Map<String, dynamic> json, {
    List<String> labelKeys = const ['label', 'day', 'date', 'name'],
    List<String> valueKeys = const ['value'],
  }) {
    return ChartPoint(
      label: _readString(json, labelKeys),
      value: _readDouble(json, valueKeys),
    );
  }
}

Map<String, dynamic>? _readMap(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
  }
  return null;
}

List<ChartPoint> _readChartPoints(
  Map<String, dynamic> json, {
  required List<String> chartKeys,
  required List<String> valueKeys,
}) {
  dynamic raw;
  for (final key in chartKeys) {
    raw = json[key];
    if (raw != null) {
      break;
    }
  }

  if (raw is List) {
    return raw.asMap().entries.map((entry) {
      final value = entry.value;
      if (value is Map<String, dynamic>) {
        final point = ChartPoint.fromJson(value, valueKeys: valueKeys);
        return point.label.isEmpty
            ? ChartPoint(
                label: _fallbackDayLabel(entry.key),
                value: point.value,
              )
            : point;
      }
      if (value is num) {
        return ChartPoint(
          label: _fallbackDayLabel(entry.key),
          value: value.toDouble(),
        );
      }
      return ChartPoint(label: _fallbackDayLabel(entry.key), value: 0);
    }).toList();
  }

  if (raw is Map) {
    return raw.entries
        .map(
          (entry) => ChartPoint(
            label: entry.key.toString(),
            value: entry.value is num ? (entry.value as num).toDouble() : 0,
          ),
        )
        .toList();
  }

  return const [];
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }
  return '';
}

double _readDouble(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return 0;
}

String _fallbackDayLabel(int index) {
  const days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  return days[index % days.length];
}

class BodyMetrics {
  final double? weightKg;
  final double? goalWeightKg;
  final double? weightDeltaToGoalKg;
  final double weightChangeThisMonthKg;
  final double? bmi;
  final String bmiStatus;
  final String? activityLevel;

  BodyMetrics({
    required this.weightKg,
    required this.goalWeightKg,
    required this.weightDeltaToGoalKg,
    required this.weightChangeThisMonthKg,
    required this.bmi,
    required this.bmiStatus,
    required this.activityLevel,
  });

  factory BodyMetrics.fromJson(Map<String, dynamic> json) {
    return BodyMetrics(
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      goalWeightKg: (json['goalWeightKg'] as num?)?.toDouble(),
      weightDeltaToGoalKg: (json['weightDeltaToGoalKg'] as num?)?.toDouble(),
      weightChangeThisMonthKg:
          (json['weightChangeThisMonthKg'] as num?)?.toDouble() ?? 0,
      bmi: (json['bmi'] as num?)?.toDouble(),
      bmiStatus: json['bmiStatus']?.toString() ?? 'Unknown',
      activityLevel: json['activityLevel']?.toString(),
    );
  }
}
