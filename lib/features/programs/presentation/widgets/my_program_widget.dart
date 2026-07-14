import 'package:disabilitymne/features/programs/controller/my_program_controller.dart';
import 'package:disabilitymne/features/programs/presentation/screens/program_detail_screen.dart';
import 'package:disabilitymne/features/programs/presentation/widgets/explore_program_widget.dart';
import 'package:disabilitymne/features/programs/services/program_interface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyProgramWidget extends StatelessWidget {
  MyProgramWidget({super.key});

  final controller = Get.isRegistered<MyProgramController>()
      ? Get.find<MyProgramController>()
      : Get.put(
          MyProgramController(programInterface: Get.find<ProgramInterface>()),
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
                  "No Programs Yet",
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
