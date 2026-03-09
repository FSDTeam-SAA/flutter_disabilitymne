import 'package:disabilitymne/features/programs/controller/library_controller.dart';
import 'package:disabilitymne/features/programs/model/library_model.dart';
import 'package:disabilitymne/features/programs/presentation/screens/exercise_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LibraryWidget extends StatelessWidget {
  LibraryWidget({super.key});

  final controller = Get.put(LibraryController(programInterface: Get.find()));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: controller.searchExercise,
              decoration: const InputDecoration(
                hintText: "Search Exercises...",
                hintStyle: TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        /// List
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.filteredList.isEmpty) {
              return const Center(
                child: Text(
                  "No Exercise Found",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: controller.filteredList.length,
              itemBuilder: (context, index) {
                final exercise = controller.filteredList[index];

                return ExerciseCard(model: exercise);
              },
            );
          }),
        ),
      ],
    );
  }
}

class ExerciseCard extends StatelessWidget {
  final LibraryModel model;

  const ExerciseCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ExerciseDetailScreen(id: model.id ?? ''));
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
            /// Image
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    model.exerciseImage ??
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
                    model.exerciseName ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${model.muscleGroups?.first ?? ""} • ${model.plan ?? ""}",
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
