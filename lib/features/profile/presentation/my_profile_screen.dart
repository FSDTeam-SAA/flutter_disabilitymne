import 'dart:io';
import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:disabilitymne/features/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MyProfileScreen extends GetView<ProfileController> {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundImage(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 10),

                /// Top AppBar
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        "My Profile",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Obx(
                      () => GestureDetector(
                        onTap: () => controller.toggleEdit(),
                        child: controller.isEditing.value
                            ? const Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Image(
                                image: AssetImage("assets/icon/user-edit.png"),
                                width: 24,
                              ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// Profile Image
                GestureDetector(
                  onTap: () {
                    if (controller.isEditing.value) {
                      _showImageSourceBottomSheet(context);
                    }
                  },
                  child: Stack(
                    children: [
                      Obx(
                        () => CircleAvatar(
                          radius: 80,
                          backgroundImage:
                              controller.pickedImagePath.value != null
                              ? FileImage(
                                  File(controller.pickedImagePath.value!),
                                )
                              : const NetworkImage("https://i.pravatar.cc/300")
                                    as ImageProvider,
                        ),
                      ),

                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            if (controller.isEditing.value) {
                              _showImageSourceBottomSheet(context);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(
                              Icons.photo_filter_sharp,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                /// Upload Photo Button (Visible only in edit mode)
                // Obx(
                //   () => controller.isEditing.value
                //       ? TextButton.icon(
                //           onPressed: () => _showImageSourceBottomSheet(context),
                //           icon: const Icon(
                //             Icons.cloud_upload_outlined,
                //             color: Colors.blue,
                //           ),
                //           label: const Text(
                //             "Upload Photo",
                //             style: TextStyle(
                //               color: Colors.blue,
                //               fontSize: 14,
                //               fontWeight: FontWeight.w600,
                //             ),
                //           ),
                //         )
                //       : const SizedBox.shrink(),
                // ),

                const SizedBox(height: 10),

                /// Personal Info
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Personal Info",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView(
                    children: [
                      Obx(
                        () => ProfileField(
                          label: "Name",
                          controller: controller.nameController,
                          enabled: controller.isEditing.value,
                        ),
                      ),
                      Obx(
                        () => ProfileField(
                          label: "Gender",
                          controller: controller.genderController,
                          enabled: controller.isEditing.value,
                        ),
                      ),
                      Obx(
                        () => ProfileField(
                          label: "Age",
                          controller: controller.ageController,
                          enabled: controller.isEditing.value,
                        ),
                      ),
                      Obx(
                        () => ProfileField(
                          label: "Height",
                          controller: controller.heightController,
                          enabled: controller.isEditing.value,
                        ),
                      ),
                      Obx(
                        () => ProfileField(
                          label: "Weight",
                          controller: controller.weightController,
                          enabled: controller.isEditing.value,
                        ),
                      ),
                      Obx(
                        () => ProfileField(
                          label: "Your Fitness Goals",
                          controller: controller.fitnessGoalsController,
                          enabled: controller.isEditing.value,
                        ),
                      ),
                      Obx(
                        () => ProfileField(
                          label: "Your mobility type",
                          controller: controller.mobilityTypeController,
                          enabled: controller.isEditing.value,
                        ),
                      ),
                      Obx(
                        () => ProfileField(
                          label: "Fitness experience",
                          controller: controller.fitnessExperienceController,
                          enabled: controller.isEditing.value,
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                /// Save Button
                Obx(
                  () => controller.isEditing.value
                      ? GestureDetector(
                          onTap: () {
                            controller.updateProfile();
                            controller
                                .toggleEdit(); // Exit edit mode after saving
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7FA9C9), Color(0xFF4E79A7)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                "Save",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImageSourceBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1F26),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Image Source",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt,
                  label: "Camera",
                  onTap: () {
                    Get.back();
                    controller.pickImageFromSource(ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library,
                  label: "Gallery",
                  onTap: () {
                    Get.back();
                    controller.pickImageFromSource(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue.withOpacity(0.5)),
            ),
            child: Icon(icon, color: Colors.blue, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;

  const ProfileField({
    super.key,
    required this.label,
    required this.controller,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: enabled ? Color(0xFF4B7FA8) : const Color(0xFF4B7FA8),
          width: enabled ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            readOnly: !enabled,
            cursorColor: Colors.blue,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}
