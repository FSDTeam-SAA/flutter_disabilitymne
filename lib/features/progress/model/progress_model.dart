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
    return ProgressData(
      stats: ProgressStats.fromJson(json['stats'] as Map<String, dynamic>? ?? const {}),
      charts: ProgressCharts.fromJson(json['charts'] as Map<String, dynamic>? ?? const {}),
      bodyMetrics:
          BodyMetrics.fromJson(json['bodyMetrics'] as Map<String, dynamic>? ?? const {}),
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

  ProgressCharts({
    required this.weeklyProgress,
    required this.weeklyCalories,
  });

  factory ProgressCharts.fromJson(Map<String, dynamic> json) {
    final wpList = json['weeklyProgress'] as List<dynamic>? ?? const [];
    final wcList = json['weeklyCalories'] as List<dynamic>? ?? const [];

    return ProgressCharts(
      weeklyProgress: wpList
          .map((e) => ChartPoint.fromJson(e as Map<String, dynamic>? ?? const {}))
          .toList(),
      weeklyCalories: wcList
          .map((e) => ChartPoint.fromJson(e as Map<String, dynamic>? ?? const {}))
          .toList(),
    );
  }
}

class ChartPoint {
  final String label;
  final double value;

  ChartPoint({
    required this.label,
    required this.value,
  });

  factory ChartPoint.fromJson(Map<String, dynamic> json) {
    return ChartPoint(
      label: json['label']?.toString() ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0,
    );
  }
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

