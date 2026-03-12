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

  @override
  void onInit() {
    super.onInit();
    fetchExercises();
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
        exerciseList.value = success.data ?? [];
        filteredList.value = exerciseList;
        isLoading.value = false;
      },
    );
  }

  void searchExercise(String query) {
    searchController.value = query;

    if (query.isEmpty) {
      filteredList.value = exerciseList;
    } else {
      filteredList.value = exerciseList
          .where((exercise) =>
              (exercise.exerciseName ?? "")
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    }
  }
}