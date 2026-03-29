import 'package:disabilitymne/features/programs/controller/explore_program%20controller.dart';
import 'package:disabilitymne/features/programs/presentation/screens/program_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:disabilitymne/features/programs/services/program_interface.dart';

class ExploreWidget extends StatelessWidget {
  ExploreWidget({super.key});

  final controller = Get.isRegistered<ProgramController>()
      ? Get.find<ProgramController>()
      : Get.put(
          ProgramController(programInterface: Get.find<ProgramInterface>()),
        );

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.getPrograms(showLoader: false),
      color: const Color(0xff6FA8DC),
      backgroundColor: const Color(0xff0E1A2B),
      child: Obx(() {
        if (controller.isLoading.value && controller.programList.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 180),
              Center(child: CircularProgressIndicator()),
            ],
          );
        }

        if (controller.programList.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 180),
              Center(
                child: Text(
                  "No Programs Found",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: controller.programList.length,
          itemBuilder: (context, index) {
            final program = controller.programList[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ProgramCard(
                title: program.programName,
                image: program.programThumbnail,
                onTap: () {
                  Get.to(() => ProgramDetailScreen(program: program));
                },
              ),
            );
          },
        );
      }),
    );
  }
}

class ProgramCard extends StatelessWidget {
  final String? title;
  final String? image;
  final VoidCallback? onTap;

  const ProgramCard({super.key, this.title, this.image, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white12,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: image == null || image!.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.white54,
                          size: 50,
                        ),
                      )
                    : Image.network(
                        image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.white54,
                                size: 50,
                              ),
                            ),
                      ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomLeft,
              child: Text(
                title ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
