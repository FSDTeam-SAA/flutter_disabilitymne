import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/text_style.dart';

class ProgramDetailScreen extends StatelessWidget {
  final String title;

  const ProgramDetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0E1A2B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        ),
        title: Text(
          "Back",
          style: AppText.lgMedium_18_500.copyWith(color: Colors.white),
        ),
        titleSpacing: 0,
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Banner Image
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      "https://i.imgur.com/8Km9tLL.png", // Using the image from ProgramCard
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// Title and Chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppText.xl2Medium_22_500.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildInfoChip("12 Exercise"),
                            _buildInfoChip("30 min"),
                            _buildInfoChip("12 Weeks"),
                            _buildInfoChip("Beginner"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Description",
                        style: AppText.lgMedium_18_500.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                        style: AppText.smRegular_14_400.copyWith(
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// Safety Note
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xff1C2533),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Safety Note",
                              style: AppText.mdSemiBold_16_600.copyWith(
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Stop if you feel pain. Consult your physiotherapist before starting if recovering from injury.",
                          style: AppText.smRegular_14_400.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// Workout Plan List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "12 Exercise in this workout plan",
                        style: AppText.lgMedium_18_500.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildWorkoutStep(1, "First click on start workout"),
                      _buildWorkoutStep(2, "Seated Shoulder Press"),
                      _buildWorkoutStep(3, "Resistance Band Row"),
                      _buildWorkoutStep(4, "Seated Chest Press"),
                      _buildWorkoutStep(5, "Wheelchair Push Drill"),
                      _buildWorkoutStep(6, "Arm Raises"),
                      _buildWorkoutStep(7, "Dumbbell Curl"),
                      _buildWorkoutStep(8, "Tricep Extension"),
                      _buildWorkoutStep(9, "Seated Punch"),
                      _buildWorkoutStep(10, "Seated March"),
                      _buildWorkoutStep(11, "Mobility Stretch"),
                      _buildWorkoutStep(12, "Cool Down"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xff4D7EA9), Color(0xff89C9E6)],
                ),
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Start Workout",
                  style: AppText.mdSemiBold_16_600.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        label,
        style: AppText.xsRegular_12_400.copyWith(color: Colors.white70),
      ),
    );
  }

  Widget _buildWorkoutStep(int step, String title) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xff4D7EA9),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  step.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (step < 12)
                Expanded(child: Container(width: 2, color: Colors.white24)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                title,
                style: AppText.mdMedium_16_500.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
