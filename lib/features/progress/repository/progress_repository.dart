import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/api_handler/base_repository.dart';
import 'package:disabilitymne/core/constants/api_endpoints.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/progress/model/progress_model.dart';

/// Repository for Progress API.
base class ProgressRepository extends BaseRepository {
  ProgressRepository(this._pigeon);

  final AuthorizedPigeon _pigeon;

  /// GET /users/me/progress
  FutureRequest<ProgressData> fetchProgress() async {
    return asyncTryCatch(
      tryFunc: () async {
        final response = await _pigeon.get(ApiEndpoints.getProgress);
        final data = extractBodyData(response) as Map<String, dynamic>?;
        if (data == null) {
          throw Exception('Invalid progress response');
        }
        return ProgressData.fromJson(data);
      },
    );
  }
}

