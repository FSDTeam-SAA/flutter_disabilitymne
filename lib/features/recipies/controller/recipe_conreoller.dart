import 'package:disabilitymne/features/recipies/model/recipes_model.dart';
import 'package:disabilitymne/features/recipies/services/interface_impl.dart';
import 'package:get/get.dart';

class RecipeController extends GetxController {
  RxList<RecipeModel> recipeList = <RecipeModel>[].obs;
  RxBool isLoading = false.obs;
  Rxn<RecipeModel> recipeDetail = Rxn<RecipeModel>();
  RxBool isDetailLoading = false.obs;

  final RecipesInterfaceImpl recipesInterface = RecipesInterfaceImpl(
    appPigeon: Get.find(),
  );

  @override
  void onInit() {
    super.onInit();
    getRecipes();
  }

  Future<void> getRecipes() async {
    isLoading.value = true;

    final result = await recipesInterface.getRecipies(RecipeModel());

    result.fold(
      (failure) {
        // Handle failure case, e.g., show an error message
        Get.snackbar('Error', failure.uiMessage);
      },
      (success) {
        if (success.data != null) {
          recipeList.assignAll(success.data!);
        }
      },
    );

    isLoading.value = false;
  }

  Future<void> getRecipeDetail(String id) async {
    isDetailLoading.value = true;
    recipeDetail.value = null;

    final result = await recipesInterface.getRecipeDetail(id);

    result.fold(
      (failure) {
        Get.snackbar('Error', failure.uiMessage);
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
        Get.snackbar('Error', failure.uiMessage);
      },
      (_) {
        final currentDetail = recipeDetail.value;
        if (currentDetail != null && currentDetail.id == recipeId) {
          recipeDetail.value = currentDetail.copyWith(isFavorite: isFavorite);
        }

        final index = recipeList.indexWhere((recipe) => recipe.id == recipeId);
        if (index != -1) {
          recipeList[index] = recipeList[index].copyWith(
            isFavorite: isFavorite,
          );
          recipeList.refresh();
        }
      },
    );
  }
}
