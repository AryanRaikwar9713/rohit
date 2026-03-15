import 'dart:convert';
import 'dart:io' if (dart.library.io) 'platform_stub.dart' as io;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/main.dart';
import 'package:streamit_laravel/screens/donation/donation_screen.dart';
import 'package:streamit_laravel/screens/donation/project_detail_screen.dart';
import 'package:streamit_laravel/screens/messaging/chat_screen.dart';
import 'package:streamit_laravel/screens/messaging/message_inbox_screen.dart';
import 'package:streamit_laravel/screens/messaging/models/message_models.dart';
import 'package:streamit_laravel/screens/notificationSection/notification_screen.dart';
import 'package:streamit_laravel/screens/social/social_screen.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_screen.dart';
import 'package:streamit_laravel/utils/app_common.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common_base.dart';
import 'constants.dart';

class PushNotificationService {
  Future<void> initFirebaseMessaging() async {
    try {
      final NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        await initializePlatformSpecificNotificationChannel();

        registerNotificationListeners();

        FirebaseMessaging.onBackgroundMessage(
            firebaseMessagingBackgroundHandler,);

        FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true,);

        // Subscribe to topic with error handling to prevent app from hanging
        try {
          await FirebaseMessaging.instance
              .subscribeToTopic(appNameTopic)
              .then((value) {
            log("${FirebaseMsgConst.topicSubscribed}$appNameTopic");
          }).catchError((error) {
            log("Failed to subscribe to topic $appNameTopic: $error");
            // Don't throw error, let app continue
          });
        } catch (e) {
          log("Error subscribing to topic $appNameTopic: $e");
          // Continue app initialization even if topic subscription fails
        }
      }
    } catch (e) {
      log("Firebase Messaging initialization error: $e");
      // Don't rethrow - allow app to continue even if Firebase Messaging fails
    }
  }

  Future<void> initializePlatformSpecificNotificationChannel() async {
    // Notification channel setup for Android
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Heads-up / popup like WhatsApp: max importance + sound + vibration
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      FirebaseMsgConst.notificationChannelIdKey,
      FirebaseMsgConst.notificationChannelNameKey,
      description: 'WAMIMS notifications',
      importance: Importance.max,
      enableLights: true,
      enableVibration: true,
      playSound: true,
      showBadge: true,
    );

    // Create notification channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Initialize FlutterLocalNotificationsPlugin - handle tap for deep link
    await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android:
            AndroidInitializationSettings('@drawable/ic_stat_ic_notification'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          PushNotificationService._handleNotificationPayload(response.payload!);
        }
      },
    );
  }

  static void _handleNotificationPayload(String payload) {
    try {
      final Map<String, dynamic> data = jsonDecode(payload) as Map<String, dynamic>;
      final type = data[FirebaseMsgConst.notificationTypeKey]?.toString();
      final conversationId = data[FirebaseMsgConst.conversationIdKey]?.toString();
      final senderIdRaw = data[FirebaseMsgConst.senderUserIdKey];
      final senderName = data[FirebaseMsgConst.senderNameKey]?.toString() ?? '';
      final postId = data[FirebaseMsgConst.postIdKey]?.toString();
      if (type != null && type.isNotEmpty) {
        if (type == 'message' && conversationId != null && conversationId.isNotEmpty) {
          final cId = int.tryParse(conversationId);
          final senderId = senderIdRaw is int ? senderIdRaw : int.tryParse(senderIdRaw?.toString() ?? '');
          if (cId != null && cId > 0 && senderId != null && senderId > 0) {
            final otherUser = MessageOtherUser(id: senderId, username: senderName.isNotEmpty ? senderName : null);
            Get.to(() => ChatScreen(conversationId: cId, otherUser: otherUser));
          } else {
            Get.to(() => const MessageInboxScreen());
          }
          return;
        }
        if (type == 'follow') {
          final userIdRaw = data[FirebaseMsgConst.userIdKey];
          final userId = userIdRaw is int ? userIdRaw : int.tryParse(userIdRaw?.toString() ?? '');
          if (userId != null && userId > 0) {
            openVammisProfile(userId: userId, isOwnProfile: userId == loginUserData.value.id);
          } else {
            Get.to(() => const SocialScreen());
          }
          return;
        }
        if (type == 'admin_broadcast') {
          Get.to(() => const WamimsNotificationScreen());
          return;
        }
        if (type == 'like' || type == 'comment' || type == 'share' ||
            type == 'reel_like' || type == 'reel_comment' || type == 'reel_upload' ||
            type == 'post_upload' || type == 'story_upload') {
          Get.to(() => const SocialScreen());
          return;
        }
        if (type == 'long_upload' || type == 'long_like' || type == 'long_comment') {
          Get.to(() => const SocialScreen());
          return;
        }
        if (type == 'impact_project' || type == 'impact_donated' || type == 'impact_viewed') {
          final projectIdRaw = data[FirebaseMsgConst.projectIdKey];
          final projectId = projectIdRaw is int ? projectIdRaw : int.tryParse(projectIdRaw?.toString() ?? '');
          if (projectId != null && projectId > 0) {
            Get.to(() => ProjectDetailScreen(id: projectId));
          } else {
            Get.to(() => const ImpactDashboardScreen());
          }
          return;
        }
      }
      if (data['url'] != null && data['url'] is String) {
        commonLaunchUrl(data['url'] as String, launchMode: LaunchMode.externalApplication);
      }
    } catch (e) {
      log('_handleNotificationPayload error: $e');
    }
  }

  void _refreshInAppNotificationList() {
    try {
      if (Get.isRegistered<WamimsNotificationController>()) {
        Get.find<WamimsNotificationController>().init();
      } else {
        Get.put(WamimsNotificationController(), permanent: true).init();
      }
    } catch (_) {}
  }

  Future<void> registerFCMAndTopics() async {
    try {
      if (io.Platform.isIOS) {
        try {
          String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken == null) {
            Future.delayed(const Duration(seconds: 3), () async {
              try {
                apnsToken = await FirebaseMessaging.instance.getAPNSToken();
              } catch (e) {
                log("Error getting APNS token: $e");
              }
            });
          }
          log("${FirebaseMsgConst.apnsNotificationTokenKey}\n$apnsToken");
        } catch (e) {
          log("Error getting APNS token: $e");
        }
      }
      FirebaseMessaging.instance.getToken().then((token) {
        log("${FirebaseMsgConst.fcmNotificationTokenKey}\n$token");
        // Terminal m clearly dikhne ke liye – copy karke Firebase "Test on device" m paste karo
        print('🔑 FCM TOKEN (copy for Firebase Test on device):\n$token');
        subScribeToTopic();
      }).catchError((error) {
        log("Error getting FCM token: $error");
        // Don't throw error, let app continue
      });
    } catch (e) {
      log("Error in registerFCMAndTopics: $e");
      // Continue even if registration fails
    }
  }

  /// Copy FCM token to clipboard - use for Firebase "Test on device"
  static Future<void> copyFcmTokenToClipboard() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await Clipboard.setData(ClipboardData(text: token));
        toast('FCM token copied! Paste in Firebase Test on device.');
        log('FCM Token (copied): $token');
      } else {
        toast('FCM token not ready. Login and try again.');
      }
    } catch (e) {
      toast('Error: $e');
      log('copyFcmToken error: $e');
    }
  }

  /// Subscribe to user_<userId> and all_users so backend can send FCM (spec: both required).
  Future<void> subScribeToTopic() async {
    try {
      final userId = loginUserData.value.id;
      final userTopic = '${FirebaseMsgConst.userWithUnderscoreKey}$userId';
      await FirebaseMessaging.instance.subscribeToTopic(userTopic).then((_) {
        log("${FirebaseMsgConst.topicSubscribed}$userTopic");
      }).catchError((error) {
        log("Failed to subscribe to topic $userTopic: $error");
      });
      await FirebaseMessaging.instance.subscribeToTopic(FirebaseMsgConst.allUsersTopicKey).then((_) {
        log("${FirebaseMsgConst.topicSubscribed}${FirebaseMsgConst.allUsersTopicKey}");
      }).catchError((error) {
        log("Failed to subscribe to topic ${FirebaseMsgConst.allUsersTopicKey}: $error");
      });
    } catch (e) {
      log("Error subscribing to topics: $e");
    }
  }

  /// Unsubscribe from user_<id> and all_users on logout.
  Future<void> unsubscribeFirebaseTopic() async {
    try {
      final userTopic = '${FirebaseMsgConst.userWithUnderscoreKey}${loginUserData.value.id}';
      await FirebaseMessaging.instance.unsubscribeFromTopic(userTopic).catchError((error) {
        log("Failed to unsubscribe from $userTopic: $error");
      });
      await FirebaseMessaging.instance.unsubscribeFromTopic(FirebaseMsgConst.allUsersTopicKey).catchError((error) {
        log("Failed to unsubscribe from ${FirebaseMsgConst.allUsersTopicKey}: $error");
      });
    } catch (e) {
      log("Error unsubscribing from topics: $e");
    }
  }

  Future<void> handleNotificationClick(RemoteMessage message,
      {bool isForeGround = false,}) async {
    // Deep navigation for message / like / comment
    final type = message.data[FirebaseMsgConst.notificationTypeKey]?.toString();
    final conversationId = message.data[FirebaseMsgConst.conversationIdKey]?.toString();
    final senderIdRaw = message.data[FirebaseMsgConst.senderUserIdKey];
    final senderName = message.data[FirebaseMsgConst.senderNameKey]?.toString() ?? '';
    final postId = message.data[FirebaseMsgConst.postIdKey]?.toString();

    if (type != null && type.isNotEmpty) {
      try {
        if (type == 'message' && conversationId != null && conversationId.isNotEmpty) {
          final cId = int.tryParse(conversationId);
          final senderId = senderIdRaw is int ? senderIdRaw : int.tryParse(senderIdRaw?.toString() ?? '');
          if (cId != null && cId > 0 && senderId != null && senderId > 0) {
            final otherUser = MessageOtherUser(id: senderId, username: senderName.isNotEmpty ? senderName : null);
            Get.to(() => ChatScreen(conversationId: cId, otherUser: otherUser));
          } else {
            Get.to(() => const MessageInboxScreen());
          }
          return;
        }
        if (type == 'follow') {
          final userIdRaw = message.data[FirebaseMsgConst.userIdKey];
          final userId = userIdRaw is int ? userIdRaw : int.tryParse(userIdRaw?.toString() ?? '');
          if (userId != null && userId > 0) {
            openVammisProfile(userId: userId, isOwnProfile: userId == loginUserData.value.id);
          } else {
            Get.to(() => const SocialScreen());
          }
          return;
        }
        if (type == 'admin_broadcast') {
          Get.to(() => const WamimsNotificationScreen());
          return;
        }
        if (type == 'like' || type == 'comment' || type == 'share' ||
            type == 'reel_like' || type == 'reel_comment' || type == 'reel_upload' ||
            type == 'post_upload' || type == 'story_upload') {
          Get.to(() => const SocialScreen());
          return;
        }
        if (type == 'long_upload' || type == 'long_like' || type == 'long_comment') {
          Get.to(() => const SocialScreen());
          return;
        }
        if (type == 'impact_project' || type == 'impact_donated' || type == 'impact_viewed') {
          final projectIdRaw = message.data[FirebaseMsgConst.projectIdKey];
          final projectId = projectIdRaw is int ? projectIdRaw : int.tryParse(projectIdRaw?.toString() ?? '');
          if (projectId != null && projectId > 0) {
            Get.to(() => ProjectDetailScreen(id: projectId));
          } else {
            Get.to(() => const ImpactDashboardScreen());
          }
          return;
        }
      } catch (e) {
        log("${FirebaseMsgConst.onClickListener} $e");
      }
    }

    if (message.data['url'] != null && message.data['url'] is String) {
      commonLaunchUrl(message.data['url'],
          launchMode: LaunchMode.externalApplication,);
    }
    printLogsNotificationData(message);
    _refreshInAppNotificationList();
    if (isForeGround) {
      String title = message.notification?.title ?? message.data['title'] ?? '';
      String body = message.notification?.body ?? message.data['body'] ?? '';
      if (title.isEmpty && type != null) {
        switch (type) {
          case 'message': title = 'New message'; break;
          case 'like': case 'reel_like': title = 'New like'; break;
          case 'comment': case 'reel_comment': title = 'New comment'; break;
          case 'share': title = 'New share'; break;
          case 'follow': title = 'New follower'; break;
          case 'reel_upload': title = 'New reel'; break;
          case 'post_upload': title = 'New post'; break;
          case 'story_upload': title = 'New story'; break;
          case 'long_upload': title = 'New long video'; break;
          case 'long_like': title = 'New like'; break;
          case 'long_comment': title = 'New comment'; break;
          case 'impact_project': title = 'New impact project'; break;
          case 'impact_donated': title = 'New donation'; break;
          case 'impact_viewed': title = 'Project viewed'; break;
          case 'admin_broadcast': title = 'Notification'; break;
          default: title = 'Notification';
        }
      }
      if (title.isNotEmpty || body.isNotEmpty) {
        showNotification(currentTimeStamp(), title.validate(), body.validate(), message);
      }
    } else {
      try {
        if (message.data.containsKey(FirebaseMsgConst.additionalDataKey)) {
          final additionalData =
              message.data[FirebaseMsgConst.additionalDataKey];
          if (additionalData != null) {
            if (additionalData!.containsKey(FirebaseMsgConst.idKey)) {
              /*  String? postId = additionalData![FirebaseMsgConst.idKey];
              String? postType = additionalData![FirebaseMsgConst.postTypeKey];*/
            }
          }
        }
      } catch (e) {
        log("${FirebaseMsgConst.onClickListener} $e");
      }
    }
  }

  /// WhatsApp-style: show ANDROID SYSTEM notification from top (foreground too).
  /// So user gets same "upar se aata hai" notification whether app is closed, background, or open.
  void _showSystemNotificationWhenForeground(RemoteMessage message) {
    final type = message.data[FirebaseMsgConst.notificationTypeKey]?.toString();
    String title = message.notification?.title ?? message.data['title']?.toString() ?? '';
    String body = message.notification?.body ?? message.data['body']?.toString() ?? '';
    if (title.isEmpty && type != null) {
      switch (type) {
        case 'message': title = 'New message'; break;
        case 'like': case 'reel_like': title = 'New like'; break;
        case 'comment': case 'reel_comment': title = 'New comment'; break;
        case 'share': title = 'New share'; break;
        case 'follow': title = 'New follower'; break;
        case 'reel_upload': title = 'New reel'; break;
        case 'post_upload': title = 'New post'; break;
        case 'story_upload': title = 'New story'; break;
        case 'long_upload': title = 'New long video'; break;
        case 'long_like': title = 'New like'; break;
        case 'long_comment': title = 'New comment'; break;
        case 'impact_project': title = 'New impact project'; break;
        case 'impact_donated': title = 'New donation'; break;
        case 'impact_viewed': title = 'Project viewed'; break;
        case 'admin_broadcast': title = 'Notification'; break;
        default: title = 'Notification';
      }
    }
    if (title.isEmpty && body.isEmpty) return;
    showNotification(currentTimeStamp(), title.validate(), body.validate(), message);
    _refreshInAppNotificationList();
  }

  Future<void> registerNotificationListeners() async {
    FirebaseMessaging.instance.setAutoInitEnabled(true).then((value) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showSystemNotificationWhenForeground(message);
      }, onError: (e) {
        log("${FirebaseMsgConst.onMessageListen} $e");
      },);

      // replacement for onResume: When the app is in the background and opened directly from the push notification.
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        handleNotificationClick(message);
      }, onError: (e) {
        log("${FirebaseMsgConst.onMessageOpened} $e");
      },);

      // workaround for onLaunch: When the app is completely closed (not in the background) and opened directly from the push notification
      FirebaseMessaging.instance.getInitialMessage().then(
          (RemoteMessage? message) {
        if (message != null) {
          handleNotificationClick(message);
        }
      }, onError: (e) {
        log("${FirebaseMsgConst.onGetInitialMessage} $e");
      },);
    }).onError((error, stackTrace) {
      log("${FirebaseMsgConst.onGetInitialMessage} $error");
    });
  }

  Future<void> showNotification(
      int id, String title, String message, RemoteMessage remoteMessage,) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    final String payload = jsonEncode(remoteMessage.data);

    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      FirebaseMsgConst.notificationChannelIdKey,
      FirebaseMsgConst.notificationChannelNameKey,
      importance: Importance.max,
      visibility: NotificationVisibility.public,
      priority: Priority.max,
      color: appColorPrimary,
      colorized: true,
      icon: '@drawable/ic_stat_ic_notification',
      enableVibration: true,
      playSound: true,
    );

    const darwinPlatformChannelSpecifics = DarwinNotificationDetails(
      presentSound: true,
      presentBanner: true,
      presentBadge: true,
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
      macOS: darwinPlatformChannelSpecifics,
    );

    flutterLocalNotificationsPlugin.show(
        id, title, message, platformChannelSpecifics,
        payload: payload);
  }

  void printLogsNotificationData(RemoteMessage message) {
    log('${FirebaseMsgConst.notificationDataKey} : ${message.data}');
    if (message.notification != null) {
      log('${FirebaseMsgConst.notificationTitleKey} : ${message.notification!.title}');
      log('${FirebaseMsgConst.notificationBodyKey} : ${message.notification!.body}');
    }
    log('${FirebaseMsgConst.messageDataCollapseKey} : ${message.collapseKey}');
    log('${FirebaseMsgConst.messageDataMessageIdKey} : ${message.messageId}');
  }

  /// Call from background/killed app so user sees a notification (e.g. like/comment/share/message).
  static Future<void> showNotificationFromBackground(RemoteMessage message) async {
    try {
      final String title = message.notification?.title ?? message.data['title']?.toString() ?? 'WAMIMS';
      final String body = message.notification?.body ?? message.data['body']?.toString() ?? 'New activity';
      final String payload = jsonEncode(message.data);
      final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        FirebaseMsgConst.notificationChannelIdKey,
        FirebaseMsgConst.notificationChannelNameKey,
        description: 'WAMIMS notifications',
        importance: Importance.max,
        enableLights: true,
        enableVibration: true,
        playSound: true,
        showBadge: true,
      );
      await plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      await plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@drawable/ic_stat_ic_notification'),
          iOS: DarwinInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            PushNotificationService._handleNotificationPayload(response.payload!);
          }
        },
      );
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        FirebaseMsgConst.notificationChannelIdKey,
        FirebaseMsgConst.notificationChannelNameKey,
        importance: Importance.max,
        visibility: NotificationVisibility.public,
        priority: Priority.max,
        enableVibration: true,
        playSound: true,
      );
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentSound: true,
        presentBanner: true,
        presentBadge: true,
      );
      await plugin.show(
        message.hashCode.abs() % 100000,
        title,
        body,
        const NotificationDetails(android: androidDetails, iOS: iosDetails, macOS: iosDetails),
        payload: payload,
      );
    } catch (e) {
      log('showNotificationFromBackground error: $e');
    }
  }
}
