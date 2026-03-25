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
      date: DateTime.tryParse(_stringValue(json['date'])) ?? DateTime.now(),
      totals: Totals.fromJson(_jsonMap(json['totals'])),
      macroPercentages: MacroPercentages.fromJson(
        _jsonMap(json['macroPercentages']),
      ),
      macroProgress: MacroProgress.fromJson(_jsonMap(json['macroProgress'])),
      targets: Targets.fromJson(_jsonMap(json['targets'])),
      energy: Energy.fromJson(_jsonMap(json['energy'])),
      totalEntries: _intValue(json['totalEntries']),
      meals: (json['meals'] as List? ?? [])
          .map((e) => Meal.fromJson(_jsonMap(e)))
          .toList(),
      mealRecommendations: (json['mealRecommendations'] as List? ?? [])
          .map((e) => MealRecommendation.fromJson(_jsonMap(e)))
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
      'mealRecommendations': mealRecommendations
          .map((e) => e.toJson())
          .toList(),
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
      caloriesKcal: _doubleValue(json['caloriesKcal']),
      proteinG: _doubleValue(json['proteinG']),
      carbsG: _doubleValue(json['carbsG']),
      fatG: _doubleValue(json['fatG']),
      fiberG: _doubleValue(json['fiberG']),
      sugarG: _doubleValue(json['sugarG']),
      totalGrams: _doubleValue(json['totalGrams']),
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
      proteinPercent: _doubleValue(json['proteinPercent']),
      carbsPercent: _doubleValue(json['carbsPercent']),
      fatPercent: _doubleValue(json['fatPercent']),
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
      carbs: MacroItem.fromJson(_jsonMap(json['carbs'])),
      protein: MacroItem.fromJson(_jsonMap(json['protein'])),
      fat: MacroItem.fromJson(_jsonMap(json['fat'])),
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
      consumedG: _doubleValue(json['consumedG']),
      targetG: _doubleValue(json['targetG']),
      remainingG: _doubleValue(json['remainingG']),
      progressPercent: _doubleValue(json['progressPercent']),
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
      weightKg: _doubleValue(json['weightKg']),
      goal: _stringValue(json['goal']),
      multipliers: Multipliers.fromJson(_jsonMap(json['multipliers'])),
      macros: MacroTargets.fromJson(_jsonMap(json['macros'])),
      calories: Calories.fromJson(_jsonMap(json['calories'])),
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
      proteinPerKg: _doubleValue(json['proteinPerKg']),
      carbsPerKg: _doubleValue(json['carbsPerKg']),
      fatPerKg: _doubleValue(json['fatPerKg']),
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
      proteinG: _doubleValue(json['proteinG']),
      carbsG: _doubleValue(json['carbsG']),
      fatG: _doubleValue(json['fatG']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'proteinG': proteinG, 'carbsG': carbsG, 'fatG': fatG};
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
      proteinCalories: _doubleValue(json['proteinCalories']),
      carbsCalories: _doubleValue(json['carbsCalories']),
      fatCalories: _doubleValue(json['fatCalories']),
      macroCalories: _doubleValue(json['macroCalories']),
      recommendedCalories: _doubleValue(json['recommendedCalories']),
      minCalories: _doubleValue(json['minCalories']),
      maxCalories: _doubleValue(json['maxCalories']),
      remainingCalories: _doubleValue(json['remainingCalories']),
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
      eatenKcal: _doubleValue(json['eatenKcal']),
      burnedKcal: _doubleValue(json['burnedKcal']),
      netKcal: _doubleValue(json['netKcal']),
      goalKcal: _doubleValue(json['goalKcal']),
      remainingKcal: _doubleValue(json['remainingKcal']),
      status: _stringValue(json['status']),
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
      mealType: _stringValue(json['mealType']),
      mealLabel: _stringValue(json['mealLabel']),
      totalEntries: _intValue(json['totalEntries']),
      totals: Totals.fromJson(_jsonMap(json['totals'])),
      macroPercentages: MacroPercentages.fromJson(
        _jsonMap(json['macroPercentages']),
      ),
      recommendation: Recommendation.fromJson(_jsonMap(json['recommendation'])),
      entries: (json['entries'] as List? ?? [])
          .map((e) => DiaryEntry.fromJson(_jsonMap(e)))
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
  final String brandName;
  final int? fdcId;
  final String date;
  final String mealType;
  final String mealLabel;
  final double quantity;
  final String servingLabel;
  final double servingGrams;
  final double totalGrams;
  final double caloriesKcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final bool isFavorite;
  final Map<String, dynamic>? nutrientsPer100g;

  DiaryEntry({
    this.id,
    required this.foodName,
    required this.brandName,
    this.fdcId,
    required this.date,
    required this.mealType,
    required this.mealLabel,
    required this.quantity,
    required this.servingLabel,
    required this.servingGrams,
    required this.totalGrams,
    required this.caloriesKcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.isFavorite,
    this.nutrientsPer100g,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    final quantity = _doubleValue(json['quantity']);
    final totalGrams = _doubleValue(json['totalGrams']);
    final fallbackServingGrams = quantity > 0 && totalGrams > 0
        ? totalGrams / quantity
        : totalGrams;

    return DiaryEntry(
      id: json['id']?.toString(),
      foodName: _stringValue(json['foodName'], fallback: 'Unknown'),
      brandName: _stringValue(json['brandName']),
      fdcId: _intOrNull(json['fdcId']),
      date: _stringValue(
        json['entryDate'],
        fallback: _stringValue(json['date']),
      ),
      mealType: _stringValue(json['mealType']),
      mealLabel: _stringValue(json['mealLabel']),
      quantity: quantity,
      servingLabel: _stringValue(json['servingLabel']),
      servingGrams: _doubleValue(
        json['servingGrams'],
        fallback: fallbackServingGrams,
      ),
      totalGrams: totalGrams,
      caloriesKcal: _doubleValue(json['caloriesKcal']),
      proteinG: _doubleValue(json['proteinG']),
      carbsG: _doubleValue(json['carbsG']),
      fatG: _doubleValue(json['fatG']),
      isFavorite: json['isFavorite'] == true,
      nutrientsPer100g: _jsonMapOrNull(json['nutrientsPer100g']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodName': foodName,
      'brandName': brandName,
      'fdcId': fdcId,
      'date': date,
      'mealType': mealType,
      'mealLabel': mealLabel,
      'quantity': quantity,
      'servingLabel': servingLabel,
      'servingGrams': servingGrams,
      'totalGrams': totalGrams,
      'caloriesKcal': caloriesKcal,
      'proteinG': proteinG,
      'carbsG': carbsG,
      'fatG': fatG,
      'isFavorite': isFavorite,
      'nutrientsPer100g': nutrientsPer100g,
    };
  }

  double get calories {
    if (caloriesKcal > 0) return caloriesKcal;
    if (nutrientsPer100g == null) return 0;
    final kcal = nutrientsPer100g!['caloriesKcal'] ?? 0;
    final ratio = (quantity * servingGrams) / 100;
    return (kcal is num ? kcal.toDouble() : 0) * ratio;
  }

  String get displayTitle {
    if (brandName.isEmpty) return foodName;
    return '$foodName | $brandName';
  }

  String get quantityLine {
    final quantityLabel = quantity.toStringAsFixed(
      quantity == quantity.roundToDouble() ? 0 : 1,
    );
    final grams = totalGrams > 0
        ? '${totalGrams.toStringAsFixed(0)} g total'
        : '';
    if (grams.isEmpty) {
      return '$quantityLabel $servingLabel';
    }
    return '$quantityLabel x $servingLabel | $grams';
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
      mealType: _stringValue(json['mealType']),
      mealLabel: _stringValue(json['mealLabel']),
      recommendation: Recommendation.fromJson(_jsonMap(json['recommendation'])),
      totals: Totals.fromJson(_jsonMap(json['totals'])),
      macroPercentages: MacroPercentages.fromJson(
        _jsonMap(json['macroPercentages']),
      ),
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
      recommendedCalories: CalorieRange.fromJson(
        _jsonMap(json['recommendedCalories']),
      ),
      eatenKcal: _doubleValue(json['eatenKcal']),
      remainingCalories: CalorieRange.fromJson(
        _jsonMap(json['remainingCalories']),
      ),
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
      minKcal: _doubleValue(
        json['minKcal'],
        fallback: _doubleValue(json['toMinKcal']),
      ),
      maxKcal: _doubleValue(
        json['maxKcal'],
        fallback: _doubleValue(json['toMaxKcal']),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'minKcal': minKcal, 'maxKcal': maxKcal};
  }
}

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
  final String favoriteKind;

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
    required this.favoriteKind,
  });

  factory NutritionEntrySummary.fromJson(Map<String, dynamic> json) {
    return NutritionEntrySummary(
      id: _stringValue(json['id']),
      entryDate: _stringValue(
        json['entryDate'],
        fallback: _stringValue(json['date']),
      ),
      mealType: _stringValue(json['mealType']),
      mealLabel: _stringValue(json['mealLabel']),
      foodName: _stringValue(json['foodName'], fallback: 'Unknown'),
      brandName: _stringValue(json['brandName']),
      source: _stringValue(json['source']),
      fdcId: _intOrNull(json['fdcId']),
      quantity: _doubleValue(json['quantity']),
      servingLabel: _stringValue(json['servingLabel']),
      totalGrams: _doubleValue(json['totalGrams']),
      caloriesKcal: _doubleValue(json['caloriesKcal']),
      proteinG: _doubleValue(json['proteinG']),
      carbsG: _doubleValue(json['carbsG']),
      fatG: _doubleValue(json['fatG']),
      fiberG: _doubleValue(json['fiberG']),
      sugarG: _doubleValue(json['sugarG']),
      imageUrl: _stringValue(json['imageUrl']),
      notes: _stringValue(json['notes']),
      isFavorite: json['isFavorite'] == true,
      favoriteKind: _stringValue(json['favoriteKind'], fallback: 'food'),
    );
  }

  String get displayTitle {
    if (brandName.isEmpty) return foodName;
    return '$foodName | $brandName';
  }

  String get quantityLine {
    final g = totalGrams > 0 ? '${totalGrams.toStringAsFixed(0)} g total' : '';
    final quantityLabel = quantity.toStringAsFixed(
      quantity == quantity.roundToDouble() ? 0 : 1,
    );
    if (g.isEmpty) {
      return '$quantityLabel $servingLabel';
    }
    return '$quantityLabel x $servingLabel | $g';
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
    final rawEntries = json['entries'] as List? ?? [];
    return NutritionHistoryPage(
      page: _intValue(json['page'], 1),
      limit: _intValue(json['limit'], 20),
      total: _intValue(json['total']),
      totalPages: _intValue(json['totalPages']),
      entries: rawEntries
          .map((e) => NutritionEntrySummary.fromJson(_jsonMap(e)))
          .toList(),
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
    List<NutritionEntrySummary> parseList(dynamic value) {
      if (value is! List) return [];
      return value
          .map((e) => NutritionEntrySummary.fromJson(_jsonMap(e)))
          .toList();
    }

    return NutritionFavoriteSections(
      foods: parseList(json['foods']),
      meals: parseList(json['meals']),
      recipes: parseList(json['recipes']),
    );
  }
}

Map<String, dynamic> _jsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map(
      (key, dynamic mapValue) => MapEntry(key.toString(), mapValue),
    );
  }
  return <String, dynamic>{};
}

Map<String, dynamic>? _jsonMapOrNull(dynamic value) {
  if (value == null) return null;
  final map = _jsonMap(value);
  return map.isEmpty ? null : map;
}

double _doubleValue(dynamic value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

int _intValue(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

int? _intOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String && value.trim().isNotEmpty) {
    return int.tryParse(value);
  }
  return null;
}

String _stringValue(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final normalized = value.toString();
  return normalized.isEmpty ? fallback : normalized;
}
