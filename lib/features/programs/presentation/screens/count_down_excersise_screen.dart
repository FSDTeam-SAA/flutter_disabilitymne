import 'dart:async';
import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:disabilitymne/features/programs/model/explore_program_model.dart';
import 'package:disabilitymne/features/programs/presentation/screens/congratulation_screen.dart';
import 'package:disabilitymne/features/programs/presentation/screens/exercise_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ExerciseWorkoutScreen extends StatefulWidget {
  final ProgramModel program;
  final int initialIndex;
  const ExerciseWorkoutScreen({
    super.key,
    required this.program,
    this.initialIndex = 0,
  });

  @override
  State<ExerciseWorkoutScreen> createState() => _ExerciseWorkoutScreenState();
}

class _ExerciseWorkoutScreenState extends State<ExerciseWorkoutScreen> {
  int seconds = 30;
  int _remainingSeconds = 30;
  Timer? _timer;
  bool _isTimerPausedManually = false;
  late int currentExerciseIndex;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoLoading = false;
  bool _isVideoCompleted = false;

  @override
  void initState() {
    super.initState();
    currentExerciseIndex = widget.initialIndex;
    _initializeExerciseVideo();
  }

  @override
  void dispose() {
    _timer?.cancel();
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
    final exercises = widget.program.exercises ?? [];
    if (exercises.isEmpty || currentExerciseIndex >= exercises.length) return;

    final currentExercise = exercises[currentExerciseIndex];
    final videoUrl = currentExercise.demoVideo.isNotEmpty
        ? currentExercise.demoVideo
        : (currentExercise.demoVideos.isNotEmpty
              ? currentExercise.demoVideos.first
              : '');

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
        looping: false,
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
      if (_videoPlayerController!.value.isPlaying &&
          _timer == null &&
          !_isTimerPausedManually) {
        _startTimer();
      } else if (!_videoPlayerController!.value.isPlaying && _timer != null) {
        _pauseTimer();
      }

      if (_videoPlayerController!.value.position >=
          _videoPlayerController!.value.duration) {
        if (!_isVideoCompleted) {
          setState(() {
            _isVideoCompleted = true;
          });
          _pauseTimer();
        }
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerPausedManually = false;
      if (_remainingSeconds == 0) {
        _remainingSeconds = seconds;
      }
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
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
    final totalExercises = widget.program.exercises?.length ?? 0;
    if (currentExerciseIndex < totalExercises - 1) {
      final nextIdx = currentExerciseIndex + 1;
      final nextExecMode = widget.program.exercises![nextIdx].executionMode;

      if (nextExecMode == 'countdown') {
        Get.to(
          () => ExerciseWorkoutScreen(
            program: widget.program,
            initialIndex: nextIdx,
          ),
          preventDuplicates: false,
        );
      } else {
        Get.to(
          () => ExerciseScreen(program: widget.program, initialIndex: nextIdx),
          preventDuplicates: false,
        );
      }
    } else {
      Get.to(() => WorkoutCompleteScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.program.exercises ?? [];
    final currentExercise = exercises.isNotEmpty
        ? exercises[currentExerciseIndex]
        : null;
    final totalExercises = exercises.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundImage(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 10),

                /// TOP BAR
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
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

                const SizedBox(height: 12),

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

                const SizedBox(height: 16),

                /// VIDEO THUMBNAIL / VIDEO PLAYER
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.black,
                    ),
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
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              else
                                Image.network(
                                  "https://images.unsplash.com/photo-1517836357463-d25dfeac3438",
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
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
                                    color: Colors.white.withOpacity(.9),
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

                const SizedBox(height: 20),

                /// WORKOUT CARD
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF334C68),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            currentExercise?.exerciseName ??
                                "First click on start workout",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            currentExercise != null
                                ? "${currentExercise.defaultSets.length} sets"
                                : "4 sets - 15 reps",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),

                        const SizedBox(height: 40),

                        /// TIMER CIRCLE
                        SizedBox(
                          height: 180,
                          width: 180,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 180,
                                width: 180,
                                child: CircularProgressIndicator(
                                  value: seconds > 0 ? _remainingSeconds / seconds : 0,
                                  strokeWidth: 20,
                                  backgroundColor: Colors.white24,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                ),
                              ),
                              Text(
                                "00:${_remainingSeconds.toString().padLeft(2, '0')}",
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        /// BUTTONS
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _pauseTimer();
                          setState(() {
                            _remainingSeconds = 0;
                            _isTimerPausedManually = true;
                          });
                        },
                        child: Container(
                          height: 50,
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
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_isVideoCompleted) {
                            nextExercise();
                          } else {
                            if (_timer != null) {
                              _pauseTimer();
                              setState(() {
                                _isTimerPausedManually = true;
                              });
                            } else {
                              _videoPlayerController?.play();
                              _startTimer();
                            }
                          }
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7FC1E8), Color(0xFF3C79B5)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              _isVideoCompleted ? "Next" : (_timer != null ? "pause" : "play"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
