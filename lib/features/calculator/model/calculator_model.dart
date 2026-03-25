class NutritionData {
  final DateTime date;
  final Totals totals;
  final MacroPercentages macroPercentages;
  final MacroProgress macroProgress;
  final Targets targets;
  final Energy energy;
  final int totalEntries;
  final List<Meal> meals;
  final List<MealRecommendation> mealRecommendations;

  NutritionData({
    required this.date,
    required this.totals,
    required this.macroPercentages,
    required this.macroProgress,
    required this.targets,
    required this.energy,
    required this.totalEntries,
    required this.meals,
    required this.mealRecommendations,
  });

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    return NutritionData(
      date: DateTime.parse(json['date']),
      totals: Totals.fromJson(json['totals']),
      macroPercentages: MacroPercentages.fromJson(json['macroPercentages']),
      macroProgress: MacroProgress.fromJson(json['macroProgress']),
      targets: Targets.fromJson(json['targets']),
      energy: Energy.fromJson(json['energy']),
      totalEntries: json['totalEntries'],
      meals: (json['meals'] as List).map((e) => Meal.fromJson(e)).toList(),
      mealRecommendations: (json['mealRecommendations'] as List)
          .map((e) => MealRecommendation.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totals': totals.toJson(),
      'macroPercentages': macroPercentages.toJson(),
      'macroProgress': macroProgress.toJson(),
      'targets': targets.toJson(),
      'energy': energy.toJson(),
      'totalEntries': totalEntries,
      'meals': meals.map((e) => e.toJson()).toList(),
      'mealRecommendations': mealRecommendations.map((e) => e.toJson()).toList(),
    };
  }

  NutritionData copyWith({
    DateTime? date,
    Totals? totals,
    MacroPercentages? macroPercentages,
    MacroProgress? macroProgress,
    Targets? targets,
    Energy? energy,
    int? totalEntries,
    List<Meal>? meals,
    List<MealRecommendation>? mealRecommendations,
  }) {
    return NutritionData(
      date: date ?? this.date,
      totals: totals ?? this.totals,
      macroPercentages: macroPercentages ?? this.macroPercentages,
      macroProgress: macroProgress ?? this.macroProgress,
      targets: targets ?? this.targets,
      energy: energy ?? this.energy,
      totalEntries: totalEntries ?? this.totalEntries,
      meals: meals ?? this.meals,
      mealRecommendations: mealRecommendations ?? this.mealRecommendations,
    );
  }
}

class Totals {
  final double caloriesKcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double sugarG;
  final double totalGrams;

  Totals({
    required this.caloriesKcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
    required this.sugarG,
    required this.totalGrams,
  });

