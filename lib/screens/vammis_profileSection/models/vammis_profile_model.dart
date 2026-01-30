// To parse this JSON data, do
//
//     final vammisProvileReponceModel = vammisProvileReponceModelFromJson(jsonString);

import 'dart:convert';

VammisProfileResponceModel vammisProvileReponceModelFromJson(String str) => VammisProfileResponceModel.fromJson(json.decode(str));

String vammisProvileReponceModelToJson(VammisProfileResponceModel data) => json.encode(data.toJson());

class VammisProfileResponceModel {
  bool? success;
  String? message;
  VammisProfile? data;
  DateTime? timestamp;

  VammisProfileResponceModel({
    this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory VammisProfileResponceModel.fromJson(Map<String, dynamic> json) => VammisProfileResponceModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : VammisProfile.fromJson(json["data"]),
    timestamp: json["timestamp"] == null ? null : DateTime.parse(json["timestamp"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
    "timestamp": timestamp?.toIso8601String(),
  };
}

class VammisProfile {
  User? user;
  Stats? stats;
  bool? isFollowing;
  ContentCounts? contentCounts;
  List<RecentActivity>? recentActivities;
  PopularityData? popularityData;
  bool? isOwnProfile;

  VammisProfile({
    this.user,
    this.stats,
    this.isFollowing,
    this.contentCounts,
    this.recentActivities,
    this.popularityData,
    this.isOwnProfile,
  });

  factory VammisProfile.fromJson(Map<String, dynamic> json) => VammisProfile(
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    stats: json["stats"] == null ? null : Stats.fromJson(json["stats"]),
    isFollowing: json["is_following"],
    contentCounts: json["content_counts"] == null ? null : ContentCounts.fromJson(json["content_counts"]),
    recentActivities: json["recent_activities"] == null ? [] : List<RecentActivity>.from(json["recent_activities"]!.map((x) => RecentActivity.fromJson(x))),
    popularityData: json["popularity_data"] == null ? null : PopularityData.fromJson(json["popularity_data"]),
    isOwnProfile: json["is_own_profile"],
  );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
    "stats": stats?.toJson(),
    "is_following": isFollowing,
    "content_counts": contentCounts?.toJson(),
    "recent_activities": recentActivities == null ? [] : List<dynamic>.from(recentActivities!.map((x) => x.toJson())),
    "popularity_data": popularityData?.toJson(),
    "is_own_profile": isOwnProfile,
  };
}

class ContentCounts {
  int? reels;
  int? posts;
  int? projects;
  int? donations;

  ContentCounts({
    this.reels,
    this.posts,
    this.projects,
    this.donations,
  });

  factory ContentCounts.fromJson(Map<String, dynamic> json) => ContentCounts(
    reels: json["reels"],
    posts: json["posts"],
    projects: json["projects"],
    donations: json["donations"],
  );

  Map<String, dynamic> toJson() => {
    "reels": reels,
    "posts": posts,
    "projects": projects,
    "donations": donations,
  };
}

class PopularityData {
  List<FollowersGrowth>? followersGrowth;
  List<Engagement>? engagement;
  List<dynamic>? donations;
  double? popularityScore;
  String? popularityTrend;

  PopularityData({
    this.followersGrowth,
    this.engagement,
    this.donations,
    this.popularityScore,
    this.popularityTrend,
  });

  factory PopularityData.fromJson(Map<String, dynamic> json) => PopularityData(
    followersGrowth: json["followers_growth"] == null ? [] : List<FollowersGrowth>.from(json["followers_growth"]!.map((x) => FollowersGrowth.fromJson(x))),
    engagement: json["engagement"] == null ? [] : List<Engagement>.from(json["engagement"]!.map((x) => Engagement.fromJson(x))),
    donations: json["donations"] == null ? [] : List<dynamic>.from(json["donations"]!.map((x) => x)),
    popularityScore: json["popularity_score"]?.toDouble(),
    popularityTrend: json["popularity_trend"],
  );

  Map<String, dynamic> toJson() => {
    "followers_growth": followersGrowth == null ? [] : List<dynamic>.from(followersGrowth!.map((x) => x.toJson())),
    "engagement": engagement == null ? [] : List<dynamic>.from(engagement!.map((x) => x.toJson())),
    "donations": donations == null ? [] : List<dynamic>.from(donations!.map((x) => x)),
    "popularity_score": popularityScore,
    "popularity_trend": popularityTrend,
  };
}

class Engagement {
  String? month;
  String? engagement;

  Engagement({
    this.month,
    this.engagement,
  });

  factory Engagement.fromJson(Map<String, dynamic> json) => Engagement(
    month: json["month"],
    engagement: json["engagement"],
  );

  Map<String, dynamic> toJson() => {
    "month": month,
    "engagement": engagement,
  };
}

class FollowersGrowth {
  String? month;
  int? newFollowers;

  FollowersGrowth({
    this.month,
    this.newFollowers,
  });

  factory FollowersGrowth.fromJson(Map<String, dynamic> json) => FollowersGrowth(
    month: json["month"],
    newFollowers: json["new_followers"],
  );

  Map<String, dynamic> toJson() => {
    "month": month,
    "new_followers": newFollowers,
  };
}

class RecentActivity {
  String? type;
  int? id;
  String? title;
  DateTime? createdAt;
  String? description;

  RecentActivity({
    this.type,
    this.id,
    this.title,
    this.createdAt,
    this.description,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) => RecentActivity(
    type: json["type"],
    id: json["id"],
    title: json["title"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "id": id,
    "title": title,
    "created_at": createdAt?.toIso8601String(),
    "description": description,
  };
}

class Stats {
  int? followers;
  int? following;
  int? reels;
  int? posts;
  int? projects;
  double? donationsReceived;
  double? donationsGiven;
  int? totalEngagement;

  Stats({
    this.followers,
    this.following,
    this.reels,
    this.posts,
    this.projects,
    this.donationsReceived,
    this.donationsGiven,
    this.totalEngagement,
  });

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
    followers: json["followers"],
    following: json["following"],
    reels: json["reels"],
    posts: json["posts"],
    projects: json["projects"],
    donationsReceived: json["donations_received"].toDouble(),
    donationsGiven: json["donations_given"]?.toDouble(),
    totalEngagement: json["total_engagement"],
  );

  Map<String, dynamic> toJson() => {
    "followers": followers,
    "following": following,
    "reels": reels,
    "posts": posts,
    "projects": projects,
    "donations_received": donationsReceived,
    "donations_given": donationsGiven,
    "total_engagement": totalEngagement,
  };
}

class User {
  int? id;
  String? username;
  String? firstName;
  String? lastName;
  String? email;
  String? mobile;
  String? avatar;
  DateTime? createdAt;
  int? reelsCount;
  int? followersCount;
  int? followingCount;
  String? bio;
  dynamic facebookLink;
  dynamic instagramLink;
  dynamic twitterLink;
  dynamic dribbbleLink;
  int? walletPoints;
  String? avatarUrl;

  User({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.mobile,
    this.avatar,
    this.createdAt,
    this.reelsCount,
    this.followersCount,
    this.followingCount,
    this.bio,
    this.facebookLink,
    this.instagramLink,
    this.twitterLink,
    this.dribbbleLink,
    this.walletPoints,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    username: json["username"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"],
    mobile: json["mobile"],
    avatar: json["avatar"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    reelsCount: json["reels_count"],
    followersCount: json["followers_count"],
    followingCount: json["following_count"],
    bio: json["bio"],
    facebookLink: json["facebook_link"],
    instagramLink: json["instagram_link"],
    twitterLink: json["twitter_link"],
    dribbbleLink: json["dribbble_link"],
    walletPoints: json["wallet_points"],
    avatarUrl: json["avatar_url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "mobile": mobile,
    "avatar": avatar,
    "created_at": createdAt?.toIso8601String(),
    "reels_count": reelsCount,
    "followers_count": followersCount,
    "following_count": followingCount,
    "bio": bio,
    "facebook_link": facebookLink,
    "instagram_link": instagramLink,
    "twitter_link": twitterLink,
    "dribbble_link": dribbbleLink,
    "wallet_points": walletPoints,
    "avatar_url": avatarUrl,
  };
}
