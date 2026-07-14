import 'package:disabilitymne/features/calculator/model/calculator_model.dart';
import 'package:disabilitymne/features/calculator/services/calculator_interface.dart';
import 'package:disabilitymne/features/auth/model/user_model.dart';
import 'package:disabilitymne/features/profile/controller/profile_controller.dart';
import 'package:get/get.dart';

class CalculatorController extends GetxController {
  final CalculatorInterface _calculatorInterface;

  CalculatorController({required CalculatorInterface calculatorInterface})
    : _calculatorInterface = calculatorInterface;

  final Rxn<NutritionData> nutritionData = Rxn<NutritionData>();
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  Worker? _profileWorker;
  _DiaryFetchRequest? _queuedRequest;

  @override
  void onInit() {
    super.onInit();
    _bindProfileUpdates();
    // fetchDiary is called with default date (today)
    fetchDiary();
  }

  Future<void> fetchDiary({
    String? goal,
    double? weightKg,
    double? proteinPerKg,
    double? carbsPerKg,
    double? fatPerKg,
    double? caloriesPerKg,
  }) async {
    final request = _DiaryFetchRequest(
      goal: goal ?? _resolveNutritionGoalFromProfile(),
      weightKg: weightKg,
      proteinPerKg: proteinPerKg,
      carbsPerKg: carbsPerKg,
      fatPerKg: fatPerKg,
      caloriesPerKg: caloriesPerKg,
    );

    if (isLoading.value) {
      _queuedRequest = request;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final result = await _calculatorInterface.getNutritionDiary(
      date: _toApiDate(selectedDate.value),
      goal: request.goal,
      weightKg: request.weightKg,
      proteinPerKg: request.proteinPerKg,
      carbsPerKg: request.carbsPerKg,
      fatPerKg: request.fatPerKg,
      caloriesPerKg: request.caloriesPerKg,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.uiMessage;
        isLoading.value = false;
      },
      (success) {
        nutritionData.value = success.data;
        isLoading.value = false;
      },
    );

    final queuedRequest = _queuedRequest;
    _queuedRequest = null;
    if (queuedRequest != null) {
      await fetchDiary(
        goal: queuedRequest.goal,
        weightKg: queuedRequest.weightKg,
        proteinPerKg: queuedRequest.proteinPerKg,
        carbsPerKg: queuedRequest.carbsPerKg,
        fatPerKg: queuedRequest.fatPerKg,
        caloriesPerKg: queuedRequest.caloriesPerKg,
      );
    }
  }

  void changeDay(int delta) {
    selectedDate.value = selectedDate.value.add(Duration(days: delta));
    fetchDiary();
  }

  String _toApiDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  void _bindProfileUpdates() {
    if (!Get.isRegistered<ProfileController>()) return;

    final profileController = Get.find<ProfileController>();
    _profileWorker = ever<UserModel?>(profileController.user, (user) {
      if (user == null) return;
      fetchDiary();
    });
  }

  String? _resolveNutritionGoalFromProfile() {
    if (!Get.isRegistered<ProfileController>()) return null;

    final profileController = Get.find<ProfileController>();
    final goals = profileController.user.value?.fitnessGoals;
    if (goals == null || goals.isEmpty) return null;

    return _mapProfileGoalToNutritionGoal(goals.first.toString());
  }

  String? _mapProfileGoalToNutritionGoal(String rawGoal) {
    switch (rawGoal.trim().toLowerCase()) {
      case 'lose_weight':
      case 'fat_loss':
        return 'fat_loss';
      case 'build_muscle':
      case 'muscle_gain':
        return 'muscle_gain';
      case 'manage_weight':
      case 'maintenance':
      case 'boost_energy':
      case 'flexibility':
      case 'general_wellness':
        return 'maintenance';
      default:
        return null;
    }
  }

  void retry() {
    fetchDiary();
  }

  @override
  void onClose() {
    _profileWorker?.dispose();
    super.onClose();
  }
}

class _DiaryFetchRequest {
  const _DiaryFetchRequest({
    this.goal,
    this.weightKg,
    this.proteinPerKg,
    this.carbsPerKg,
    this.fatPerKg,
    this.caloriesPerKg,
  });

  final String? goal;
  final double? weightKg;
  final double? proteinPerKg;
  final double? carbsPerKg;
  final double? fatPerKg;
  final double? caloriesPerKg;
}
