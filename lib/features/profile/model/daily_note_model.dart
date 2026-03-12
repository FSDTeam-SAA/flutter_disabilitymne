class DailyNoteModel {
  final String weekStartDate;
  final String content;
  final DateTime date;

  DailyNoteModel({
    required this.weekStartDate,
    required this.content,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      "weekStartDate": weekStartDate,
      "content": content,
      "date": date.toIso8601String(),
    };
  }

  factory DailyNoteModel.fromJson(Map<String, dynamic> json) {
    return DailyNoteModel(
      weekStartDate: json['weekStartDate'] ?? '',
      content: json['content'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}
