class LibraryModel {
  final String? id;
  final String? exerciseName;
  final String? userType;
  final String? plan;
  final dynamic assignedUser;
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
      id: json['id']?.toString() ?? '',
      exerciseName: json['exerciseName']?.toString() ?? '',
      userType: json['userType']?.toString() ?? '',
      plan: json['plan']?.toString() ?? '',
      assignedUser: json['assignedUser'],
      description: json['description']?.toString() ?? '',
      keyBenefits: _toStringList(json['keyBenefits']),
      muscleGroups: _toStringList(json['muscleGroups']),
      exerciseImage: json['exerciseImage']?.toString() ?? '',
      demoVideo: json['demoVideo']?.toString() ?? '',
      targetMuscleImage: json['targetMuscleImage']?.toString() ?? '',
      exerciseImages: _toStringList(json['exerciseImages']),
      targetMuscleImages: _toStringList(json['targetMuscleImages']),
      demoVideos: _toStringList(json['demoVideos']),
      isVisibleInLibrary: json['isVisibleInLibrary'] ?? false,
      status: json['status']?.toString() ?? '',
      isActive: json['isActive'] ?? false,
      programNames: _toStringList(json['programNames']),
      programCount: _toInt(json['programCount']),
      createdAt: _toDateTime(json['createdAt']),
      updatedAt: _toDateTime(json['updatedAt']),
    );
  }

  /// Convert List
  static List<LibraryModel> fromJsonList(dynamic data) {
    if (data is! List) {
      return const [];
    }

    return data
        .whereType<Map>()
        .map((e) => LibraryModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
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

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

List<String> _toStringList(dynamic value) {
  if (value is! List) {
    return const [];
  }

  return value
      .where((item) => item != null)
      .map((item) => item.toString())
      .toList();
}
