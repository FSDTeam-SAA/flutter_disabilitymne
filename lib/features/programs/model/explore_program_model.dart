class ProgramModel {
  final String? id;
  final String? programName;
  final String? programDuration;
  final int? durationMinutes;
  final String? programLevel;
  final String? userType;
  final String? plan;
  final String? assignedUser;
  final String? programDescription;
  final String? safetyNote;
  final String? mobilityType;
  final int? weekCount;
  final int? totalExercises;
  final List<String>? exerciseIds;
  final List<ProgramExerciseModel>? exercises;
  final String? status;
  final bool? isActive;
  final String? programImage;
  final String? programThumbnail;
  final List<String>? programImages;
  final List<String>? programThumbnails;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProgramModel({
    this.id,
    this.programName,
    this.programDuration,
    this.durationMinutes,
    this.programLevel,
    this.userType,
    this.plan,
    this.assignedUser,
    this.programDescription,
    this.safetyNote,
    this.mobilityType,
    this.weekCount,
    this.totalExercises,
    this.exerciseIds,
    this.exercises,
    this.status,
    this.isActive,
    this.programImage,
    this.programThumbnail,
    this.programImages,
    this.programThumbnails,
    this.createdAt,
    this.updatedAt,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id'] ?? '',
      programName: json['programName'] ?? '',
      programDuration: json['programDuration'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 0,
      programLevel: json['programLevel'] ?? '',
      userType: json['userType'] ?? '',
      plan: json['plan'] ?? '',
      assignedUser: json['assignedUser'],
      programDescription: json['programDescription'] ?? '',
      safetyNote: json['safetyNote'] ?? '',
      mobilityType: json['mobilityType'] ?? '',
      weekCount: json['weekCount'] ?? 0,
      totalExercises: json['totalExercises'] ?? 0,
      exerciseIds: List<String>.from(json['exerciseIds'] ?? []),
      exercises: (json['exercises'] as List)
          .map((e) => ProgramExerciseModel.fromJson(e))
          .toList(),
      status: json['status'] ?? '',
      isActive: json['isActive'] ?? false,
      programImage: json['programImage'] ?? '',
      programThumbnail: json['programThumbnail'] ?? '',
      programImages: List<String>.from(json['programImages'] ?? []),
      programThumbnails: List<String>.from(json['programThumbnails'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'programName': programName,
      'programDuration': programDuration,
      'durationMinutes': durationMinutes,
      'programLevel': programLevel,
      'userType': userType,
      'plan': plan,
      'assignedUser': assignedUser,
      'programDescription': programDescription,
      'safetyNote': safetyNote,
      'mobilityType': mobilityType,
      'weekCount': weekCount,
      'totalExercises': totalExercises,
      'exerciseIds': exerciseIds,
      'exercises': exercises?.map((e) => e.toJson()).toList(),
      'status': status,
      'isActive': isActive,
      'programImage': programImage,
      'programThumbnail': programThumbnail,
      'programImages': programImages,
      'programThumbnails': programThumbnails,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static List<ProgramModel> fromJsonList(List data) {
    return data.map((e) => ProgramModel.fromJson(e)).toList();
  }
}

class ProgramExerciseModel {
  final String id;
  final String exerciseName;
  final String name;
  final int order;
  final String userType;
  final String plan;
  final String? assignedUser;
  final String description;
  final List<String> keyBenefits;
  final List<String> muscleGroups;
  final List<String> exerciseImages;
  final String image;
  final List<String> targetMuscleImages;
  final String targetMuscleImage;
  final List<String> demoVideos;
  final String demoVideo;
  final List<dynamic> defaultSets;
  final int? durationSeconds;
  final int? calories;
  final bool isVisibleInLibrary;
  final String status;
  final bool isActive;
  String? executionMode;

  ProgramExerciseModel({
    required this.id,
    required this.exerciseName,
    required this.name,
    required this.order,
    required this.userType,
    required this.plan,
    this.assignedUser,
    required this.description,
    required this.keyBenefits,
    required this.muscleGroups,
    required this.exerciseImages,
    required this.image,
    required this.targetMuscleImages,
    required this.targetMuscleImage,
    required this.demoVideos,
    required this.demoVideo,
    required this.defaultSets,
    this.durationSeconds,
    this.calories,
    required this.isVisibleInLibrary,
    required this.status,
    required this.isActive,
    this.executionMode,
  });

  factory ProgramExerciseModel.fromJson(Map<String, dynamic> json) {
    return ProgramExerciseModel(
      id: json['id'] ?? '',
      exerciseName: json['exerciseName'] ?? '',
      name: json['name'] ?? '',
      order: json['order'] ?? 0,
      userType: json['userType'] ?? '',
      plan: json['plan'] ?? '',
      assignedUser: json['assignedUser'],
      description: json['description'] ?? '',
      keyBenefits: List<String>.from(json['keyBenefits'] ?? []),
      muscleGroups: List<String>.from(json['muscleGroups'] ?? []),
      exerciseImages: List<String>.from(json['exerciseImages'] ?? []),
      image: json['image'] ?? '',
      targetMuscleImages: List<String>.from(json['targetMuscleImages'] ?? []),
      targetMuscleImage: json['targetMuscleImage'] ?? '',
      demoVideos: List<String>.from(json['demoVideos'] ?? []),
      demoVideo: json['demoVideo'] ?? '',
      defaultSets: json['defaultSets'] ?? [],
      durationSeconds: json['durationSeconds'],
      calories: json['calories'],
      isVisibleInLibrary: json['isVisibleInLibrary'] ?? false,
      status: json['status'] ?? '',
      isActive: json['isActive'] ?? false,
      executionMode: json['executionMode'],
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseName': exerciseName,
      'name': name,
      'order': order,
      'userType': userType,
      'plan': plan,
      'assignedUser': assignedUser,
      'description': description,
      'keyBenefits': keyBenefits,
      'muscleGroups': muscleGroups,
      'exerciseImages': exerciseImages,
      'image': image,
      'targetMuscleImages': targetMuscleImages,
      'targetMuscleImage': targetMuscleImage,
      'demoVideos': demoVideos,
      'demoVideo': demoVideo,
      'defaultSets': defaultSets,
      'durationSeconds': durationSeconds,
      'calories': calories,
      'isVisibleInLibrary': isVisibleInLibrary,
      'status': status,
      'isActive': isActive,
      'executionMode': executionMode,
    };
  }
}
