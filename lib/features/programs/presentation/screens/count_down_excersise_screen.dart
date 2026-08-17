import 'dart:async';
import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:disabilitymne/features/programs/controller/workout_session_controller.dart';
import 'package:disabilitymne/features/programs/model/explore_program_model.dart';
import 'package:disabilitymne/features/programs/model/model.dart';
import 'package:disabilitymne/features/programs/presentation/screens/congratulation_screen.dart';
import 'package:disabilitymne/features/programs/presentation/screens/exercise_screen.dart';
import 'package:disabilitymne/features/programs/utils/video_url_selector.dart';
import 'package:disabilitymne/features/programs/utils/countdown_sound_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ExerciseWorkoutScreen extends StatefulWidget {
  final ProgramModel program;
  final int dayIndex;
  final String dayLabel;
  final List<ProgramExerciseModel> dayExercises;
  final String sessionTag;
  final int initialIndex;
  const ExerciseWorkoutScreen({
    super.key,
    required this.program,
    required this.dayIndex,
    required this.dayLabel,
    required this.dayExercises,
    required this.sessionTag,
    this.initialIndex = 0,
  });

  @override
  State<ExerciseWorkoutScreen> createState() => _ExerciseWorkoutScreenState();
}

class _ExerciseWorkoutScreenState extends State<ExerciseWorkoutScreen> {
  int seconds = 30;
  int _remainingSeconds = 30;
  Timer? _timer;
  late int currentExerciseIndex;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoLoading = false;
  bool _isVideoCompleted = false;
  final CountdownSoundPlayer _countdownSounds = CountdownSoundPlayer();

  @override
  void initState() {
    super.initState();
    currentExerciseIndex = widget.initialIndex;
    _initializeExerciseVideo();
    _countdownSounds.init();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownSounds.dispose();
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
      _isVideoCompleted = false;
    });

    await _disposeVideoPlayer();

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );
      await _videoPlayerController!.initialize();

      _videoPlayerController!.addListener(_videoListener);

      setState(() {
        seconds = currentExercise.durationSeconds ?? 30;
        _remainingSeconds = seconds;
      });

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

  void _videoListener() {
    if (_videoPlayerController != null) {
      if (_videoPlayerController!.value.position >=
          _videoPlayerController!.value.duration) {
        if (!_isVideoCompleted) {
          setState(() {
            _isVideoCompleted = true;
          });
        }
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      if (_remainingSeconds == 0) {
        _remainingSeconds = seconds;
      }
    });
    _countdownSounds.prepareSession();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        _countdownSounds.playForRemaining(_remainingSeconds);
        if (_remainingSeconds == 0) {
          _pauseTimer();
        }
      } else {
        _pauseTimer();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
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
        sets: _defaultSetsFromExercise(currentExercise),
        durationMinutes: (seconds / 60).ceil(),
      );
    }

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

  @override
  Widget build(BuildContext context) {
    final exercises = widget.dayExercises;
    final currentExercise = exercises.isNotEmpty
        ? exercises[currentExerciseIndex]
        : null;
    final totalExercises = exercises.length;
    final screenH = MediaQuery.sizeOf(context).height;
    final compact = screenH < 760;
    final videoHeight = (screenH * 0.22).clamp(120.0, compact ? 156.0 : 200.0);
    final gap = compact ? 10.0 : 16.0;
    final buttonH = compact ? 46.0 : 50.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundImage(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(height: compact ? 4 : 10),

                /// TOP BAR
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          "Back",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Text(
                      "Exercise ${currentExerciseIndex + 1} of $totalExercises",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),

                SizedBox(height: compact ? 8 : 12),

                /// PROGRESS BAR
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: totalExercises > 0
                        ? (currentExerciseIndex + 1) / totalExercises
                        : 0,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.lightBlue,
                    ),
                  ),
                ),

                SizedBox(height: gap),

                /// VIDEO THUMBNAIL / VIDEO PLAYER
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: videoHeight,
                    width: double.infinity,
                    child: ColoredBox(
                      color: Colors.black,
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
                                Positioned.fill(
                                  child: currentExercise?.image != null &&
                                          currentExercise!.image.isNotEmpty
                                      ? Image.network(
                                          currentExercise.image,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          "https://images.unsplash.com/photo-1517836357463-d25dfeac3438",
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                if (_isVideoLoading)
                                  const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                else
                                  Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: .9,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      size: 36,
                                      color: Colors.black87,
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ),
                ),

                SizedBox(height: gap),

                /// WORKOUT CARD
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      16,
                      compact ? 14 : 18,
                      16,
                      compact ? 16 : 22,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF334C68),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentExercise?.exerciseName ??
                              "First click on start workout",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentExercise != null
                              ? "${currentExercise.defaultSets.length} sets"
                              : "",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: compact ? 12 : 16),
                        Expanded(
                          child: Center(
                            child: SizedBox(
                              height: compact ? 118 : 132,
                              width: compact ? 118 : 132,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox.expand(
                                    child: CircularProgressIndicator(
                                      value: seconds > 0
                                          ? _remainingSeconds / seconds
                                          : 0,
                                      strokeWidth: 14,
                                      backgroundColor: Colors.white24,
                                      valueColor:
                                          const AlwaysStoppedAnimation<
                                            Color
                                          >(Colors.white),
                                    ),
                                  ),
                                  Text(
                                    "00:${_remainingSeconds.toString().padLeft(2, '0')}",
                                    style: TextStyle(
                                      fontSize: compact ? 24 : 28,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: compact ? 16 : 20),
                Row(
                  children: [
                    /// STOP BUTTON
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _pauseTimer();
                          setState(() {
                            _remainingSeconds = 0;
                          });
                        },
                        child: Container(
                          height: buttonH,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              "Stop",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    /// PAUSE/PLAY BUTTON (Only affects Timer)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_timer != null) {
                            _pauseTimer();
                            setState(() {});
                          } else {
                            _startTimer();
                          }
                        },
                        child: Container(
                          height: buttonH,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF8AC5E5), Color(0xFF5B89B2)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              _timer != null ? "Pause" : "Play",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 10 : 16),

                /// NEXT BUTTON
                GestureDetector(
                  onTap: nextExercise,
                  child: Container(
                    height: buttonH,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF8AC5E5), Color(0xFF5B89B2)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "Next Exercise",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: compact ? 10 : 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<SetModel> _defaultSetsFromExercise(ProgramExerciseModel exercise) {
    if (exercise.defaultSets.isEmpty) {
      return const [];
    }

    final List<SetModel> sets = [];
    for (var i = 0; i < exercise.defaultSets.length; i++) {
      final item = exercise.defaultSets[i];
      if (item is! Map) {
        continue;
      }

      final setNumber = _safeInt(item['setNumber']) ?? (i + 1);
      final reps = _safeInt(item['reps']) ?? 0;
      final weightKg = _safeInt(item['weightKg']) ?? 0;
      sets.add(SetModel(setNumber: setNumber, reps: reps, weightKg: weightKg));
    }

    return sets;
  }

  int? _safeInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
