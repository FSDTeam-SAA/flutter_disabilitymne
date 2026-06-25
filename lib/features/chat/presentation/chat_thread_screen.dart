import 'dart:io';

import 'package:app_pigeon/app_pigeon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:disabilitymne/app/app_manager.dart';
import 'package:disabilitymne/core/helpers/auth_role.dart';
import 'package:disabilitymne/features/chat/controller/chat_thread_controller.dart';
import 'package:disabilitymne/features/chat/model/chat_models.dart';
import 'package:disabilitymne/features/chat/repository/chat_repository.dart';
import 'package:disabilitymne/features/chat/service/chat_socket_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class ChatThreadScreen extends StatefulWidget {
  const ChatThreadScreen({
    super.key,
    required this.threadId,
    required this.counterpartName,
    this.counterpartImageUrl,
    this.locationLabel = 'Coach',
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
  final ImagePicker _picker = ImagePicker();
  final List<File> _pendingFiles = [];
  int _prevMessageCount = 0;

  static const Color _screenBg = Color(0xFFF5F7FB);
  static const Color _headerBg = Color(0xFF0B1A2A);
  static const Color _sentBubble = Color(0xFF2F80C1);
  static const Color _receivedBubble = Color(0xFFFFFFFF);
  static const Color _inputBg = Color(0xFFFFFFFF);
  static const Color _muted = Color(0xFF667085);

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

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 82);
    if (file == null) return;
    setState(() => _pendingFiles.add(File(file.path)));
  }

  Future<void> _pickVideo() async {
    final file = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 3),
    );
    if (file == null) return;
    setState(() => _pendingFiles.add(File(file.path)));
  }

  void _showAttachmentSheet() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0D5DD),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _AttachmentAction(
                      icon: Icons.photo_outlined,
                      label: 'Photo',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                    const SizedBox(width: 12),
                    _AttachmentAction(
                      icon: Icons.photo_camera_outlined,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    const SizedBox(width: 12),
                    _AttachmentAction(
                      icon: Icons.videocam_outlined,
                      label: 'Video',
                      onTap: () {
                        Navigator.pop(context);
                        _pickVideo();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _pendingFiles.isEmpty) return;

    final files = List<File>.from(_pendingFiles);
    await controller.sendMessage(text, files: files);

    if (controller.errorMessage.value == null) {
      _textController.clear();
      setState(_pendingFiles.clear);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  String? get _currentUserId {
    final authStatus = Get.find<AppManager>().currentAuthStatus;
    if (authStatus is Authenticated) return authStatus.auth.userId;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBg,
      appBar: AppBar(
        backgroundColor: _headerBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white24,
              backgroundImage: widget.counterpartImageUrl?.isNotEmpty == true
                  ? NetworkImage(widget.counterpartImageUrl!)
                  : null,
              child: widget.counterpartImageUrl?.isNotEmpty == true
                  ? null
                  : Text(
                      widget.counterpartName.isNotEmpty
                          ? widget.counterpartName[0].toUpperCase()
                          : 'C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.counterpartName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Obx(() {
                    final connected = controller.socketConnected.value;
                    return Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: connected
                                ? const Color(0xFF32D583)
                                : const Color(0xFFFDB022),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          connected ? 'Live chat' : 'Connecting',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  }),
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
                return const Center(child: CircularProgressIndicator());
              }

              return StreamBuilder<List<ChatMessage>>(
                stream: controller.messagesStream,
                initialData: controller.messages,
                builder: (context, snapshot) {
                  final list = snapshot.data ?? const <ChatMessage>[];
                  if (list.length > _prevMessageCount) {
                    _prevMessageCount = list.length;
                    _scrollToBottom();
                  } else {
                    _prevMessageCount = list.length;
                  }

                  if (list.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages yet',
                        style: TextStyle(color: _muted, fontSize: 15),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final message = list[index];
                      final isMine =
                          message.sender?.id.isNotEmpty == true &&
                          message.sender?.id == _currentUserId;
                      return _MessageBubble(message: message, isMine: isMine);
                    },
                  );
                },
              );
            }),
          ),
          Obx(() {
            final error = controller.errorMessage.value;
            if (error == null || error.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFB42318), fontSize: 12),
              ),
            );
          }),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: 10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE4E7EC))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_pendingFiles.isNotEmpty) _buildPendingFiles(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _roundIconButton(
                  onPressed: controller.isSending.value
                      ? null
                      : _showAttachmentSheet,
                  icon: Icons.add,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 46),
                    decoration: BoxDecoration(
                      color: _inputBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFD0D5DD)),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(
                        color: Color(0xFF101828),
                        fontSize: 15,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Message your coach',
                        hintStyle: TextStyle(color: _muted, fontSize: 15),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.newline,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => _roundIconButton(
                    onPressed: controller.isSending.value ? null : _send,
                    icon: controller.isSending.value
                        ? Icons.hourglass_top_rounded
                        : Icons.send_rounded,
                    filled: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingFiles() {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(bottom: 10),
        itemCount: _pendingFiles.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final file = _pendingFiles[index];
          final path = file.path.toLowerCase();
          final isVideo =
              path.endsWith('.mp4') ||
              path.endsWith('.mov') ||
              path.endsWith('.m4v') ||
              path.endsWith('.webm');

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 68,
                  height: 68,
                  color: const Color(0xFFE4E7EC),
                  child: isVideo
                      ? const Icon(
                          Icons.play_circle_fill_rounded,
                          color: _headerBg,
                          size: 30,
                        )
                      : Image.file(file, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                right: 3,
                top: 3,
                child: GestureDetector(
                  onTap: () => setState(() => _pendingFiles.removeAt(index)),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _roundIconButton({
    required VoidCallback? onPressed,
    required IconData icon,
    bool filled = false,
  }) {
    return Material(
      color: filled ? _sentBubble : const Color(0xFFF2F4F7),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(
            icon,
            color: filled ? Colors.white : const Color(0xFF344054),
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _AttachmentAction extends StatelessWidget {
  const _AttachmentAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFF175CD3), size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF101828),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.76,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: isMine
                    ? _ChatThreadScreenState._sentBubble
                    : _ChatThreadScreenState._receivedBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(17),
                  topRight: const Radius.circular(17),
                  bottomLeft: Radius.circular(isMine ? 17 : 5),
                  bottomRight: Radius.circular(isMine ? 5 : 17),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMine
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.attachments.isNotEmpty)
                    ...message.attachments.map(
                      (attachment) => Padding(
                        padding: EdgeInsets.only(
                          bottom: message.message.isNotEmpty ? 8 : 0,
                        ),
                        child: _AttachmentPreview(attachment: attachment),
                      ),
                    ),
                  if (message.message.isNotEmpty)
                    Text(
                      message.message,
                      style: TextStyle(
                        color: isMine ? Colors.white : const Color(0xFF101828),
                        fontSize: 15,
                        height: 1.35,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      color: isMine
                          ? Colors.white.withValues(alpha: 0.72)
                          : const Color(0xFF98A2B3),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime? value) {
    if (value == null) return '';
    final hour = value.hour > 12 ? value.hour - 12 : value.hour;
    final displayHour = hour == 0 ? 12 : hour;
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '$displayHour:$minute $suffix';
  }
}

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({required this.attachment});

  final ChatAttachment attachment;

  bool get _isImage {
    final type = attachment.mimetype?.toLowerCase() ?? '';
    final url = attachment.url.toLowerCase();
    return type.startsWith('image/') ||
        url.endsWith('.png') ||
        url.endsWith('.jpg') ||
        url.endsWith('.jpeg') ||
        url.endsWith('.webp') ||
        url.endsWith('.gif');
  }

  bool get _isVideo {
    final type = attachment.mimetype?.toLowerCase() ?? '';
    final url = attachment.url.toLowerCase();
    return type.startsWith('video/') ||
        url.endsWith('.mp4') ||
        url.endsWith('.mov') ||
        url.endsWith('.m4v') ||
        url.endsWith('.webm');
  }

  @override
  Widget build(BuildContext context) {
    if (_isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: attachment.url,
          width: 230,
          fit: BoxFit.cover,
          placeholder: (_, _) => Container(
            width: 230,
            height: 150,
            color: const Color(0xFFE4E7EC),
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (_, _, _) => const _FileAttachmentTile(),
        ),
      );
    }

    if (_isVideo) {
      return _VideoAttachment(url: attachment.url);
    }

    return const _FileAttachmentTile();
  }
}

class _VideoAttachment extends StatefulWidget {
  const _VideoAttachment({required this.url});

  final String url;

  @override
  State<_VideoAttachment> createState() => _VideoAttachmentState();
}

class _VideoAttachmentState extends State<_VideoAttachment> {
  late final VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 230,
        height: 150,
        color: Colors.black,
        child: !_ready
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    if (!_controller.value.isPlaying)
                      const Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _FileAttachmentTile extends StatelessWidget {
  const _FileAttachmentTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE4E7EC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.attach_file, color: Color(0xFF344054)),
          SizedBox(width: 8),
          Text('Attachment', style: TextStyle(color: Color(0xFF344054))),
        ],
      ),
    );
  }
}
