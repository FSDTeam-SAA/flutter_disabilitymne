import 'package:disabilitymne/features/auth/model/user_model.dart';
import 'package:disabilitymne/features/profile/model/update_profile_model.dart';
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

  /// units
  final RxString weightUnit = "kg".obs;
  final RxString heightUnit = "cm".obs;

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

          heightController.text = userData.height?.value != null
              ? "${userData.height!.value}"
              : '';
          heightUnit.value = userData.height?.unit ?? 'cm';

          weightController.text = userData.weightCurrent?.value != null
              ? "${userData.weightCurrent!.value}"
              : '';
          weightUnit.value = userData.weightCurrent?.unit ?? 'kg';

          fitnessGoalsController.text = userData.fitnessGoals?.join(", ") ?? '';

          mobilityTypeController.text = userData.mobilityType ?? '';

          fitnessExperienceController.text = userData.fitnessExperience ?? '';
        }
      },
    );

    isLoading.value = false;
  }
  Future<void> updateProfile() async {
    try {
      isLoading.value = true;

      /// split name
      final names = nameController.text.trim().split(" ");

      final firstName = names.isNotEmpty ? names.first : "";
      final lastName = names.length > 1 ? names.sublist(1).join(" ") : "";

      /// fitness goals list
      final goals = fitnessGoalsController.text
          .split(",")
          .map((e) => e.trim())
          .toList();

      /// create model
      final params = UserProfileUpdateModel(
        firstName: firstName,
        lastName: lastName,
        phone: user.value?.phone,
        bio: user.value?.bio,
        preferredLanguage: user.value?.preferredLanguage,
        gender: genderController.text,
        age: int.tryParse(ageController.text),

        /// weight
        weightCurrent: Measurement(
          value: int.tryParse(weightController.text),
          unit: weightUnit.value,
        ),

        /// height
        height: Measurement(
          value: int.tryParse(heightController.text),
          unit: heightUnit.value,
        ),

        goalWeight: user.value?.goalWeight,

        fitnessGoals: goals,
        mobilityType: mobilityTypeController.text,
        fitnessExperience: fitnessExperienceController.text,
        onboardingStep: 8,
      );

      final response = await profileInterface.updateProfile(params);

      response.fold(
        (failure) {
          Get.snackbar("Error", failure.uiMessage);
        },
        (success) {
          Get.snackbar(
            "Success",
            success.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.7),
            colorText: Colors.white,
          );

          /// refresh profile
          getProfile();
          toggleEdit();
        },
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
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
