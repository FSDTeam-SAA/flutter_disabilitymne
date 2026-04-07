import 'package:disabilitymne/core/api_handler/base_repository.dart';
import 'package:disabilitymne/core/api_handler/success.dart';
import 'package:disabilitymne/core/componenet/pagination/paginated_models.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/recipies/model/recipes_model.dart';

abstract base class RecipesInterface extends BaseRepository {
  FutureRequest<Success<PaginatedResponse<RecipeModel>>> getRecipies({
    required int page,
    int limit = 20,
    String? recipeType,
  });
  FutureRequest<Success<RecipeModel>> getRecipeDetail(String id);
  FutureRequest<Success<NoData>> toggleFavorite({
    required String id,
    required bool isFavorite,
  });
}
