import 'package:cached_network_image/cached_network_image.dart';
import 'package:disabilitymne/features/programs/controller/explore_program%20controller.dart';
import 'package:disabilitymne/features/programs/presentation/screens/program_detail_screen.dart';
import 'package:disabilitymne/features/programs/services/program_interface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
              controller.loadMorePrograms();
            }
            return false;
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount:
                controller.programList.length +
                (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.programList.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final program = controller.programList[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ProgramCard(
                  title: program.programName,
                  image: program.programThumbnail,
                  imageFit: BoxFit.cover,
                  onTap: () {
                    Get.to(() => ProgramDetailScreen(program: program));
                  },
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class ProgramCard extends StatelessWidget {
  static const double bannerHeight = 200;
  static const double bannerAspectRatio = 2.0;
  static double get horizontalBannerWidth => bannerHeight * bannerAspectRatio;

  final String? title;
  final String? image;
  final VoidCallback? onTap;
  final BoxFit imageFit;

  const ProgramCard({
    super.key,
    this.title,
    this.image,
    this.onTap,
    this.imageFit = BoxFit.cover,
  });

  Widget _buildPlaceholder() {
    return Container(
      height: bannerHeight,
      width: double.infinity,
      color: const Color(0xFF172435),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.white54,
        size: 50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: bannerHeight,
          width: double.infinity,
          child: image == null || image!.isEmpty
              ? _buildPlaceholder()
              : ColoredBox(
                  color: const Color(0xFF172435),
                  child: CachedNetworkImage(
                    imageUrl: image!,
                    width: double.infinity,
                    height: bannerHeight,
                    fit: imageFit,
                    alignment: Alignment.center,
                    placeholder: (_, _) => Container(
                      height: bannerHeight,
                      width: double.infinity,
                      color: const Color(0xFF172435),
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        color: Color(0xff6FA8DC),
                        strokeWidth: 2,
                      ),
                    ),
                    errorWidget: (_, _, _) => _buildPlaceholder(),
                  ),
                ),
        ),
      ),
    );
  }
}
