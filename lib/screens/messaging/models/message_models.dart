/// Models for WAMIMS messaging API responses.
library;

class MessageOtherUser {
  final int id;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? fileUrl;

  MessageOtherUser({
    required this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.fileUrl,
  });

  factory MessageOtherUser.fromJson(Map<String, dynamic> json) {
    return MessageOtherUser(
      id: (json['id'] is int) ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      username: json['username']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      fileUrl: json['file_url']?.toString(),
    );
  }

  String get displayName {
    if ((firstName ?? '').trim().isNotEmpty || (lastName ?? '').trim().isNotEmpty) {
      return '${(firstName ?? '').trim()} ${(lastName ?? '').trim()}'.trim();
    }
    return (username ?? 'User').trim();
  }
}

class MessageItem {
  final int id;
  final int conversationId;
  final int senderId;
  final String type; // text, image, audio, video, file
  final String? body;
  final String? attachmentUrl;
  final String? attachmentMime;
  final bool isEncrypted;
  final String createdAt;

  MessageItem({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    this.body,
    this.attachmentUrl,
    this.attachmentMime,
    this.isEncrypted = false,
    required this.createdAt,
  });

  factory MessageItem.fromJson(Map<String, dynamic> json) {
    return MessageItem(
      id: (json['id'] is int) ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      conversationId: (json['conversation_id'] is int) ? json['conversation_id'] as int : int.tryParse(json['conversation_id']?.toString() ?? '0') ?? 0,
      senderId: (json['sender_id'] is int) ? json['sender_id'] as int : int.tryParse(json['sender_id']?.toString() ?? '0') ?? 0,
      type: json['type']?.toString() ?? 'text',
      body: json['body']?.toString(),
      attachmentUrl: json['attachment_url']?.toString(),
      attachmentMime: json['attachment_mime']?.toString(),
      isEncrypted: json['is_encrypted'] == 1 || json['is_encrypted'] == true,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class LastMessage {
  final int id;
  final int senderId;
  final String type;
  final String? body;
  final String? attachmentUrl;
  final String createdAt;

  LastMessage({
    required this.id,
    required this.senderId,
    required this.type,
    this.body,
    this.attachmentUrl,
    required this.createdAt,
  });

  factory LastMessage.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return LastMessage(id: 0, senderId: 0, type: 'text', createdAt: '');
    }
    return LastMessage(
      id: (json['id'] is int) ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      senderId: (json['sender_id'] is int) ? json['sender_id'] as int : int.tryParse(json['sender_id']?.toString() ?? '0') ?? 0,
      type: json['type']?.toString() ?? 'text',
      body: json['body']?.toString(),
      attachmentUrl: json['attachment_url']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class MessageConversation {
  final int conversationId;
  final MessageOtherUser otherUser;
  final LastMessage? lastMessage;
  final int unreadCount;
  final String updatedAt;

  MessageConversation({
    required this.conversationId,
    required this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
  });

  factory MessageConversation.fromJson(Map<String, dynamic> json) {
    return MessageConversation(
      conversationId: (json['conversation_id'] is int) ? json['conversation_id'] as int : int.tryParse(json['conversation_id']?.toString() ?? '0') ?? 0,
      otherUser: MessageOtherUser.fromJson(Map<String, dynamic>.from(json['other_user'] ?? {})),
      lastMessage: json['last_message'] != null ? LastMessage.fromJson(Map<String, dynamic>.from(json['last_message'] as Map)) : null,
      unreadCount: (json['unread_count'] is int) ? json['unread_count'] as int : int.tryParse(json['unread_count']?.toString() ?? '0') ?? 0,
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}
