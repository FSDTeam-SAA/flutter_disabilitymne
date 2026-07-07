import 'package:disabilitymne/core/componenet/pagination/paginated_models.dart';
import 'package:disabilitymne/features/recipies/model/recipes_model.dart';
import 'package:disabilitymne/features/recipies/services/interface_impl.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/helpers/app_snackbar.dart';

class RecipeController extends GetxController {
  static const int _pageSize = 20;
  static const List<String> supportedMealTypes = <String>[
    'breakfast',
    'lunch',
    'dinner',
    'snack',
  ];

  final RxMap<String, PaginatedState<RecipeModel>> mealStates =
      <String, PaginatedState<RecipeModel>>{}.obs;
  final Rxn<RecipeModel> recipeDetail = Rxn<RecipeModel>();
  final RxBool isDetailLoading = false.obs;

  final RecipesInterfaceImpl recipesInterface = RecipesInterfaceImpl(
    appPigeon: Get.find(),
  );

  @override
  void onInit() {
    super.onInit();
    ensureMealLoaded(supportedMealTypes.first);
  }

  String _normalizeMealType(String mealType) {
    final normalized = mealType.trim().toLowerCase();
    if (supportedMealTypes.contains(normalized)) {
      return normalized;
    }
    return supportedMealTypes.first;
  }

  PaginatedState<RecipeModel> stateForMealType(String mealType) {
    final normalizedMealType = _normalizeMealType(mealType);
    return mealStates[normalizedMealType] ??
        PaginatedState<RecipeModel>.initial(limit: _pageSize);
  }

  Future<void> getRecipes({
    Iterable<String> mealTypes = const <String>['breakfast'],
  }) async {
    await refreshMealTypes(mealTypes);
  }

  Future<void> ensureMealLoaded(String mealType) async {
    final normalizedMealType = _normalizeMealType(mealType);
    final state = stateForMealType(normalizedMealType);
    if (state.hasLoaded ||
        state.isInitialLoading ||
        state.isRefreshing ||
        state.isLoadingMore) {
      return;
    }

    await _fetchMealTypePage(normalizedMealType, refresh: false);
  }

  Future<void> refreshMealType(String mealType) async {
    await _fetchMealTypePage(_normalizeMealType(mealType), refresh: true);
  }

  Future<void> refreshMealTypes(Iterable<String> mealTypes) async {
    final normalizedMealTypes = mealTypes
        .map(_normalizeMealType)
        .toSet()
        .toList(growable: false);

    await Future.wait(
      normalizedMealTypes.map((mealType) => refreshMealType(mealType)),
    );
  }

  Future<void> loadMoreMealType(String mealType) async {
    final normalizedMealType = _normalizeMealType(mealType);
    final state = stateForMealType(normalizedMealType);
    if (!state.hasLoaded ||
        !state.hasMore ||
        state.isInitialLoading ||
        state.isRefreshing ||
        state.isLoadingMore) {
      return;
    }

    await _fetchMealTypePage(
      normalizedMealType,
      refresh: false,
      loadMore: true,
    );
  }

  Future<void> _fetchMealTypePage(
    String mealType, {
    required bool refresh,
    bool loadMore = false,
  }) async {
    final currentState = stateForMealType(mealType);
    final shouldShowInitialLoading =
        (!currentState.hasLoaded || currentState.items.isEmpty) && !loadMore;
    final nextPage = loadMore ? currentState.meta.page + 1 : 1;

    mealStates[mealType] = currentState.copyWith(
      isInitialLoading: shouldShowInitialLoading,
      isRefreshing: refresh && !shouldShowInitialLoading,
      isLoadingMore: loadMore,
    );

    final result = await recipesInterface.getRecipies(
      page: nextPage,
      limit: _pageSize,
      recipeType: mealType,
    );

    result.fold(
      (failure) {
        mealStates[mealType] = currentState.copyWith(
          isInitialLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
        );
        AppSnackbar.show('Error', failure.uiMessage);
      },
      (success) {
        final response = success.data;
        final nextItems = response?.items ?? const <RecipeModel>[];
        mealStates[mealType] = currentState.copyWith(
          items: loadMore ? [...currentState.items, ...nextItems] : nextItems,
          meta: response?.meta,
          hasLoaded: true,
          isInitialLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
        );
      },
    );
  }

  Future<void> getRecipeDetail(String id) async {
    isDetailLoading.value = true;
    recipeDetail.value = null;

    final result = await recipesInterface.getRecipeDetail(id);

    result.fold(
      (failure) {
        AppSnackbar.show('Error', failure.uiMessage);
      },
      (success) {
        recipeDetail.value = success.data;
      },
    );

    isDetailLoading.value = false;
  }

  Future<void> toggleFavorite({
    required String recipeId,
    required bool isFavorite,
  }) async {
    final result = await recipesInterface.toggleFavorite(
      id: recipeId,
      isFavorite: isFavorite,
    );

    result.fold(
      (failure) {
        AppSnackbar.show('Error', failure.uiMessage);
      },
      (_) {
        final currentDetail = recipeDetail.value;
        if (currentDetail != null && currentDetail.id == recipeId) {
          recipeDetail.value = currentDetail.copyWith(isFavorite: isFavorite);
        }

        final mealKeys = mealStates.keys.toList(growable: false);
        for (final mealKey in mealKeys) {
          final mealState = mealStates[mealKey];
          if (mealState == null) {
            continue;
          }

          final updatedItems = mealState.items
              .map(
                (recipe) => recipe.id == recipeId
                    ? recipe.copyWith(isFavorite: isFavorite)
                    : recipe,
              )
              .toList(growable: false);

          mealStates[mealKey] = mealState.copyWith(items: updatedItems);
        }
      },
    );
  }
}
