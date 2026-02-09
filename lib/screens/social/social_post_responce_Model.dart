// To parse this JSON data, do
//
//     final getSocialPostResponceModel = getSocialPostResponceModelFromJson(jsonString);

import 'dart:convert';

GetSocialPostResponceModel getSocialPostResponceModelFromJson(String str) => GetSocialPostResponceModel.fromJson(json.decode(str));

String getSocialPostResponceModelToJson(GetSocialPostResponceModel data) => json.encode(data.toJson());

class GetSocialPostResponceModel {
  String? status;
  String? message;
  Data? data;

  GetSocialPostResponceModel({
    this.status,
    this.message,
    this.data,
  });

  factory GetSocialPostResponceModel.fromJson(Map<String, dynamic> json) => GetSocialPostResponceModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  List<SocialPost>? posts;
  Pagination? pagination;
  UserContext? userContext;

  Data({
    this.posts,
    this.pagination,
    this.userContext,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    posts: json["posts"] == null ? [] : List<SocialPost>.from(json["posts"]!.map((x) => SocialPost.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
    userContext: json["user_context"] == null ? null : UserContext.fromJson(json["user_context"]),
  );

  Map<String, dynamic> toJson() => {
    "posts": posts == null ? [] : List<dynamic>.from(posts!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
    "user_context": userContext?.toJson(),
  };
}

class Pagination {
  int? currentPage;
  int? totalPages;
  String? totalPosts;
  int? postsPerPage;
  bool? hasNextPage;
  bool? hasPrevPage;

  Pagination({
    this.currentPage,
    this.totalPages,
    this.totalPosts,
    this.postsPerPage,
    this.hasNextPage,
    this.hasPrevPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    totalPages: json["total_pages"],
    totalPosts: json["total_posts"],
    postsPerPage: json["posts_per_page"],
    hasNextPage: json["has_next_page"],
    hasPrevPage: json["has_prev_page"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "total_pages": totalPages,
    "total_posts": totalPosts,
    "posts_per_page": postsPerPage,
    "has_next_page": hasNextPage,
    "has_prev_page": hasPrevPage,
  };
}

class SocialPost {
  String? postId;
  String? title;
  String? caption;
  String? imageUrl;
  String? hashtags;
  String? location;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isFeatured;
  String? postType;
  Engagement? engagement;
  User? user;
  List<RecentComment>? recentComments;
  dynamic media;

  SocialPost({
    this.postId,
    this.title,
    this.caption,
    this.imageUrl,
    this.hashtags,
    this.location,
    this.createdAt,
    this.updatedAt,
    this.isFeatured,
    this.postType,
    this.engagement,
    this.user,
    this.recentComments,
    this.media,
  });

  factory SocialPost.fromJson(Map<String, dynamic> json) => SocialPost(
    postId: json["post_id"],
    title: json["title"],
    caption: json["caption"],
    imageUrl: json["image_url"],
    hashtags: json["hashtags"],
    location: json["location"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    isFeatured: json["is_featured"],
    postType: json["post_type"],
    engagement: json["engagement"] == null ? null : Engagement.fromJson(json["engagement"]),
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    recentComments: json["recent_comments"] == null ? [] : List<RecentComment>.from(json["recent_comments"]!.map((x) => RecentComment.fromJson(x))),
    media: json["media"],
  );

  Map<String, dynamic> toJson() => {
    "post_id": postId,
    "title": title,
    "caption": caption,
    "image_url": imageUrl,
    "hashtags": hashtags,
    "location": location,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "is_featured": isFeatured,
    "post_type": postType,
    "engagement": engagement?.toJson(),
    "user": user?.toJson(),
    "recent_comments": recentComments == null ? [] : List<dynamic>.from(recentComments!.map((x) => x.toJson())),
    "media": media,
  };
}

class Engagement {
  int? likesCount;
  int? commentsCount;
  int? sharesCount;
  bool? isLiked;

  Engagement({
    this.likesCount,
    this.commentsCount,
    this.sharesCount,
    this.isLiked,
  });

  factory Engagement.fromJson(Map<String, dynamic> json) => Engagement(
    likesCount: json["likes_count"],
    commentsCount: json["comments_count"],
    sharesCount: json["shares_count"],
    isLiked: json["is_liked"],
  );

  Map<String, dynamic> toJson() => {
    "likes_count": likesCount,
    "comments_count": commentsCount,
    "shares_count": sharesCount,
    "is_liked": isLiked,
  };
}

class RecentComment {
  String? comment;
  int? userId;
  dynamic username;
  String? fullName;
  int? commentId;
  DateTime? createdAt;
  int? likesCount;
  String? profileImage;
  int? isLikedByUser;

  RecentComment({
    this.comment,
    this.userId,
    this.username,
    this.fullName,
    this.commentId,
    this.createdAt,
    this.likesCount,
    this.profileImage,
    this.isLikedByUser,
  });

  factory RecentComment.fromJson(Map<String, dynamic> json) => RecentComment(
    comment: json["comment"],
    userId: json["user_id"],
    username: json["username"],
    fullName: json["full_name"],
    commentId: json["comment_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    likesCount: json["likes_count"],
    profileImage: json["profile_image"],
    isLikedByUser: json["is_liked_by_user"],
  );

  Map<String, dynamic> toJson() => {
    "comment": comment,
    "user_id": userId,
    "username": username,
    "full_name": fullName,
    "comment_id": commentId,
    "created_at": createdAt?.toIso8601String(),
    "likes_count": likesCount,
    "profile_image": profileImage,
    "is_liked_by_user": isLikedByUser,
  };
}

class User {
  String? userId;
  dynamic username;
  String? firstName;
  String? lastName;
  String? fullName;
  String? profileImage;
  bool? isFollowed;
  bool? hasYouTubeChannel;

  User({
    this.userId,
    this.username,
    this.firstName,
    this.lastName,
    this.fullName,
    this.profileImage,
    this.isFollowed,
    this.hasYouTubeChannel,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: json["user_id"],
    username: json["username"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    fullName: json["full_name"],
    profileImage: json["profile_image"],
    isFollowed: json["is_followed"],
    hasYouTubeChannel: json["has_youtube_channel"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "username": username,
    "first_name": firstName,
    "last_name": lastName,
    "full_name": fullName,
    "profile_image": profileImage,
    "is_followed": isFollowed,
    "has_youtube_channel": hasYouTubeChannel,
  };
}

class UserContext {
  int? userId;
  bool? hasUserContext;

  UserContext({
    this.userId,
    this.hasUserContext,
  });

  factory UserContext.fromJson(Map<String, dynamic> json) => UserContext(
    userId: json["user_id"],
    hasUserContext: json["has_user_context"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "has_user_context": hasUserContext,
  };
}
