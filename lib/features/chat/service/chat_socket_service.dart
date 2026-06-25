import 'dart:async';
import 'package:disabilitymne/features/chat/model/chat_models.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../core/constants/api_endpoints.dart';

/// Connection state for the Socket.IO client.
enum SocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// Real-time chat using Socket.IO. Connect with JWT, join/leave thread rooms,
/// listen for chat:message:new and chat:thread:updated, handle reconnection
/// and lifecycle (pause/resume).
class ChatSocketService {
  /// Set to true to enable debugPrint logs for socket connection, events, and errors.
  static const bool debug = false;

  io.Socket? _socket;
  final String socketUrl;
  String? _lastToken;
  final Set<String> _joinedThreadIds = {};
  final StreamController<SocketConnectionState> _stateController =
      StreamController<SocketConnectionState>.broadcast();
  final StreamController<ChatMessage> _newMessageController =
      StreamController<ChatMessage>.broadcast();
  final StreamController<ChatThreadSummary> _threadUpdatedController =
      StreamController<ChatThreadSummary>.broadcast();
  final StreamController<ChatThreadReadEvent> _threadReadController =
      StreamController<ChatThreadReadEvent>.broadcast();

  static const int _reconnectionAttempts = 10;
  static const int _reconnectionDelayMs = 1000;
  static const int _reconnectionDelayMaxMs = 10000;

  ChatSocketService({required this.socketUrl});

  /// Current connection state.
  SocketConnectionState get connectionState => _currentState;
  SocketConnectionState _currentState = SocketConnectionState.disconnected;

  /// Stream of connection state changes.
  Stream<SocketConnectionState> get onConnectionState =>
      _stateController.stream;

  /// Stream of new messages (from chat:message:new).
  Stream<ChatMessage> get onNewMessage => _newMessageController.stream;

  /// Stream of thread updates (from chat:thread:updated).
  Stream<ChatThreadSummary> get onThreadUpdated =>
      _threadUpdatedController.stream;

  /// Stream of read receipts (from chat:thread:read).
  Stream<ChatThreadReadEvent> get onThreadRead => _threadReadController.stream;

  bool get isConnected => _socket?.connected ?? false;

  // void debugPrint(String message) {
  //   if (debug) debugPrint('ChatSocketService: $message');
  // }

  /// Set connection state and notify listeners.
  void _setState(SocketConnectionState state) {
    if (_currentState == state) return;
    _currentState = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
    debugPrint('state=$state');
  }

