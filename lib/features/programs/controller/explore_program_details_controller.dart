import 'package:disabilitymne/features/programs/model/explore_program_model.dart';
import 'package:get/get.dart';

class ProgramDetailController extends GetxController {

  final ProgramModel program;

  ProgramDetailController(this.program);

  RxBool isLoading = false.obs;

  String get title => program.programName ?? "";

  String get description => program.programDescription ?? "";

  String get safetyNote => program.safetyNote ?? "";

  int get totalExercises => program.totalExercises ?? 0;

  String get duration => program.programDuration ?? "";

  int get weeks => program.weekCount ?? 0;

  String get level => program.programLevel ?? "";

  String get image => program.programImage ?? "";

  List<ProgramExerciseModel> get exercises => program.exercises ?? [];

}