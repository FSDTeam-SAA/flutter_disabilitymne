import 'package:disabilitymne/features/programs/model/library_model.dart';
import 'package:disabilitymne/features/programs/services/program_interface.dart';
import 'package:get/get.dart';

class ExerciseDetailController extends GetxController {
  ExerciseDetailController({
    required this.programInterface,
    required this.exerciseId,
  });

  final ProgramInterface programInterface;

  final RxBool isLoading = true.obs;
  final Rx<LibraryModel?> exercise = Rx<LibraryModel?>(null);

  final String exerciseId;

  @override
  void onInit() {
    super.onInit();
    fetchExerciseDetail();
  }

  Future<void> fetchExerciseDetail() async {
    isLoading.value = true;

    final response = await programInterface.getLibraryDetail(
      LibraryModel(id: exerciseId),
    );

    response.fold(
      (error) {
        isLoading.value = false;
        Get.snackbar("Error", error.uiMessage);
      },
      (success) {
        exercise.value = success.data;
        isLoading.value = false;
      },
    );
  }
}
