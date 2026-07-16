import 'package:disabilitymne/core/helpers/premium_access.dart';
import 'package:disabilitymne/features/profile/controller/profile_controller.dart';
import 'package:disabilitymne/features/programs/presentation/widgets/explore_program_widget.dart';
import 'package:disabilitymne/features/programs/presentation/widgets/library_widget.dart';
import 'package:disabilitymne/features/programs/presentation/widgets/my_program_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  int selectedTab = 0;

  ProfileController get _profileController => Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = _profileController.user.value;
      final hideExplore = premiumShouldHideExplore(user);
      final tabs = hideExplore
          ? const ["Your Program", "Library"]
          : const ["Your Program", "Explore", "Library"];
      final tabIndex = selectedTab.clamp(0, tabs.length - 1);

      return Scaffold(
        backgroundColor: const Color(0xff0E1A2B),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Programs",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  hideExplore
                      ? "Your assigned workouts and exercise library"
                      : "Adaptive exercises for your ability",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              if (hideExplore && !premiumHasAssignedWorkout(user))
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Text(
                    premiumAwaitingCoachMessage,
                    style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.35),
                  ),
                ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: List.generate(
                      tabs.length,
                      (index) => Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTab = index;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: tabIndex == index
                                  ? const Color(0xff6FA8DC)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              tabs[index],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: tabIndex == index
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: IndexedStack(
                  index: tabIndex,
                  children: hideExplore
                      ? [MyProgramWidget(), LibraryWidget()]
                      : [
                          MyProgramWidget(),
                          ExploreWidget(),
                          LibraryWidget(),
                        ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
