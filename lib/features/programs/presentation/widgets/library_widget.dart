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
              color: Colors.white.withValues(alpha: 0.1),
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
          child: RefreshIndicator(
            onRefresh: controller.fetchExercises,
            color: const Color(0xff6FA8DC),
            backgroundColor: const Color(0xff0E1A2B),
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.filteredList.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 180),
                    Center(child: CircularProgressIndicator()),
                  ],
                );
              }

              if (controller.filteredList.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 180),
                    Center(
                      child: Text(
                        "No Exercise Found",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                );
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.pixels >=
                      notification.metrics.maxScrollExtent - 200) {
                    controller.loadMoreExercises();
                  }
                  return false;
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount:
                      controller.filteredList.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= controller.filteredList.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final exercise = controller.filteredList[index];

                    return ExerciseCard(model: exercise);
                  },
                ),
              );
            }),
          ),
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
    final primaryMuscleGroup = (model.muscleGroups?.isNotEmpty ?? false)
        ? model.muscleGroups!.first
        : '';
    final plan = (model.plan ?? '').trim();
    final subtitleParts = <String>[
      if (primaryMuscleGroup.isNotEmpty) primaryMuscleGroup,
      if (plan.isNotEmpty) plan,
    ];

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
                  child:
                      model.exerciseImage == null ||
                          model.exerciseImage!.isEmpty
                      ? Container(
                          height: 70,
                          width: 70,
                          color: Colors.white12,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.white54,
                            size: 30,
                          ),
                        )
                      : Image.network(
                          model.exerciseImage!,
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 70,
                                width: 70,
                                color: Colors.white12,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white54,
                                  size: 30,
                                ),
                              ),
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
                    subtitleParts.join(' • '),
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
