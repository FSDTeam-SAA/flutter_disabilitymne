import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/exercise_detail_screen.dart';

class LibraryWidget extends StatelessWidget {
  const LibraryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search Exercises...",
                hintStyle: TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        /// Exercise List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: const [
              ExerciseCard(
                title: "Chest Press Machines",
                subtitle: "Chest • Gym machines",
              ),

              ExerciseCard(
                title: "Banded Bicep Curl",
                subtitle: "Arms • Resistance Bands",
              ),

              ExerciseCard(
                title: "Seated Hip Abductors",
                subtitle: "Arms • Resistance Bands",
              ),

              ExerciseCard(
                title: "Leg Extension Machine",
                subtitle: "Legs • Gym machines",
              ),

              ExerciseCard(
                title: "Banded Kneeling Poirj...",
                subtitle: "Chest • Resistance Bands",
              ),
              ExerciseCard(
                title: "Chest Press Machines",
                subtitle: "Chest • Gym machines",
              ),

              ExerciseCard(
                title: "Banded Bicep Curl",
                subtitle: "Arms • Resistance Bands",
              ),

              ExerciseCard(
                title: "Seated Hip Abductors",
                subtitle: "Arms • Resistance Bands",
              ),

              ExerciseCard(
                title: "Leg Extension Machine",
                subtitle: "Legs • Gym machines",
              ),

              ExerciseCard(
                title: "Banded Kneeling Poirj...",
                subtitle: "Chest • Resistance Bands",
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ExerciseCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const ExerciseCard({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ExerciseDetailScreen(title: title, subtitle: subtitle));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
          gradient: const LinearGradient(
            colors: [Color(0xff0F1C2E), Color(0xff1B2D4A)],
          ),
        ),
        child: Row(
          children: [
            /// Thumbnail
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b",
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  height: 28,
                  width: 28,
                  decoration: const BoxDecoration(
                    color: Colors.white70,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            /// Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
