import 'dart:async';

import 'package:disabilitymne/app/controller/app_ground_controller.dart';
import 'package:disabilitymne/core/auth/subscription_gate.dart';
import 'package:disabilitymne/core/helpers/premium_access.dart';
import 'package:disabilitymne/core/theme/app_colors.dart';
import 'package:disabilitymne/features/calculator/presentation/screens/calculator_screen.dart';
import 'package:disabilitymne/features/home/presentation/home_screen.dart';
import 'package:disabilitymne/features/profile/controller/profile_controller.dart';
import 'package:disabilitymne/features/profile/presentation/profile_screen.dart';
import 'package:disabilitymne/features/programs/presentation/screens/program_screen.dart';
import 'package:disabilitymne/features/recipies/presentation/screen/recipies_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppGround extends StatefulWidget {
  const AppGround({super.key});

  @override
  State<AppGround> createState() => _AppGroundState();
}

class _AppGroundState extends State<AppGround> with WidgetsBindingObserver {
  late final AppGroundController controller;
  Worker? _paidAccessWorker;
  Timer? _subscriptionPollTimer;

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
    // Permanent controller keeps last tab (e.g. Profile) across logout→login.
    controller.resetToHome();
    WidgetsBinding.instance.addObserver(this);
    if (Get.isRegistered<ProfileController>()) {
      final profile = Get.find<ProfileController>();
      void kickIfUnpaid() {
        final user = profile.user.value;
        if (user != null && !isPaidSubscriber(user)) {
          Get.offAll(() => screenForAuthenticatedUser(user));
        }
      }

      kickIfUnpaid();
      _paidAccessWorker = ever(profile.user, (_) => kickIfUnpaid());
    }

    // Re-check membership periodically so expired App Store subs lock the app.
    _subscriptionPollTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      if (!Get.isRegistered<ProfileController>()) return;
      Get.find<ProfileController>().getProfile();
    });
  }

  @override
  void dispose() {
    _subscriptionPollTimer?.cancel();
    _paidAccessWorker?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().getProfile();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final isPremium = Get.isRegistered<ProfileController>()
            ? isPremiumActiveUser(Get.find<ProfileController>().user.value)
            : false;

        final pages = [
          HomeScreen(isPremiumUser: isPremium),
          const ProgramsScreen(),
          const RecipesScreen(),
          CalculatorScreen(),
          ProfileScreen(),
        ];

        return pages[controller.currentIndex.value];
      }),
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
                color: Colors.black.withValues(alpha: .4),
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
