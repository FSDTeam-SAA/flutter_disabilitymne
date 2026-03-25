import 'package:disabilitymne/core/api_handler/base_repository.dart';
import 'package:disabilitymne/core/api_handler/success.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/calculator/model/calculator_model.dart';

abstract base class CalculatorInterface extends BaseRepository {

  FutureRequest<Success<NutritionData>> calculate(NutritionData params);
  FutureRequest<Success<NutritionData>> getNutritionDiary({
    required String date,
    String? goal,
    double? weightKg,
    double? proteinPerKg,
    double? carbsPerKg,
    double? fatPerKg,
    double? caloriesPerKg,
  });

  FutureRequest<Success<NutritionHistoryPage>> getNutritionHistory({
    int page = 1,
    int limit = 30,
    String? mealType,
    String? query,
  });

  FutureRequest<Success<NutritionFavoriteSections>> getNutritionFavoriteSections({
    int limit = 50,
  });
}