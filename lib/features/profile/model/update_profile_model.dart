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
  String? fitnessExperience;
  int? onboardingStep;
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
    this.fitnessExperience,
    this.onboardingStep,
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
    fitnessExperience = json['fitnessExperience'];
    onboardingStep = json['onboardingStep'];
    profileImage = json['profileImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['phone'] = phone;
    data['bio'] = bio;
    data['preferredLanguage'] = preferredLanguage;
    data['gender'] = gender;
    data['age'] = age;

    if (weightCurrent != null) {
      data['weightCurrent'] = weightCurrent!.toJson();
    }

    if (goalWeight != null) {
      data['goalWeight'] = goalWeight!.toJson();
    }

    if (height != null) {
      data['height'] = height!.toJson();
    }

    data['fitnessGoals'] = fitnessGoals;
    data['mobilityType'] = mobilityType;
    data['fitnessExperience'] = fitnessExperience;
    data['onboardingStep'] = onboardingStep;
    data['profileImage'] = profileImage;

    return data;
  }
}
