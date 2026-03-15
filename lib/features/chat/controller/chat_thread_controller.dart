import 'dart:async';
import 'package:disabilitymne/core/auth/access_token_holder.dart';
import 'package:disabilitymne/features/chat/model/chat_models.dart';
import 'package:disabilitymne/features/chat/repository/chat_repository.dart';
import 'package:disabilitymne/features/chat/service/chat_socket_service.dart';
import 'package:get/get.dart';

/// Controller for a single chat thread: loads messages, sends via API,
/// keeps message list updated from socket chat:message:new, joins/leaves thread.
class ChatThreadController extends GetxController {
  ChatThreadController({
    required this.threadId,
    required this.counterpartName,
    required ChatRepository repo,
    required ChatSocketService socketService,
    AccessTokenHolder? tokenHolder,
  })  : _repo = repo,
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

  StreamSubscription<ChatMessage>? _newMessageSub;

  @override
  void onInit() {
    super.onInit();
    _connectSocketAndJoin();
    _newMessageSub = _socketService.onNewMessage.listen(_onNewMessage);
    loadMessages();
    markAsRead();
  }

  @override
  void onClose() {
    _socketService.leaveThread(threadId);
    _newMessageSub?.cancel();
    super.onClose();
  }

  void _connectSocketAndJoin() {
    final token = _tokenHolder?.token?.trim();
    if (token != null && token.isNotEmpty) {
      if (!_socketService.isConnected) {
        _socketService.connect(token);
      }
      _socketService.joinThread(threadId);
    }
  }

  void _onNewMessage(ChatMessage msg) {
    if (msg.threadId != threadId) return;
    if (messages.any((m) => m.id == msg.id)) return;
    messages.add(msg);
  }

  Future<void> loadMessages() async {
    isLoading.value = true;
    errorMessage.value = null;
    final result = await _repo.getThreadMessages(threadId: threadId);
    result.fold(
      (f) => errorMessage.value = f.uiMessage,
      (res) => messages.value = List<ChatMessage>.from(res.messages),
    );
    isLoading.value = false;
  }

  Future<void> markAsRead() async {
    await _repo.markThreadAsRead(threadId);
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    isSending.value = true;
    errorMessage.value = null;
    final result = await _repo.sendMessage(threadId: threadId, text: trimmed);
    result.fold(
      (f) => errorMessage.value = f.uiMessage,
      (msg) {
        if (!messages.any((m) => m.id == msg.id)) {
          messages.add(msg);
        }
      },
    );
    isSending.value = false;
  }
}
