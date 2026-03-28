import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/features/programs/model/model.dart';
import 'package:disabilitymne/features/programs/services/program_interface.dart';

class ExerciseController extends GetxController {
  final ProgramInterface programInterface;
  final String exerciseId;

  ExerciseController({
    required this.programInterface,
    required this.exerciseId,
  });

  final Rx<ExerciseData?> exerciseData = Rx<ExerciseData?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  // List of sets, each represented by a map of controllers for KG and Reps
  final RxList<Map<String, TextEditingController>> setControllers =
      <Map<String, TextEditingController>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchExerciseSettings();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  void _disposeControllers() {
    for (var controllers in setControllers) {
      controllers['kg']?.dispose();
      controllers['reps']?.dispose();
    }
  }

  Future<void> fetchExerciseSettings() async {
    isLoading.value = true;
    final id = exerciseId;
    final response = await programInterface.getExercisesData(
      ExerciseData(
        exercise: Exercise(id: id, exerciseName: ''),
        executionMode: '',
        hasCustomSettings: false,
        defaultSets: [],
        customSets: [],
        effectiveSets: [],
        sets: 0,
        reps: 0,
        countdown: false,
        durationSeconds: 0,
        weightKg: 0,
      ),
    );

    response.fold(
      (error) {
        isLoading.value = false;
        // Even if fetching fails, initialize with 1 default set so user can save
        _initializeControllers(ExerciseData(
          exercise: Exercise(id: id, exerciseName: ''),
          executionMode: 'set_reps',
          hasCustomSettings: false,
          defaultSets: [],
          customSets: [],
          effectiveSets: [],
          sets: 0,
          reps: 0,
          countdown: false,
          durationSeconds: 0,
          weightKg: 0,
        ));
        debugPrint("Failed to load exercise settings: ${error.uiMessage}");
      },
      (success) {
        exerciseData.value = success.data;
        _initializeControllers(success.data ?? ExerciseData(
          exercise: Exercise(id: id, exerciseName: ''),
          executionMode: 'set_reps',
          hasCustomSettings: false,
          defaultSets: [],
          customSets: [],
          effectiveSets: [],
          sets: 0,
          reps: 0,
          countdown: false,
          durationSeconds: 0,
          weightKg: 0,
        ));
        isLoading.value = false;
      },
    );
  }

  void _initializeControllers(ExerciseData data) {
    _disposeControllers();
    setControllers.clear();

    // Prefer customSets if they exist, otherwise use defaultSets or effectiveSets
    final setsToUse = data.customSets.isNotEmpty
        ? data.customSets
        : (data.effectiveSets.isNotEmpty ? data.effectiveSets : data.defaultSets);

    for (var set in setsToUse) {
      setControllers.add({
        "kg": TextEditingController(text: set.weightKg.toString()),
        "reps": TextEditingController(text: set.reps.toString()),
      });
    }

    if (setControllers.isEmpty) {
        // Add a default empty set if nothing is returned
        addSet();
    }
  }

  void addSet() {
    setControllers.add({
      "kg": TextEditingController(),
      "reps": TextEditingController(),
    });
  }

  void removeSet(int index) {
    if (setControllers.length > index) {
      setControllers[index]['kg']?.dispose();
      setControllers[index]['reps']?.dispose();
      setControllers.removeAt(index);

      // Ensure at least one set is always present
      if (setControllers.isEmpty) {
        addSet();
      }
    }
  }

  Future<void> updateExerciseSettings() async {
    isSaving.value = true;
    
    final List<SetModel> updatedSets = [];
    for (int i = 0; i < setControllers.length; i++) {
      final kg = int.tryParse(setControllers[i]['kg']?.text ?? '0') ?? 0;
      final reps = int.tryParse(setControllers[i]['reps']?.text ?? '0') ?? 0;
      updatedSets.add(SetModel(setNumber: i + 1, reps: reps, weightKg: kg));
    }

    // Use existing data if available, otherwise create a minimal default object
    final currentData = exerciseData.value;
    final updatedData = ExerciseData(
      exercise: currentData?.exercise ?? Exercise(id: exerciseId, exerciseName: ''),
      executionMode: currentData?.executionMode ?? 'set_reps',
      hasCustomSettings: true,
      defaultSets: currentData?.defaultSets ?? [],
      customSets: updatedSets,
      effectiveSets: updatedSets,
      sets: updatedSets.length,
      reps: updatedSets.isNotEmpty ? updatedSets.first.reps : 0, 
      countdown: currentData?.countdown ?? false,
      durationSeconds: currentData?.durationSeconds ?? 0,
      weightKg: updatedSets.isNotEmpty ? updatedSets.first.weightKg : 0,
    );

    final response = await programInterface.putExercisesData(updatedData);

    response.fold(
      (error) {
        isSaving.value = false;
        Get.snackbar("Error", "Failed to save settings: ${error.uiMessage}");
      },
      (success) {
        isSaving.value = false;
        exerciseData.value = success.data;
        Get.snackbar("Success", "Exercise settings saved successfully.");
      },
    );
  }

  List<SetModel> getCurrentSets() {
    final List<SetModel> currentSets = [];
    for (int i = 0; i < setControllers.length; i++) {
      final kg = int.tryParse(setControllers[i]['kg']?.text ?? '0') ?? 0;
      final reps = int.tryParse(setControllers[i]['reps']?.text ?? '0') ?? 0;
      currentSets.add(SetModel(setNumber: i + 1, reps: reps, weightKg: kg));
    }

    return currentSets;
  }
}
