import 'package:disabilitymne/features/programs/model/explore_program_model.dart';
import 'package:disabilitymne/features/programs/presentation/screens/congratulation_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ExerciseScreen extends StatefulWidget {
  final ProgramModel program;
  final int initialIndex;
  const ExerciseScreen({
    super.key,
    required this.program,
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

  List<Map<String, TextEditingController>> sets = [
    {"kg": TextEditingController(text: "06"), "reps": TextEditingController()},
    {"kg": TextEditingController(text: "06"), "reps": TextEditingController()},
    {"kg": TextEditingController(text: "08"), "reps": TextEditingController()},
  ];

  @override
  void initState() {
    super.initState();
    currentExerciseIndex = widget.initialIndex;
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

  void addSet() {
    setState(() {
      sets.add({
        "kg": TextEditingController(),
        "reps": TextEditingController(),
      });
    });
  }

  void removeSet(int index) {
    setState(() {
      sets.removeAt(index);
    });
  }

  void nextExercise() {
    final totalExercises = widget.program.exercises?.length ?? 0;
    debugPrint(
      "Next Exercise clicked. Current Index: $currentExerciseIndex, Total: $totalExercises",
    );

    if (currentExerciseIndex < totalExercises - 1) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ExerciseScreen(
            program: widget.program,
            initialIndex: currentExerciseIndex + 1,
          ),
        ),
      );
    } else {
      debugPrint("Exercise completed. Popping back to Program screen.");
      // Done - Popup to program screen (Pop all exercise screens + ReadyStartScreen)
      int popCount = totalExercises + 1; // All exercises + ReadyStartScreen
      int currentPop = 0;
      // Navigator.popUntil(context, (route) {
      //   return currentPop++ == popCount;
      // });
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
      backgroundColor: const Color(0xff0F1C2E),
      body: SafeArea(
        child: Padding(
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
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text("Back", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Text(
                    "Exercise ${currentExerciseIndex + 1} of $totalExercises",
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

              const SizedBox(height: 20),

              /// VIDEO CARD
              Container(
                height: 200,
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
                              "assets/images/exercise.jpg",
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          if (_isVideoLoading)
                            const CircularProgressIndicator(color: Colors.white)
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

              const SizedBox(height: 10),

              /// SET CARD
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF263D57),
                  ),
                  child: Column(
                    children: [
                      /// SAVE BUTTON
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4B7FA8),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF70AACD)),
                          ),
                          child: const Text(
                            "Save",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// SET LIST
                      Expanded(
                        child: ListView.builder(
                          itemCount: sets.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  /// SET TITLE
                                  Text(
                                    "Set ${index + 1}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 20),

                                  /// KG FIELD
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: sets[index]["kg"],
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: inputDecoration("kg"),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  /// REPS FIELD
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: sets[index]["reps"],
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: inputDecoration("reps"),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  /// DELETE BUTTON
                                  GestureDetector(
                                    onTap: () => removeSet(index),
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
                      ),

                      const SizedBox(height: 10),

                      /// ADD SET BUTTON
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 51),
                          side: const BorderSide(color: Color(0xFF70AACD)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: addSet,
                        child: const Text(
                          "Add New Set",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// NEXT BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: nextExercise,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff9BD3FF), Color(0xff5CA9D6)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        currentExerciseIndex < totalExercises - 1
                            ? "Next Exercise"
                            : "Continue",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
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
        borderSide: const BorderSide(color: Color(0xFF1A263D)),
      ),
    );
  }
}
