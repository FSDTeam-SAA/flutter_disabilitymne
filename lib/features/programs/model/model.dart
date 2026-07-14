class ExerciseData {
  final Exercise exercise;
  final String executionMode;
  final bool hasCustomSettings;
  final List<SetModel> defaultSets;
  final List<SetModel> customSets;
  final List<SetModel> effectiveSets;
  final int sets;
  final int reps;
  final bool countdown;
  final int? durationSeconds;
  final int weightKg;

  ExerciseData({
    required this.exercise,
    required this.executionMode,
    required this.hasCustomSettings,
    required this.defaultSets,
    required this.customSets,
    required this.effectiveSets,
    required this.sets,
    required this.reps,
    required this.countdown,
    required this.durationSeconds,
    required this.weightKg,
  });

  factory ExerciseData.fromJson(Map<String, dynamic> json) {
    return ExerciseData(
      exercise: Exercise.fromJson(json['exercise']),
      executionMode: json['executionMode'] ?? '',
      hasCustomSettings: json['hasCustomSettings'] ?? false,
      defaultSets: (json['defaultSets'] as List? ?? [])
          .map((e) => SetModel.fromJson(e))
          .toList(),
      customSets: (json['customSets'] as List? ?? [])
          .map((e) => SetModel.fromJson(e))
          .toList(),
      effectiveSets: (json['effectiveSets'] as List? ?? [])
          .map((e) => SetModel.fromJson(e))
          .toList(),
      sets: json['sets'] ?? 0,
      reps: json['reps'] ?? 0,
      countdown: json['countdown'] ?? false,
      durationSeconds: json['durationSeconds'],
      weightKg: json['weightKg'] is double
          ? (json['weightKg'] as double).toInt()
          : (json['weightKg'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise.toJson(),
      'executionMode': executionMode,
      'hasCustomSettings': hasCustomSettings,
      'defaultSets': defaultSets.map((e) => e.toJson()).toList(),
      'customSets': customSets.map((e) => e.toJson()).toList(),
      'effectiveSets': effectiveSets.map((e) => e.toJson()).toList(),
      'sets': sets,
      'reps': reps,
      'countdown': countdown,
      'durationSeconds': durationSeconds,
      'weightKg': weightKg,
    };
  }

  static List<ExerciseData> fromJsonList(List data) {
    return data.map((e) => ExerciseData.fromJson(e)).toList();
  }
}

// ================= EXERCISE =================

class Exercise {
  final String id;
  final String exerciseName;

  Exercise({
    required this.id,
    required this.exerciseName,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? '',
      exerciseName: json['exerciseName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseName': exerciseName,
    };
  }
}

// ================= SET MODEL =================

class SetModel {
  final int setNumber;
  final int reps;
  final int weightKg;

  SetModel({
    required this.setNumber,
    required this.reps,
    required this.weightKg,
  });

  factory SetModel.fromJson(Map<String, dynamic> json) {
    return SetModel(
      setNumber: json['setNumber'] ?? 0,
      reps: json['reps'] ?? 0,
      weightKg: json['weightKg'] is double
          ? (json['weightKg'] as double).toInt()
          : (json['weightKg'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'reps': reps,
      'weightKg': weightKg,
    };
  }
}