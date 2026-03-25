import 'package:disabilitymne/core/api_handler/base_repository.dart';
import 'package:disabilitymne/core/api_handler/success.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/recipies/model/recipes_model.dart';

abstract base class RecipesInterface extends BaseRepository {
  FutureRequest<Success<List<RecipeModel>>> getRecipies(RecipeModel params);
  FutureRequest<Success<RecipeModel>> getRecipeDetail(String id);
  FutureRequest<Success<NoData>> toggleFavorite({
    required String id,
    required bool isFavorite,
  });
}
