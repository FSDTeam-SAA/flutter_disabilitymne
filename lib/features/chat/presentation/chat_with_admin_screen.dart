import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Chat with Admin screen matching the design:
/// Dark blue background, app bar with avatar + Admin + LOCATION,
/// incoming (white) / outgoing (light blue) bubbles, input bar with + and send.
class ChatWithAdminScreen extends StatefulWidget {
  const ChatWithAdminScreen({super.key});

  @override
  State<ChatWithAdminScreen> createState() => _ChatWithAdminScreenState();
}

class _ChatWithAdminScreenState extends State<ChatWithAdminScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(text: 'HI', isFromAdmin: true),
    ChatMessage(text: 'HI', isFromAdmin: true),
    ChatMessage(text: 'Hello', isFromAdmin: false),
    ChatMessage(text: 'Hello', isFromAdmin: false),
    ChatMessage(text: 'HI', isFromAdmin: true),
    ChatMessage(text: 'Hello', isFromAdmin: false),
    ChatMessage(text: 'Hello', isFromAdmin: false),
  ];

  static const Color _scaffoldBg = Color(0xFF1A2430);
  static const Color _incomingBubbleBg = Color(0xFFFFFFFF);
  static const Color _outgoingBubbleBg = Color(0xFF5B9BD5);
  static const Color _inputBarBg = Color(0xFF2D3644);
  static const Color _inputFieldBg = Color(0xFF3D4554);
  static const Color _avatarGray = Color(0xFF6B7280);
  static const Color _sendButtonBg = Color(0xFF4A5568);

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isFromAdmin: false));
      _messageController.clear();
    });
    Future.microtask(() {
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
      backgroundColor: _scaffoldBg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _scaffoldBg,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Get.back(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: _avatarGray,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.location_on, size: 12, color: Colors.white.withOpacity(0.7)),
                  const SizedBox(width: 4),
                  Text(
                    'LOCATION',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final showAvatar = msg.isFromAdmin &&
            (index == 0 || _messages[index - 1].isFromAdmin == false);
        return _MessageBubble(
          message: msg,
          showAvatar: showAvatar,
          incomingBubbleBg: _incomingBubbleBg,
          outgoingBubbleBg: _outgoingBubbleBg,
          avatarColor: _avatarGray,
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + MediaQuery.of(context).padding.bottom),
      color: _inputBarBg,
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Material(
              color: _sendButtonBg,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 44, maxHeight: 120),
                decoration: BoxDecoration(
                  color: _inputFieldBg,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter your message',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: _sendButtonBg,
              borderRadius: BorderRadius.circular(22),
              child: InkWell(
                onTap: _sendMessage,
                borderRadius: BorderRadius.circular(22),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.send, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isFromAdmin;

  ChatMessage({required this.text, required this.isFromAdmin});
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;
  final Color incomingBubbleBg;
  final Color outgoingBubbleBg;
  final Color avatarColor;

  const _MessageBubble({
    required this.message,
    required this.showAvatar,
    required this.incomingBubbleBg,
    required this.outgoingBubbleBg,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isFromAdmin) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (showAvatar)
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 36),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: incomingBubbleBg,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.zero,
                    topRight: const Radius.circular(18),
                    bottomLeft: const Radius.circular(18),
                    bottomRight: const Radius.circular(18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(
                    color: Color(0xFF25272D),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: outgoingBubbleBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.zero,
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
