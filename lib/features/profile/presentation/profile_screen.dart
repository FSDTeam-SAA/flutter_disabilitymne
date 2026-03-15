import 'dart:io';

import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:disabilitymne/features/auth/services/auth_interface.dart';
import 'package:disabilitymne/features/onboarding/choose_plan_screen.dart';
import 'package:disabilitymne/features/profile/controller/profile_controller.dart';
import 'package:disabilitymne/features/profile/presentation/change_password_screen.dart';
import 'package:disabilitymne/features/profile/presentation/daily_notes_screen.dart';
import 'package:disabilitymne/features/profile/presentation/help_support_screen.dart';
import 'package:disabilitymne/features/profile/presentation/language_accessibility_screen.dart';
import 'package:disabilitymne/features/profile/presentation/my_profile_screen.dart';
import 'package:disabilitymne/features/profile/presentation/notification_screen.dart';
import 'package:disabilitymne/features/profile/presentation/privacy_legal_screen.dart';
import 'package:disabilitymne/features/profile/presentation/terms_condition_screen.dart';
import 'package:disabilitymne/features/programs/presentation/screens/count_down_excersise_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileController controller;

  void showLogoutDialog({required VoidCallback onConfirm}) {
    Get.defaultDialog(
      backgroundColor: Colors.white,
      title: "Are you sure?",
      middleText: "Want to sign out from your application",
      titleStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      middleTextStyle: const TextStyle(fontSize: 16, color: Colors.black),
      barrierDismissible: true,
      radius: 16,
      contentPadding: const EdgeInsets.all(20),
      cancel: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          Get.back();
        },
        child: const Text("Cancel"),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF314E94),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          Get.find<AuthInterface>().logout();
        },
        child: Text("Logout"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    controller = Get.find<ProfileController>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundImage(
        child: SizedBox(
          width: double.infinity,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  /// Header – profile image & name from controller
                  Obx(() {
                    final user = controller.user.value;
                    final profileImageUrl = user?.profileImage;
                    final hasProfileImage = profileImageUrl != null &&
                        profileImageUrl.isNotEmpty;
                    final pickedPath = controller.pickedImagePath.value;

                    ImageProvider<Object> avatarImage;
                    if (pickedPath != null && File(pickedPath).existsSync()) {
                      avatarImage = FileImage(File(pickedPath));
                    } else if (hasProfileImage) {
                      avatarImage = NetworkImage(profileImageUrl);
                    } else {
                      avatarImage = const AssetImage("assets/image/app_logo.png");
                    }

                    final name = [
                      user?.firstName,
                      user?.lastName,
                    ].whereType<String>().join(' ').trim();
                    final displayName =
                        name.isNotEmpty ? name : 'User';

                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: avatarImage,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome $displayName 👋",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Good morning!",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 16),

                  /// Progress Cards
                  Row(
                    children: const [
                      Expanded(
                        child: _StatCard(
                          title: "Streak",
                          value: "7",
                          icon: Icons.local_fire_department_outlined,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          title: "Workouts",
                          value: "9",
                          icon: Icons.fitness_center,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          title: "Calories",
                          value: "0%",
                          icon: Icons.local_fire_department,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Settings List
                  Expanded(
                    child: ListView(
                      children: [
                        _SettingsTile(
                          icon: Icons.person_outline,
                          title: "My Profile",
                          subtitle: "View personal details",
                          onTap: () {
                            Get.to(() => MyProfileScreen());
                          },
                        ),
                        _SettingsTile(
                          icon: Icons.lock_outline,
                          title: "Change Password",
                          subtitle: "Update your password",
                          onTap: () {
                            Get.to(() => ChangePasswordScreen());
                          },
                        ),
                        _SettingsTile(
                          icon: Icons.note_outlined,
                          title: "Daily Notes",
                          subtitle: "View Notes you have added daily",
                          onTap: () {
                            Get.to(() => const DailyNotesScreen());
                          },
                        ),
                        _SettingsTile(
                          icon: Icons.workspace_premium_outlined,
                          title: "Subscription & Billing",
                          subtitle: "Manage your plan",
                          onTap: () {
                            Get.to(() => ChoosePlanScreen());
                          },
                        ),
                        _SettingsTile(
                          icon: Icons.language,
                          title: "Language & Accessibility",
                          subtitle: "English/Serbian",
                          onTap: () {
                            Get.to(() => const LanguageAccessibilityScreen());
                          },
                        ),
                        _SettingsTile(
                          icon: Icons.notifications_none,
                          title: "Notification Settings",
                          subtitle: "Manage alerts",
                          onTap: () {
                            Get.to(() => NotificationScreen());
                          },
                        ),
                        _SettingsTile(
                          icon: Icons.support_agent_outlined,
                          title: "Help & Support",
                          subtitle: "FAQs and contact",
                          onTap: () {
                            Get.to(() => HelpSupportScreen());
                          },
                        ),
                        _SettingsTile(
                          icon: Icons.chat_bubble_outline,
                          title: "Chat with Admin",
                          subtitle: "Message support",
                          onTap: () {
                          },
                        ),
                        _SettingsTile(
                          icon: Icons.privacy_tip_outlined,
                          title: "Privacy & Legal",
                          subtitle: "Privacy policy & data",
                          onTap: () {
                            Get.to(() => const PrivacyLegalScreen());
                          },
                        ),
                        _SettingsTile(
                          icon: Icons.description_outlined,
                          title: "Terms of Service",
                          subtitle: "App usage terms and conditions",
                          onTap: () {
                            Get.to(() => const TermsConditionScreen());
                          },
                        ),
                        _SettingsTile(
                          icon: Icons.lock_outline,
                          title: "Privacy & Security",
                          subtitle: "View personal details",
                          onTap: () {
                            Get.to(() => ExerciseWorkoutScreen());
                          },
                        ),

                        const SizedBox(height: 10),

                        /// Sign Out
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              showLogoutDialog(
                                onConfirm: () {
                                  Get.find<AuthInterface>().logout();
                                },
                              );
                            },
                            icon: const Icon(
                              Icons.logout,
                              size: 24,
                              color: Colors.red,
                            ),
                            label: const Text(
                              "Sign Out",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF223650),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF4B7FA8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(icon, color: Colors.white70),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4B7FA8)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF223148),
            border: Border.all(color: const Color(0xFF4B7FA8)),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white54,
          size: 16,
        ),
      ),
    );
  }
}
