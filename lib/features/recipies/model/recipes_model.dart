class RecipeModel {
  String? id;
  String? recipeName;
  String? recipeDuration;
  int? durationMinutes;
  String? recipeType;
  String? userType;
  dynamic assignedUser;
  int? caloriesKcal;
  int? proteinG;
  int? carbsG;
  int? fatG;
  String? nutritionSummary;
  String? recipeImage;
  List<String>? recipeImages;
  String? status;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? howToPrepare;
  List<String>? ingredients;

  RecipeModel({
    this.id,
    this.recipeName,
    this.recipeDuration,
    this.durationMinutes,
    this.recipeType,
    this.userType,
    this.assignedUser,
    this.caloriesKcal,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.nutritionSummary,
    this.recipeImage,
    this.recipeImages,
    this.status,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.howToPrepare,
    this.ingredients,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'],
      recipeName: json['recipeName'],
      recipeDuration: json['recipeDuration'],
      durationMinutes: json['durationMinutes'],
      recipeType: json['recipeType'],
      userType: json['userType'],
      assignedUser: json['assignedUser'],
      caloriesKcal: json['caloriesKcal'],
      proteinG: json['proteinG'],
      carbsG: json['carbsG'],
      fatG: json['fatG'],
      nutritionSummary: json['nutritionSummary'],
      recipeImage: json['recipeImage'],
      recipeImages: json['recipeImages'] != null
          ? List<String>.from(json['recipeImages'])
          : [],
      status: json['status'],
      isActive: json['isActive'],
      howToPrepare: json['howToPrepare'],
      ingredients: json['ingredients'] != null
          ? List<String>.from(json['ingredients'])
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "recipeName": recipeName,
      "recipeDuration": recipeDuration,
      "durationMinutes": durationMinutes,
      "recipeType": recipeType,
      "userType": userType,
      "assignedUser": assignedUser,
      "caloriesKcal": caloriesKcal,
      "proteinG": proteinG,
      "carbsG": carbsG,
      "fatG": fatG,
      "nutritionSummary": nutritionSummary,
      "recipeImage": recipeImage,
      "recipeImages": recipeImages,
      "status": status,
      "isActive": isActive,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "howToPrepare": howToPrepare,
      "ingredients": ingredients,
    };
  }

  //fromjsonlist
  static List<RecipeModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => RecipeModel.fromJson(json)).toList();
  }
}
