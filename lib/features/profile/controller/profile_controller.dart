import 'package:disabilitymne/features/auth/model/user_model.dart';
import 'package:disabilitymne/features/profile/services/profile_interface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  ProfileController({required this.profileInterface});

  final ProfileInterface profileInterface;

  /// user model
  Rxn<UserModel> user = Rxn<UserModel>();

  /// text controllers
  final nameController = TextEditingController();
  final genderController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final fitnessGoalsController = TextEditingController();
  final mobilityTypeController = TextEditingController();
  final fitnessExperienceController = TextEditingController();

  /// image picker
  final RxnString pickedImagePath = RxnString();
  final ImagePicker _picker = ImagePicker();

  /// edit mode
  final RxBool isEditing = false.obs;

  /// loading
  final RxBool isLoading = false.obs;

  /// toggle edit mode
  void toggleEdit() {
    isEditing.toggle();
  }

  /// ================================
  /// GET PROFILE API
  /// ================================
  Future<void> getProfile() async {
    isLoading.value = true;

    final response = await profileInterface.getProfile(UserModel());

    response.fold(
      (failure) {
        Get.snackbar("Error", failure.uiMessage);
      },
      (success) {
        final userData = success.data;

        if (userData != null) {
          user.value = userData;

          /// fill controllers
          nameController.text =
              "${userData.firstName ?? ''} ${userData.lastName ?? ''}".trim();

          genderController.text = userData.gender ?? '';

          ageController.text = userData.age != null
              ? userData.age.toString()
              : '';

          heightController.text = userData.height != null
              ? "${userData.height}"
              : '';

          weightController.text = userData.weightCurrent != null
              ? "${userData.weightCurrent}"
              : '';

          fitnessGoalsController.text = userData.fitnessGoals?.join(", ") ?? '';

          mobilityTypeController.text = userData.mobilityType ?? '';

          fitnessExperienceController.text = userData.fitnessExperience ?? '';
        }
      },
    );

    isLoading.value = false;
  }

  /// ================================
  /// UPDATE PROFILE
  /// ================================
  Future<void> updateProfile() async {
    try {
      Get.snackbar(
        "Success",
        "Profile updated successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );

      toggleEdit();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// ================================
  /// PICK IMAGE
  /// ================================
  Future<void> pickImageFromSource(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);

      if (image != null) {
        pickedImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: $e");
    }
  }

  /// ================================
  /// UPLOAD PROFILE IMAGE
  /// ================================
  Future<void> uploadProfilePicture() async {
    if (pickedImagePath.value == null) {
      Get.snackbar("Error", "Please select image first");
      return;
    }

    try {
      Get.snackbar(
        "Success",
        "Profile picture uploaded successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// ================================
  /// INIT
  /// ================================
  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  /// ================================
  /// DISPOSE
  /// ================================
  @override
  void onClose() {
    nameController.dispose();
    genderController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    fitnessGoalsController.dispose();
    mobilityTypeController.dispose();
    fitnessExperienceController.dispose();
    super.onClose();
  }
}
