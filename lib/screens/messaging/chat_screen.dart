import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/configs.dart';
import 'package:streamit_laravel/screens/messaging/chat_attachments_helper.dart';
import 'package:streamit_laravel/screens/messaging/chat_controller.dart';
import 'package:streamit_laravel/screens/messaging/models/message_models.dart';
import 'package:streamit_laravel/utils/app_common.dart';
import 'package:streamit_laravel/generated/assets.dart';
import 'package:streamit_laravel/utils/colors.dart';

class ChatScreen extends StatelessWidget {
  final int conversationId;
  final MessageOtherUser otherUser;

  const ChatScreen({super.key, required this.conversationId, required this.otherUser});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatController(conversationId: conversationId, otherUser: otherUser));
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              appScreenBackgroundDark,
              Color(0xFF0a0a0f),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _GlassAppBar(controller: controller, otherUser: otherUser),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white54),
                    );
                  }
                  if (controller.error.value.isNotEmpty && controller.messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.error.value,
                            style: const TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          16.height,
                          TextButton.icon(
                            onPressed: () => controller.loadInitial(),
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            label: const Text('Retry', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  }
                  final displayList = controller.messages.reversed.toList();
                  return NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n is ScrollEndNotification &&
                          n.metrics.pixels >= n.metrics.maxScrollExtent - 80) {
                        controller.loadMore();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      itemCount: displayList.length + (controller.hasMore.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == displayList.length) {
                          return controller.loadingMore.value
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: SizedBox(
                                      height: 28,
                                      width: 28,
                                      child: CircularProgressIndicator(
                                        color: Colors.white38,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink();
                        }
                        final msg = displayList[index];
                        return _MessageBubble(
                          message: msg,
                          isMe: controller.isSentByMe(msg),
                        );
                      },
                    ),
                  );
                }),
              ),
              _GlassChatInput(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatController controller;
  final MessageOtherUser otherUser;

  const _GlassAppBar({required this.controller, required this.otherUser});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final avatarUrl = otherUser.fileUrl != null && otherUser.fileUrl!.trim().isNotEmpty
        ? resolveImageUrl(otherUser.fileUrl, pathPrefix: 'storage/avatars/')
        : '';
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                onPressed: () => Get.back(),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white12,
                backgroundImage: avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : const AssetImage(Assets.iconsIcDefaultUser) as ImageProvider,
                onBackgroundImageError: (_, __) {},
              ),
              12.width,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherUser.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Tap to call • Coming soon',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.call_rounded, color: Colors.white.withValues(alpha: 0.8), size: 24),
                onPressed: () => toast('Voice call – coming soon'),
                tooltip: 'Voice call',
              ),
              IconButton(
                icon: Icon(Icons.videocam_rounded, color: Colors.white.withValues(alpha: 0.8), size: 24),
                onPressed: () => toast('Video call – coming soon'),
                tooltip: 'Video call',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wraps child so tap opens [attachmentUrl] in browser/custom tab (video/audio/file).
class _TapToOpenAttachment extends StatelessWidget {
  final String? attachmentUrl;
  final Widget child;

  const _TapToOpenAttachment({this.attachmentUrl, required this.child});

  @override
  Widget build(BuildContext context) {
    final url = attachmentUrl?.trim();
    if (url == null || url.isEmpty) return child;
    return InkWell(
      onTap: () => launchUrlCustomURL(url),
      borderRadius: BorderRadius.circular(14),
      child: child,
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageItem message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final margin = isMe
        ? const EdgeInsets.only(left: 72, bottom: 8)
        : const EdgeInsets.only(right: 72, bottom: 8);

    Widget content;
    switch (message.type) {
      case 'image':
        final url = message.attachmentUrl != null && message.attachmentUrl!.trim().isNotEmpty
            ? (message.attachmentUrl!.startsWith('http')
                ? message.attachmentUrl!
                : resolveImageUrl(message.attachmentUrl))
            : null;
        content = Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (url != null)
              _TapToOpenAttachment(
                attachmentUrl: message.attachmentUrl,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    url,
                    width: 240,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : _buildPlaceholder(200, 240),
                    errorBuilder: (_, __, ___) => _buildPlaceholder(200, 240),
                  ),
                ),
              ),
            if (message.body != null && message.body!.trim().isNotEmpty) 8.height,
            if (message.body != null && message.body!.trim().isNotEmpty)
              Text(
                message.body!,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            _buildTime(message.createdAt),
          ],
        );
        break;
      case 'audio':
        content = _TapToOpenAttachment(
          attachmentUrl: message.attachmentUrl,
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.mic_rounded, color: Colors.white, size: 22),
                  ),
                  10.width,
                  Text(
                    message.body ?? 'Audio',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              _buildTime(message.createdAt),
            ],
          ),
        );
        break;
      case 'video':
      case 'file':
        content = _TapToOpenAttachment(
          attachmentUrl: message.attachmentUrl,
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      message.type == 'video' ? Icons.videocam_rounded : Icons.insert_drive_file_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  10.width,
                  Flexible(
                    child: Text(
                      message.body ?? (message.attachmentUrl ?? 'Attachment'),
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              _buildTime(message.createdAt),
            ],
          ),
        );
        break;
      default:
        content = Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.body ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            _buildTime(message.createdAt),
          ],
        );
    }

    return Align(
      alignment: alignment,
      child: Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? Colors.green.withValues(alpha: 0.35)
                    : Colors.white.withValues(alpha: 0.12),
                border: Border.all(
                  color: isMe
                      ? Colors.green.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(double h, double w) {
    return Container(
      width: w,
      height: h,
      color: Colors.white12,
      child: const Icon(Icons.image_rounded, color: Colors.white38, size: 48),
    );
  }

  Widget _buildTime(String createdAt) {
    String timeStr = '';
    try {
      final dt = DateTime.tryParse(createdAt);
      if (dt != null) {
        timeStr = DateFormat('HH:mm').format(dt);
      } else {
        timeStr = createdAt;
      }
    } catch (_) {
      timeStr = createdAt;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        timeStr,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 11,
        ),
      ),
    );
  }
}

