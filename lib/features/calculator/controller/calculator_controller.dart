import 'package:disabilitymne/features/calculator/model/calculator_model.dart';
import 'package:disabilitymne/features/calculator/services/calculator_interface.dart';
import 'package:get/get.dart';

class CalculatorController extends GetxController {
  final CalculatorInterface _calculatorInterface;

  CalculatorController({required CalculatorInterface calculatorInterface})
      : _calculatorInterface = calculatorInterface;

  final Rxn<NutritionData> nutritionData = Rxn<NutritionData>();
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
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
    if (isLoading.value) return; // Prevent multiple overlapping requests

    isLoading.value = true;
    errorMessage.value = '';

    final result = await _calculatorInterface.getNutritionDiary(
      date: _toApiDate(selectedDate.value),
      goal: goal,
      weightKg: weightKg,
      proteinPerKg: proteinPerKg,
      carbsPerKg: carbsPerKg,
      fatPerKg: fatPerKg,
      caloriesPerKg: caloriesPerKg,
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

  void retry() {
    fetchDiary();
  }
}
