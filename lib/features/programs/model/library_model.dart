class LibraryModel {
  final String? id;
  final String? exerciseName;
  final String? userType;
  final String? plan;
  final String? assignedUser;
  final String? description;
  final List<String>? keyBenefits;
  final List<String>? muscleGroups;
  final String? exerciseImage;
  final String? demoVideo;
  final String? targetMuscleImage;
  final List<String>? exerciseImages;
  final List<String>? targetMuscleImages;
  final List<String>? demoVideos;
  final bool? isVisibleInLibrary;
  final String? status;
  final bool? isActive;
  final List<String>? programNames;
  final int? programCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LibraryModel({
    this.id,
    this.exerciseName,
    this.userType,
    this.plan,
    this.assignedUser,
    this.description,
    this.keyBenefits,
    this.muscleGroups,
    this.exerciseImage,
    this.demoVideo,
    this.targetMuscleImage,
    this.exerciseImages,
    this.targetMuscleImages,
    this.demoVideos,
    this.isVisibleInLibrary,
    this.status,
    this.isActive,
    this.programNames,
    this.programCount,
    this.createdAt,
    this.updatedAt,
  });

  factory LibraryModel.fromJson(Map<String, dynamic> json) {
    return LibraryModel(
      id: json['id'] ?? '',
      exerciseName: json['exerciseName'] ?? '',
      userType: json['userType'] ?? '',
      plan: json['plan'] ?? '',
      assignedUser: json['assignedUser'],
      description: json['description'] ?? '',
      keyBenefits: List<String>.from(json['keyBenefits'] ?? []),
      muscleGroups: List<String>.from(json['muscleGroups'] ?? []),
      exerciseImage: json['exerciseImage'] ?? '',
      demoVideo: json['demoVideo'] ?? '',
      targetMuscleImage: json['targetMuscleImage'] ?? '',
      exerciseImages: List<String>.from(json['exerciseImages'] ?? []),
      targetMuscleImages: List<String>.from(json['targetMuscleImages'] ?? []),
      demoVideos: List<String>.from(json['demoVideos'] ?? []),
      isVisibleInLibrary: json['isVisibleInLibrary'] ?? false,
      status: json['status'] ?? '',
      isActive: json['isActive'] ?? false,
      programNames: List<String>.from(json['programNames'] ?? []),
      programCount: json['programCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  /// Convert List
  static List<LibraryModel> fromJsonList(List data) {
    return data.map((e) => LibraryModel.fromJson(e)).toList();
  }

  /// For API params
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "exerciseName": exerciseName,
      "userType": userType,
      "plan": plan,
      "assignedUser": assignedUser,
      "description": description,
      "keyBenefits": keyBenefits,
      "muscleGroups": muscleGroups,
      "exerciseImage": exerciseImage,
      "demoVideo": demoVideo,
      "targetMuscleImage": targetMuscleImage,
      "exerciseImages": exerciseImages,
      "targetMuscleImages": targetMuscleImages,
      "demoVideos": demoVideos,
      "isVisibleInLibrary": isVisibleInLibrary,
      "status": status,
      "isActive": isActive,
      "programNames": programNames,
      "programCount": programCount,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }
}
