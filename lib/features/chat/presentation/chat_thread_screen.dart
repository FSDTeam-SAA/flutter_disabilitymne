import 'package:disabilitymne/features/chat/controller/chat_thread_controller.dart';
import 'package:disabilitymne/features/chat/model/chat_models.dart';
import 'package:disabilitymne/features/chat/repository/chat_repository.dart';
import 'package:disabilitymne/features/chat/service/chat_socket_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Real-time chat thread screen. Connect with token, join thread on open,
/// listen for chat:message:new, send via API and receive socket updates.
/// Leave thread on close.
class ChatThreadScreen extends StatefulWidget {
  const ChatThreadScreen({
    super.key,
    required this.threadId,
    required this.counterpartName,
    this.counterpartImageUrl,
    this.locationLabel = 'LOCATION',
  });

  final String threadId;
  final String counterpartName;
  final String? counterpartImageUrl;
  final String locationLabel;

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  late final ChatThreadController controller;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const Color _screenBg = Color(0xFF0B1A2A);
  static const Color _receivedDot = Color(0xFF696D73);
  static const Color _inputBg = Color(0xFF2A3645);
  static const Color _hintColor = Color(0xFFA0A8B7);
  static const Color _attachButtonBg = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      ChatThreadController(
        threadId: widget.threadId,
        counterpartName: widget.counterpartName,
        repo: Get.find<ChatRepository>(),
        socketService: Get.find<ChatSocketService>(),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    controller.sendMessage(text);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBg,
      appBar: AppBar(
        backgroundColor: _screenBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: _receivedDot,
              backgroundImage: widget.counterpartImageUrl != null
                  ? NetworkImage(widget.counterpartImageUrl!)
                  : null,
              child: widget.counterpartImageUrl == null
                  ? null
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.counterpartName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14, color: Colors.white.withValues(alpha: 0.8)),
                      const SizedBox(width: 4),
                      Text(
                        widget.locationLabel,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              if (controller.errorMessage.value != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      controller.errorMessage.value!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              }
              final list = controller.messages;
              if (list.isEmpty) {
                return const Center(
                  child: Text(
                    'No messages yet. Say hello!',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                );
              }
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return _MessageBubble(message: list[index]);
                },
              );
            }),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: _screenBg,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _circleButton(
              onPressed: () {
                // TODO: attachments
              },
              child: const Icon(Icons.add, color: Colors.black87, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                decoration: BoxDecoration(
                  color: _inputBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter your message',
                    hintStyle: const TextStyle(color: _hintColor, fontSize: 16),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  maxLines: 4,
                  minLines: 1,
                  onSubmitted: (_) => _send(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Obx(() => _circleButton(
                  onPressed: controller.isSending.value ? null : _send,
                  child: Icon(
                    Icons.send_rounded,
                    color: controller.isSending.value
                        ? Colors.grey
                        : Colors.black87,
                    size: 22,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _circleButton({
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    return Material(
      color: _attachButtonBg,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  static const Color _sentBubble = Color(0xFF4B7FA8);
  static const Color _receivedBubble = Color(0xFFFFFFFF);
  static const Color _receivedDot = Color(0xFF696D73);
  static const Color _sentText = Color(0xFFFFFFFF);
  static const Color _receivedText = Color(0xFF1C2533);

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: _receivedDot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMine ? _sentBubble : _receivedBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMine ? 16 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 16),
                ),
              ),
              child: Text(
                message.message,
                style: TextStyle(
                  color: isMine ? _sentText : _receivedText,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (isMine) const SizedBox(width: 14),
        ],
      ),
    );
  }
}
