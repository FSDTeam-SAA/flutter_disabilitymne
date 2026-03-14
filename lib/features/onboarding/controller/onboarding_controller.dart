import 'package:disabilitymne/features/auth/model/user_model.dart' show Measurement;
import 'package:disabilitymne/features/profile/model/update_profile_model.dart';
import 'package:disabilitymne/features/profile/services/profile_interface.dart';
import 'package:get/get.dart';

/// Contract: UI labels → API slugs for onboarding PATCH /api/v1/users/me
class OnboardingSlugs {
  /// Fitness goals (order matches FitnessGoalsScreen._options)
  static const List<String> fitnessGoals = [
    'build_muscle',      // Build Muscle
    'lose_weight',       // Lose weight
    'manage_weight',     // Manage Weight
    'boost_energy',      // Boost Energy
    'flexibility',       // Flexibility
    'general_wellness',  // General Wellness
  ];

  /// Mobility types (order matches MobilityTypeSelectionScreen._options + Other)
  static const List<String> mobilityTypes = [
    'wheelchair_user',
    'limited_mobility',
    'amputee_leg',
    'amputee_arm',
    'neurological_condition',
    'chronic_pain',
    'visual_impairment',
    'other',
  ];

  /// Fitness experience (order matches FitnessExperienceScreen: Beginner, Intermediate, Advanced)
  static const List<String> fitnessExperience = [
    'beginner',
    'intermediate',
    'advanced',
  ];
}

/// Holds onboarding state and submits PATCH /users/me when flow completes.
class OnboardingController extends GetxController {
  OnboardingController({required this.profileInterface});

  final ProfileInterface profileInterface;

  RxBool isLoading = false.obs;

  String? gender;
  int? age;
  double? weightValue;
  String weightUnit = 'kg';
  double? goalWeightValue;
  String goalWeightUnit = 'kg';
  double? heightValue;
  String heightUnit = 'cm';
  List<int> fitnessGoalIndices = [];
  int? mobilityTypeIndex;
  String mobilityTypeOtherText = '';
  int? fitnessExperienceIndex;

  void setGender(String? value) => gender = value;
  void setAge(int? value) => age = value;
  void setWeight(double value, String unit) {
    weightValue = value;
    weightUnit = unit;
  }

  void setGoalWeight(double value, String unit) {
    goalWeightValue = value;
    goalWeightUnit = unit;
  }

  void setHeight(double value, String unit) {
    heightValue = value;
    heightUnit = unit;
  }

  void setFitnessGoals(List<int> indices) => fitnessGoalIndices = indices;
  void setMobilityType(int? index, [String otherText = '']) {
    mobilityTypeIndex = index;
    mobilityTypeOtherText = otherText.trim();
  }

  void setFitnessExperience(int? index) => fitnessExperienceIndex = index;

  UserProfileUpdateModel buildPayload() {
    final fitnessGoalsSlugs = fitnessGoalIndices
        .where((i) => i >= 0 && i < OnboardingSlugs.fitnessGoals.length)
        .map((i) => OnboardingSlugs.fitnessGoals[i])
        .toList();

    String? mobilitySlug;
    String? mobilityOther;
    if (mobilityTypeIndex != null) {
      if (mobilityTypeIndex! >= 0 && mobilityTypeIndex! < OnboardingSlugs.mobilityTypes.length) {
        mobilitySlug = OnboardingSlugs.mobilityTypes[mobilityTypeIndex!];
        if (mobilitySlug == 'other') {
          mobilityOther = mobilityTypeOtherText.isNotEmpty ? mobilityTypeOtherText : null;
        }
      }
    }

    String? experienceSlug;
    if (fitnessExperienceIndex != null &&
        fitnessExperienceIndex! >= 0 &&
        fitnessExperienceIndex! < OnboardingSlugs.fitnessExperience.length) {
      experienceSlug = OnboardingSlugs.fitnessExperience[fitnessExperienceIndex!];
    }

    return UserProfileUpdateModel(
      gender: gender,
      age: age,
      weightCurrent: weightValue != null
          ? Measurement(value: weightValue!.round(), unit: weightUnit)
          : null,
      goalWeight: goalWeightValue != null
          ? Measurement(value: goalWeightValue!.round(), unit: goalWeightUnit)
          : null,
      height: heightValue != null
          ? Measurement(value: heightValue!.round(), unit: heightUnit)
          : null,
      fitnessGoals: fitnessGoalsSlugs,
      mobilityType: mobilitySlug,
      mobilityTypeOther: mobilityOther,
      fitnessExperience: experienceSlug,
      onboardingStep: 8,
      onboardingCompleted: true,
    );
  }

  /// PATCH {{baseUrl}}/api/v1/users/me with onboarding payload.
  Future<bool> submitOnboarding() async {
    if (isLoading.value) return false;
    isLoading.value = true;

    final payload = buildPayload();
    final result = await profileInterface.updateProfile(payload);

    isLoading.value = false;

    return result.fold(
      (failure) {
        Get.snackbar('Error', failure.uiMessage);
        return false;
      },
      (_) => true,
    );
  }
}
