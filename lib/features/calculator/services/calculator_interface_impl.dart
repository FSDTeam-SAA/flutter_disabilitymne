import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/api_handler/success.dart';
import 'package:disabilitymne/core/constants/api_endpoints.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/calculator/model/calculator_model.dart';
import 'package:disabilitymne/features/calculator/services/calculator_interface.dart';
import 'package:flutter/material.dart';

final class CalculatorInterfaceImpl extends CalculatorInterface {
  CalculatorInterfaceImpl({required this.appPigeon});
  final AppPigeon appPigeon;

  @override
  FutureRequest<Success<NutritionData>> getNutritionDiary({
    required String date,
    String? goal,
    double? weightKg,
    double? proteinPerKg,
    double? carbsPerKg,
    double? fatPerKg,
    double? caloriesPerKg,
  }) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final query = <String, String>{
          'date': date,
          if (goal != null && goal.isNotEmpty) 'goal': goal,
          if (weightKg != null) 'weightKg': weightKg.toString(),
          if (proteinPerKg != null) 'proteinPerKg': proteinPerKg.toString(),
          if (carbsPerKg != null) 'carbsPerKg': carbsPerKg.toString(),
          if (fatPerKg != null) 'fatPerKg': fatPerKg.toString(),
          if (caloriesPerKg != null) 'caloriesPerKg': caloriesPerKg.toString(),
        };

        final uri = Uri.parse(
          ApiEndpoints.nutritionDiary,
        ).replace(queryParameters: query);

        final response = await appPigeon.get(uri.toString());
        debugPrint("GET NUTRITION DIARY RESPONSE => ${response.data}");

        final data = extractBodyData(response);
        if (data == null) {
          throw Exception('No data found in nutrition diary response');
        }

        return Success(
          data: NutritionData.fromJson(data),
          message: extractSuccessMessage(response),
        );
      },
    );
  }

  @override
  FutureRequest<Success<NutritionData>> calculate(NutritionData params) async {
    return await asyncTryCatch(
      tryFunc: () async {
        // Calculate might be a POST if it's sending a whole model to be processed
        final response = await appPigeon.get(
          ApiEndpoints.nutritionDiary,
          data: params.toJson(),
        );
        debugPrint("CALCULATE RESPONSE => ${response.data}");
        final data = extractBodyData(response);
        if (data == null) {
          throw Exception('No data found in calculate response');
        }
        return Success(
          data: NutritionData.fromJson(data),
          message: extractSuccessMessage(response),
        );
      },
    );
  }

  @override
  FutureRequest<Success<NutritionHistoryPage>> getNutritionHistory({
    int page = 1,
    int limit = 30,
    String? mealType,
    String? query,
  }) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final queryParams = <String, String>{
          'page': page.toString(),
          'limit': limit.toString(),
          if (mealType != null && mealType.isNotEmpty) 'mealType': mealType,
          if (query != null && query.trim().isNotEmpty) 'query': query.trim(),
        };
        final uri = Uri.parse(
          ApiEndpoints.nutritionHistory,
        ).replace(queryParameters: queryParams);
        final response = await appPigeon.get(uri.toString());
        debugPrint('GET NUTRITION HISTORY RESPONSE => ${response.data}');
        final data = extractBodyData(response);
        if (data is! Map) {
          throw Exception('Invalid nutrition history response');
        }
        return Success(
          data: NutritionHistoryPage.fromJson(Map<String, dynamic>.from(data)),
          message: extractSuccessMessage(response),
        );
      },
    );
  }

  @override
  FutureRequest<Success<NutritionFavoriteSections>>
  getNutritionFavoriteSections({int limit = 50}) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final uri = Uri.parse(
          ApiEndpoints.nutritionFavoriteSections,
        ).replace(queryParameters: {'limit': limit.toString()});
        final response = await appPigeon.get(uri.toString());
        debugPrint(
          'GET NUTRITION FAVORITE SECTIONS RESPONSE => ${response.data}',
        );
        final data = extractBodyData(response);
        if (data is! Map) {
          throw Exception('Invalid favorite sections response');
        }
        return Success(
          data: NutritionFavoriteSections.fromJson(
            Map<String, dynamic>.from(data),
          ),
          message: extractSuccessMessage(response),
        );
      },
    );
  }

  @override
  FutureRequest<Success<NutritionEntrySummary>> updateNutritionDiaryEntry({
    required String entryId,
    required Map<String, dynamic> payload,
  }) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.patch(
          ApiEndpoints.nutritionDiaryEntryById(entryId),
          data: payload,
        );
        debugPrint('PATCH NUTRITION ENTRY RESPONSE => ${response.data}');
        final data = extractBodyData(response);
        if (data is! Map) {
          throw Exception('Invalid nutrition entry update response');
        }

        return Success(
          data: NutritionEntrySummary.fromJson(Map<String, dynamic>.from(data)),
          message: extractSuccessMessage(response),
        );
      },
    );
  }

  @override
  FutureRequest<Success<NoData>> deleteNutritionDiaryEntry({
    required String entryId,
  }) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.delete(
          ApiEndpoints.nutritionDiaryEntryById(entryId),
        );
        debugPrint('DELETE NUTRITION ENTRY RESPONSE => ${response.data}');

        return Success(
          data: NoData(),
          message: extractSuccessMessage(response),
        );
      },
    );
  }

  @override
  FutureRequest<Success<NutritionEntrySummary>> saveNutritionFavoriteMeal({
    required String date,
    required String mealType,
    String? title,
  }) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.post(
          ApiEndpoints.nutritionFavoriteMeals,
          data: {
            'date': date,
            'mealType': mealType,
            if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
          },
        );
        debugPrint('SAVE NUTRITION FAVORITE MEAL RESPONSE => ${response.data}');
        final data = extractBodyData(response);
        if (data is! Map) {
          throw Exception('Invalid favorite meal response');
        }

        return Success(
          data: NutritionEntrySummary.fromJson(Map<String, dynamic>.from(data)),
          message: extractSuccessMessage(response),
        );
      },
    );
  }

  @override
  FutureRequest<Success<NoData>> deleteNutritionFavoriteMeal({
    required String mealFavoriteId,
  }) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.delete(
          ApiEndpoints.nutritionFavoriteMealById(mealFavoriteId),
        );
        debugPrint(
          'DELETE NUTRITION FAVORITE MEAL RESPONSE => ${response.data}',
        );

        return Success(
          data: NoData(),
          message: extractSuccessMessage(response),
        );
      },
    );
  }

  @override
  FutureRequest<Success<NoData>> toggleRecipeFavorite({
    required String recipeId,
    required bool isFavorite,
  }) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.patch(
          ApiEndpoints.toggleRecipeFavorite(recipeId),
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
