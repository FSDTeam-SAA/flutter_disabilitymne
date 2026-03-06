import 'package:disabilitymne/features/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppGround extends StatelessWidget {
  AppGround({super.key});

  final AppGroundController controller =
      Get.put(AppGroundController(), permanent: true);

  final List<Widget> pages = [
    Scaffold(),
    Scaffold(),
    Scaffold(),
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
      backgroundColor: const Color(0xFF0B1A2A),
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
                color: Colors.black.withOpacity(.4),
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
                        icons[index],
                        size: 28,
                        color: isSelected
                            ? Colors.white
                            : Colors.white70,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
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

class AppGroundController extends GetxController {
  final currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}