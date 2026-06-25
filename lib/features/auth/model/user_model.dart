class UserModel {
  final String? id;
  final String? role;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? bio;
  final String? preferredLanguage;
  final AccessibilityPreferences? accessibilityPreferences;
  final String? profileImage;
  final String? gender;
  final int? age;
  final Measurement? weightCurrent;
  final Measurement? goalWeight;
  final Measurement? height;
  final List<dynamic>? fitnessGoals;
  final String? mobilityType;
  final String? mobilityTypeOther;
  final String? fitnessExperience;
  final int? onboardingStep;
  final bool? onboardingCompleted;
  final String? selectedPlan;
  final String? subscriptionStatus;
  final String? trialActivatedAt;
  final String? trialEndsAt;
  final String? subscriptionStartedAt;
  final String? subscriptionEndsAt;
  final String? lastLoginAt;
  final String? accountStatus;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    this.id,
    this.role,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.bio,
    this.preferredLanguage,
    this.accessibilityPreferences,
    this.profileImage,
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
    this.selectedPlan,
    this.subscriptionStatus,
    this.trialActivatedAt,
    this.trialEndsAt,
    this.subscriptionStartedAt,
    this.subscriptionEndsAt,
    this.lastLoginAt,
    this.accountStatus,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      role: json['role'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      bio: json['bio'],
      preferredLanguage: json['preferredLanguage'],
      accessibilityPreferences: json['accessibilityPreferences'] != null
          ? AccessibilityPreferences.fromJson(json['accessibilityPreferences'])
          : null,
      profileImage: json['profileImage'],
      gender: json['gender'],
      age: json['age'],
      weightCurrent: json['weightCurrent'] != null
          ? Measurement.fromJson(json['weightCurrent'])
          : null,
      goalWeight: json['goalWeight'] != null
          ? Measurement.fromJson(json['goalWeight'])
          : null,
      height: json['height'] != null
          ? Measurement.fromJson(json['height'])
          : null,
      fitnessGoals: json['fitnessGoals'],
      mobilityType: json['mobilityType'],
      mobilityTypeOther: json['mobilityTypeOther'],
      fitnessExperience: json['fitnessExperience'],
      onboardingStep: json['onboardingStep'],
      onboardingCompleted: json['onboardingCompleted'],
      selectedPlan: json['selectedPlan'],
      subscriptionStatus: json['subscriptionStatus'],
      trialActivatedAt: json['trialActivatedAt'],
      trialEndsAt: json['trialEndsAt'],
      subscriptionStartedAt: json['subscriptionStartedAt'],
      subscriptionEndsAt: json['subscriptionEndsAt'],
      lastLoginAt: json['lastLoginAt'],
      accountStatus: json['accountStatus'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'bio': bio,
      'preferredLanguage': preferredLanguage,
      'accessibilityPreferences': accessibilityPreferences?.toJson(),
      'profileImage': profileImage,
      'gender': gender,
      'age': age,
      'weightCurrent': weightCurrent?.toJson(),
      'goalWeight': goalWeight?.toJson(),
      'height': height?.toJson(),
      'fitnessGoals': fitnessGoals,
      'mobilityType': mobilityType,
      'mobilityTypeOther': mobilityTypeOther,
      'fitnessExperience': fitnessExperience,
      'onboardingStep': onboardingStep,
      'onboardingCompleted': onboardingCompleted,
      'selectedPlan': selectedPlan,
      'subscriptionStatus': subscriptionStatus,
      'trialActivatedAt': trialActivatedAt,
      'trialEndsAt': trialEndsAt,
      'subscriptionStartedAt': subscriptionStartedAt,
      'subscriptionEndsAt': subscriptionEndsAt,
      'lastLoginAt': lastLoginAt,
      'accountStatus': accountStatus,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class Measurement {
  final int? value;
  final String? unit;

  Measurement({this.value, this.unit});

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(value: json['value'], unit: json['unit']);
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'unit': unit};
  }
}

class AccessibilityPreferences {
  final bool? largerText;
  final bool? highContrast;
  final bool? reducedMotion;
  final bool? screenReaderOptimized;

  AccessibilityPreferences({
    this.largerText,
    this.highContrast,
    this.reducedMotion,
    this.screenReaderOptimized,
  });

  factory AccessibilityPreferences.fromJson(Map<String, dynamic> json) {
    return AccessibilityPreferences(
      largerText: json['largerText'],
      highContrast: json['highContrast'],
      reducedMotion: json['reducedMotion'],
      screenReaderOptimized: json['screenReaderOptimized'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'largerText': largerText,
      'highContrast': highContrast,
      'reducedMotion': reducedMotion,
      'screenReaderOptimized': screenReaderOptimized,
    };
  }
}
