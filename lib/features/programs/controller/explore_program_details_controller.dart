import 'package:disabilitymne/features/programs/model/explore_program_model.dart';
import 'package:get/get.dart';

class ProgramDetailController extends GetxController {
  final ProgramModel program;

  ProgramDetailController(this.program);

  RxBool isLoading = false.obs;
  RxInt selectedDayIndex = 0.obs;

  String get title => program.programName ?? "";

  String get description => program.programDescription ?? "";

  String get safetyNote => program.safetyNote ?? "";

  int get totalExercises => program.totalExercises ?? 0;

  String get duration => program.programDuration ?? "";

  int get weeks => program.weekCount ?? 0;

  String get level => program.programLevel ?? "";

  String get image => program.programImage ?? "";

  List<ProgramWorkoutDay> get workoutDays {
    final configuredDays = (program.workoutDays ?? [])
        .where((day) => day.dayIndex >= 1 && day.dayIndex <= 7 && day.exercises.isNotEmpty)
        .toList();

    if (configuredDays.isNotEmpty) {
      configuredDays.sort((a, b) => a.dayIndex.compareTo(b.dayIndex));
      return configuredDays;
    }

    final fallbackExercises = program.exercises ?? [];
    if (fallbackExercises.isEmpty) {
      return const [];
    }

    final fallbackDay = DateTime.now().weekday;
    return [
      ProgramWorkoutDay(
        dayIndex: fallbackDay,
        dayLabel: _dayLabel(fallbackDay),
        exerciseIds: fallbackExercises.map((exercise) => exercise.id).toList(),
        totalExercises: fallbackExercises.length,
        exercises: fallbackExercises,
      ),
    ];
  }

  ProgramWorkoutDay? get selectedWorkoutDay {
    if (workoutDays.isEmpty) {
      return null;
    }

    final matchedDay = workoutDays.where((day) => day.dayIndex == selectedDayIndex.value).toList();
    if (matchedDay.isNotEmpty) {
      return matchedDay.first;
    }

    return workoutDays.first;
  }

  List<ProgramExerciseModel> get exercises => selectedWorkoutDay?.exercises ?? const [];

  @override
  void onInit() {
    super.onInit();

    final days = workoutDays;
    if (days.isEmpty) {
      selectedDayIndex.value = DateTime.now().weekday;
      return;
    }

    final todayIndex = DateTime.now().weekday;
    final hasToday = days.any((day) => day.dayIndex == todayIndex);
    selectedDayIndex.value = hasToday ? todayIndex : days.first.dayIndex;
  }

  void selectWorkoutDay(int dayIndex) {
    selectedDayIndex.value = dayIndex;
  }
}

String _dayLabel(int dayIndex) {
  switch (dayIndex) {
    case 1:
      return 'Mon';
    case 2:
      return 'Tue';
    case 3:
      return 'Wed';
    case 4:
      return 'Thu';
    case 5:
      return 'Fri';
    case 6:
      return 'Sat';
    case 7:
      return 'Sun';
    default:
      return 'Day $dayIndex';
  }
}
