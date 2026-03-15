/// Response for GET /users/me/daily-tracker/notes?page=1&limit=20
///
/// Backend returns: { success, data: [...], meta: { page, limit, total, totalPages } }
library;

/// Single note item from the list API.
class DailyTrackerNoteItem {
  final String trackerId;
  final String weekStartDate;
  final int weekNumber;
  final int dayIndex;
  final String text;
  final DateTime? createdAt;
  final String? date;

  DailyTrackerNoteItem({
    required this.trackerId,
    required this.weekStartDate,
    required this.weekNumber,
    required this.dayIndex,
    required this.text,
    this.createdAt,
    this.date,
  });

  factory DailyTrackerNoteItem.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    return DailyTrackerNoteItem(
      trackerId: json['trackerId'] as String? ?? '',
      weekStartDate: json['weekStartDate']?.toString() ?? '',
      weekNumber: json['weekNumber'] as int? ?? 0,
      dayIndex: json['dayIndex'] as int? ?? 1,
      text: json['text'] as String? ?? '',
      createdAt: createdAtRaw != null
          ? DateTime.tryParse(createdAtRaw.toString())
          : null,
      date: json['date'] as String?,
    );
  }
}

/// Pagination meta from the list API.
class DailyTrackerNotesMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  DailyTrackerNotesMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory DailyTrackerNotesMeta.fromJson(Map<String, dynamic> json) {
    return DailyTrackerNotesMeta(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}

/// Full response for GET daily-tracker/notes.
class DailyTrackerNotesListResponse {
  final List<DailyTrackerNoteItem> data;
  final DailyTrackerNotesMeta meta;

  DailyTrackerNotesListResponse({
    required this.data,
    required this.meta,
  });

  factory DailyTrackerNotesListResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    final metaJson = json['meta'] as Map<String, dynamic>? ?? {};
    return DailyTrackerNotesListResponse(
      data: dataList
          .map((e) => DailyTrackerNoteItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: DailyTrackerNotesMeta.fromJson(metaJson),
    );
  }
}
