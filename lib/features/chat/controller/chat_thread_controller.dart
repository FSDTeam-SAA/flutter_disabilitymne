import 'dart:async';
import 'dart:io';

import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/auth/access_token_holder.dart';
import 'package:disabilitymne/features/chat/model/chat_models.dart';
import 'package:disabilitymne/features/chat/repository/chat_repository.dart';
import 'package:disabilitymne/features/chat/service/chat_socket_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Controller for a single chat thread: loads messages, sends via Socket.IO
/// (with REST fallback), keeps message list updated from socket events,
/// joins/leaves thread, and reflects socket connection state.
class ChatThreadController extends GetxController {
  ChatThreadController({
    required this.threadId,
    required this.counterpartName,
    required ChatRepository repo,
    required ChatSocketService socketService,
    AccessTokenHolder? tokenHolder,
  }) : _repo = repo,
       _socketService = socketService,
       _tokenHolder = tokenHolder {
    _tokenHolder ??= Get.isRegistered<AccessTokenHolder>()
        ? Get.find<AccessTokenHolder>()
        : null;
  }

  final String threadId;
  final String counterpartName;
  final ChatRepository _repo;
  final ChatSocketService _socketService;
  AccessTokenHolder? _tokenHolder;

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;
  final RxnString errorMessage = RxnString();
  final RxBool socketConnected = false.obs;

  final StreamController<List<ChatMessage>> _messagesStreamController =
      StreamController<List<ChatMessage>>.broadcast();

  /// Live stream of messages for StreamBuilder.
  Stream<List<ChatMessage>> get messagesStream =>
      _messagesStreamController.stream;

  StreamSubscription<ChatMessage>? _newMessageSub;
  StreamSubscription<SocketConnectionState>? _stateSub;

  void _emitMessages() {
    if (!_messagesStreamController.isClosed) {
      _messagesStreamController.add(List<ChatMessage>.from(messages));
    }
  }

  @override
  void onInit() {
    super.onInit();
    _messagesStreamController.add([]);
    _newMessageSub = _socketService.onNewMessage.listen(_onNewMessage);
    _stateSub = _socketService.onConnectionState.listen(_onConnectionState);
    socketConnected.value = _socketService.isConnected;
    // Fire-and-forget: load history while we connect the live socket.
    unawaited(connectSocketAndJoin());
    unawaited(loadMessages());
    unawaited(markAsRead());
  }

  @override
  void onClose() {
    _socketService.leaveThread(threadId);
    _newMessageSub?.cancel();
    _stateSub?.cancel();
    _messagesStreamController.close();
    super.onClose();
  }

  void _onConnectionState(SocketConnectionState state) {
    socketConnected.value = state == SocketConnectionState.connected;
  }

  /// Resolve JWT from in-memory holder, or fall back to persisted auth record.
  Future<String?> _resolveAccessToken() async {
    final cached = _tokenHolder?.token?.trim();
    if (cached != null && cached.isNotEmpty) return cached;

    if (!Get.isRegistered<AuthorizedPigeon>()) return null;
    try {
      final auth = await Get.find<AuthorizedPigeon>().getCurrentAuthRecord();
      final token = auth?.toJson()['access_token'] as String?;
      final trimmed = token?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        _tokenHolder?.setToken(trimmed);
        return trimmed;
      }
    } catch (e) {
      debugPrint('ChatThreadController: resolve token error: $e');
    }
    return null;
  }

  Future<bool> connectSocketAndJoin() async {
    try {
      final token = await _resolveAccessToken();
      if (token == null || token.isEmpty) {
        debugPrint('Socket Connect Problem : missing access token');
        socketConnected.value = false;
        return false;
      }

      final connected = await _socketService.ensureConnected(token);
      socketConnected.value = connected;
      if (connected) {
        _socketService.joinThread(threadId);
      }
      return connected;
    } catch (e) {
      debugPrint('Socket Connect Problem : $e');
      socketConnected.value = false;
      return false;
    }
  }

  void _onNewMessage(ChatMessage msg) {
    final msgThreadId = msg.threadId?.trim() ?? '';
    if (msgThreadId.isNotEmpty && msgThreadId != threadId.trim()) return;
    if (msg.id.isEmpty) return;
    if (messages.any((m) => m.id == msg.id)) return;
    messages.add(msg);
    _emitMessages();
  }

  Future<void> loadMessages() async {
    isLoading.value = true;
    errorMessage.value = null;
    final result = await _repo.getThreadMessages(threadId: threadId);
    result.fold((f) => errorMessage.value = f.uiMessage, (res) {
      messages.value = List<ChatMessage>.from(res.messages);
      _emitMessages();
    });
    isLoading.value = false;
  }

  Future<void> markAsRead() async {
    await _repo.markThreadAsRead(threadId);
  }

  Future<void> sendMessage(String text, {List<File> files = const []}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty && files.isEmpty) return;
    isSending.value = true;
    errorMessage.value = null;

    final attachments = <ChatAttachment>[];
    for (final file in files) {
      final lowerPath = file.path.toLowerCase();
      final isVideo =
          lowerPath.endsWith('.mp4') ||
          lowerPath.endsWith('.mov') ||
          lowerPath.endsWith('.m4v') ||
          lowerPath.endsWith('.webm');

      final uploadResult = await _repo.uploadAttachment(file, isVideo: isVideo);
      final failed = uploadResult.fold(
        (f) {
          errorMessage.value = f.uiMessage;
          return true;
        },
        (attachment) {
          attachments.add(attachment);
          return false;
        },
      );

      if (failed) {
        isSending.value = false;
        return;
      }
    }

    try {
      final connected = await connectSocketAndJoin();

      if (connected) {
        final msg = await _socketService.sendMessage(
          threadId: threadId,
          message: trimmed,
          attachments: attachments,
        );
        if (!messages.any((m) => m.id == msg.id)) {
          messages.add(msg);
          _emitMessages();
        }
      } else {
        // REST fallback so chat still works when live socket is down.
        final result = await _repo.sendMessage(
          threadId: threadId,
          text: trimmed,
          attachments: attachments,
        );
        result.fold(
          (f) => errorMessage.value = f.uiMessage,
          (msg) {
            if (!messages.any((m) => m.id == msg.id)) {
              messages.add(msg);
              _emitMessages();
            }
          },
        );
      }
    } catch (e) {
      // Last resort: try REST if socket send threw.
      final result = await _repo.sendMessage(
        threadId: threadId,
        text: trimmed,
        attachments: attachments,
      );
      result.fold(
        (f) => errorMessage.value = f.uiMessage.isNotEmpty
            ? f.uiMessage
            : e.toString().replaceFirst('Exception: ', ''),
        (msg) {
          errorMessage.value = null;
          if (!messages.any((m) => m.id == msg.id)) {
            messages.add(msg);
            _emitMessages();
          }
        },
      );
    } finally {
      isSending.value = false;
    }
  }
}
