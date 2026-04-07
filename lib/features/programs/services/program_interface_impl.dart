import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/api_handler/success.dart';
import 'package:disabilitymne/core/componenet/pagination/paginated_models.dart';
import 'package:disabilitymne/core/constants/api_endpoints.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/programs/model/explore_program_model.dart';
import 'package:disabilitymne/features/programs/model/library_model.dart';
import 'package:disabilitymne/features/programs/model/model.dart';
import 'package:disabilitymne/features/programs/services/program_interface.dart';
import 'package:flutter/foundation.dart';

final class ProgramInterfaceImpl extends ProgramInterface {
  ProgramInterfaceImpl({required this.appPigeon});
  final AppPigeon appPigeon;

  Uri _buildPagedUri(
    String baseUrl, {
    required int page,
    required int limit,
    String? search,
  }) {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final normalizedSearch = search?.trim();
    if (normalizedSearch != null && normalizedSearch.isNotEmpty) {
      queryParameters['search'] = normalizedSearch;
    }

    return Uri.parse(baseUrl).replace(queryParameters: queryParameters);
  }

  @override
  FutureRequest<Success<PaginatedResponse<LibraryModel>>> getLibrary({
    required int page,
    int limit = 20,
    String? search,
  }) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.get(
          _buildPagedUri(
            ApiEndpoints.getAllLibrary,
            page: page,
            limit: limit,
            search: search,
          ).toString(),
        );
        debugPrint('GET LIBRARY RESPONSE => ${response.data}');
        return Success(
          data: parsePaginatedResponseEnvelope<LibraryModel>(
            response.data,
            itemFromJson: LibraryModel.fromJson,
            fallbackPage: page,
            fallbackLimit: limit,
          ),
          message: extractSuccessMessage(response),
        );
      },
    );
  }

  @override
  FutureRequest<Success<PaginatedResponse<ProgramModel>>> getExploreProgram({
    required int page,
    int limit = 20,
  }) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.get(
          _buildPagedUri(
            ApiEndpoints.getExplorePrograms,
            page: page,
            limit: limit,
          ).toString(),
        );
        debugPrint('GET EXPLORE PROGRAM RESPONSE => ${response.data}');
        return Success(
          data: parsePaginatedResponseEnvelope<ProgramModel>(
            response.data,
            itemFromJson: ProgramModel.fromJson,
            fallbackPage: page,
            fallbackLimit: limit,
          ),
          message: extractSuccessMessage(response),
        );
      },
    );
  }

  @override
  FutureRequest<Success<PaginatedResponse<ProgramModel>>> getMyPrograms({
    required int page,
    int limit = 20,
  }) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.get(
          _buildPagedUri(
            ApiEndpoints.getMyPrograms,
            page: page,
            limit: limit,
          ).toString(),
        );
        debugPrint('GET MY PROGRAM RESPONSE => ${response.data}');
        return Success(
          data: parsePaginatedResponseEnvelope<ProgramModel>(
            response.data,
            itemFromJson: ProgramModel.fromJson,
            fallbackPage: page,
            fallbackLimit: limit,
          ),
          message: extractSuccessMessage(response),
        );
      },
    );
  }

  @override
  FutureRequest<Success<LibraryModel>> getLibraryDetail(
    LibraryModel params,
  ) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.get(
          ApiEndpoints.getLibraryDetail(params.id ?? ''),
          data: params.toJson(),
        );
        debugPrint('GET LIBRARY DETAIL RESPONSE => ${response.data}');
        final libraryDetail = LibraryModel.fromJson(response.data['data']);
        return Success(
          data: libraryDetail,
          message: extractSuccessMessage(response),
        );
      },
    );
  }

  @override
  FutureRequest<Success<ProgramModel>> getProgramDetail(
    ProgramModel params,
  ) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.get(
          ApiEndpoints.getProgramDetail(params.id ?? ''),
          data: params.toJson(),
        );
        debugPrint('GET PROGRAM DETAIL RESPONSE => ${response.data}');
        final programDetail = ProgramModel.fromJson(response.data['data']);
        return Success(
          data: programDetail,
          message: extractSuccessMessage(response),
        );
      },
    );
  }

  @override
  FutureRequest<Success<ProgramModel>> startProgram(ProgramModel params) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.post(
          ApiEndpoints.startProgram(params.id ?? ''),
        );
        debugPrint('START PROGRAM RESPONSE => ${response.data}');
        final programDetail = ProgramModel.fromJson(response.data['data']);
        return Success(
          data: programDetail,
          message: extractSuccessMessage(response),
        );
      },
    );
  }

  @override
  FutureRequest<Success<ExerciseData>> getExercisesData(
    ExerciseData params,
  ) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.get(
          ApiEndpoints.getExcerisesData(params.exercise.id),
        );
        debugPrint('GET EXERCISES RESPONSE => ${response.data}');
        final exercise = ExerciseData.fromJson(response.data['data']);
        return Success(
          data: exercise,
          message: extractSuccessMessage(response),
        );
      },
    );
  }

  @override
  FutureRequest<Success<ExerciseData>> putExercisesData(
    ExerciseData params,
  ) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.put(
          ApiEndpoints.putExcerisesData(params.exercise.id),
          data: params.toJson(),
        );
        debugPrint('PUT EXERCISES RESPONSE => ${response.data}');
        final exercise = ExerciseData.fromJson(response.data['data']);
        return Success(
          data: exercise,
          message: extractSuccessMessage(response),
        );
      },
    );
  }

  @override
  FutureRequest<Success<NoData>> completeWorkoutSession(
    Map<String, dynamic> payload,
  ) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.post(
          ApiEndpoints.completeWorkoutSession,
          data: payload,
        );
        debugPrint('COMPLETE WORKOUT SESSION RESPONSE => ${response.data}');
        return Success(
          data: NoData(),
          message: extractSuccessMessage(response),
        );
      },
    );
  }
}
