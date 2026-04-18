class ProgramModel {
  final String? id;
  final String? programName;
  final String? programDuration;
  final int? durationMinutes;
  final String? programLevel;
  final String? userType;
  final String? plan;
  final dynamic assignedUser;
  final String? programDescription;
  final String? safetyNote;
  final String? mobilityType;
  final int? weekCount;
  final int? totalExercises;
  final List<String>? exerciseIds;
  final List<ProgramExerciseModel>? exercises;
  final List<ProgramWorkoutDay>? workoutDays;
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
    this.workoutDays,
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
    final exercisesJson = json['exercises'] as List? ?? const [];

    return ProgramModel(
      id: json['id']?.toString() ?? '',
      programName: json['programName']?.toString() ?? '',
      programDuration: json['programDuration']?.toString() ?? '',
      durationMinutes: _toInt(json['durationMinutes']),
      programLevel: json['programLevel']?.toString() ?? '',
      userType: json['userType']?.toString() ?? '',
      plan: json['plan']?.toString() ?? '',
      assignedUser: json['assignedUser'],
      programDescription: json['programDescription']?.toString() ?? '',
      safetyNote: json['safetyNote']?.toString() ?? '',
      mobilityType: json['mobilityType']?.toString() ?? '',
      weekCount: _toInt(json['weekCount']),
      totalExercises: _toInt(json['totalExercises']),
      exerciseIds: _toStringList(json['exerciseIds']),
      exercises: exercisesJson
          .whereType<Map>()
          .map(
            (e) => ProgramExerciseModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
      workoutDays: (json['workoutDays'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => ProgramWorkoutDay.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      status: json['status']?.toString() ?? '',
      isActive: json['isActive'] ?? false,
      programImage: json['programImage']?.toString() ?? '',
      programThumbnail: json['programThumbnail']?.toString() ?? '',
      programImages: _toStringList(json['programImages']),
      programThumbnails: _toStringList(json['programThumbnails']),
      createdAt: _toDateTime(json['createdAt']),
      updatedAt: _toDateTime(json['updatedAt']),
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
      'workoutDays': workoutDays?.map((e) => e.toJson()).toList(),
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

  static List<ProgramModel> fromJsonList(dynamic data) {
    if (data is! List) {
      return const [];
    }

    return data
        .whereType<Map>()
        .map((e) => ProgramModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

class ProgramWorkoutDay {
  final int dayIndex;
  final String dayLabel;
  final List<String> exerciseIds;
  final int totalExercises;
  final List<ProgramExerciseModel> exercises;

  ProgramWorkoutDay({
    required this.dayIndex,
    required this.dayLabel,
    required this.exerciseIds,
    required this.totalExercises,
    required this.exercises,
  });

  factory ProgramWorkoutDay.fromJson(Map<String, dynamic> json) {
    final exercisesJson = json['exercises'] as List? ?? const [];

    return ProgramWorkoutDay(
      dayIndex: _toInt(json['dayIndex']) ?? 0,
      dayLabel: json['dayLabel']?.toString() ?? '',
      exerciseIds: _toStringList(json['exerciseIds']),
      totalExercises: _toInt(json['totalExercises']) ?? 0,
      exercises: exercisesJson
          .whereType<Map>()
          .map(
            (e) => ProgramExerciseModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayIndex': dayIndex,
      'dayLabel': dayLabel,
      'exerciseIds': exerciseIds,
      'totalExercises': totalExercises,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

class ProgramExerciseModel {
  final String id;
  final String exerciseName;
  final String name;
  final int order;
  final String userType;
  final String plan;
  final dynamic assignedUser;
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
      id: json['id']?.toString() ?? '',
      exerciseName: json['exerciseName']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      order: _toInt(json['order']) ?? 0,
      userType: json['userType']?.toString() ?? '',
      plan: json['plan']?.toString() ?? '',
      assignedUser: json['assignedUser'],
      description: json['description']?.toString() ?? '',
      keyBenefits: _toStringList(json['keyBenefits']),
      muscleGroups: _toStringList(json['muscleGroups']),
      exerciseImages: _toStringList(json['exerciseImages']),
      image: json['image']?.toString() ?? '',
      targetMuscleImages: _toStringList(json['targetMuscleImages']),
      targetMuscleImage: json['targetMuscleImage']?.toString() ?? '',
      demoVideos: _toStringList(json['demoVideos']),
      demoVideo: json['demoVideo']?.toString() ?? '',
      defaultSets: (json['defaultSets'] as List? ?? const []),
      durationSeconds: _toInt(json['durationSeconds']),
      calories: _toInt(json['calories']),
      isVisibleInLibrary: json['isVisibleInLibrary'] ?? false,
      status: json['status']?.toString() ?? '',
      isActive: json['isActive'] ?? false,
      executionMode: json['executionMode']?.toString(),
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
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList();
}
