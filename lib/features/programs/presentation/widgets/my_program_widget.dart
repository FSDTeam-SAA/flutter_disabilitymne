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
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.programList.isEmpty) {
        return const Center(
          child: Text("No Programs Yet", style: TextStyle(color: Colors.white)),
        );
      }

      return ListView.builder(
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
    });
  }
}
