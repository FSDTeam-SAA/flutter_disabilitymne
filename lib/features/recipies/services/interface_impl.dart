import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/api_handler/success.dart';
import 'package:disabilitymne/core/constants/api_endpoints.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/recipies/model/recipes_model.dart';
import 'package:disabilitymne/features/recipies/services/recipes_interface.dart';
import 'package:flutter/material.dart';

final class RecipesInterfaceImpl extends RecipesInterface {
  RecipesInterfaceImpl({required this.appPigeon});
  final AppPigeon appPigeon;
  @override
  FutureRequest<Success<List<RecipeModel>>> getRecipies(
    RecipeModel params,
  ) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.get(
          ApiEndpoints.getAllRecipies,
          data: params.toJson(),
        );
        debugPrint('GET RECIPES RESPONSE => ${response.data}');
        final recipes = RecipeModel.fromJsonList(response.data['data']);
        return Success(data: recipes, message: extractSuccessMessage(response));
      },
    );
  }

  @override
  FutureRequest<Success<RecipeModel>> getRecipeDetail(String id) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.get(ApiEndpoints.getRecipeDetail(id));
        debugPrint('GET RECIPE DETAIL RESPONSE => ${response.data}');
        final recipe = RecipeModel.fromJson(response.data['data']);
        return Success(data: recipe, message: extractSuccessMessage(response));
      },
    );
  }
}
