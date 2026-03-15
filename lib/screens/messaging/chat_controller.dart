import 'dart:async';

import 'package:get/get.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/messaging/message_api.dart';
import 'package:streamit_laravel/screens/messaging/models/message_models.dart';

class ChatController extends GetxController {
  final int conversationId;
  final MessageOtherUser otherUser;

  ChatController({required this.conversationId, required this.otherUser});

  final RxList<MessageItem> messages = <MessageItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool loadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxString error = ''.obs;
  final RxBool sending = false.obs;
  Timer? _pollTimer;
  int? _currentUserId;

  int? get lastMessageId => messages.isEmpty ? null : messages.last.id;
  int? get firstMessageId => messages.isEmpty ? null : messages.first.id;

  bool get isMe => _currentUserId != null && otherUser.id != _currentUserId;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
    loadInitial();
    _markRead();
    _startPolling();
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }

  Future<void> _loadCurrentUser() async {
    final user = await DB().getUser();
    _currentUserId = user?.id;
  }

  bool isSentByMe(MessageItem m) => m.senderId == _currentUserId;

  Future<void> loadInitial() async {
    isLoading.value = true;
    error.value = '';
    MessageApi.getMessages(
      conversationId: conversationId,
      onSuccess: (list, hasMoreVal) {
        messages.assignAll(list);
        hasMore.value = hasMoreVal;
        isLoading.value = false;
      },
      onError: (msg) {
        error.value = msg;
        isLoading.value = false;
      },
    );
  }

  Future<void> _markRead() async {
    MessageApi.markRead(
      conversationId: conversationId,
      onSuccess: () {},
      onError: (_) {},
    );
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _pollNew());
  }

  Future<void> _pollNew() async {
    // When no messages yet, use 0 so we get any new messages (id > 0)
    final lastId = lastMessageId ?? 0;
    MessageApi.getMessages(
      conversationId: conversationId,
      afterId: lastId,
      onSuccess: (list, _) {
        if (list.isNotEmpty) {
          messages.addAll(list);
          error.value = '';
        }
      },
      onError: (_) {},
    );
  }

  Future<void> loadMore() async {
    final firstId = firstMessageId;
    if (firstId == null || !hasMore.value || loadingMore.value) return;
    loadingMore.value = true;
    MessageApi.getMessages(
      conversationId: conversationId,
      beforeId: firstId,
      onSuccess: (list, hasMoreVal) {
        if (list.isNotEmpty) {
          messages.insertAll(0, list);
        }
        hasMore.value = hasMoreVal;
        loadingMore.value = false;
      },
      onError: (_) {
        loadingMore.value = false;
      },
    );
  }

  Future<void> sendText(String body) async {
    final text = body.trim();
    if (text.isEmpty) return;
    sending.value = true;
    MessageApi.sendText(
      conversationId: conversationId,
      body: text,
      onSuccess: (msg) {
        messages.add(msg);
        sending.value = false;
      },
      onError: (msg) {
        error.value = msg;
        sending.value = false;
      },
    );
  }

  Future<void> sendAttachment({
    required String type,
    required List<int> fileBytes,
    required String fileName,
    String? body,
  }) async {
    sending.value = true;
    MessageApi.sendAttachment(
      conversationId: conversationId,
      type: type,
      fileBytes: fileBytes,
      fileName: fileName,
      body: body,
      onSuccess: (msg) {
        messages.add(msg);
        sending.value = false;
      },
      onError: (msg) {
        error.value = msg;
        sending.value = false;
      },
    );
  }
}
