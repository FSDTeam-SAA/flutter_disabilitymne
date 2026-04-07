import 'package:disabilitymne/core/api_handler/base_repository.dart';
import 'package:disabilitymne/core/api_handler/success.dart';
import 'package:disabilitymne/core/componenet/pagination/paginated_models.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/programs/model/explore_program_model.dart';
import 'package:disabilitymne/features/programs/model/library_model.dart';
import 'package:disabilitymne/features/programs/model/model.dart';

abstract base class ProgramInterface extends BaseRepository {
  FutureRequest<Success<PaginatedResponse<LibraryModel>>> getLibrary({
    required int page,
    int limit = 20,
    String? search,
  });
  FutureRequest<Success<PaginatedResponse<ProgramModel>>> getExploreProgram({
    required int page,
    int limit = 20,
  });
  FutureRequest<Success<PaginatedResponse<ProgramModel>>> getMyPrograms({
    required int page,
    int limit = 20,
  });
  FutureRequest<Success<LibraryModel>> getLibraryDetail(LibraryModel params);
  FutureRequest<Success<ProgramModel>> getProgramDetail(ProgramModel params);
  FutureRequest<Success<ProgramModel>> startProgram(ProgramModel params);

  FutureRequest<Success<ExerciseData>> getExercisesData(ExerciseData params);
  FutureRequest<Success<ExerciseData>> putExercisesData(ExerciseData params);
  FutureRequest<Success<NoData>> completeWorkoutSession(
    Map<String, dynamic> payload,
  );
}
