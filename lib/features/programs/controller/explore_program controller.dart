import 'package:get/get.dart';
import '../model/explore_program_model.dart';
import '../services/program_interface.dart';

class ProgramController extends GetxController {
  ProgramController({required this.programInterface});

  final ProgramInterface programInterface;

  RxBool isLoading = false.obs;

  RxList<ProgramModel> programList = <ProgramModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getPrograms();
  }

  Future<void> getPrograms() async {
    isLoading.value = true;

    final response =
        await programInterface.getExploreProgram(ProgramModel());

    response.fold(
      (error) {
        isLoading.value = false;
        Get.snackbar("Error", error.uiMessage);
      },
      (success) {
        programList.value = success.data ?? [];
        isLoading.value = false;
      },
    );
  }
}