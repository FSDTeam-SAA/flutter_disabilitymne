import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/features/programs/controller/workout_session_controller.dart';
import 'package:disabilitymne/features/programs/model/explore_program_model.dart';
import 'package:disabilitymne/features/programs/services/program_interface.dart';

class WorkoutCompleteScreen extends StatefulWidget {
  final ProgramModel program;
  final int dayIndex;
  final String dayLabel;
  final String sessionTag;

  const WorkoutCompleteScreen({
    super.key,
    required this.program,
    required this.dayIndex,
    required this.dayLabel,
    required this.sessionTag,
  });

  @override
  State<WorkoutCompleteScreen> createState() => _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState extends State<WorkoutCompleteScreen> {
  int selectedIndex = -1;
  bool isSubmitting = false;
  final TextEditingController notesController = TextEditingController();

  final List<Map<String, dynamic>> reactions = [
    {"image": "assets/logo/Group.png", "title": "Easy", "level": "easy"},
    {"image": "assets/logo/Frame.png", "title": "Intermediate", "level": "intermediate"},
    {"image": "assets/logo/3.png", "title": "Very Hard", "level": "very_hard"},
  ];

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> _submitWorkoutCompletion() async {
    if (isSubmitting) return;

    if (widget.program.id == null || widget.program.id!.isEmpty) {
      Get.snackbar("Error", "Program id is missing. Please try again.");
      return;
    }

    if (!Get.isRegistered<WorkoutSessionController>(tag: widget.sessionTag)) {
      Get.snackbar("Error", "Workout session data was not found.");
      return;
    }

    final sessionController = Get.find<WorkoutSessionController>(tag: widget.sessionTag);
    if (!sessionController.isDayComplete) {
      Get.snackbar(
        "Workout incomplete",
        "Complete all assigned exercises before submitting this day.",
      );
      return;
    }

    final exercisesPayload = sessionController.buildExercisePayload();
    if (exercisesPayload.isEmpty) {
      Get.snackbar("Workout incomplete", "No completed exercises found for this session.");
      return;
    }

    final payload = <String, dynamic>{
      'programId': widget.program.id,
      'dayIndex': widget.dayIndex,
      'weekStartDate': sessionController.weekStartDate,
      'tzOffsetMinutes': sessionController.tzOffsetMinutes,
      'exercises': exercisesPayload,
    };

    if (selectedIndex >= 0) {
      payload['experienceLevel'] = reactions[selectedIndex]['level'];
    }

    final note = notesController.text.trim();
    if (note.isNotEmpty) {
      payload['notes'] = note;
    }

    setState(() {
      isSubmitting = true;
    });

    final response = await Get.find<ProgramInterface>().completeWorkoutSession(payload);
    response.fold(
      (error) {
        if (!mounted) return;
        setState(() {
          isSubmitting = false;
        });
        Get.snackbar("Error", error.uiMessage);
      },
      (success) {
        if (!mounted) return;
        setState(() {
          isSubmitting = false;
        });
        Get.snackbar("Success", success.message);

        if (Get.isRegistered<WorkoutSessionController>(tag: widget.sessionTag)) {
          Get.delete<WorkoutSessionController>(tag: widget.sessionTag, force: true);
        }

        Navigator.popUntil(
          context,
          (route) => !Navigator.canPop(context),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff0D1B2A), Color(0xff1B263B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Text(
                "Congratulation!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "You have completed todays all workout for this program",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),

              const SizedBox(height: 6),

              Text(
                widget.dayLabel.isNotEmpty ? "Completed: ${widget.dayLabel}" : "Completed day ${widget.dayIndex}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 13),
              ),

              const SizedBox(height: 30),

              /// Trophy Image
              Image.asset("assets/image/congratulations_2.png", height: 180),

              const SizedBox(height: 16),

              const Text(
                "How was this experience?",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),

              const SizedBox(height: 4),

              /// Reaction Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(reactions.length, (index) {
                  final item = reactions[index];

                  final isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Color(0xFF82C0DF)
                                : Colors.transparent,
                          ),
                          child: Image.asset(
                            item["image"],
                            height: 48,
                            width: 48,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item["title"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 25),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Notes ( Optional )",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),

              const SizedBox(height: 10),

              /// Notes TextField
              TextField(
                controller: notesController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Type your notes here",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.transparent,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
              ),

              const Spacer(),

              /// Next Program Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitWorkoutCompletion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6FA9D6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isSubmitting ? "Submitting..." : "Complete Workout Day",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// Back To Home Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.popUntil(
                      context,
                      (route) => !Navigator.canPop(context),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Back to Home",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
