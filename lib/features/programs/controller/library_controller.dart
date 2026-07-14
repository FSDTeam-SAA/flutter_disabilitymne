import 'package:disabilitymne/core/helpers/premium_access.dart';
import 'package:disabilitymne/features/profile/controller/profile_controller.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/helpers/app_snackbar.dart';

import '../model/library_model.dart';
import '../services/program_interface.dart';

class LibraryController extends GetxController {
  static const int _pageSize = 20;

  LibraryController({required this.programInterface});

  final ProgramInterface programInterface;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;

  final RxList<LibraryModel> exerciseList = <LibraryModel>[].obs;
  final RxList<LibraryModel> filteredList = <LibraryModel>[].obs;

  final RxString searchController = ''.obs;
  final ProfileController profileController = Get.find<ProfileController>();

  Worker? _searchWorker;
  int _currentPage = 0;
  int _requestToken = 0;

  bool get isPremiumUser => isPremiumActiveUser(profileController.user.value);

  @override
  void onInit() {
    super.onInit();
    fetchExercises();

    _searchWorker = debounce<String>(
      searchController,
      (_) => fetchExercises(showLoader: exerciseList.isEmpty),
      time: const Duration(milliseconds: 350),
    );

    ever(profileController.user, (_) => _applyFilters());
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    super.onClose();
  }

  Future<void> fetchExercises({bool showLoader = true}) async {
    if (isLoadingMore.value) {
      return;
    }

    final requestToken = ++_requestToken;

    if (showLoader || exerciseList.isEmpty) {
      isLoading.value = true;
    }

    final response = await programInterface.getLibrary(
      page: 1,
      limit: _pageSize,
      search: searchController.value,
    );

    if (requestToken != _requestToken) {
      return;
    }

    response.fold(
      (error) {
        isLoading.value = false;
        isLoadingMore.value = false;
        AppSnackbar.show("Error", error.uiMessage);
      },
      (success) {
        final pageData = success.data;
        exerciseList.assignAll(pageData?.items ?? const <LibraryModel>[]);
        _currentPage = pageData?.meta.page ?? 1;
        hasMore.value = pageData?.meta.hasMore ?? false;
        _applyFilters();
        isLoading.value = false;
        isLoadingMore.value = false;
      },
    );
  }

  Future<void> loadMoreExercises() async {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) {
      return;
    }

    final requestToken = ++_requestToken;
    isLoadingMore.value = true;

    final response = await programInterface.getLibrary(
      page: _currentPage + 1,
      limit: _pageSize,
      search: searchController.value,
    );

    if (requestToken != _requestToken) {
      return;
    }

    response.fold(
      (error) {
        isLoadingMore.value = false;
        AppSnackbar.show("Error", error.uiMessage);
      },
      (success) {
        final pageData = success.data;
        exerciseList.addAll(pageData?.items ?? const <LibraryModel>[]);
        _currentPage = pageData?.meta.page ?? _currentPage;
        hasMore.value = pageData?.meta.hasMore ?? false;
        _applyFilters();
        isLoadingMore.value = false;
      },
    );
  }

  void searchExercise(String query) {
    final normalizedQuery = query.trim();
    if (normalizedQuery == searchController.value) {
      return;
    }

    searchController.value = normalizedQuery;
  }

  void _applyFilters() {
    Iterable<LibraryModel> baseList = exerciseList;
    if (!isPremiumUser) {
      baseList = baseList.where(
        (exercise) => (exercise.plan ?? "").toLowerCase() != "premium",
      );
    }

    filteredList.assignAll(baseList);
  }
}
