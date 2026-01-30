// To parse this JSON data, do
//
//     final getCahnnelResponcModel = getCahnnelResponcModelFromJson(jsonString);

import 'dart:convert';

GetChannelResponceModel getCahnnelResponcModelFromJson(String str) => GetChannelResponceModel.fromJson(json.decode(str));

String getCahnnelResponcModelToJson(GetChannelResponceModel data) => json.encode(data.toJson());

class GetChannelResponceModel {
  bool? success;
  bool? hasChannel;
  VideoChannel? channel;
  String? message;

  GetChannelResponceModel({
    this.success,
    this.hasChannel,
    this.channel,
    this.message,
  });

  factory GetChannelResponceModel.fromJson(Map<String, dynamic> json) => GetChannelResponceModel(
    success: json["success"],
    hasChannel: json["has_channel"],
    channel: json["channel"] == null ? null : VideoChannel.fromJson(json["channel"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "has_channel": hasChannel,
    "channel": channel?.toJson(),
    "message": message,
  };
}


class VideoChannel {
  int? id;
  int? userId;
  String? username;
  String? channelName;
  String? description;
  String? profileImageUrl;
  String? status;
  String? rejectionReason;
  String? approvedBy;
  DateTime? createdAt;
  DateTime? updatedAt;

  VideoChannel({
    this.id,
    this.userId,
    this.username,
    this.channelName,
    this.description,
    this.profileImageUrl,
    this.status,
    this.rejectionReason,
    this.approvedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory VideoChannel.fromJson(Map<String, dynamic> json) => VideoChannel(
    id: json["id"],
    userId: json["user_id"],
    username: json["username"],
    channelName: json["channel_name"],
    description: json["description"],
    profileImageUrl: json["profile_image_url"],
    status: json["status"],
    rejectionReason: json["rejection_reason"],
    approvedBy: json["approved_by"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "username": username,
    "channel_name": channelName,
    "description": description,
    "profile_image_url": profileImageUrl,
    "status": status,
    "rejection_reason": rejectionReason,
    "approved_by": approvedBy,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
