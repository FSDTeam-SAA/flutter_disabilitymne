class NotificationModel {
  String? id;
  String? type;
  String? title;
  String? message;
  bool? read;       // <- change to bool
  String? readAt;
  String? createdAt;
  String? timeAgo;

  NotificationModel({
    this.id,
    this.type,
    this.title,
    this.message,
    this.read,
    this.readAt,
    this.createdAt,
    this.timeAgo,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      message: json['message'],
      read: json['read'] ?? false,
      readAt: json['readAt'],
      createdAt: json['createdAt'],
      timeAgo: json['timeAgo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'read': read,
      'readAt': readAt,
      'createdAt': createdAt,
      'timeAgo': timeAgo,
    };
  }
}