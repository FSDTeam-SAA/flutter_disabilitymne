import 'package:disabilitymne/core/api_handler/base_repository.dart';
import 'package:disabilitymne/core/api_handler/success.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/programs/model/explore_program_model.dart';
import 'package:disabilitymne/features/programs/model/library_model.dart';
import 'package:disabilitymne/features/programs/model/model.dart';

abstract base class ProgramInterface extends BaseRepository {
  FutureRequest<Success<List<LibraryModel>>> getLibrary(LibraryModel params);
  FutureRequest<Success<List<ProgramModel>>> getExploreProgram(
    ProgramModel params,
  );
  FutureRequest<Success<List<ProgramModel>>> getMyPrograms(ProgramModel params);
  FutureRequest<Success<LibraryModel>> getLibraryDetail(LibraryModel params);
  FutureRequest<Success<ProgramModel>> getProgramDetail(ProgramModel params);
  FutureRequest<Success<ProgramModel>> startProgram(ProgramModel params);

  FutureRequest<Success<ExerciseData>> getExercisesData(ExerciseData params);
  FutureRequest<Success<ExerciseData>> putExercisesData(ExerciseData params);
}
