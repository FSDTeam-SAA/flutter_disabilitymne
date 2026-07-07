/// Profile field values aligned with backend `user.model.js` enums and ranges.
class ProfileFieldOptions {
  ProfileFieldOptions._();

  static const int minAge = 13;
  static const int maxAge = 120;

  static const int minHeightCm = 100;
  static const int maxHeightCm = 250;

  static const int minHeightInches = 48; // 4'0"
  static const int maxHeightInches = 84; // 7'0"

  static const int minWeightKg = 30;
  static const int maxWeightKg = 200;

  static const int minWeightLbs = 66;
  static const int maxWeightLbs = 440;

  static const List<String> genders = [
    'male',
    'female',
    'other',
    'prefer_not_to_say',
  ];

  static const List<String> heightUnits = ['cm', 'ft'];
  static const List<String> weightUnits = ['kg', 'lbs'];

  static const List<String> fitnessGoals = [
    'build_muscle',
    'lose_weight',
    'manage_weight',
    'boost_energy',
    'flexibility',
    'general_wellness',
  ];

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

  static const List<String> fitnessExperienceLevels = [
    'beginner',
    'intermediate',
    'advanced',
  ];

  static const Map<String, String> genderLabels = {
    'male': 'Male',
    'female': 'Female',
    'other': 'Other',
    'prefer_not_to_say': 'Prefer not to say',
  };

  static const Map<String, String> fitnessGoalLabels = {
    'build_muscle': 'Build muscle',
    'lose_weight': 'Lose weight',
    'manage_weight': 'Manage weight',
    'boost_energy': 'Boost energy',
    'flexibility': 'Flexibility',
    'general_wellness': 'General wellness',
  };

  static const Map<String, String> mobilityTypeLabels = {
    'wheelchair_user': 'Wheelchair user',
    'limited_mobility': 'Limited mobility',
    'amputee_leg': 'Amputee (leg)',
    'amputee_arm': 'Amputee (arm)',
    'neurological_condition': 'Neurological condition',
    'chronic_pain': 'Chronic pain',
    'visual_impairment': 'Visual impairment',
    'other': 'Other',
  };

  static const Map<String, String> fitnessExperienceLabels = {
    'beginner': 'Beginner',
    'intermediate': 'Intermediate',
    'advanced': 'Advanced',
  };

  static List<String> get ageOptions => List.generate(
    maxAge - minAge + 1,
    (index) => '${minAge + index}',
  );

  static List<String> heightValueOptions(String unit) {
    if (unit == 'ft') {
      return List.generate(
        maxHeightInches - minHeightInches + 1,
        (index) => '${minHeightInches + index}',
      );
    }
    return List.generate(
      maxHeightCm - minHeightCm + 1,
      (index) => '${minHeightCm + index}',
    );
  }

  static List<String> weightValueOptions(String unit) {
    if (unit == 'lbs') {
      return List.generate(
        maxWeightLbs - minWeightLbs + 1,
        (index) => '${minWeightLbs + index}',
      );
    }
    return List.generate(
      maxWeightKg - minWeightKg + 1,
      (index) => '${minWeightKg + index}',
    );
  }

  static String labelFor(String value, Map<String, String> labels) {
    return labels[value] ?? value.replaceAll('_', ' ');
  }

  static String formatAge(String value) => '$value years old';

  static String formatHeight(String value, String unit) {
    if (value.isEmpty) return '';
    if (unit == 'ft') {
      return formatHeightInches(int.tryParse(value) ?? 0);
    }
    return '$value cm';
  }

  static String formatWeight(String value, String unit) {
    if (value.isEmpty) return '';
    return '$value $unit';
  }

  static String formatHeightInches(int totalInches) {
    if (totalInches <= 0) return '';
    final feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    return "$feet'$inches\"";
  }

  static int? parseStoredHeight(int? value, String unit) {
    if (value == null) return null;
    if (unit == 'ft') {
      if (value >= minHeightInches && value <= maxHeightInches) {
        return value;
      }
      final inches = (value / 2.54).round();
      return inches.clamp(minHeightInches, maxHeightInches);
    }
    return value.clamp(minHeightCm, maxHeightCm);
  }

  static int? parseStoredWeight(int? value, String unit) {
    if (value == null) return null;
    if (unit == 'lbs') {
      if (value >= minWeightLbs && value <= maxWeightLbs) {
        return value;
      }
      final lbs = (value * 2.20462).round();
      return lbs.clamp(minWeightLbs, maxWeightLbs);
    }
    return value.clamp(minWeightKg, maxWeightKg);
  }
}
