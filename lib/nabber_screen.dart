import 'package:disabilitymne/app/controller/app_ground_controller.dart';
import 'package:disabilitymne/core/theme/app_colors.dart';
import 'package:disabilitymne/features/home/presentation/home_screen.dart';
import 'package:disabilitymne/features/profile/presentation/profile_screen.dart';
import 'package:disabilitymne/features/programs/presentation/screens/program_screen.dart';
import 'package:disabilitymne/features/recipies/presentation/screen/recipies_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppGround extends StatelessWidget {
  AppGround({super.key});

  final AppGroundController controller =
      Get.put(AppGroundController(), permanent: true);

  final List<Widget> pages = [
    HomeScreen(isPremiumUser: true,),
    ProgramsScreen(),
    RecipesScreen(),
    Scaffold(),
    ProfileScreen(),
  ];

  final List<IconData> icons = const [
    Icons.home_outlined,
    Icons.menu_book_outlined,
    Icons.restaurant_menu_outlined,
    Icons.calculate_outlined,
    Icons.person_outline,
  ];

  final List<String> labels = const [
    'Home',
    'Programs',
    'Recipes',
    'Calculators',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => pages[controller.currentIndex.value]),
      backgroundColor: Colors.transparent,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 85,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0B1A2A),
                Color(0xFF12263A),
                
              ],
            ),
            border: Border.all(
              color: Colors.white24,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:  .4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(labels.length, (index) {
                final isSelected = controller.currentIndex.value == index;

                return GestureDetector(
                  onTap: () => controller.changeIndex(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected && index == 0
                            ? Icons.home_rounded
                            : icons[index],
                        size: 28,
                        color: isSelected
                            ? AppColors.gradientButtonEnd
                            : Colors.white70,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[index],
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.gradientButtonEnd
                              : Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}