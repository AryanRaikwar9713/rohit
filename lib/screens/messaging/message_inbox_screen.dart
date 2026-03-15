import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/configs.dart';
import 'package:streamit_laravel/screens/messaging/models/message_models.dart';
import 'package:streamit_laravel/generated/assets.dart';
import 'package:streamit_laravel/screens/messaging/message_inbox_controller.dart';
import 'package:streamit_laravel/screens/messaging/chat_screen.dart';
import 'package:streamit_laravel/utils/colors.dart';

class MessageInboxScreen extends StatelessWidget {
  const MessageInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<MessageInboxController>()
        ? Get.find<MessageInboxController>()
        : Get.put(MessageInboxController());
    return Scaffold(
      backgroundColor: appScreenBackgroundDark,
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        backgroundColor: appScreenBackgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          // Lightweight skeleton list so UI feels instant even if network is slow
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                  12.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 14,
                          width: Get.width * 0.35,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        8.height,
                        Container(
                          height: 12,
                          width: Get.width * 0.55,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        }
        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.error.value, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                16.height,
                ElevatedButton(onPressed: () => controller.loadConversations(), child: const Text('Retry')),
              ],
            ),
          );
        }
        if (controller.conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.white.withOpacity(0.5)),
                16.height,
                Text('No conversations yet', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 18)),
                8.height,
                const Text('Start a chat from a user profile', style: TextStyle(color: Colors.white54, fontSize: 14)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.loadConversations,
          color: Colors.white,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.conversations.length,
            itemBuilder: (context, index) {
              final c = controller.conversations[index];
              return _ConversationTile(
                conversation: c,
                onTap: () {
                  Get.to(() => ChatScreen(
                    conversationId: c.conversationId,
                    otherUser: c.otherUser,
                  ),)?.then((_) => controller.loadConversations());
                },
              );
            },
          ),
        );
      }),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final MessageConversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final other = conversation.otherUser;
    final last = conversation.lastMessage;
    final avatarUrl = other.fileUrl != null && other.fileUrl!.trim().isNotEmpty
        ? resolveImageUrl(other.fileUrl, pathPrefix: 'storage/avatars/')
        : '';
    String subtitle = 'No messages yet';
    if (last != null) {
      if (last.type == 'image') {
        subtitle = '📷 Photo';
      } else if (last.type == 'audio') subtitle = '🎤 Audio';
      else if (last.type == 'video') subtitle = '🎬 Video';
      else if (last.type == 'file') subtitle = '📎 File';
      else subtitle = last.body ?? '';
    }
    DateTime? updated;
    try {
      if (conversation.updatedAt.isNotEmpty) {
        updated = DateTime.tryParse(conversation.updatedAt);
      }
    } catch (_) {}
    final timeText = updated != null ? DateFormat.Hm().format(updated.toLocal()) : '';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade800,
              backgroundImage: avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : const AssetImage(Assets.iconsIcDefaultUser) as ImageProvider,
              onBackgroundImageError: (_, __) {},
            ),
            12.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          other.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (timeText.isNotEmpty)
                        Text(
                          timeText,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                  4.height,
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${conversation.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
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
    );
  }
}
