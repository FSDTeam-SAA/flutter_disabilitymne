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
          if (proteinPerKg != null)
            'proteinPerKg': proteinPerKg.toString(),
          if (carbsPerKg != null) 'carbsPerKg': carbsPerKg.toString(),
          if (fatPerKg != null) 'fatPerKg': fatPerKg.toString(),
          if (caloriesPerKg != null)
            'caloriesPerKg': caloriesPerKg.toString(),
        };

        final uri = Uri.parse(ApiEndpoints.nutritionDiary).replace(queryParameters: query);

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
            message: extractSuccessMessage(response));
      },
    );
  }
}