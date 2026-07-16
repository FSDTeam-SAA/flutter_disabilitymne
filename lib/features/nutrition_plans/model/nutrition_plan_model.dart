class NutritionPlanModel {
  final String id;
  final String title;
  final String description;
  final List<NutritionDayModel> nutritionDays;

  const NutritionPlanModel({
    required this.id,
    required this.title,
    required this.description,
    required this.nutritionDays,
  });

  factory NutritionPlanModel.fromJson(Map<String, dynamic> json) {
    final days = (json['nutritionDays'] as List<dynamic>? ?? [])
        .map((e) => NutritionDayModel.fromJson(e as Map<String, dynamic>? ?? const {}))
        .toList();
    return NutritionPlanModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      nutritionDays: days,
    );
  }
}

class NutritionDayModel {
  final int dayIndex;
  final String label;
  final List<NutritionMealModel> meals;

  const NutritionDayModel({
    required this.dayIndex,
    required this.label,
    required this.meals,
  });

  factory NutritionDayModel.fromJson(Map<String, dynamic> json) {
    final meals = (json['meals'] as List<dynamic>? ?? [])
        .map((e) => NutritionMealModel.fromJson(e as Map<String, dynamic>? ?? const {}))
        .toList();
    return NutritionDayModel(
      dayIndex: int.tryParse(json['dayIndex']?.toString() ?? '') ?? 0,
      label: json['label']?.toString() ?? '',
      meals: meals,
    );
  }
}

class NutritionMealModel {
  final String mealType;
  final int order;
  final String notes;
  final NutritionRecipeRef? recipe;

  const NutritionMealModel({
    required this.mealType,
    required this.order,
    required this.notes,
    this.recipe,
  });

  factory NutritionMealModel.fromJson(Map<String, dynamic> json) {
    final recipeJson = json['recipe'];
    return NutritionMealModel(
      mealType: json['mealType']?.toString() ?? 'meal',
      order: int.tryParse(json['order']?.toString() ?? '') ?? 0,
      notes: json['notes']?.toString() ?? '',
      recipe: recipeJson is Map<String, dynamic>
          ? NutritionRecipeRef.fromJson(recipeJson)
          : null,
    );
  }
}

class NutritionRecipeRef {
  final String id;
  final String recipeName;
  final String recipeType;
  final int? caloriesKcal;
  final String? recipeImage;
  final int? durationMinutes;

  const NutritionRecipeRef({
    required this.id,
    required this.recipeName,
    required this.recipeType,
    this.caloriesKcal,
    this.recipeImage,
    this.durationMinutes,
  });

  factory NutritionRecipeRef.fromJson(Map<String, dynamic> json) {
    return NutritionRecipeRef(
      id: json['id']?.toString() ?? '',
      recipeName: json['recipeName']?.toString() ?? '',
      recipeType: json['recipeType']?.toString() ?? '',
      caloriesKcal: int.tryParse(json['caloriesKcal']?.toString() ?? ''),
      recipeImage: json['recipeImage']?.toString(),
      durationMinutes: int.tryParse(json['durationMinutes']?.toString() ?? ''),
    );
  }
}
