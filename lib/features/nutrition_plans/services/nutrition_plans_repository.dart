import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/api_handler/base_repository.dart';
import 'package:disabilitymne/core/constants/api_endpoints.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/nutrition_plans/model/nutrition_plan_model.dart';

base class NutritionPlansRepository extends BaseRepository {
  NutritionPlansRepository(this._pigeon);

  final AuthorizedPigeon _pigeon;

  FutureRequest<List<NutritionPlanModel>> fetchMyPlans() async {
    return asyncTryCatch(
      tryFunc: () async {
        final response = await _pigeon.get(ApiEndpoints.myNutritionPlans);
        final data = extractBodyData(response);
        if (data is! List) return <NutritionPlanModel>[];
        return data
            .map((e) => NutritionPlanModel.fromJson(e as Map<String, dynamic>? ?? const {}))
            .toList();
      },
    );
  }
}
