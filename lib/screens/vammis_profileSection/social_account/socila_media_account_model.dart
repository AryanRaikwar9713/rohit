// To parse this JSON data, do
//
//     final getSocilaMediaAccountResponceModel = getSocilaMediaAccountResponceModelFromJson(jsonString);

import 'dart:convert';

GetSocialMediaAccountResponceModel getSocilaMediaAccountResponceModelFromJson(String str) => GetSocialMediaAccountResponceModel.fromJson(json.decode(str));

String getSocilaMediaAccountResponceModelToJson(GetSocialMediaAccountResponceModel data) => json.encode(data.toJson());

class GetSocialMediaAccountResponceModel {
  bool? success;
  String? apiFile;
  List<SocialMediaAccount>? socialMedia;
  int? total;
  String? message;

  GetSocialMediaAccountResponceModel({
    this.success,
    this.apiFile,
    this.socialMedia,
    this.total,
    this.message,
  });

  factory GetSocialMediaAccountResponceModel.fromJson(Map<String, dynamic> json) => GetSocialMediaAccountResponceModel(
    success: json["success"],
    apiFile: json["api_file"],
    socialMedia: json["social_media"] == null ? [] : List<SocialMediaAccount>.from(json["social_media"]!.map((x) => SocialMediaAccount.fromJson(x))),
    total: json["total"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "api_file": apiFile,
    "social_media": socialMedia == null ? [] : List<dynamic>.from(socialMedia!.map((x) => x.toJson())),
    "total": total,
    "message": message,
  };
}

class SocialMediaAccount {
  int? id;
  int? userId;
  String? platform;
  String? username;
  String? url;
  DateTime? createdAt;
  DateTime? updatedAt;

  SocialMediaAccount({
    this.id,
    this.userId,
    this.platform,
    this.username,
    this.url,
    this.createdAt,
    this.updatedAt,
  });

  factory SocialMediaAccount.fromJson(Map<String, dynamic> json) => SocialMediaAccount(
    id: json["id"],
    userId: json["user_id"],
    platform: json["platform"],
    username: json["username"],
    url: json["url"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "platform": platform,
    "username": username,
    "url": url,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
