import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/network/auth_apis.dart';
import 'package:streamit_laravel/screens/auth/model/notification_model.dart';
import 'package:streamit_laravel/screens/donation/donation_screen.dart';
import 'package:streamit_laravel/screens/messaging/chat_screen.dart';
import 'package:streamit_laravel/screens/messaging/message_inbox_screen.dart';
import 'package:streamit_laravel/screens/messaging/models/message_models.dart';
import 'package:streamit_laravel/screens/social/social_screen.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_screen.dart';
import 'package:streamit_laravel/utils/app_common.dart';
import 'package:streamit_laravel/utils/colors.dart';

class WamimsNotificationScreen extends StatelessWidget {
  const WamimsNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<WamimsNotificationController>()
        ? Get.find<WamimsNotificationController>()
        : Get.put(WamimsNotificationController());
    return Scaffold(
      backgroundColor: appScreenBackgroundDark,
      appBar: AppBar(
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: appScreenBackgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (controller.notificationDetail.isNotEmpty)
            TextButton(
              onPressed: () => controller.clearAll(context: context),
              child: const Text(
                'Clear all',
                style: TextStyle(color: appColorPrimary, fontSize: 14),
              ),
            ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notificationDetail.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white54),
          );
        }
        if (controller.error.value.isNotEmpty) {
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
                TextButton(
                  onPressed: () => controller.init(),
                  child: const Text('Retry', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }
        if (controller.notificationDetail.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none_rounded,
                    size: 64, color: Colors.white.withOpacity(0.4),),
                16.height,
                Text(
                  'No notifications yet',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                  ),
                ),
                8.height,
                Text(
                  'You’ll see message, like and comment updates here',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => controller.init(),
          color: Colors.white,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: controller.notificationDetail.length,
            itemBuilder: (context, index) {
              final n = controller.notificationDetail[index];
              final detail = n.data.notificationDetail;
              final isMessage = n.type.toLowerCase().contains('message');
              final title = isMessage
                  ? (detail.userName.isNotEmpty
                      ? '${detail.userName} sent you a message'
                      : (n.data.subject.isNotEmpty ? n.data.subject : 'New message'))
                  : (n.data.subject.isNotEmpty
                      ? n.data.subject
                      : (detail.type.isNotEmpty ? detail.type : 'Notification'));
              final subtitle = detail.bookingServicesNames.isNotEmpty
                  ? detail.bookingServicesNames
                  : (detail.userName.isNotEmpty && !isMessage ? detail.userName : '');
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () => _onNotificationTap(n, detail),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white12,
                    child: Icon(
                      _iconForType(n.type),
                      color: Colors.white70,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: subtitle.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                    onPressed: () => controller.remove(context: context, id: n.id),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  static IconData _iconForType(String type) {
    if (type.toLowerCase().contains('message')) return Icons.chat_bubble_outline;
    if (type.toLowerCase().contains('like')) return Icons.favorite_border;
    if (type.toLowerCase().contains('comment')) return Icons.comment_outlined;
    return Icons.notifications_none_rounded;
  }

  static void _onNotificationTap(NotificationData n, NotificationDetail detail) {
    final type = n.type.toLowerCase();
    if (type.contains('message')) {
      final cId = int.tryParse(detail.conversationId ?? '');
      if (cId != null && cId > 0 && detail.userId > 0) {
        final otherUser = MessageOtherUser(
          id: detail.userId,
          username: detail.userName.isNotEmpty ? detail.userName : null,
        );
        Get.to(() => ChatScreen(conversationId: cId, otherUser: otherUser));
      } else {
        Get.to(() => const MessageInboxScreen());
      }
      return;
    }
    if (type.contains('follow') && detail.userId > 0) {
      openVammisProfile(userId: detail.userId, isOwnProfile: detail.userId == loginUserData.value.id);
      return;
    }
    if (type.contains('impact')) {
      Get.to(() => const ImpactDashboardScreen());
      return;
    }
    if (type.contains('admin_broadcast')) {
      return;
    }
    Get.to(() => const SocialScreen());
  }
}

class WamimsNotificationController extends GetxController {
  final RxList<NotificationData> notificationDetail = <NotificationData>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxInt page = 1.obs;
  final RxBool isLastPage = false.obs;
  /// Real unread count from API; 0 = no new notifications
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<void> init() async {
    if (!isLoggedIn.value) {
      error.value = 'Please log in to see notifications';
      isLoading.value = false;
      unreadCount.value = 0;
      return;
    }
    isLoading.value = true;
    error.value = '';
    page.value = 1;
    notificationDetail.clear();
    try {
      await AuthServiceApis().markAllNotificationsAsRead();
      unreadCount.value = 0;
      await AuthServiceApis().getNotificationDetail(
        page: page.value,
        perPage: 20,
        notifications: notificationDetail,
        lastPageCallBack: (last) => isLastPage.value = last,
        unreadCountCallBack: (c) => unreadCount.value = c,
      );
      notificationDetail.refresh();
    } catch (e) {
      error.value = e.toString();
    }
    isLoading.value = false;
  }

  /// Lightweight refresh of unread count (for badge). Call when entering Social/Home.
  Future<void> refreshUnreadCount() async {
    if (!isLoggedIn.value) {
      unreadCount.value = 0;
      return;
    }
    try {
      final temp = <NotificationData>[];
      await AuthServiceApis().getNotificationDetail(
        page: 1,
        perPage: 1,
        notifications: temp,
        unreadCountCallBack: (c) => unreadCount.value = c,
      );
    } catch (_) {}
  }

  Future<void> remove({required BuildContext context, required String id}) async {
    try {
      await AuthServiceApis().removeNotification(notificationId: id);
      final removed = notificationDetail.firstWhereOrNull((n) => n.id == id);
      notificationDetail.removeWhere((n) => n.id == id);
      if (removed?.readAt == null && unreadCount.value > 0) {
        unreadCount.value = (unreadCount.value - 1).clamp(0, 999999);
      }
      toast('Notification removed');
    } catch (e) {
      toast(e.toString());
    }
  }

  Future<void> clearAll({required BuildContext context}) async {
    try {
      await AuthServiceApis().clearAllNotification();
    } catch (_) {
      // Backend may not have api/notification-deleteall; clear locally anyway
    }
    notificationDetail.clear();
    unreadCount.value = 0;
    toast('All notifications cleared');
  }
}
