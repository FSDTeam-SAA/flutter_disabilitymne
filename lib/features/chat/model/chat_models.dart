// Chat models matching backend API and socket payloads.

class ChatUserLite {
  final String id;
  final String? firstName;
  final String? email;
  final String? role;
  final String? profileImage;

  const ChatUserLite({
    required this.id,
    this.firstName,
    this.email,
    this.role,
    this.profileImage,
  });

  factory ChatUserLite.fromJson(Map<String, dynamic> json) {
    String? profileImage;
    final p = json['profileImage'];
    if (p is String && p.isNotEmpty) profileImage = p;
    if (profileImage == null && p is Map)
      profileImage = p['url']?.toString().trim();
    return ChatUserLite(
      id: _str(json['id'] ?? json['_id']),
      firstName: json['firstName'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      profileImage: profileImage,
    );
  }

  static String _str(dynamic v) =>
      v == null ? '' : (v is String ? v : v.toString()).trim();

  String get displayName =>
      firstName?.trim().isNotEmpty == true ? firstName! : (email ?? id);
}

class ChatAttachment {
  final String url;
  final String? publicId;
  final String? mimetype;
  final int size;

  const ChatAttachment({
    required this.url,
    this.publicId,
    this.mimetype,
    this.size = 0,
  });

  factory ChatAttachment.fromJson(Map<String, dynamic> json) {
    return ChatAttachment(
      url: _str(json['url']),
      publicId: json['publicId'] as String?,
      mimetype: json['mimetype'] as String?,
      size: (json['size'] is int) ? json['size'] as int : 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'publicId': publicId ?? '',
    'mimetype': mimetype ?? '',
    'size': size,
  };

  static String _str(dynamic v) =>
      v == null ? '' : (v is String ? v : v.toString()).trim();
}

class ChatMessage {
  final String id;
  final String? threadId;
  final ChatUserLite? sender;
  final ChatUserLite? recipient;
  final String message;
  final List<ChatAttachment> attachments;
  final DateTime? readAt;
  final bool isMine;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ChatMessage({
    required this.id,
    this.threadId,
    this.sender,
    this.recipient,
    this.message = '',
    this.attachments = const [],
    this.readAt,
    this.isMine = false,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final att = json['attachments'];
    List<ChatAttachment> list = [];
    if (att is List) {
      for (final e in att) {
        if (e is Map<String, dynamic>) {
          list.add(ChatAttachment.fromJson(e));
        } else if (e is Map) {
          list.add(ChatAttachment.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return ChatMessage(
      id: _str(json['id'] ?? json['_id']),
      // ignore: prefer_null_aware_operators
      threadId: json['threadId'] != null
          ? json['threadId'].toString().trim()
          : null,
      sender: json['sender'] is Map<String, dynamic>
          ? ChatUserLite.fromJson(json['sender'] as Map<String, dynamic>)
          : json['sender'] is String
          ? ChatUserLite(id: json['sender'])
          : null,
      recipient: json['recipient'] is Map<String, dynamic>
          ? ChatUserLite.fromJson(json['recipient'] as Map<String, dynamic>)
          : json['recipient'] is String
          ? ChatUserLite(id: json['recipient'])
          : null,
      message: (json['message'] as String?) ?? '',
      attachments: list,
      readAt: _parseDate(json['readAt']),
      isMine:
          json['isMine'] == true ||
          json['isMine'] == 'true' ||
          json['is_mine'] == true,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static String _str(dynamic v) =>
      v == null ? '' : (v is String ? v : v.toString()).trim();

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}

/// Summary for thread list or socket chat:thread:updated.
class ChatThreadSummary {
  final String id;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final DateTime? updatedAt;

  const ChatThreadSummary({
    required this.id,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.updatedAt,
  });

  factory ChatThreadSummary.fromJson(Map<String, dynamic> json) {
    return ChatThreadSummary(
      id: ChatMessage._str(json['id']),
      lastMessagePreview: json['lastMessagePreview'] as String?,
      lastMessageAt: ChatMessage._parseDate(json['lastMessageAt']),
      updatedAt: ChatMessage._parseDate(json['updatedAt']),
    );
  }
}
