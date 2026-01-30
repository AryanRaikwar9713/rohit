// To parse this JSON data, do
//
//     final getReelsResponceModel = getReelsResponceModelFromJson(jsonString);

import 'dart:convert';

GetReelsResponceModel getReelsResponceModelFromJson(String str) => GetReelsResponceModel.fromJson(json.decode(str));

String getReelsResponceModelToJson(GetReelsResponceModel data) => json.encode(data.toJson());

class GetReelsResponceModel {
  bool? success;
  ReelData? data;

  GetReelsResponceModel({
    this.success,
    this.data,
  });

  factory GetReelsResponceModel.fromJson(Map<String, dynamic> json) => GetReelsResponceModel(
    success: json["success"],
    data: json["data"] == null ? null : ReelData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
  };
}

class ReelData {
  List<Reel>? reels;
  Pagination? pagination;
  Performance? performance;

  ReelData({
    this.reels,
    this.pagination,
    this.performance,
  });

  factory ReelData.fromJson(Map<String, dynamic> json) => ReelData(
    reels: json["reels"] == null ? [] : List<Reel>.from(json["reels"]!.map((x) => Reel.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
    performance: json["performance"] == null ? null : Performance.fromJson(json["performance"]),
  );

  Map<String, dynamic> toJson() => {
    "reels": reels == null ? [] : List<dynamic>.from(reels!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
    "performance": performance?.toJson(),
  };
}

class Pagination {
  int? currentPage;
  dynamic nextPage;
  int? limit;
  bool? hasMore;

  Pagination({
    this.currentPage,
    this.nextPage,
    this.limit,
    this.hasMore,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    nextPage: json["next_page"],
    limit: json["limit"],
    hasMore: json["has_more"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "next_page": nextPage,
    "limit": limit,
    "has_more": hasMore,
  };
}

class Performance {
  String? executionTime;
  String? memoryUsage;
  int? reelsCount;
  bool? optimized;

  Performance({
    this.executionTime,
    this.memoryUsage,
    this.reelsCount,
    this.optimized,
  });

  factory Performance.fromJson(Map<String, dynamic> json) => Performance(
    executionTime: json["execution_time"],
    memoryUsage: json["memory_usage"],
    reelsCount: json["reels_count"],
    optimized: json["optimized"],
  );

  Map<String, dynamic> toJson() => {
    "execution_time": executionTime,
    "memory_usage": memoryUsage,
    "reels_count": reelsCount,
    "optimized": optimized,
  };
}

class Reel {
  int? id;
  User? user;
  Content? content;
  Stats? stats;
  Interactions? interactions;
  Optimization? optimization;

  Reel({
    this.id,
    this.user,
    this.content,
    this.stats,
    this.interactions,
    this.optimization,
  });

  factory Reel.fromJson(Map<String, dynamic> json) => Reel(
    id: json["id"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    content: json["content"] == null ? null : Content.fromJson(json["content"]),
    stats: json["stats"] == null ? null : Stats.fromJson(json["stats"]),
    interactions: json["interactions"] == null ? null : Interactions.fromJson(json["interactions"]),
    optimization: json["optimization"] == null ? null : Optimization.fromJson(json["optimization"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user": user?.toJson(),
    "content": content?.toJson(),
    "stats": stats?.toJson(),
    "interactions": interactions?.toJson(),
    "optimization": optimization?.toJson(),
  };
}

class Content {
  String? videoUrl;
  String? thumbnailUrl;
  String? caption;
  List<String>? hashtags;
  String? location;
  int? duration;
  Map<String, Quality>? qualities;

  Content({
    this.videoUrl,
    this.thumbnailUrl,
    this.caption,
    this.hashtags,
    this.location,
    this.duration,
    this.qualities,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
    videoUrl: json["video_url"],
    thumbnailUrl: json["thumbnail_url"],
    caption: json["caption"],
    hashtags: json["hashtags"] == null ? [] : List<String>.from(json["hashtags"]!.map((x) => x)),
    location: json["location"],
    duration: json["duration"],
    qualities: Map.from(json["qualities"]!).map((k, v) => MapEntry<String, Quality>(k, Quality.fromJson(v))),
  );

  Map<String, dynamic> toJson() => {
    "video_url": videoUrl,
    "thumbnail_url": thumbnailUrl,
    "caption": caption,
    "hashtags": hashtags == null ? [] : List<dynamic>.from(hashtags!.map((x) => x)),
    "location": location,
    "duration": duration,
    "qualities": Map.from(qualities!).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
  };
}

class Quality {
  String? url;
  int? fileSize;

  Quality({
    this.url,
    this.fileSize,
  });

  factory Quality.fromJson(Map<String, dynamic> json) => Quality(
    url: json["url"],
    fileSize: json["file_size"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "file_size": fileSize,
  };
}

class Interactions {
  bool? isLiked;
  bool? isBookmarked;

  Interactions({
    this.isLiked,
    this.isBookmarked,
  });

  factory Interactions.fromJson(Map<String, dynamic> json) => Interactions(
    isLiked: json["is_liked"],
    isBookmarked: json["is_bookmarked"],
  );

  Map<String, dynamic> toJson() => {
    "is_liked": isLiked,
    "is_bookmarked": isBookmarked,
  };
}

class Optimization {
  bool? preload;
  bool? lazyLoad;
  String? suggestedQuality;

  Optimization({
    this.preload,
    this.lazyLoad,
    this.suggestedQuality,
  });

  factory Optimization.fromJson(Map<String, dynamic> json) => Optimization(
    preload: json["preload"],
    lazyLoad: json["lazy_load"],
    suggestedQuality: json["suggested_quality"],
  );

  Map<String, dynamic> toJson() => {
    "preload": preload,
    "lazy_load": lazyLoad,
    "suggested_quality": suggestedQuality,
  };
}

class Stats {
  int? likesCount;
  int? commentsCount;
  int? sharesCount;
  DateTime? createdAt;
  String? timeAgo;

  Stats({
    this.likesCount,
    this.commentsCount,
    this.sharesCount,
    this.createdAt,
    this.timeAgo,
  });

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
    likesCount: json["likes_count"],
    commentsCount: json["comments_count"],
    sharesCount: json["shares_count"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    timeAgo: json["time_ago"],
  );

  Map<String, dynamic> toJson() => {
    "likes_count": likesCount,
    "comments_count": commentsCount,
    "shares_count": sharesCount,
    "created_at": createdAt?.toIso8601String(),
    "time_ago": timeAgo,
  };
}

class User {
  int? id;
  dynamic username;
  String? fullName;
  String? avatar;
  int? reelsCount;
  int? followersCount;
  bool? isFollowing;

  User({
    this.id,
    this.username,
    this.fullName,
    this.avatar,
    this.reelsCount,
    this.followersCount,
    this.isFollowing,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    username: json["username"],
    fullName: json["full_name"],
    avatar: json["avatar"],
    reelsCount: json["reels_count"],
    followersCount: json["followers_count"],
    isFollowing: json["is_following"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "full_name": fullName,
    "avatar": avatar,
    "reels_count": reelsCount,
    "followers_count": followersCount,
    "is_following": isFollowing,
  };


  var d =
  {
    "content_type":'user',
    'content_id':21,
    'Content_title':'tittle',
    'Content_description':'discription'
  };
}
