import 'package:disabilitymne/features/progress/model/progress_model.dart';
import 'package:disabilitymne/features/progress/repository/progress_repository.dart';
import 'package:get/get.dart';

/// Controller for Progress screen.
class ProgressController extends GetxController {
  ProgressController(this._repo);

  final ProgressRepository _repo;

  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<ProgressData> progressData = Rxn<ProgressData>();

  ProgressStats get stats =>
      progressData.value?.stats ??
      ProgressStats(
        streakDays: 0,
        totalWorkouts: 0,
        caloriesPercent: 0,
        activityPeriodWeeks: 0,
      );

  ProgressCharts get charts =>
      progressData.value?.charts ??
      ProgressCharts(
        weeklyProgress: const [],
        weeklyCalories: const [],
      );

  BodyMetrics get bodyMetrics =>
      progressData.value?.bodyMetrics ??
      BodyMetrics(
        weightKg: null,
        goalWeightKg: null,
        weightDeltaToGoalKg: null,
        weightChangeThisMonthKg: 0,
        bmi: null,
        bmiStatus: 'Unknown',
        activityLevel: null,
      );

  @override
  void onInit() {
    super.onInit();
    fetchProgress();
  }

  Future<void> fetchProgress() async {
    isLoading.value = true;
    errorMessage.value = null;
    final result = await _repo.fetchProgress();
    result.fold(
      (failure) {
        errorMessage.value = failure.uiMessage;
        progressData.value = null;
      },
      (data) {
        progressData.value = data;
      },
    );
    isLoading.value = false;
  }
}

