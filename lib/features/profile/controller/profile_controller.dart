import 'dart:io';

import 'package:disabilitymne/features/auth/model/user_model.dart';
import 'package:disabilitymne/features/profile/constants/profile_field_options.dart';
import 'package:disabilitymne/features/profile/model/update_profile_model.dart';
import 'package:disabilitymne/features/profile/services/profile_interface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/helpers/app_snackbar.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  ProfileController({required this.profileInterface});

  final ProfileInterface profileInterface;

  static const List<String> WEIGHT_UNITS = ProfileFieldOptions.weightUnits;
  static const List<String> HEIGHT_UNITS = ProfileFieldOptions.heightUnits;
  static const List<String> FITNESS_GOALS = ProfileFieldOptions.fitnessGoals;
  static const List<String> MOBILITY_TYPES = ProfileFieldOptions.mobilityTypes;
  static const List<String> FITNESS_EXPERIENCE_LEVELS =
      ProfileFieldOptions.fitnessExperienceLevels;

  /// user model
  Rxn<UserModel> user = Rxn<UserModel>();

  /// text controllers
  final nameController = TextEditingController();
  final mobilityTypeOtherController = TextEditingController();

  /// Dropdown selections
  final RxString selectedGender = ''.obs;
  final RxString selectedAge = ''.obs;
  final RxString selectedHeight = ''.obs;
  final RxString selectedWeight = ''.obs;
  final RxString selectedFitnessGoal = ''.obs;
  final RxString selectedMobilityType = ''.obs;
  final RxString selectedFitnessExperience = ''.obs;

  /// image picker
  final RxnString pickedImagePath = RxnString();
  final ImagePicker _picker = ImagePicker();

  /// units
  final RxString weightUnit = 'kg'.obs;
  final RxString heightUnit = 'cm'.obs;

  /// edit mode
  final RxBool isEditing = false.obs;

  /// loading
  final RxBool isLoading = false.obs;

  /// uploading profile image
  final RxBool isUploadingImage = false.obs;

  List<String> get heightValueOptions =>
      ProfileFieldOptions.heightValueOptions(heightUnit.value);

  List<String> get weightValueOptions =>
      ProfileFieldOptions.weightValueOptions(weightUnit.value);

  /// toggle edit mode
  void toggleEdit() {
    if (isEditing.value) {
      _populateFormFromUser(user.value);
    }
    isEditing.toggle();
  }

  void exitEditMode() {
    isEditing.value = false;
  }

  void onHeightUnitChanged(String unit) {
    heightUnit.value = unit;
    _syncMeasurementSelection(
      selectedValue: selectedHeight,
      options: heightValueOptions,
    );
  }

  void onWeightUnitChanged(String unit) {
    weightUnit.value = unit;
    _syncMeasurementSelection(
      selectedValue: selectedWeight,
      options: weightValueOptions,
    );
  }

  void _syncMeasurementSelection({
    required RxString selectedValue,
    required List<String> options,
  }) {
    if (selectedValue.value.isEmpty) return;
    if (options.contains(selectedValue.value)) return;
    selectedValue.value = '';
  }

  /// ================================
  /// GET PROFILE API
  /// ================================
  Future<void> getProfile() async {
    if (isClosed) return;

    isLoading.value = true;

    final response = await profileInterface.getProfile(UserModel());

    if (isClosed) return;

    response.fold(
      (failure) {
        AppSnackbar.show('Error', failure.uiMessage);
      },
      (success) {
        final userData = success.data;

        if (userData != null) {
          user.value = userData;
          _populateFormFromUser(userData);
        }
      },
    );

    if (!isClosed) {
      isLoading.value = false;
    }
  }

  void _populateFormFromUser(UserModel? userData) {
    if (userData == null || isClosed) return;

    nameController.text =
        '${userData.firstName ?? ''} ${userData.lastName ?? ''}'.trim();

    selectedGender.value = ProfileFieldOptions.genders.contains(userData.gender)
        ? userData.gender!
        : '';

    selectedAge.value =
        userData.age != null &&
            userData.age! >= ProfileFieldOptions.minAge &&
            userData.age! <= ProfileFieldOptions.maxAge
        ? userData.age.toString()
        : '';

    heightUnit.value = ProfileFieldOptions.heightUnits.contains(
      userData.height?.unit,
    )
        ? userData.height!.unit!
        : 'cm';

    final parsedHeight = ProfileFieldOptions.parseStoredHeight(
      userData.height?.value,
      heightUnit.value,
    );
    selectedHeight.value = parsedHeight?.toString() ?? '';

    weightUnit.value = ProfileFieldOptions.weightUnits.contains(
      userData.weightCurrent?.unit,
    )
        ? userData.weightCurrent!.unit!
        : 'kg';

    final parsedWeight = ProfileFieldOptions.parseStoredWeight(
      userData.weightCurrent?.value,
      weightUnit.value,
    );
    selectedWeight.value = parsedWeight?.toString() ?? '';

    if (userData.fitnessGoals != null && userData.fitnessGoals!.isNotEmpty) {
      final goal = userData.fitnessGoals!.first.toString();
      selectedFitnessGoal.value = FITNESS_GOALS.contains(goal) ? goal : '';
    } else {
      selectedFitnessGoal.value = '';
    }

    selectedMobilityType.value =
        MOBILITY_TYPES.contains(userData.mobilityType)
        ? userData.mobilityType!
        : '';

    mobilityTypeOtherController.text = userData.mobilityTypeOther ?? '';

    selectedFitnessExperience.value =
        FITNESS_EXPERIENCE_LEVELS.contains(userData.fitnessExperience)
        ? userData.fitnessExperience!
        : '';
  }

  Future<void> updateProfile() async {
    debugPrint('[ProfileController] updateProfile started');

    try {
      isLoading.value = true;

      final names = nameController.text.trim().split(' ');
      final firstName = names.isNotEmpty ? names.first : '';
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

      final params = UserProfileUpdateModel(
        firstName: firstName,
        lastName: lastName,
        phone: user.value?.phone,
        bio: user.value?.bio,
        preferredLanguage: user.value?.preferredLanguage,
        gender: selectedGender.value.isNotEmpty ? selectedGender.value : null,
        age: int.tryParse(selectedAge.value),
        weightCurrent: selectedWeight.value.isNotEmpty
            ? Measurement(
                value: int.tryParse(selectedWeight.value),
                unit: weightUnit.value,
              )
            : null,
        height: selectedHeight.value.isNotEmpty
            ? Measurement(
                value: int.tryParse(selectedHeight.value),
                unit: heightUnit.value,
              )
            : null,
        goalWeight: user.value?.goalWeight,
        fitnessGoals: selectedFitnessGoal.value.isNotEmpty
            ? [selectedFitnessGoal.value]
            : [],
        mobilityType: selectedMobilityType.value.isNotEmpty
            ? selectedMobilityType.value
            : null,
        mobilityTypeOther: selectedMobilityType.value == 'other'
            ? mobilityTypeOtherController.text.trim()
            : null,
        fitnessExperience: selectedFitnessExperience.value.isNotEmpty
            ? selectedFitnessExperience.value
            : null,
        onboardingStep: 8,
      );

      final response = await profileInterface.updateProfile(params);

      if (isClosed) return;

      response.fold(
        (failure) {
          AppSnackbar.show('Error', failure.uiMessage);
        },
        (success) {
          AppSnackbar.success(
            'Success',
            success.message,
            snackPosition: SnackPosition.TOP,
          );

          getProfile().then((_) {
            if (!isClosed) exitEditMode();
          });
        },
      );
    } catch (e, stackTrace) {
      debugPrint('[ProfileController] updateProfile exception => $e');
      debugPrint('[ProfileController] updateProfile stackTrace => $stackTrace');
      if (!isClosed) {
        AppSnackbar.show('Error', e.toString());
      }
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  /// ================================
  /// PICK IMAGE & UPLOAD (only profile image via API)
  /// ================================
  Future<void> pickImageFromSource(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);

      if (image != null) {
        pickedImagePath.value = image.path;

        final file = File(image.path);
        if (!await file.exists()) {
          AppSnackbar.show('Error', 'Image file not found');
          return;
        }

        isUploadingImage.value = true;
        final response = await profileInterface.updateMyProfileImage(file);

        if (isClosed) return;

        response.fold(
          (failure) {
            AppSnackbar.show('Error', failure.uiMessage);
          },
          (success) {
            if (success.data != null) {
              user.value = success.data;
              pickedImagePath.value = null;
            }
            AppSnackbar.success(
              'Success',
              success.message,
              snackPosition: SnackPosition.TOP,
            );
          },
        );
      }
    } catch (e) {
      if (!isClosed) {
        AppSnackbar.show('Error', 'Failed to pick image: $e');
      }
    } finally {
      if (!isClosed) {
        isUploadingImage.value = false;
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    mobilityTypeOtherController.dispose();
    super.onClose();
  }
}
