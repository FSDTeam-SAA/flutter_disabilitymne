import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/text_style.dart';
import '../../controller/exercise_detail_controller.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final String id;

  const ExerciseDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ExerciseDetailController(programInterface: Get.find(), exerciseId: id),
      tag: id,
    );

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
          "Exercise Details",
          style: AppText.lgMedium_18_500.copyWith(color: Colors.white),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final model = controller.exercise.value;

        if (model == null) {
          return Center(
            child: Text(
              "Exercise not found",
              style: AppText.mdMedium_16_500.copyWith(color: Colors.white),
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Video/Image Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        model.demoVideos?.first ?? '',
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 220,
                          width: double.infinity,
                          color: Colors.white10,
                          child: const Icon(
                            Icons.image,
                            color: Colors.white24,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                    if (model.demoVideo != null && model.demoVideo!.isNotEmpty)
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 32,
                          color: Colors.black,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// Title and Plan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.exerciseName ?? '',
                      style: AppText.xxlSemiBold_24_600.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    if (model.plan != null && model.plan!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          model.plan!.toUpperCase(),
                          style: AppText.xsMedium_12_500.copyWith(
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
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
                    const SizedBox(height: 12),
                    Text(
                      model.description ?? 'No description available.',
                      style: AppText.smRegular_14_400.copyWith(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// Target Muscle Groups (as Chips)
              if (model.muscleGroups != null && model.muscleGroups!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Target Muscle Groups",
                        style: AppText.lgMedium_18_500.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: model.muscleGroups!.map((muscle) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Text(
                              muscle,
                              style: AppText.smMedium_14_500.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              /// Key Benefits
              if (model.keyBenefits != null && model.keyBenefits!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Key Benefits",
                        style: AppText.lgMedium_18_500.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...model.keyBenefits!
                          .map((benefit) => _buildBenefitItem(benefit))
                          .toList(),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              /// Target Muscle Image
              if (model.targetMuscleImage != null &&
                  model.targetMuscleImage!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Muscle Diagram",
                        style: AppText.lgMedium_18_500.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            model.targetMuscleImage!,
                            height: 250,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.accessibility_new,
                                  size: 150,
                                  color: Colors.white10,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Text("○ ", style: TextStyle(color: Colors.white70)),
          Expanded(
            child: Text(
              text,
              style: AppText.smRegular_14_400.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
