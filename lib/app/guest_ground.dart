import 'package:disabilitymne/app/controller/app_ground_controller.dart';
import 'package:disabilitymne/core/helpers/guest_auth_prompt.dart';
import 'package:disabilitymne/core/theme/app_colors.dart';
import 'package:disabilitymne/features/calculator/presentation/screens/calculator_screen.dart';
import 'package:disabilitymne/features/guest/guest_profile_screen.dart';
import 'package:disabilitymne/features/home/presentation/home_screen.dart';
import 'package:disabilitymne/features/programs/presentation/screens/program_screen.dart';
import 'package:disabilitymne/features/recipies/presentation/screen/recipies_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Main shell for unauthenticated users — recipes are free; other tabs require sign-in.
class GuestGround extends StatefulWidget {
  const GuestGround({super.key});

  static const int homeTabIndex = 0;
  static const int recipesTabIndex = 2;
  static const int profileTabIndex = 4;

  @override
  State<GuestGround> createState() => _GuestGroundState();
}

class _GuestGroundState extends State<GuestGround> {
  late final AppGroundController controller;

  final List<Widget> pages = const [
    HomeScreen(isGuestMode: true),
    ProgramsScreen(),
    RecipesScreen(),
    CalculatorScreen(),
    GuestProfileScreen(),
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
  void initState() {
    super.initState();
    controller = Get.put(AppGroundController(), permanent: true);
    // Avoid marking Obx dirty while GuestGround is still mounting.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.changeIndex(GuestGround.homeTabIndex);
    });
  }

  void _onTabTap(int index) {
    if (index == GuestGround.homeTabIndex ||
        index == GuestGround.recipesTabIndex ||
        index == GuestGround.profileTabIndex) {
      controller.changeIndex(index);
      return;
    }

    final message = switch (index) {
      1 => 'Sign in to browse and start fitness programs.',
      3 => 'Sign in to use nutrition calculators.',
      _ => 'Create a free account or sign in to access this feature.',
    };
    showGuestAuthPrompt(message: message);
  }

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
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(labels.length, (index) {
                final isSelected = controller.currentIndex.value == index;

                return GestureDetector(
                  onTap: () => _onTabTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected && index == GuestGround.recipesTabIndex
                            ? Icons.restaurant_menu
                            : isSelected && index == 0
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
