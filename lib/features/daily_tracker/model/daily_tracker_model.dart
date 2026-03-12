/// Models for Daily Tracker API.
///
/// **Backend mapping:**
/// - days[0] = Monday, days[1] = Tuesday, ..., days[6] = Sunday
/// - dayIndex: 1=Mon, 2=Tue, ..., 7=Sun
library;

// ---------------------------------------------------------------------------
// Response models (from backend JSON)
// ---------------------------------------------------------------------------

/// Response for GET /daily-tracker.
class DailyTrackerResponse {
  final DailyTrackerData data;

  DailyTrackerResponse({required this.data});

  factory DailyTrackerResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] as Map<String, dynamic>?;
    if (dataJson == null) throw ArgumentError('data is required');
    return DailyTrackerResponse(
      data: DailyTrackerData.fromJson(dataJson),
    );
  }
}

/// Inner data from GET response.
class DailyTrackerData {
  final String id;
  final String weekStartDateRaw; // Backend ISO - do not use for UI state
  final int weekNumber;
  final double completionRate;
  final List<Habit> habits;
  final List<TrackerNote> notes;

  DailyTrackerData({
    required this.id,
    required this.weekStartDateRaw,
    required this.weekNumber,
    required this.completionRate,
    required this.habits,
    required this.notes,
  });

  factory DailyTrackerData.fromJson(Map<String, dynamic> json) {
    final habitsList = json['habits'] as List<dynamic>? ?? [];
    final notesList = json['notes'] as List<dynamic>? ?? [];

    return DailyTrackerData(
      id: json['id'] as String? ?? '',
      weekStartDateRaw: json['weekStartDate']?.toString() ?? '',
      weekNumber: json['weekNumber'] as int? ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0,
      habits: habitsList.map((e) => Habit.fromJson(e as Map<String, dynamic>)).toList(),
      notes: notesList.map((e) => TrackerNote.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

/// Single habit from backend.
class Habit {
  final String key;
  final String title;
  final String icon;
  final List<bool> days; // days[0]=Mon, days[1]=Tue, ..., days[6]=Sun

  Habit({
    required this.key,
    required this.title,
    required this.icon,
    required this.days,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    final daysRaw = json['days'] as List<dynamic>? ?? [];
    final days = List<bool>.generate(
      7,
      (i) => i < daysRaw.length && daysRaw[i] == true,
    );

    return Habit(
      key: json['key'] as String? ?? '',
      title: json['title'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      days: days,
    );
  }

  /// Emoji for UI display.
  String get emoji {
    const map = {
      'apple': '🍎',
      'no_alcohol': '🚫',
      'workout': '🏋️‍♀',
      'water': '💧',
      'camera': '📸',
      'book': '📚',
    };
    return map[icon] ?? '✓';
  }

  Habit copyWithToggledDay(int arrayIndex) {
    if (arrayIndex < 0 || arrayIndex >= 7) return this;
    final updated = List<bool>.from(days);
    updated[arrayIndex] = !updated[arrayIndex];
    return Habit(key: key, title: title, icon: icon, days: updated);
  }
}

/// Note from backend.
class TrackerNote {
  final String text;
  final int dayIndex;
  final DateTime? createdAt;

  TrackerNote({
    required this.text,
    required this.dayIndex,
    this.createdAt,
  });

  factory TrackerNote.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    return TrackerNote(
      text: json['text'] as String? ?? '',
      dayIndex: json['dayIndex'] as int? ?? 1,
      createdAt: createdAtRaw != null ? DateTime.tryParse(createdAtRaw.toString()) : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Request payloads (to backend)
// ---------------------------------------------------------------------------

/// PATCH body for toggle habit.
class ToggleHabitPayload {
  final String weekStartDate; // YYYY-MM-DD
  final String habitKey;
  final int dayIndex; // 1=Mon..7=Sun
  final bool completed;

  ToggleHabitPayload({
    required this.weekStartDate,
    required this.habitKey,
    required this.dayIndex,
    required this.completed,
  });

  Map<String, dynamic> toJson() => {
        'weekStartDate': weekStartDate,
        'habitKey': habitKey,
        'dayIndex': dayIndex,
        'completed': completed,
      };
}

/// POST body for add note.
class AddNotePayload {
  final String weekStartDate; // YYYY-MM-DD
  final int dayIndex; // 1=Mon..7=Sun
  final String text;

  AddNotePayload({
    required this.weekStartDate,
    required this.dayIndex,
    required this.text,
  });

  Map<String, dynamic> toJson() => {
        'weekStartDate': weekStartDate,
        'dayIndex': dayIndex,
        'text': text,
      };
}
