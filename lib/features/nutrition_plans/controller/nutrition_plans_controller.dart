import 'package:disabilitymne/core/helpers/app_snackbar.dart';
import 'package:disabilitymne/features/nutrition_plans/model/nutrition_plan_model.dart';
import 'package:disabilitymne/features/nutrition_plans/services/nutrition_plans_repository.dart';
import 'package:get/get.dart';

class NutritionPlansController extends GetxController {
  NutritionPlansController({required this.repository});

  final NutritionPlansRepository repository;

  final RxBool isLoading = false.obs;
  final RxList<NutritionPlanModel> plans = <NutritionPlanModel>[].obs;
  final RxInt selectedDayIndex = 1.obs;

  @override
  void onInit() {
    super.onInit();
    loadPlans();
  }

  Future<void> loadPlans() async {
    isLoading.value = true;
    final response = await repository.fetchMyPlans();
    response.fold(
      (error) {
        isLoading.value = false;
        AppSnackbar.show('Error', error.uiMessage);
      },
      (items) {
        plans.assignAll(items);
        if (items.isNotEmpty && items.first.nutritionDays.isNotEmpty) {
          selectedDayIndex.value = items.first.nutritionDays.first.dayIndex;
        }
        isLoading.value = false;
      },
    );
  }
}
