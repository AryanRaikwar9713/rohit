import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:streamit_laravel/configs.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/messaging/models/message_models.dart';

/// WAMIMS Messaging API – 1:1 chat (text, image, audio, video, file).
/// Base: https://wamims.international/social/message
class MessageApi {
  static String get _base => MESSAGE_BASE_URL;

  static Future<Map<String, String>> _headers() async {
    final h = await DB().getHeaderForRow();
    return h ?? {};
  }

  /// GET get_conversations.php – inbox list
  static Future<void> getConversations({
    required void Function(List<MessageConversation>) onSuccess,
    required void Function(String) onError,
    void Function(http.Response)? onFailure,
  }) async {
    try {
      final url = '$_base/get_conversations.php';
      final response = await http.get(Uri.parse(url), headers: await _headers());
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && (data['success'] == true)) {
        final list = (data['conversations'] as List?)
            ?.map((e) => MessageConversation.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ?? [];
        onSuccess(list);
      } else if (response.statusCode == 401) {
        onError(data['error']?.toString() ?? 'Authentication required');
      } else {
        onError(data['error']?.toString() ?? 'Failed to load conversations');
        onFailure?.call(response);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  /// GET/POST get_or_create_conversation.php – open chat with user
  static Future<void> getOrCreateConversation({
    required int otherUserId,
    required void Function(int conversationId, MessageOtherUser otherUser) onSuccess,
    required void Function(String) onError,
    void Function(http.Response)? onFailure,
  }) async {
    try {
      final url = '$_base/get_or_create_conversation.php?other_user_id=$otherUserId';
      final response = await http.get(Uri.parse(url), headers: await _headers());
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && (data['success'] == true)) {
        final cId = (data['conversation_id'] is int) ? data['conversation_id'] as int : int.tryParse(data['conversation_id']?.toString() ?? '0') ?? 0;
        final other = MessageOtherUser.fromJson(Map<String, dynamic>.from(data['other_user'] ?? {}));
        onSuccess(cId, other);
      } else if (response.statusCode == 401) {
        onError(data['error']?.toString() ?? 'Authentication required');
      } else {
        onError(data['error']?.toString() ?? 'Failed to get conversation');
        onFailure?.call(response);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  /// GET get_messages.php – load messages (initial, poll after_id, load older before_id)
  static Future<void> getMessages({
    required int conversationId,
    int limit = 50,
    int? afterId,
    int? beforeId,
    required void Function(List<MessageItem> messages, bool hasMore) onSuccess,
    required void Function(String) onError,
    void Function(http.Response)? onFailure,
  }) async {
    try {
      var url = '$_base/get_messages.php?conversation_id=$conversationId&limit=$limit';
      if (afterId != null) url += '&after_id=$afterId';
      if (beforeId != null) url += '&before_id=$beforeId';
      final response = await http.get(Uri.parse(url), headers: await _headers());
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && (data['success'] == true)) {
        final list = (data['messages'] as List?)
            ?.map((e) => MessageItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ?? [];
        final hasMore = data['has_more'] == true;
        onSuccess(list, hasMore);
      } else if (response.statusCode == 401) {
        onError(data['error']?.toString() ?? 'Authentication required');
      } else if (response.statusCode == 403) {
        onError(data['error']?.toString() ?? 'Not a participant');
      } else {
        onError(data['error']?.toString() ?? 'Failed to load messages');
        onFailure?.call(response);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  /// POST send_message.php – text only (body)
  static Future<void> sendText({
    required int conversationId,
    required String body,
    required void Function(MessageItem message) onSuccess,
    required void Function(String) onError,
    void Function(http.Response)? onFailure,
  }) async {
    try {
      final url = '$_base/send_message.php';
      final headers = await _headers();
      headers['Content-Type'] = 'application/x-www-form-urlencoded';
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: 'conversation_id=$conversationId&type=text&body=${Uri.encodeComponent(body)}',
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && (data['success'] == true) && data['message'] != null) {
        onSuccess(MessageItem.fromJson(Map<String, dynamic>.from(data['message'] as Map)));
      } else {
        onError(data['error']?.toString() ?? 'Failed to send message');
        onFailure?.call(response);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  /// POST send_message.php – multipart (image, audio, video, file)
  static Future<void> sendAttachment({
    required int conversationId,
    required String type, // image, audio, video, file
    required List<int> fileBytes,
    required String fileName,
    String? body,
    required void Function(MessageItem message) onSuccess,
    required void Function(String) onError,
    void Function(http.Response)? onFailure,
  }) async {
    try {
      final url = Uri.parse('$_base/send_message.php');
      final headers = await _headers();
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);
      request.fields['conversation_id'] = conversationId.toString();
      request.fields['type'] = type;
      if (body != null && body.isNotEmpty) request.fields['body'] = body;
      request.files.add(http.MultipartFile.fromBytes(
        'attachment',
        fileBytes,
        filename: fileName,
      ),);
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && (data['success'] == true) && data['message'] != null) {
        onSuccess(MessageItem.fromJson(Map<String, dynamic>.from(data['message'] as Map)));
      } else {
        onError(data['error']?.toString() ?? 'Failed to send attachment');
        onFailure?.call(response);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  /// POST mark_read.php
  static Future<void> markRead({
    required int conversationId,
    int? lastReadMessageId,
    required void Function() onSuccess,
    required void Function(String) onError,
  }) async {
    try {
      final url = '$_base/mark_read.php';
      var bodyStr = 'conversation_id=$conversationId';
      if (lastReadMessageId != null) bodyStr += '&last_read_message_id=$lastReadMessageId';
      final headers = await _headers();
      headers['Content-Type'] = 'application/x-www-form-urlencoded';
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: bodyStr,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && (data['success'] == true)) {
        onSuccess();
      } else {
        onError(data['error']?.toString() ?? 'Failed to mark read');
      }
    } catch (e) {
      onError(e.toString());
    }
  }
}
