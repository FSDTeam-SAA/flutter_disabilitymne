import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:disabilitymne/features/programs/model/explore_program_model.dart';
import 'package:disabilitymne/features/programs/presentation/screens/exercise_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:get/utils.dart';

class ReadyStartScreen extends StatelessWidget {
  final ProgramModel program;
  const ReadyStartScreen({super.key, required this.program});

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
                Image.asset(
                  "assets/logo/image.png",
                  height: 200,
                  width: 200,
                ),
        
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
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
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
                    children: const [
                      InfoRow(
                        icon: Icons.check_circle,
                        color: Colors.green,
                        text: "12 Exercise",
                      ),
                      SizedBox(height: 12),
                      InfoRow(
                        icon: Icons.access_time,
                        color: Colors.blue,
                        text: "30 Minute",
                      ),
                      SizedBox(height: 12),
                      InfoRow(
                        icon: Icons.calendar_month,
                        color: Colors.blueAccent,
                        text: "12 Week Program",
                      ),
                      SizedBox(height: 12),
                      InfoRow(
                        icon: Icons.error,
                        color: Colors.red,
                        text: "Stop if pain occurs",
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Get.to(ExerciseScreen());
                    },
                    child: const Text(
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Back to Programs",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
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
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 14,
          ),
        )
      ],
    );
  }
}