  static Map<String, dynamic>? _toMap(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((k, v) => MapEntry(k?.toString() ?? '', v));
    }
    return null;
  }

  static String _str(dynamic v) =>
      v == null ? '' : (v is String ? v : v.toString()).trim();

  /// Connect to socket server with JWT. Call when user is authenticated.
  /// Reconnection is enabled; on reconnect the client will re-join all previously joined threads.
  /// If already connected with the same token, skips reconnecting.
  void connect(String accessToken) {
    if (accessToken.isEmpty) {
      debugPrint('cannot connect without access token');
      return;
    }
    // Initially check: socket already connected with same token → no need to reconnect
    if (_socket != null && _socket!.connected && _lastToken == accessToken) {
      _setState(SocketConnectionState.connected);
      debugPrint('already connected, skipping reconnect');
      return;
    }
    disconnect();
    _lastToken = accessToken;
    _setState(SocketConnectionState.connecting);

    _socket = io.io(
      ApiEndpoints.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(_reconnectionAttempts)
          .setReconnectionDelay(_reconnectionDelayMs)
          .setReconnectionDelayMax(_reconnectionDelayMaxMs)
          .setAuth({'token': accessToken})
          .setQuery({'token': accessToken})
          .setExtraHeaders({'Authorization': 'Bearer $accessToken'})
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint("Socket is connected");
      _setState(SocketConnectionState.connected);
      _rejoinAllThreads();
    });

    _socket!.onDisconnect((reason) {
      _setState(SocketConnectionState.disconnected);
      debugPrint('disconnected reason=$reason');
    });

    _socket!.onReconnectAttempt((attempt) {
      _setState(SocketConnectionState.reconnecting);
      debugPrint('reconnect attempt $attempt');
    });

    _socket!.onReconnect((_) {
      _setState(SocketConnectionState.connected);
      _rejoinAllThreads();
      debugPrint('reconnected');
    });

    _socket!.onReconnectError((e) {
      _setState(SocketConnectionState.error);
      debugPrint('reconnect error $e');
    });

    _socket!.onReconnectFailed((_) {
      _setState(SocketConnectionState.error);
      debugPrint('reconnect failed');
    });

    _socket!.onConnectError((e) {
      _setState(SocketConnectionState.error);
      debugPrint('connect error $e');
    });

    _socket!.onError((e) {
      _setState(SocketConnectionState.error);
      debugPrint('socket error $e');
    });

    _socket!.on('chat:message:new', (data) {
      final map = _toMap(data);
      if (map == null) return;
      final msg = map['message'];
      Map<String, dynamic>? msgMap = _toMap(msg);
      if (msgMap == null) return;
      final payloadThreadId = _str(map['threadId']);
      if (payloadThreadId.isNotEmpty &&
          (msgMap['threadId'] == null || _str(msgMap['threadId']).isEmpty)) {
        msgMap = Map<String, dynamic>.from(msgMap)
          ..['threadId'] = payloadThreadId;
      }
      try {
        debugPrint("New Message Data : $msgMap");
        _newMessageController.add(ChatMessage.fromJson(msgMap));
      } catch (e, st) {
        debugPrint('parse chat:message:new error $e $st');
      }
    });

    _socket!.on('chat:thread:updated', (data) {
      final map = _toMap(data);
      if (map == null) return;
      final thread = map['thread'];
      final threadMap = _toMap(thread);
      if (threadMap != null) {
        try {
          _threadUpdatedController.add(ChatThreadSummary.fromJson(threadMap));
        } catch (e, st) {
          debugPrint('parse chat:thread:updated error $e $st');
        }
      }
    });

    _socket!.on('chat:thread:read', (data) {
      debugPrint("New Message from Socket -> $data");
      final map = _toMap(data);
      if (map == null) return;
      try {
        final readAt = map['readAt'];
        _threadReadController.add(
          ChatThreadReadEvent(
            threadId: _str(map['threadId']),
            readerId: _str(map['readerId']),
            markedCount: (map['markedCount'] is int)
                ? map['markedCount'] as int
                : 0,
            readAt: readAt != null
                ? DateTime.tryParse(readAt.toString())
                : null,
          ),
        );
      } catch (e, st) {
        debugPrint('parse chat:thread:read error $e $st');
      }
    });
  }

  void _rejoinAllThreads() {
    for (final id in _joinedThreadIds) {
      if (id.trim().isEmpty) continue;
      _socket?.emit('chat:join-thread', id);
    }
    if (_joinedThreadIds.isNotEmpty) {
      debugPrint('re-joined ${_joinedThreadIds.length} thread(s)');
    }
  }

  /// Join thread room. Call when opening a chat screen.
  void joinThread(String threadId) {
    final id = threadId.trim();
    if (id.isEmpty) return;
    _joinedThreadIds.add(id);
    _socket?.emit('chat:join-thread', id);
    debugPrint('joined thread $id');
  }

  /// Leave thread room. Call when closing the chat screen.
  void leaveThread(String threadId) {
    final id = threadId.trim();
    if (id.isEmpty) return;
    _joinedThreadIds.remove(id);
    _socket?.emit('chat:leave-thread', id);
    debugPrint('left thread $id');
  }

  /// Emit a custom event to the server. Use for any future server events.
  /// Backend currently listens: chat:join-thread(threadId), chat:leave-thread(threadId).
  void emit(String event, [dynamic data]) {
    if (event.trim().isEmpty) return;
    if (data != null) {
      _socket?.emit(event, data);
    } else {
      _socket?.emit(event);
    }
    debugPrint('emit $event');
  }

  Future<ChatMessage> sendMessage({
    required String threadId,
    String message = '',
    List<ChatAttachment> attachments = const [],
  }) {
    final completer = Completer<ChatMessage>();
    final socket = _socket;

    if (socket == null || !socket.connected) {
      completer.completeError(Exception('Socket is not connected.'));
      return completer.future;
    }

    final payload = {
      'threadId': threadId,
      'message': message,
      'attachments': attachments
          .map((attachment) => attachment.toJson())
          .toList(),
    };

    Timer(const Duration(seconds: 15), () {
      if (!completer.isCompleted) {
        completer.completeError(Exception('Message send timed out.'));
      }
    });

    socket.emitWithAck(
      'chat:message:send',
      payload,
      ack: (data) {
        if (completer.isCompleted) return;

        final map = _toMap(data);
        if (map == null || map['success'] != true) {
          completer.completeError(
            Exception(
              _str(map?['message']).isEmpty
                  ? 'Failed to send message.'
                  : _str(map?['message']),
            ),
          );
          return;
        }

        final messageMap = _toMap(map['data']);
        if (messageMap == null) {
          completer.completeError(Exception('Invalid send message response.'));
          return;
        }

        completer.complete(ChatMessage.fromJson(messageMap));
      },
    );

    return completer.future;
  }

  /// Disconnect and clear state. Call on logout or when pausing app if desired.
  void disconnect() {
    _joinedThreadIds.clear();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _lastToken = null;
    _setState(SocketConnectionState.disconnected);
  }

  /// Reconnect using the last token (e.g. on app resume). No-op if never connected or no token.
  void reconnect() {
    final token = _lastToken?.trim();
    if (token != null && token.isNotEmpty && !isConnected) {
      connect(token);
    }
  }

  /// Call when app is paused (optional). Disconnects to save resources.
  void disconnectOnPause() {
    _socket?.disconnect();
    _setState(SocketConnectionState.disconnected);
  }

  /// Call when app is resumed (optional). Reconnects with last token and re-joins threads.
  void reconnectOnResume() {
    reconnect();
  }

  void dispose() {
    disconnect();
    _stateController.close();
    _newMessageController.close();
    _threadUpdatedController.close();
    _threadReadController.close();
  }
}

/// Event payload for chat:thread:read.
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
