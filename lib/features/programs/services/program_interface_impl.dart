import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/api_handler/success.dart';
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
  @override
  FutureRequest<Success<List<LibraryModel>>> getLibrary(
    LibraryModel params,
  ) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.get(
          ApiEndpoints.getAllLibrary,
          data: params.toJson(),
        );
        debugPrint('GET LIBRARY RESPONSE => ${response.data}');
        final library = LibraryModel.fromJsonList(response.data['data']);
        return Success(data: library, message: extractSuccessMessage(response));
      },
    );
  }

  @override
  FutureRequest<Success<List<ProgramModel>>> getExploreProgram(
    ProgramModel params,
  ) async {
    return await asyncTryCatch(
      tryFunc: () async {
        final response = await appPigeon.get(
          ApiEndpoints.getAllPrograms,
          data: params.toJson(),
        );
        debugPrint('GET EXPLORE PROGRAM RESPONSE => ${response.data}');
        final programs = ProgramModel.fromJsonList(response.data['data']);
        return Success(
          data: programs,
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
  FutureRequest<Success<ExerciseData>> getExercisesData(
    ExerciseData params,
  ) async {
    return await asyncTryCatch(tryFunc: () async {
      final response = await appPigeon.get(
        ApiEndpoints.getExcerisesData(params.exercise.id),
      );
      debugPrint('GET EXERCISES RESPONSE => ${response.data}');
      final exercise = ExerciseData.fromJson(response.data['data']);
      return Success(data: exercise, message: extractSuccessMessage(response));
    });
  }

  @override
  FutureRequest<Success<ExerciseData>> putExercisesData(
    ExerciseData params,
  ) async {
    return await asyncTryCatch(tryFunc: () async {
      final response = await appPigeon.put(
        ApiEndpoints.putExcerisesData(params.exercise.id),
        data: params.toJson(),
      );
      debugPrint('PUT EXERCISES RESPONSE => ${response.data}');
      final exercise = ExerciseData.fromJson(response.data['data']);
      return Success(data: exercise, message: extractSuccessMessage(response));
    });
  }
}
