import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:disabilitymne/features/programs/controller/my_program_controller.dart';
import 'package:disabilitymne/features/programs/controller/workout_session_controller.dart';
import 'package:disabilitymne/features/programs/model/explore_program_model.dart';
import 'package:disabilitymne/features/programs/presentation/screens/count_down_excersise_screen.dart';
import 'package:disabilitymne/features/programs/presentation/screens/exercise_screen.dart';
import 'package:disabilitymne/features/programs/services/program_interface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/helpers/app_snackbar.dart';

class ReadyStartScreen extends StatefulWidget {
  final ProgramModel program;
  final int dayIndex;
  final String dayLabel;
  final List<ProgramExerciseModel> dayExercises;

  const ReadyStartScreen({
    super.key,
    required this.program,
    required this.dayIndex,
    required this.dayLabel,
    required this.dayExercises,
  });

  @override
  State<ReadyStartScreen> createState() => _ReadyStartScreenState();
}

class _ReadyStartScreenState extends State<ReadyStartScreen> {
  bool _isStarting = false;

  String get _sessionTag {
    final rawId = widget.program.id ?? '';
    final id = rawId.isNotEmpty ? rawId : 'program';
    return 'workout-session-$id-${widget.dayIndex}';
  }

  Future<void> _startProgramTracking() async {
    if (widget.program.id == null || widget.program.id!.isEmpty) {
      return;
    }

    final response = await Get.find<ProgramInterface>().startProgram(
      ProgramModel(id: widget.program.id),
    );

    response.fold(
      (error) {
        AppSnackbar.show('Error', error.uiMessage);
      },
      (_) {
        if (Get.isRegistered<MyProgramController>()) {
          Get.find<MyProgramController>().getPrograms(showLoader: false);
        }
      },
    );
  }

  Future<void> _goToWorkout() async {
    if (widget.dayExercises.isEmpty) {
      return;
    }

    if (Get.isRegistered<WorkoutSessionController>(tag: _sessionTag)) {
      Get.delete<WorkoutSessionController>(tag: _sessionTag, force: true);
    }
    Get.put(
      WorkoutSessionController(
        program: widget.program,
        dayIndex: widget.dayIndex,
        dayLabel: widget.dayLabel,
        dayExercises: widget.dayExercises,
      ),
      tag: _sessionTag,
    );

    if (mounted) {
      setState(() => _isStarting = false);
    }

    if (widget.dayExercises.first.executionMode == 'countdown') {
      await Get.to(
        () => ExerciseWorkoutScreen(
          program: widget.program,
          dayIndex: widget.dayIndex,
          dayLabel: widget.dayLabel,
          dayExercises: widget.dayExercises,
          sessionTag: _sessionTag,
          initialIndex: 0,
        ),
        preventDuplicates: false,
      );
    } else {
      await Get.to(
        () => ExerciseScreen(
          program: widget.program,
          dayIndex: widget.dayIndex,
          dayLabel: widget.dayLabel,
          dayExercises: widget.dayExercises,
          sessionTag: _sessionTag,
          initialIndex: 0,
        ),
        preventDuplicates: false,
      );
    }

    if (mounted) {
      setState(() => _isStarting = false);
    }
  }

  Future<void> _handleReady() async {
    if (_isStarting) return;

    if (widget.dayExercises.isEmpty) {
      AppSnackbar.show(
        'No workout available',
        'No exercises are assigned for this day.',
      );
      return;
    }

    setState(() => _isStarting = true);

    try {
      await _startProgramTracking();

      if (!mounted) return;

      if (widget.dayExercises.isEmpty) {
        setState(() => _isStarting = false);
        AppSnackbar.show(
          'No workout available',
          'No exercises are assigned for this day.',
        );
        return;
      }

      await _goToWorkout();
    } catch (_) {
      if (mounted) {
        setState(() => _isStarting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundImage(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),

                /// Image
                Image.asset("assets/logo/image.png", height: 200, width: 200),

                /// Title
                const Text(
                  "Ready to start?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Adaptive Strength Training Sessions",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 25),

                /// Info Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Color(0xFF172435),
                  ),
                  child: Column(
                    children: [
                      InfoRow(
                        icon: Icons.check_circle,
                        color: Colors.green,
                        text: '${widget.dayExercises.length} Exercise',
                      ),
                      const SizedBox(height: 12),
                      InfoRow(
                        icon: Icons.access_time,
                        color: Colors.blue,
                        text: '${widget.program.durationMinutes ?? 0} Minute',
                      ),
                      const SizedBox(height: 12),
                      InfoRow(
                        icon: Icons.calendar_month,
                        color: Colors.blueAccent,
                        text: widget.dayLabel.isNotEmpty
                            ? widget.dayLabel
                            : 'Day ${widget.dayIndex}',
                      ),
                      const SizedBox(height: 12),
                      InfoRow(
                        icon: Icons.error,
                        color: Colors.red,
                        text: widget.program.safetyNote ?? 'Stop if pain occurs',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// Primary Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff8FD3FF),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(
                        0xff8FD3FF,
                      ).withValues(alpha: 0.7),
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isStarting ? null : _handleReady,
                    child: _isStarting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "I'm Ready",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 14),

                /// Outline Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isStarting ? null : () => Navigator.pop(context),
                    child: const Text(
                      "Back to Programs",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const InfoRow({
    super.key,
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Text(text, style: TextStyle(color: color, fontSize: 16)),
      ],
    );
  }
}
