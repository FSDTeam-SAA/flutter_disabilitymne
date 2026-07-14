import 'package:disabilitymne/features/programs/controller/exercise_controller.dart';
import 'package:disabilitymne/features/programs/controller/workout_session_controller.dart';
import 'package:disabilitymne/features/programs/model/explore_program_model.dart';
import 'package:disabilitymne/features/programs/presentation/screens/congratulation_screen.dart';
import 'package:disabilitymne/features/programs/presentation/screens/count_down_excersise_screen.dart';
import 'package:disabilitymne/features/programs/services/program_interface.dart';
import 'package:disabilitymne/features/programs/utils/video_url_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ExerciseScreen extends StatefulWidget {
  final ProgramModel program;
  final int dayIndex;
  final String dayLabel;
  final List<ProgramExerciseModel> dayExercises;
  final String sessionTag;
  final int initialIndex;
  const ExerciseScreen({
    super.key,
    required this.program,
    required this.dayIndex,
    required this.dayLabel,
    required this.dayExercises,
    required this.sessionTag,
    this.initialIndex = 0,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  late int currentExerciseIndex;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoLoading = false;

  late ExerciseController controller;

  @override
  void initState() {
    super.initState();
    currentExerciseIndex = widget.initialIndex;
    final exercises = widget.dayExercises;
    final currentExercise = exercises.isNotEmpty
        ? exercises[currentExerciseIndex]
        : null;

    controller = Get.put(
      ExerciseController(
        programInterface: Get.find<ProgramInterface>(),
        exerciseId: currentExercise?.id ?? '',
      ),
      tag: currentExercise?.id, // Use tag to handle multiple screens in stack
    );

    _initializeExerciseVideo();
  }

  @override
  void dispose() {
    _disposeVideoPlayer();
    super.dispose();
  }

  Future<void> _disposeVideoPlayer() async {
    await _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _videoPlayerController = null;
    _chewieController = null;
  }

  Future<void> _initializeExerciseVideo() async {
    final exercises = widget.dayExercises;
    if (exercises.isEmpty || currentExerciseIndex >= exercises.length) return;

    final currentExercise = exercises[currentExerciseIndex];
    final videoUrl = selectPreferredVideoUrl(
      demoVideo: currentExercise.demoVideo,
      demoVideos: currentExercise.demoVideos,
    );

    if (videoUrl.isEmpty) return;

    setState(() {
      _isVideoLoading = true;
    });

    await _disposeVideoPlayer();

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: true,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        allowFullScreen: true,
        allowPlaybackSpeedChanging: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint("Error initializing video: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
        });
      }
    }
  }

  void nextExercise() {
    final exercises = widget.dayExercises;
    final totalExercises = exercises.length;
    final currentExercise =
        exercises.isNotEmpty &&
            currentExerciseIndex >= 0 &&
            currentExerciseIndex < exercises.length
        ? exercises[currentExerciseIndex]
        : null;

    if (currentExercise != null &&
        Get.isRegistered<WorkoutSessionController>(tag: widget.sessionTag)) {
      final sessionController = Get.find<WorkoutSessionController>(
        tag: widget.sessionTag,
      );
      sessionController.markExerciseCompleted(
        exercise: currentExercise,
        sets: controller.getCurrentSets(),
      );
    }

    debugPrint(
      "Next Exercise clicked. Current Index: $currentExerciseIndex, Total: $totalExercises",
    );

    if (currentExerciseIndex < totalExercises - 1) {
      final nextIdx = currentExerciseIndex + 1;
      final nextExecMode = exercises[nextIdx].executionMode;

      if (nextExecMode == 'countdown') {
        Get.to(
          () => ExerciseWorkoutScreen(
            program: widget.program,
            dayIndex: widget.dayIndex,
            dayLabel: widget.dayLabel,
            dayExercises: widget.dayExercises,
            sessionTag: widget.sessionTag,
            initialIndex: nextIdx,
          ),
          preventDuplicates: false,
        );
      } else {
        Get.to(
          () => ExerciseScreen(
            program: widget.program,
            dayIndex: widget.dayIndex,
            dayLabel: widget.dayLabel,
            dayExercises: widget.dayExercises,
            sessionTag: widget.sessionTag,
            initialIndex: nextIdx,
          ),
          preventDuplicates: false,
        );
      }
    } else {
      debugPrint("Exercise completed. Popping back to Program screen.");
      Get.to(
        () => WorkoutCompleteScreen(
          program: widget.program,
          dayIndex: widget.dayIndex,
          dayLabel: widget.dayLabel,
          sessionTag: widget.sessionTag,
        ),
      );
    }
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.dayExercises;
    final currentExercise = exercises.isNotEmpty
        ? exercises[currentExerciseIndex]
        : null;
    final totalExercises = exercises.length;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final keyboardVisible = bottomInset > 0;

    return Scaffold(
      backgroundColor: const Color(0xff0F1C2E),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  /// TOP BAR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              _dismissKeyboard();
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Back',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      Text(
                        'Exercise ${currentExerciseIndex + 1} of $totalExercises',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// PROGRESS BAR
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: totalExercises > 0
                          ? (currentExerciseIndex + 1) / totalExercises
                          : 0,
                      minHeight: 6,
                      backgroundColor: Colors.white24,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    /// VIDEO CARD
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: keyboardVisible ? 130 : 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child:
                          _chewieController != null &&
                              _chewieController!
                                  .videoPlayerController
                                  .value
                                  .isInitialized
                          ? Chewie(controller: _chewieController!)
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                if (currentExercise?.image != null &&
                                    currentExercise!.image.isNotEmpty)
                                  Image.network(
                                    currentExercise.image,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                else
                                  Image.asset(
                                    'assets/images/exercise.jpg',
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                if (_isVideoLoading)
                                  const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                else
                                  const CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white70,
                                    child: Icon(
                                      Icons.play_arrow,
                                      size: 35,
                                      color: Colors.black87,
                                    ),
                                  ),
                              ],
                            ),
                    ),

                    const SizedBox(height: 10),

                    if (currentExercise != null)
                      Text(
                        currentExercise.exerciseName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    const SizedBox(height: 12),

                    /// SET CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF263D57),
                      ),
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const SizedBox(
                            height: 180,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          );
                        }
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: controller.isSaving.value
                                    ? null
                                    : () {
                                        _dismissKeyboard();
                                        controller.updateExerciseSettings();
                                      },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4B7FA8),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF70AACD),
                                    ),
                                  ),
                                  child: controller.isSaving.value
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Save',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.setControllers.length,
                              itemBuilder: (context, index) {
                                final controllers =
                                    controller.setControllers[index];
                                final isLastSet =
                                    index == controller.setControllers.length - 1;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Set ${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: controllers['kg'],
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                          textInputAction: isLastSet
                                              ? TextInputAction.done
                                              : TextInputAction.next,
                                          scrollPadding: const EdgeInsets.only(
                                            bottom: 160,
                                          ),
                                          onSubmitted: (_) {
                                            if (isLastSet) {
                                              _dismissKeyboard();
                                            }
                                          },
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          decoration: inputDecoration('kg'),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: controllers['reps'],
                                          keyboardType: TextInputType.number,
                                          textInputAction: isLastSet
                                              ? TextInputAction.done
                                              : TextInputAction.next,
                                          scrollPadding: const EdgeInsets.only(
                                            bottom: 160,
                                          ),
                                          onSubmitted: (_) => _dismissKeyboard(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          decoration: inputDecoration('reps'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          _dismissKeyboard();
                                          controller.removeSet(index);
                                        },
                                        child: const Icon(
                                          Icons.cancel_outlined,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 10),

                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 51),
                                side: const BorderSide(
                                  color: Color(0xFF70AACD),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                _dismissKeyboard();
                                controller.addSet();
                              },
                              child: const Text(
                                'Add New Set',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            if (keyboardVisible)
              _KeyboardDismissBar(onDismiss: _dismissKeyboard),

            Padding(
              padding: EdgeInsets.fromLTRB(
                18,
                keyboardVisible ? 4 : 0,
                18,
                keyboardVisible ? 8 : 10,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _dismissKeyboard();
                    nextExercise();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF8AC5E5), Color(0xFF5B89B2)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        currentExerciseIndex < totalExercises - 1
                            ? 'Next Exercise'
                            : 'Continue',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: const Color(0xff1E334B),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF1A263D)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF1A263D)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF70AACD)),
      ),
    );
  }
}

class _KeyboardDismissBar extends StatelessWidget {
  final VoidCallback onDismiss;

  const _KeyboardDismissBar({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1E334B),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF70AACD)),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.keyboard_hide, color: Colors.white54, size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Editing set values',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: onDismiss,
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Color(0xFF8AC5E5),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
