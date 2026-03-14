import 'package:disabilitymne/features/auth/model/user_model.dart';

class UserProfileUpdateModel {
  String? firstName;
  String? lastName;
  String? phone;
  String? bio;
  String? preferredLanguage;
  String? gender;
  int? age;
  Measurement? weightCurrent;
  Measurement? goalWeight;
  Measurement? height;
  List<String>? fitnessGoals;
  String? mobilityType;
  String? mobilityTypeOther;
  String? fitnessExperience;
  int? onboardingStep;
  bool? onboardingCompleted;
  String? profileImage;

  UserProfileUpdateModel({
    this.firstName,
    this.lastName,
    this.phone,
    this.bio,
    this.preferredLanguage,
    this.gender,
    this.age,
    this.weightCurrent,
    this.goalWeight,
    this.height,
    this.fitnessGoals,
    this.mobilityType,
    this.mobilityTypeOther,
    this.fitnessExperience,
    this.onboardingStep,
    this.onboardingCompleted,
    this.profileImage,
  });

  UserProfileUpdateModel.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    phone = json['phone'];
    bio = json['bio'];
    preferredLanguage = json['preferredLanguage'];
    gender = json['gender'];
    age = json['age'];

    weightCurrent = json['weightCurrent'] != null
        ? Measurement.fromJson(json['weightCurrent'])
        : null;

    goalWeight = json['goalWeight'] != null
        ? Measurement.fromJson(json['goalWeight'])
        : null;

    height = json['height'] != null
        ? Measurement.fromJson(json['height'])
        : null;

    fitnessGoals = json['fitnessGoals'] != null
        ? List<String>.from(json['fitnessGoals'])
        : [];

    mobilityType = json['mobilityType'];
    mobilityTypeOther = json['mobilityTypeOther'];
    fitnessExperience = json['fitnessExperience'];
    onboardingStep = json['onboardingStep'];
    onboardingCompleted = json['onboardingCompleted'];
    profileImage = json['profileImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (phone != null) data['phone'] = phone;
    if (bio != null) data['bio'] = bio;
    if (preferredLanguage != null) data['preferredLanguage'] = preferredLanguage;
    if (gender != null) data['gender'] = gender;
    if (age != null) data['age'] = age;

    if (weightCurrent != null) {
      data['weightCurrent'] = weightCurrent!.toJson();
    }

    if (goalWeight != null) {
      data['goalWeight'] = goalWeight!.toJson();
    }

    if (height != null) {
      data['height'] = height!.toJson();
    }

    if (fitnessGoals != null) {
      data['fitnessGoals'] = fitnessGoals;
    }

    if (mobilityType != null) data['mobilityType'] = mobilityType;
    if (mobilityTypeOther != null && mobilityTypeOther!.isNotEmpty) {
      data['mobilityTypeOther'] = mobilityTypeOther;
    }
    if (fitnessExperience != null) data['fitnessExperience'] = fitnessExperience;
    if (onboardingStep != null) data['onboardingStep'] = onboardingStep;
    if (onboardingCompleted != null) data['onboardingCompleted'] = onboardingCompleted;
    if (profileImage != null) data['profileImage'] = profileImage;

    return data;
  }
}
