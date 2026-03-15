import 'dart:async';
import 'package:disabilitymne/features/chat/model/chat_models.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Real-time chat using Socket.IO. Connect with JWT, join/leave thread rooms,
/// listen for chat:message:new (and optional thread events).
class ChatSocketService {
  io.Socket? _socket;
  final String socketUrl;
  final StreamController<ChatMessage> _newMessageController =
      StreamController<ChatMessage>.broadcast();
  final StreamController<ChatThreadSummary> _threadUpdatedController =
      StreamController<ChatThreadSummary>.broadcast();
  final StreamController<ChatThreadReadEvent> _threadReadController =
      StreamController<ChatThreadReadEvent>.broadcast();

  ChatSocketService({required this.socketUrl});

  /// Stream of new messages (from chat:message:new).
  Stream<ChatMessage> get onNewMessage => _newMessageController.stream;

  /// Stream of thread updates (from chat:thread:updated).
  Stream<ChatThreadSummary> get onThreadUpdated =>
      _threadUpdatedController.stream;

  /// Stream of read receipts (from chat:thread:read).
  Stream<ChatThreadReadEvent> get onThreadRead =>
      _threadReadController.stream;

  bool get isConnected => _socket?.connected ?? false;

  /// Connect to socket server with JWT. Call when user is authenticated.
  /// Token can be from your auth storage (e.g. AuthorizedPigeon / getCurrentAuthRecord).
  void connect(String accessToken) {
    if (accessToken.trim().isEmpty) {
      debugPrint('ChatSocketService: cannot connect without access token');
      return;
    }
    disconnect();
    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': accessToken})
          .build(),
    );
    _socket!.onConnect((_) {
      debugPrint('ChatSocketService: connected');
    });
    _socket!.onDisconnect((_) {
      debugPrint('ChatSocketService: disconnected');
    });
    _socket!.onConnectError((e) {
      debugPrint('ChatSocketService: connect error $e');
    });
    _socket!.on('chat:message:new', (data) {
      if (data is Map<String, dynamic>) {
        final msg = data['message'];
        if (msg is Map<String, dynamic>) {
          _newMessageController.add(ChatMessage.fromJson(msg));
        }
      }
    });
    _socket!.on('chat:thread:updated', (data) {
      if (data is Map<String, dynamic>) {
        final thread = data['thread'];
        if (thread is Map<String, dynamic>) {
          _threadUpdatedController.add(ChatThreadSummary.fromJson(thread));
        }
      }
    });
    _socket!.on('chat:thread:read', (data) {
      if (data is Map<String, dynamic>) {
        _threadReadController.add(ChatThreadReadEvent(
          threadId: _str(data['threadId']),
          readerId: _str(data['readerId']),
          markedCount: (data['markedCount'] is int) ? data['markedCount'] as int : 0,
          readAt: data['readAt'] != null ? DateTime.tryParse(data['readAt'].toString()) : null,
        ));
      }
    });
  }

  static String _str(dynamic v) =>
      v == null ? '' : (v is String ? v : v.toString()).trim();

  /// Join thread room. Call when opening a chat screen.
  void joinThread(String threadId) {
    final id = threadId.trim();
    if (id.isEmpty) return;
    _socket?.emit('chat:join-thread', id);
    debugPrint('ChatSocketService: joined thread $id');
  }

  /// Leave thread room. Call when closing the chat screen.
  void leaveThread(String threadId) {
    final id = threadId.trim();
    if (id.isEmpty) return;
    _socket?.emit('chat:leave-thread', id);
    debugPrint('ChatSocketService: left thread $id');
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _newMessageController.close();
    _threadUpdatedController.close();
    _threadReadController.close();
  }
}

class ChatThreadReadEvent {
  final String threadId;
  final String readerId;
  final int markedCount;
  final DateTime? readAt;

  const ChatThreadReadEvent({
    required this.threadId,
    required this.readerId,
    required this.markedCount,
    this.readAt,
  });
}
