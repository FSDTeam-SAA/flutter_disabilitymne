import 'dart:io';
import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:disabilitymne/features/profile/constants/profile_field_options.dart';
import 'package:disabilitymne/features/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MyProfileScreen extends GetView<ProfileController> {
  const MyProfileScreen({super.key});

  Future<void> _handleRefresh() async {
    if (controller.isEditing.value || controller.isUploadingImage.value) {
      return;
    }
    await controller.getProfile();
  }

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

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: const Color(0xff6FA8DC),
                    backgroundColor: const Color(0xff0E1A2B),
                    notificationPredicate: (notification) {
                      return !controller.isEditing.value &&
                          !controller.isUploadingImage.value &&
                          defaultScrollNotificationPredicate(notification);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          /// Profile Image
                          Center(
                            child: Obx(
                              () => GestureDetector(
                                onTap: () {
                                  if (controller.isEditing.value &&
                                      !controller.isUploadingImage.value) {
                                    _showImageSourceBottomSheet(context);
                                  }
                                },
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 80,
                                      backgroundImage:
                                          controller.pickedImagePath.value !=
                                              null
                                          ? FileImage(
                                              File(
                                                controller
                                                    .pickedImagePath
                                                    .value!,
                                              ),
                                            )
                                          : (controller
                                                        .user
                                                        .value
                                                        ?.profileImage !=
                                                    null &&
                                                controller
                                                    .user
                                                    .value!
                                                    .profileImage!
                                                    .isNotEmpty)
                                          ? NetworkImage(
                                              controller
                                                  .user
                                                  .value!
                                                  .profileImage!,
                                            )
                                          : const AssetImage(
                                                  "assets/image/app_logo.png",
                                                )
                                                as ImageProvider,
                                    ),
                                    if (controller.isEditing.value)
                                      Positioned(
                                        bottom: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () {
                                            if (controller.isEditing.value &&
                                                !controller
                                                    .isUploadingImage
                                                    .value) {
                                              _showImageSourceBottomSheet(
                                                context,
                                              );
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 3,
                                              ),
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
                                    if (controller.isUploadingImage.value)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black45,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "Personal Info",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Obx(() {
                            if (controller.isLoading.value) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 40.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ProfileField(
                                  label: 'Name',
                                  controller: controller.nameController,
                                  enabled: controller.isEditing.value,
                                ),
                                ProfileField(
                                  label: 'Gender',
                                  enabled: controller.isEditing.value,
                                  isDropdown: true,
                                  selectedValue: controller.selectedGender,
                                  dropdownItems: ProfileFieldOptions.genders,
                                  optionLabels: ProfileFieldOptions.genderLabels,
                                ),
                                ProfileField(
                                  label: 'Age',
                                  enabled: controller.isEditing.value,
                                  isDropdown: true,
                                  usePickerSheet: true,
                                  selectedValue: controller.selectedAge,
                                  dropdownItems: ProfileFieldOptions.ageOptions,
                                  displayValueBuilder: ProfileFieldOptions.formatAge,
                                ),
                                ProfileField(
                                  label: 'Height',
                                  enabled: controller.isEditing.value,
                                  isMeasurement: true,
                                  usePickerSheet: true,
                                  selectedValue: controller.selectedHeight,
                                  dropdownItems: controller.heightValueOptions,
                                  unit: controller.heightUnit,
                                  units: ProfileController.HEIGHT_UNITS,
                                  onUnitChanged: controller.onHeightUnitChanged,
                                  displayValueBuilder: (value) =>
                                      ProfileFieldOptions.formatHeight(
                                        value,
                                        controller.heightUnit.value,
                                      ),
                                ),
                                ProfileField(
                                  label: 'Weight',
                                  enabled: controller.isEditing.value,
                                  isMeasurement: true,
                                  usePickerSheet: true,
                                  selectedValue: controller.selectedWeight,
                                  dropdownItems: controller.weightValueOptions,
                                  unit: controller.weightUnit,
                                  units: ProfileController.WEIGHT_UNITS,
                                  onUnitChanged: controller.onWeightUnitChanged,
                                  displayValueBuilder: (value) =>
                                      ProfileFieldOptions.formatWeight(
                                        value,
                                        controller.weightUnit.value,
                                      ),
                                ),
                                ProfileField(
                                  label: 'Your Fitness Goals',
                                  enabled: controller.isEditing.value,
                                  isDropdown: true,
                                  selectedValue: controller.selectedFitnessGoal,
                                  dropdownItems: ProfileController.FITNESS_GOALS,
                                  optionLabels:
                                      ProfileFieldOptions.fitnessGoalLabels,
                                ),
                                ProfileField(
                                  label: 'Your mobility type',
                                  enabled: controller.isEditing.value,
                                  isDropdown: true,
                                  selectedValue: controller.selectedMobilityType,
                                  dropdownItems: ProfileController.MOBILITY_TYPES,
                                  optionLabels:
                                      ProfileFieldOptions.mobilityTypeLabels,
                                ),
                                if (controller.selectedMobilityType.value ==
                                    'other')
                                  ProfileField(
                                    label: 'Describe your mobility type',
                                    controller:
                                        controller.mobilityTypeOtherController,
                                    enabled: controller.isEditing.value,
                                  ),
                                ProfileField(
                                  label: 'Fitness experience',
                                  enabled: controller.isEditing.value,
                                  isDropdown: true,
                                  selectedValue:
                                      controller.selectedFitnessExperience,
                                  dropdownItems: ProfileController
                                      .FITNESS_EXPERIENCE_LEVELS,
                                  optionLabels: ProfileFieldOptions
                                      .fitnessExperienceLabels,
                                ),
                                const SizedBox(height: 20),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),

                /// Save Button
                Obx(
                  () => controller.isEditing.value
                      ? GestureDetector(
                          onTap: () async {
                            await controller.updateProfile();
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
              color: Colors.blue.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue.withValues(alpha:0.5)),
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
  final TextEditingController? controller;
  final bool enabled;
  final bool isMeasurement;
  final bool isDropdown;
  final bool usePickerSheet;
  final RxString? unit;
  final List<String>? units;
  final RxString? selectedValue;
  final List<String>? dropdownItems;
  final Map<String, String>? optionLabels;
  final String Function(String value)? displayValueBuilder;
  final ValueChanged<String>? onUnitChanged;

  const ProfileField({
    super.key,
    required this.label,
    this.controller,
    this.enabled = true,
    this.isMeasurement = false,
    this.isDropdown = false,
    this.usePickerSheet = false,
    this.unit,
    this.units,
    this.selectedValue,
    this.dropdownItems,
    this.optionLabels,
    this.displayValueBuilder,
    this.onUnitChanged,
  });

  String _labelFor(String value) {
    if (optionLabels != null) {
      return ProfileFieldOptions.labelFor(value, optionLabels!);
    }
    return value.replaceAll('_', ' ');
  }

  String _displayValue(String value) {
    if (value.isEmpty) return '';
    if (displayValueBuilder != null) {
      return displayValueBuilder!(value);
    }
    return _labelFor(value);
  }

  Future<void> _openPickerSheet(BuildContext context) async {
    if (!enabled ||
        selectedValue == null ||
        dropdownItems == null ||
        dropdownItems!.isEmpty) {
      return;
    }

    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1A1F26),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final initialIndex = dropdownItems!.indexOf(selectedValue!.value);
        final scrollController = ScrollController(
          initialScrollOffset: initialIndex > 0 ? initialIndex * 48.0 : 0,
        );

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Select $label',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 280,
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: dropdownItems!.length,
                  itemBuilder: (context, index) {
                    final value = dropdownItems![index];
                    final isSelected = selectedValue!.value == value;

                    return ListTile(
                      title: Text(
                        _displayValue(value),
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF6FA8DC)
                              : Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFF6FA8DC),
                            )
                          : null,
                      onTap: () => Navigator.pop(sheetContext, value),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (picked != null) {
      selectedValue!.value = picked;
    }
  }

  Widget _buildDropdownSelector(BuildContext context) {
    return Obx(() {
      final currentValue = selectedValue!.value;
      final hasValue = currentValue.isNotEmpty;

      if (usePickerSheet) {
        return InkWell(
          onTap: enabled ? () => _openPickerSheet(context) : null,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hasValue ? _displayValue(currentValue) : 'Select option',
                  style: TextStyle(
                    color: hasValue ? Colors.white : Colors.white54,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (enabled)
                const Icon(Icons.arrow_drop_down, color: Colors.blue),
            ],
          ),
        );
      }

      return DropdownButton<String>(
        value: hasValue ? currentValue : null,
        hint: const Text(
          'Select option',
          style: TextStyle(color: Colors.white54),
        ),
        isExpanded: true,
        dropdownColor: const Color(0xFF1A1F26),
        icon: enabled
            ? const Icon(Icons.arrow_drop_down, color: Colors.blue)
            : const SizedBox.shrink(),
        underline: const SizedBox.shrink(),
        onChanged: enabled
            ? (String? newValue) {
                if (newValue != null) {
                  selectedValue!.value = newValue;
                }
              }
            : null,
        items: dropdownItems!.map((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              _displayValue(value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF4B7FA8),
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
          Row(
            children: [
              Expanded(
                child: selectedValue != null && dropdownItems != null
                    ? _buildDropdownSelector(context)
                    : TextFormField(
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
              ),
              if (isMeasurement && unit != null && units != null)
                Obx(
                  () => DropdownButton<String>(
                    value: unit!.value,
                    dropdownColor: const Color(0xFF1A1F26),
                    icon: enabled
                        ? const Icon(Icons.arrow_drop_down, color: Colors.blue)
                        : const SizedBox.shrink(),
                    underline: const SizedBox.shrink(),
                    onChanged: enabled
                        ? (String? newValue) {
                            if (newValue != null) {
                              onUnitChanged?.call(newValue);
                            }
                          }
                        : null,
                    items: units!.map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