  factory Totals.fromJson(Map<String, dynamic> json) {
    return Totals(
      caloriesKcal: (json['caloriesKcal'] ?? 0).toDouble(),
      proteinG: (json['proteinG'] ?? 0).toDouble(),
      carbsG: (json['carbsG'] ?? 0).toDouble(),
      fatG: (json['fatG'] ?? 0).toDouble(),
      fiberG: (json['fiberG'] ?? 0).toDouble(),
      sugarG: (json['sugarG'] ?? 0).toDouble(),
      totalGrams: (json['totalGrams'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'caloriesKcal': caloriesKcal,
      'proteinG': proteinG,
      'carbsG': carbsG,
      'fatG': fatG,
      'fiberG': fiberG,
      'sugarG': sugarG,
      'totalGrams': totalGrams,
    };
  }
}

class MacroPercentages {
  final double proteinPercent;
  final double carbsPercent;
  final double fatPercent;

  MacroPercentages({
    required this.proteinPercent,
    required this.carbsPercent,
    required this.fatPercent,
  });

  factory MacroPercentages.fromJson(Map<String, dynamic> json) {
    return MacroPercentages(
      proteinPercent: (json['proteinPercent'] ?? 0).toDouble(),
      carbsPercent: (json['carbsPercent'] ?? 0).toDouble(),
      fatPercent: (json['fatPercent'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proteinPercent': proteinPercent,
      'carbsPercent': carbsPercent,
      'fatPercent': fatPercent,
    };
  }
}

class MacroProgress {
  final MacroItem carbs;
  final MacroItem protein;
  final MacroItem fat;

  MacroProgress({
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  factory MacroProgress.fromJson(Map<String, dynamic> json) {
    return MacroProgress(
      carbs: MacroItem.fromJson(json['carbs']),
      protein: MacroItem.fromJson(json['protein']),
      fat: MacroItem.fromJson(json['fat']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carbs': carbs.toJson(),
      'protein': protein.toJson(),
      'fat': fat.toJson(),
    };
  }
}

class MacroItem {
  final double consumedG;
  final double targetG;
  final double remainingG;
  final double progressPercent;

  MacroItem({
    required this.consumedG,
    required this.targetG,
    required this.remainingG,
    required this.progressPercent,
  });

  factory MacroItem.fromJson(Map<String, dynamic> json) {
    return MacroItem(
      consumedG: (json['consumedG'] ?? 0).toDouble(),
      targetG: (json['targetG'] ?? 0).toDouble(),
      remainingG: (json['remainingG'] ?? 0).toDouble(),
      progressPercent: (json['progressPercent'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'consumedG': consumedG,
      'targetG': targetG,
      'remainingG': remainingG,
      'progressPercent': progressPercent,
    };
  }
}

class Targets {
  final double weightKg;
  final String goal;
  final Multipliers multipliers;
  final MacroTargets macros;
  final Calories calories;

  Targets({
    required this.weightKg,
    required this.goal,
    required this.multipliers,
    required this.macros,
    required this.calories,
  });

  factory Targets.fromJson(Map<String, dynamic> json) {
    return Targets(
      weightKg: (json['weightKg'] ?? 0).toDouble(),
      goal: json['goal'] ?? '',
      multipliers: Multipliers.fromJson(json['multipliers']),
      macros: MacroTargets.fromJson(json['macros']),
      calories: Calories.fromJson(json['calories']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weightKg': weightKg,
      'goal': goal,
      'multipliers': multipliers.toJson(),
      'macros': macros.toJson(),
      'calories': calories.toJson(),
    };
  }
}

class Multipliers {
  final double proteinPerKg;
  final double carbsPerKg;
  final double fatPerKg;

  Multipliers({
    required this.proteinPerKg,
    required this.carbsPerKg,
    required this.fatPerKg,
  });

  factory Multipliers.fromJson(Map<String, dynamic> json) {
    return Multipliers(
      proteinPerKg: (json['proteinPerKg'] ?? 0).toDouble(),
      carbsPerKg: (json['carbsPerKg'] ?? 0).toDouble(),
      fatPerKg: (json['fatPerKg'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proteinPerKg': proteinPerKg,
      'carbsPerKg': carbsPerKg,
      'fatPerKg': fatPerKg,
    };
  }
}

class MacroTargets {
  final double proteinG;
  final double carbsG;
  final double fatG;

  MacroTargets({
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  factory MacroTargets.fromJson(Map<String, dynamic> json) {
    return MacroTargets(
      proteinG: (json['proteinG'] ?? 0).toDouble(),
      carbsG: (json['carbsG'] ?? 0).toDouble(),
      fatG: (json['fatG'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proteinG': proteinG,
      'carbsG': carbsG,
      'fatG': fatG,
    };
  }
}

class Calories {
  final double proteinCalories;
  final double carbsCalories;
  final double fatCalories;
  final double macroCalories;
  final double recommendedCalories;
  final double minCalories;
  final double maxCalories;
  final double remainingCalories;

  Calories({
    required this.proteinCalories,
    required this.carbsCalories,
    required this.fatCalories,
    required this.macroCalories,
    required this.recommendedCalories,
    required this.minCalories,
    required this.maxCalories,
    required this.remainingCalories,
  });

  factory Calories.fromJson(Map<String, dynamic> json) {
    return Calories(
      proteinCalories: (json['proteinCalories'] ?? 0).toDouble(),
      carbsCalories: (json['carbsCalories'] ?? 0).toDouble(),
      fatCalories: (json['fatCalories'] ?? 0).toDouble(),
      macroCalories: (json['macroCalories'] ?? 0).toDouble(),
      recommendedCalories: (json['recommendedCalories'] ?? 0).toDouble(),
      minCalories: (json['minCalories'] ?? 0).toDouble(),
      maxCalories: (json['maxCalories'] ?? 0).toDouble(),
      remainingCalories: (json['remainingCalories'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proteinCalories': proteinCalories,
      'carbsCalories': carbsCalories,
      'fatCalories': fatCalories,
      'macroCalories': macroCalories,
      'recommendedCalories': recommendedCalories,
      'minCalories': minCalories,
      'maxCalories': maxCalories,
      'remainingCalories': remainingCalories,
    };
  }
}

class Energy {
  final double eatenKcal;
  final double burnedKcal;
  final double netKcal;
  final double goalKcal;
  final double remainingKcal;
  final String status;

  Energy({
    required this.eatenKcal,
    required this.burnedKcal,
    required this.netKcal,
    required this.goalKcal,
    required this.remainingKcal,
    required this.status,
  });

  factory Energy.fromJson(Map<String, dynamic> json) {
    return Energy(
      eatenKcal: (json['eatenKcal'] ?? 0).toDouble(),
      burnedKcal: (json['burnedKcal'] ?? 0).toDouble(),
      netKcal: (json['netKcal'] ?? 0).toDouble(),
      goalKcal: (json['goalKcal'] ?? 0).toDouble(),
      remainingKcal: (json['remainingKcal'] ?? 0).toDouble(),
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eatenKcal': eatenKcal,
      'burnedKcal': burnedKcal,
      'netKcal': netKcal,
      'goalKcal': goalKcal,
      'remainingKcal': remainingKcal,
      'status': status,
    };
  }
}

class Meal {
  final String mealType;
  final String mealLabel;
  final int totalEntries;
  final Totals totals;
  final MacroPercentages macroPercentages;
  final Recommendation recommendation;
  final List<DiaryEntry> entries;

  Meal({
    required this.mealType,
    required this.mealLabel,
    required this.totalEntries,
    required this.totals,
    required this.macroPercentages,
    required this.recommendation,
    required this.entries,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      mealType: json['mealType'] ?? '',
      mealLabel: json['mealLabel'] ?? '',
      totalEntries: json['totalEntries'] ?? 0,
      totals: Totals.fromJson(json['totals']),
      macroPercentages: MacroPercentages.fromJson(json['macroPercentages']),
      recommendation: Recommendation.fromJson(json['recommendation']),
      entries: (json['entries'] as List? ?? [])
          .map((e) => DiaryEntry.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mealType': mealType,
      'mealLabel': mealLabel,
      'totalEntries': totalEntries,
      'totals': totals.toJson(),
      'macroPercentages': macroPercentages.toJson(),
      'recommendation': recommendation.toJson(),
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }
}

class DiaryEntry {
  final String? id;
  final String foodName;
  final int? fdcId;
  final String date;
  final String mealType;
  final double quantity;
  final String servingLabel;
  final double servingGrams;
  final Map<String, dynamic>? nutrientsPer100g;

  DiaryEntry({
    this.id,
    required this.foodName,
    this.fdcId,
    required this.date,
    required this.mealType,
    required this.quantity,
    required this.servingLabel,
    required this.servingGrams,
    this.nutrientsPer100g,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id']?.toString(),
      foodName: json['foodName'] ?? 'Unknown',
      fdcId: json['fdcId'],
      date: json['date'] ?? '',
      mealType: json['mealType'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      servingLabel: json['servingLabel'] ?? '',
      servingGrams: (json['servingGrams'] ?? 0).toDouble(),
      nutrientsPer100g: json['nutrientsPer100g'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodName': foodName,
      'fdcId': fdcId,
      'date': date,
      'mealType': mealType,
      'quantity': quantity,
      'servingLabel': servingLabel,
      'servingGrams': servingGrams,
      'nutrientsPer100g': nutrientsPer100g,
    };
  }

  double get calories {
    if (nutrientsPer100g == null) return 0;
    final kcal = nutrientsPer100g!['caloriesKcal'] ?? 0;
    final ratio = (quantity * servingGrams) / 100;
    return (kcal is num ? kcal.toDouble() : 0) * ratio;
  }
}

class MealRecommendation {
  final String mealType;
  final String mealLabel;
  final Recommendation recommendation;
  final Totals totals;
  final MacroPercentages macroPercentages;

  MealRecommendation({
    required this.mealType,
    required this.mealLabel,
    required this.recommendation,
    required this.totals,
    required this.macroPercentages,
  });

  factory MealRecommendation.fromJson(Map<String, dynamic> json) {
    return MealRecommendation(
      mealType: json['mealType'] ?? '',
      mealLabel: json['mealLabel'] ?? '',
      recommendation: Recommendation.fromJson(json['recommendation']),
      totals: Totals.fromJson(json['totals']),
      macroPercentages: MacroPercentages.fromJson(json['macroPercentages']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mealType': mealType,
      'mealLabel': mealLabel,
      'recommendation': recommendation.toJson(),
      'totals': totals.toJson(),
      'macroPercentages': macroPercentages.toJson(),
    };
  }
}

class Recommendation {
  final CalorieRange recommendedCalories;
  final double eatenKcal;
  final CalorieRange remainingCalories;

  Recommendation({
    required this.recommendedCalories,
    required this.eatenKcal,
    required this.remainingCalories,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      recommendedCalories: CalorieRange.fromJson(json['recommendedCalories']),
      eatenKcal: (json['eatenKcal'] ?? 0).toDouble(),
      remainingCalories: CalorieRange.fromJson(json['remainingCalories']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommendedCalories': recommendedCalories.toJson(),
      'eatenKcal': eatenKcal,
      'remainingCalories': remainingCalories.toJson(),
    };
  }
}

class CalorieRange {
  final double minKcal;
  final double maxKcal;

  CalorieRange({required this.minKcal, required this.maxKcal});

  factory CalorieRange.fromJson(Map<String, dynamic> json) {
    return CalorieRange(
      minKcal: (json['minKcal'] ?? json['toMinKcal'] ?? 0).toDouble(),
      maxKcal: (json['maxKcal'] ?? json['toMaxKcal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minKcal': minKcal,
      'maxKcal': maxKcal,
    };
  }
}

/// Single logged item as returned by `/nutrition/history`, `/nutrition/favorites`, etc.
class NutritionEntrySummary {
  final String id;
  final String entryDate;
  final String mealType;
  final String mealLabel;
  final String foodName;
  final String brandName;
  final String source;
  final int? fdcId;
  final double quantity;
  final String servingLabel;
  final double totalGrams;
  final double caloriesKcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double sugarG;
  final String imageUrl;
  final String notes;
  final bool isFavorite;

  NutritionEntrySummary({
    required this.id,
    required this.entryDate,
    required this.mealType,
    required this.mealLabel,
    required this.foodName,
    required this.brandName,
    required this.source,
    this.fdcId,
    required this.quantity,
    required this.servingLabel,
    required this.totalGrams,
    required this.caloriesKcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
    required this.sugarG,
    required this.imageUrl,
    required this.notes,
    required this.isFavorite,
  });

  factory NutritionEntrySummary.fromJson(Map<String, dynamic> json) {
    return NutritionEntrySummary(
      id: json['id']?.toString() ?? '',
      entryDate: json['entryDate']?.toString() ?? '',
      mealType: json['mealType']?.toString() ?? '',
      mealLabel: json['mealLabel']?.toString() ?? '',
      foodName: json['foodName']?.toString() ?? 'Unknown',
      brandName: json['brandName']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      fdcId: json['fdcId'] is int
          ? json['fdcId'] as int
          : int.tryParse('${json['fdcId'] ?? ''}'),
      quantity: (json['quantity'] ?? 0).toDouble(),
      servingLabel: json['servingLabel']?.toString() ?? '',
      totalGrams: (json['totalGrams'] ?? 0).toDouble(),
      caloriesKcal: (json['caloriesKcal'] ?? 0).toDouble(),
      proteinG: (json['proteinG'] ?? 0).toDouble(),
      carbsG: (json['carbsG'] ?? 0).toDouble(),
      fatG: (json['fatG'] ?? 0).toDouble(),
      fiberG: (json['fiberG'] ?? 0).toDouble(),
      sugarG: (json['sugarG'] ?? 0).toDouble(),
      imageUrl: json['imageUrl']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      isFavorite: json['isFavorite'] == true,
    );
  }

  String get displayTitle {
    if (brandName.isEmpty) return foodName;
    return '$foodName · $brandName';
  }

  String get quantityLine {
    final g = totalGrams > 0 ? '${totalGrams.toStringAsFixed(0)} g total' : '';
    if (g.isEmpty) {
      return '${quantity.toStringAsFixed(quantity == quantity.roundToDouble() ? 0 : 1)} $servingLabel';
    }
    return '${quantity.toStringAsFixed(quantity == quantity.roundToDouble() ? 0 : 1)} × $servingLabel · $g';
  }
}

class NutritionHistoryPage {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final List<NutritionEntrySummary> entries;

  NutritionHistoryPage({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.entries,
  });

  factory NutritionHistoryPage.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v, [int fallback = 0]) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse('$v') ?? fallback;
    }

    final raw = json['entries'];
    final list = raw is List
        ? raw
            .map((e) => NutritionEntrySummary.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList()
        : <NutritionEntrySummary>[];
    return NutritionHistoryPage(
      page: asInt(json['page'], 1),
      limit: asInt(json['limit'], 20),
      total: asInt(json['total'], 0),
      totalPages: asInt(json['totalPages'], 0),
      entries: list,
    );
  }
}

class NutritionFavoriteSections {
  final List<NutritionEntrySummary> foods;
  final List<NutritionEntrySummary> meals;
  final List<NutritionEntrySummary> recipes;

  NutritionFavoriteSections({
    required this.foods,
    required this.meals,
    required this.recipes,
  });

  factory NutritionFavoriteSections.fromJson(Map<String, dynamic> json) {
    List<NutritionEntrySummary> parseList(dynamic v) {
      if (v is! List) return [];
      return v
          .map((e) => NutritionEntrySummary.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return NutritionFavoriteSections(
      foods: parseList(json['foods']),
      meals: parseList(json['meals']),
      recipes: parseList(json['recipes']),
    );
  }
}
