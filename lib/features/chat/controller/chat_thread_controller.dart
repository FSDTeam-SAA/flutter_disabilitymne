import 'dart:async';
import 'dart:io';

import 'package:disabilitymne/core/auth/access_token_holder.dart';
import 'package:disabilitymne/features/chat/model/chat_models.dart';
import 'package:disabilitymne/features/chat/repository/chat_repository.dart';
import 'package:disabilitymne/features/chat/service/chat_socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

/// Controller for a single chat thread: loads messages, sends via Socket.IO,
/// keeps message list updated from socket chat:message:new, joins/leaves thread,
/// and reflects socket connection state.
///
/// Socket emit flow (backend chatSocket.js):
/// - chat:join-thread(threadId) → done in onInit via _socketService.joinThread(threadId)
/// - chat:leave-thread(threadId) → done in onClose via _socketService.leaveThread(threadId)
/// To emit any other event: _socketService.emit('event-name', data);
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

  /// Live stream of messages for StreamBuilder. Emits when messages load or socket sends new message.
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
    connectSocketAndJoin();
    _newMessageSub = _socketService.onNewMessage.listen(_onNewMessage);
    _stateSub = _socketService.onConnectionState.listen(_onConnectionState);
    socketConnected.value = _socketService.isConnected;
    loadMessages();
    markAsRead();
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

  void connectSocketAndJoin() {
    try {
      final token = _tokenHolder?.token?.trim();
      if (token == null || token.isEmpty) {
        debugPrint('Socket Connect Problem : missing access token');
        return;
      }

      if (!_socketService.isConnected) {
        _socketService.connect(token);
      }

      _socketService.joinThread(threadId);
    } catch (e) {
      debugPrint("Socket Connect Problem : $e");
    }
  }

  // 0..................................

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

  /// Mark this thread as read (REST + optional socket chat:thread:read is emitted by backend).
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
      if (!_socketService.isConnected) {
        connectSocketAndJoin();
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }

      final msg = await _socketService.sendMessage(
        threadId: threadId,
        message: trimmed,
        attachments: attachments,
      );

      if (!messages.any((m) => m.id == msg.id)) {
        messages.add(msg);
        _emitMessages();
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isSending.value = false;
    }
  }
}
