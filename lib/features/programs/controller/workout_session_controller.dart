import 'package:disabilitymne/features/daily_tracker/utils/daily_tracker_date_utils.dart';
import 'package:disabilitymne/features/programs/model/explore_program_model.dart';
import 'package:disabilitymne/features/programs/model/model.dart';
import 'package:get/get.dart';

class WorkoutSessionExerciseEntry {
  final String exerciseId;
  final List<SetModel> sets;
  final int durationMinutes;
  final int caloriesBurned;

  WorkoutSessionExerciseEntry({
    required this.exerciseId,
    required this.sets,
    required this.durationMinutes,
    required this.caloriesBurned,
  });

  Map<String, dynamic> toPayload() {
    return {
      'exerciseId': exerciseId,
      'sets': sets.map((set) => set.toJson()).toList(),
      if (durationMinutes > 0) 'durationMinutes': durationMinutes,
      if (caloriesBurned > 0) 'caloriesBurned': caloriesBurned,
    };
  }
}

class WorkoutSessionController extends GetxController {
  final ProgramModel program;
  final int dayIndex;
  final String dayLabel;
  final List<ProgramExerciseModel> dayExercises;

  WorkoutSessionController({
    required this.program,
    required this.dayIndex,
    required this.dayLabel,
    required this.dayExercises,
  });

  final RxMap<String, WorkoutSessionExerciseEntry> _completedExercises =
      <String, WorkoutSessionExerciseEntry>{}.obs;

  late final DateTime _startedAt = DateTime.now();

  String get weekStartDate => weekStartDateFromSelected(_startedAt);

  int get tzOffsetMinutes => DateTime.now().timeZoneOffset.inMinutes;

  int get completedCount => _completedExercises.length;

  bool get isDayComplete {
    if (dayExercises.isEmpty) {
      return false;
    }

    return dayExercises.every((exercise) =>
        _completedExercises.containsKey(exercise.id) &&
        _completedExercises[exercise.id] != null);
  }

  void markExerciseCompleted({
    required ProgramExerciseModel exercise,
    List<SetModel>? sets,
    int? durationMinutes,
    int? caloriesBurned,
  }) {
    if (exercise.id.isEmpty) {
      return;
    }

    final normalizedSets =
        (sets != null && sets.isNotEmpty) ? sets : _defaultSetsForExercise(exercise);

    _completedExercises[exercise.id] = WorkoutSessionExerciseEntry(
      exerciseId: exercise.id,
      sets: normalizedSets,
      durationMinutes: durationMinutes ?? 0,
      caloriesBurned: caloriesBurned ?? 0,
    );
  }

  List<Map<String, dynamic>> buildExercisePayload() {
    return dayExercises
        .map((exercise) => _completedExercises[exercise.id])
        .whereType<WorkoutSessionExerciseEntry>()
        .map((entry) => entry.toPayload())
        .where((row) => (row['exerciseId']?.toString().isNotEmpty ?? false))
        .toList();
  }

  List<SetModel> _defaultSetsForExercise(ProgramExerciseModel exercise) {
    final defaults = exercise.defaultSets;
    if (defaults.isEmpty) {
      return const [];
    }

    final List<SetModel> sets = [];
    for (var i = 0; i < defaults.length; i++) {
      final item = defaults[i];
      if (item is! Map) {
        continue;
      }

      final setNumber = _safeInt(item['setNumber']) ?? (i + 1);
      final reps = _safeInt(item['reps']) ?? 0;
      final weightKg = _safeInt(item['weightKg']) ?? 0;

      sets.add(SetModel(
        setNumber: setNumber,
        reps: reps,
        weightKg: weightKg,
      ));
    }

    return sets;
  }

  int? _safeInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
