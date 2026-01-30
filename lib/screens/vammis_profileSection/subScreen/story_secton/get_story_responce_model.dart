// To parse this JSON data, do
//
//     final getstoryResponceModel = getstoryResponceModelFromJson(jsonString);

import 'dart:convert';

GetStoryResponceModel getstoryResponceModelFromJson(String str) => GetStoryResponceModel.fromJson(json.decode(str));

String getstoryResponceModelToJson(GetStoryResponceModel data) => json.encode(data.toJson());

class GetStoryResponceModel {
  bool? success;
  String? apiFile;
  List<StoryUser>? stories;
  int? totalUsers;
  int? totalStories;
  String? message;

  GetStoryResponceModel({
    this.success,
    this.apiFile,
    this.stories,
    this.totalUsers,
    this.totalStories,
    this.message,
  });

  factory GetStoryResponceModel.fromJson(Map<String, dynamic> json) => GetStoryResponceModel(
    success: json["success"],
    apiFile: json["api_file"],
    stories: json["stories"] == null ? [] : List<StoryUser>.from(json["stories"]!.map((x) => StoryUser.fromJson(x))),
    totalUsers: json["total_users"],
    totalStories: json["total_stories"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "api_file": apiFile,
    "stories": stories == null ? [] : List<dynamic>.from(stories!.map((x) => x.toJson())),
    "total_users": totalUsers,
    "total_stories": totalStories,
    "message": message,
  };
}

class StoryUser {
  _User? user;
  List<StoryStory>? stories;
  bool? isOwnStory;
  int? storyCount;

  StoryUser({
    this.user,
    this.stories,
    this.storyCount,
    this.isOwnStory,
  });

  factory StoryUser.fromJson(Map<String, dynamic> json) => StoryUser(
    user: json["user"] == null ? null : _User.fromJson(json["user"]),
    stories: json["stories"] == null ? [] : List<StoryStory>.from(json["stories"]!.map((x) => StoryStory.fromJson(x))),
    storyCount: json["story_count"],
    isOwnStory: json["is_own_story"],
  );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
    "stories": stories == null ? [] : List<dynamic>.from(stories!.map((x) => x.toJson())),
    "story_count": storyCount,
    "is_own_story": isOwnStory,
  };
}

class StoryStory {
  int? id;
  int? userId;
  dynamic text;
  String? mediaUrl;
  String? mediaType;
  DateTime? createdAt;
  DateTime? expiresAt;
  _User? user;

  StoryStory({
    this.id,
    this.userId,
    this.text,
    this.mediaUrl,
    this.mediaType,
    this.createdAt,
    this.expiresAt,
    this.user,
  });

  factory StoryStory.fromJson(Map<String, dynamic> json) => StoryStory(
    id: json["id"],
    userId: json["user_id"],
    text: json["text"],
    mediaUrl: json["media_url"],
    mediaType: json["media_type"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    expiresAt: json["expires_at"] == null ? null : DateTime.parse(json["expires_at"]),
    user: json["user"] == null ? null : _User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "text": text,
    "media_url": mediaUrl,
    "media_type": mediaType,
    "created_at": createdAt?.toIso8601String(),
    "expires_at": expiresAt?.toIso8601String(),
    "user": user?.toJson(),
  };
}

class _User {
  int? id;
  String? username;
  String? name;
  dynamic avatar;

  _User({
    this.id,
    this.username,
    this.name,
    this.avatar,
  });

  factory _User.fromJson(Map<String, dynamic> json) => _User(
    id: json["id"],
    username: json["username"],
    name: json["name"],
    avatar: json["avatar"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "name": name,
    "avatar": avatar,
  };
}
