import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final nameController = TextEditingController(text: "Evan");
  final genderController = TextEditingController(text: "Female");
  final ageController = TextEditingController(text: "26");
  final heightController = TextEditingController(text: "182 cm");
  final weightController = TextEditingController(text: "72 kg");
  final fitnessGoalsController = TextEditingController(
    text: "Improve Mobility, Build Strength",
  );
  final mobilityTypeController = TextEditingController(text: "Wheelchair User");
  final fitnessExperienceController = TextEditingController(text: "Beginner");

  final RxnString pickedImagePath = RxnString();
  final ImagePicker _picker = ImagePicker();
  final RxBool isEditing = false.obs;

  void toggleEdit() {
    isEditing.toggle();
  }

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

  void uploadProfilePicture() {
    if (pickedImagePath.value != null) {
      // Placeholder for actual API call
      Get.snackbar(
        "Success",
        "Profile picture uploaded successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar("Error", "Please select an image first");
    }
  }

  void updateProfile() {
    Get.snackbar(
      "Success",
      "Profile updated successfully",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.7),
      colorText: Colors.white,
    );
  }

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
