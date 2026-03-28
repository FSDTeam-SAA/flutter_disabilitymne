import 'package:disabilitymne/features/profile/controller/profile_controller.dart';
import 'package:get/get.dart';

import '../model/library_model.dart';
import '../services/program_interface.dart';

class LibraryController extends GetxController {
  LibraryController({required this.programInterface});

  final ProgramInterface programInterface;

  RxBool isLoading = false.obs;

  RxList<LibraryModel> exerciseList = <LibraryModel>[].obs;
  RxList<LibraryModel> filteredList = <LibraryModel>[].obs;

  final searchController = ''.obs;
  final profileController = Get.find<ProfileController>();

  bool get isPremiumUser {
    final user = profileController.user.value;
    return user?.selectedPlan == 'premium_plan';
  }


  @override
  void onInit() {
    super.onInit();
    fetchExercises();
    
    // Re-apply filters if user profile (plan) changes
    ever(profileController.user, (_) => _applyFilters());
  }


  Future<void> fetchExercises() async {
    isLoading.value = true;

    final response = await programInterface.getLibrary(LibraryModel());

    response.fold(
      (error) {
        isLoading.value = false;
        Get.snackbar("Error", error.uiMessage);
      },
      (success) {
        final allExercises = success.data ?? [];
        exerciseList.value = allExercises;
        _applyFilters();
        isLoading.value = false;
      },

    );
  }

  void searchExercise(String query) {
    searchController.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    final query = searchController.value.toLowerCase();
    
    // 1. Filter by plan first
    Iterable<LibraryModel> baseList = exerciseList;
    if (!isPremiumUser) {
      baseList = baseList.where((e) => (e.plan ?? "").toLowerCase() != "premium");
    }

    // 2. Filter by search query
    if (query.isEmpty) {
      filteredList.value = baseList.toList();
    } else {
      filteredList.value = baseList
          .where((exercise) =>
              (exercise.exerciseName ?? "")
                  .toLowerCase()
                  .contains(query))
          .toList();
    }
  }

}