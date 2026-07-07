import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/api_handler/success.dart';
import 'package:disabilitymne/core/componenet/pagination/paginated_models.dart';
import 'package:disabilitymne/core/constants/api_endpoints.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/recipies/model/recipes_model.dart';
import 'package:disabilitymne/features/recipies/services/recipes_interface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final class RecipesInterfaceImpl extends RecipesInterface {
  RecipesInterfaceImpl({required this.appPigeon});
  final AppPigeon appPigeon;

  Future<bool> _isAuthenticated() async {
    try {
      final auth = await Get.find<AuthorizedPigeon>().getCurrentAuthRecord();
      return auth != null;
    } catch (_) {
      return false;
    }
  }

  Uri _buildRecipesUri({
    required String listEndpoint,
    required int page,
    required int limit,
    String? recipeType,
  }) {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final normalizedRecipeType = recipeType?.trim();
    if (normalizedRecipeType != null && normalizedRecipeType.isNotEmpty) {
      queryParameters['recipeType'] = normalizedRecipeType;
    }

    return Uri.parse(listEndpoint).replace(queryParameters: queryParameters);
  }

  @override
  FutureRequest<Success<PaginatedResponse<RecipeModel>>> getRecipies({
    required int page,
    int limit = 20,
    String? recipeType,
  }) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final isAuthenticated = await _isAuthenticated();
        final listEndpoint = isAuthenticated
            ? ApiEndpoints.getAllRecipies
            : ApiEndpoints.getPublicRecipies;

        final response = await appPigeon.get(
          _buildRecipesUri(
            listEndpoint: listEndpoint,
            page: page,
            limit: limit,
            recipeType: recipeType,
          ).toString(),
        );
        debugPrint('GET RECIPES PAGE $page RESPONSE => ${response.data}');

        final paginatedResponse = parsePaginatedResponseEnvelope<RecipeModel>(
          response.data,
          itemFromJson: RecipeModel.fromJson,
          fallbackPage: page,
          fallbackLimit: limit,
        );

        return Success(
          data: paginatedResponse,
          message: extractSuccessMessage(response),
        );
      },
    );
  }

  @override
  FutureRequest<Success<RecipeModel>> getRecipeDetail(String id) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final isAuthenticated = await _isAuthenticated();
        final endpoint = isAuthenticated
            ? ApiEndpoints.getRecipeDetail(id)
            : ApiEndpoints.getPublicRecipeDetail(id);

        final response = await appPigeon.get(endpoint);
        debugPrint('GET RECIPE DETAIL RESPONSE => ${response.data}');
        final recipe = RecipeModel.fromJson(response.data['data']);
        return Success(data: recipe, message: extractSuccessMessage(response));
      },
    );
  }

  @override
  FutureRequest<Success<NoData>> toggleFavorite({
    required String id,
    required bool isFavorite,
  }) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.patch(
          ApiEndpoints.toggleRecipeFavorite(id),
          data: {'isFavorite': isFavorite},
        );
        debugPrint('TOGGLE RECIPE FAVORITE RESPONSE => ${response.data}');
        return Success(
          data: NoData(),
          message: extractSuccessMessage(response),
        );
      },
    );
  }
}
