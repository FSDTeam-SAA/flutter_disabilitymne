import 'package:disabilitymne/features/programs/model/explore_program_model.dart';
import 'package:disabilitymne/features/programs/services/program_interface.dart';
import 'package:get/get.dart';

class MyProgramController extends GetxController {
  MyProgramController({required this.programInterface});

  final ProgramInterface programInterface;

  RxBool isLoading = false.obs;
  RxList<ProgramModel> programList = <ProgramModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getPrograms();
  }

  Future<void> getPrograms({bool showLoader = true}) async {
    if (showLoader) {
      isLoading.value = true;
    }

    final response = await programInterface.getMyPrograms(ProgramModel());

    response.fold(
      (error) {
        if (showLoader) {
          isLoading.value = false;
        }
        Get.snackbar("Error", error.uiMessage);
      },
      (success) {
        programList.value = success.data ?? [];
        isLoading.value = false;
      },
    );
  }
}
