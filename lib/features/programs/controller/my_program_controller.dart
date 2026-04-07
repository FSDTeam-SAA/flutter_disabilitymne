import 'package:disabilitymne/features/programs/model/explore_program_model.dart';
import 'package:disabilitymne/features/programs/services/program_interface.dart';
import 'package:get/get.dart';

class MyProgramController extends GetxController {
  static const int _pageSize = 20;

  MyProgramController({required this.programInterface});

  final ProgramInterface programInterface;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxList<ProgramModel> programList = <ProgramModel>[].obs;

  int _currentPage = 0;

  @override
  void onInit() {
    super.onInit();
    getPrograms();
  }

  Future<void> getPrograms({bool showLoader = true}) async {
    if (isLoadingMore.value || (isLoading.value && programList.isEmpty)) {
      return;
    }

    if (showLoader || programList.isEmpty) {
      isLoading.value = true;
    }

    final response = await programInterface.getMyPrograms(
      page: 1,
      limit: _pageSize,
    );

    response.fold(
      (error) {
        isLoading.value = false;
        Get.snackbar("Error", error.uiMessage);
      },
      (success) {
        final pageData = success.data;
        programList.assignAll(pageData?.items ?? const <ProgramModel>[]);
        _currentPage = pageData?.meta.page ?? 1;
        hasMore.value = pageData?.meta.hasMore ?? false;
        isLoading.value = false;
        isLoadingMore.value = false;
      },
    );
  }

  Future<void> loadMorePrograms() async {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) {
      return;
    }

    isLoadingMore.value = true;

    final response = await programInterface.getMyPrograms(
      page: _currentPage + 1,
      limit: _pageSize,
    );

    response.fold(
      (error) {
        isLoadingMore.value = false;
        Get.snackbar("Error", error.uiMessage);
      },
      (success) {
        final pageData = success.data;
        programList.addAll(pageData?.items ?? const <ProgramModel>[]);
        _currentPage = pageData?.meta.page ?? _currentPage;
        hasMore.value = pageData?.meta.hasMore ?? false;
        isLoadingMore.value = false;
      },
    );
  }
}