class _GlassChatInput extends StatefulWidget {
  final ChatController controller;

  const _GlassChatInput({required this.controller});

  @override
  State<_GlassChatInput> createState() => _GlassChatInputState();
}

class _GlassChatInputState extends State<_GlassChatInput> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    widget.controller.sendText(text);
  }

  Future<void> _pickAndSendImage() async {
    final r = await pickImageFromGallery();
    if (r != null) {
      widget.controller.sendAttachment(
        type: r.type,
        fileBytes: r.fileBytes,
        fileName: r.fileName,
        body: r.body,
      );
    }
  }

  Future<void> _pickAndSendVideo() async {
    final r = await pickVideo();
    if (r != null) {
      widget.controller.sendAttachment(
        type: r.type,
        fileBytes: r.fileBytes,
        fileName: r.fileName,
        body: r.body,
      );
    }
  }

  Future<void> _pickAndSendDocument() async {
    final r = await pickDocumentOrAudio();
    if (r != null) {
      widget.controller.sendAttachment(
        type: r.type,
        fileBytes: r.fileBytes,
        fileName: r.fileName,
        body: r.body,
      );
    }
  }

  Widget _inputBarIcon(IconData icon, String tooltip, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 22),
          ),
        ),
      ),
    );
  }

  void _showAttachmentSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AttachmentSheet(
        onPickImage: () async {
          Navigator.pop(ctx);
          await _pickAndSendImage();
        },
        onTakePhoto: () async {
          Navigator.pop(ctx);
          final r = await pickImageFromCamera();
          if (r != null) {
            widget.controller.sendAttachment(
              type: r.type,
              fileBytes: r.fileBytes,
              fileName: r.fileName,
              body: r.body,
            );
          }
        },
        onPickVideo: () async {
          Navigator.pop(ctx);
          await _pickAndSendVideo();
        },
        onPickDocument: () async {
          Navigator.pop(ctx);
          await _pickAndSendDocument();
        },
        onSendLocation: () async {
          Navigator.pop(ctx);
          final text = await getLocationText();
          if (text != null && text.isNotEmpty) {
            widget.controller.sendText(text);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: EdgeInsets.only(left: 8, right: 8, top: 10, bottom: 10 + bottomPad),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showAttachmentSheet,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 28,
                    ),
                  ),
                ),
              ),
              _inputBarIcon(Icons.photo_library_rounded, 'Image', _pickAndSendImage),
              _inputBarIcon(Icons.videocam_rounded, 'Video', _pickAndSendVideo),
              _inputBarIcon(Icons.insert_drive_file_rounded, 'Document', _pickAndSendDocument),
              4.width,
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Message',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                        maxLines: 4,
                        minLines: 1,
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                  ),
                ),
              ),
              8.width,
              Obx(() {
                final sending = widget.controller.sending.value;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: sending ? null : _send,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: sending
                            ? Colors.grey.withValues(alpha: 0.3)
                            : appColorPrimary.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: sending
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.black87, size: 22),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentSheet extends StatelessWidget {
  final VoidCallback onPickImage;
  final VoidCallback onTakePhoto;
  final VoidCallback onPickVideo;
  final VoidCallback onPickDocument;
  final VoidCallback onSendLocation;

  const _AttachmentSheet({
    required this.onPickImage,
    required this.onTakePhoto,
    required this.onPickVideo,
    required this.onPickDocument,
    required this.onSendLocation,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 24,
            right: 24,
            bottom: 24 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade900.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              20.height,
              Text(
                'Send',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              16.height,
              Row(
                children: [
                  _AttachmentOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: onPickImage,
                  ),
                  16.width,
                  _AttachmentOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: onTakePhoto,
                  ),
                  16.width,
                  _AttachmentOption(
                    icon: Icons.videocam_rounded,
                    label: 'Video',
                    onTap: onPickVideo,
                  ),
                ],
              ),
              16.height,
              Row(
                children: [
                  _AttachmentOption(
                    icon: Icons.insert_drive_file_rounded,
                    label: 'Document',
                    onTap: onPickDocument,
                  ),
                  16.width,
                  _AttachmentOption(
                    icon: Icons.location_on_rounded,
                    label: 'Location',
                    onTap: onSendLocation,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              children: [
                Icon(icon, color: Colors.white, size: 28),
                8.height,
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
