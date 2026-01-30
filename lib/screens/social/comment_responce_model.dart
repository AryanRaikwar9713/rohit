// To parse this JSON data, do
//
//     final socialPostCommnetResponceModel = socialPostCommnetResponceModelFromJson(jsonString);

import 'dart:convert';

SocialPostCommnetResponceModel socialPostCommnetResponceModelFromJson(String str) => SocialPostCommnetResponceModel.fromJson(json.decode(str));

String socialPostCommnetResponceModelToJson(SocialPostCommnetResponceModel data) => json.encode(data.toJson());

class SocialPostCommnetResponceModel {
  String? status;
  String? message;
  CommentData? data;

  SocialPostCommnetResponceModel({
    this.status,
    this.message,
    this.data,
  });

  factory SocialPostCommnetResponceModel.fromJson(Map<String, dynamic> json) => SocialPostCommnetResponceModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : CommentData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class CommentData {
  int? postId;
  List<SocialPostComment>? comments;
  Pagination? pagination;
  UserContext? userContext;

  CommentData({
    this.postId,
    this.comments,
    this.pagination,
    this.userContext,
  });

  factory CommentData.fromJson(Map<String, dynamic> json) => CommentData(
    postId: json["post_id"],
    comments: json["comments"] == null ? [] : List<SocialPostComment>.from(json["comments"]!.map((x) => SocialPostComment.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
    userContext: json["user_context"] == null ? null : UserContext.fromJson(json["user_context"]),
  );

  Map<String, dynamic> toJson() => {
    "post_id": postId,
    "comments": comments == null ? [] : List<dynamic>.from(comments!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
    "user_context": userContext?.toJson(),
  };
}

class SocialPostComment {
  String? commentId;
  User? user;
  String? comment;
  DateTime? createdAt;
  Engagement? engagement;
  List<dynamic>? replies;
  bool? isEdited;
  bool? isMyComment;

  SocialPostComment({
    this.commentId,
    this.user,
    this.comment,
    this.createdAt,
    this.engagement,
    this.replies,
    this.isEdited,
    this.isMyComment,
  });

  factory SocialPostComment.fromJson(Map<String, dynamic> json) => SocialPostComment(
    commentId: json["comment_id"].toString(),
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    comment: json["comment"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    engagement: json["engagement"] == null ? null : Engagement.fromJson(json["engagement"]),
    replies: json["replies"] == null ? [] : List<dynamic>.from(json["replies"]!.map((x) => x)),
    isEdited: json["is_edited"],
    isMyComment: json["is_my_comment"],
  );

  Map<String, dynamic> toJson() => {
    "comment_id": commentId,
    "user": user?.toJson(),
    "comment": comment,
    "created_at": createdAt?.toIso8601String(),
    "engagement": engagement?.toJson(),
    "replies": replies == null ? [] : List<dynamic>.from(replies!.map((x) => x)),
    "is_edited": isEdited,
    "is_my_comment": isMyComment,
  };
}

class Engagement {
  int? likesCount;
  bool? isLiked;
  int? repliesCount;

  Engagement({
    this.likesCount,
    this.isLiked,
    this.repliesCount,
  });

  factory Engagement.fromJson(Map<String, dynamic> json) => Engagement(
    likesCount: json["likes_count"],
    isLiked: json["is_liked"],
    repliesCount: json["replies_count"],
  );

  Map<String, dynamic> toJson() => {
    "likes_count": likesCount,
    "is_liked": isLiked,
    "replies_count": repliesCount,
  };
}

class User {
  String? userId;
  String? username;
  String? firstName;
  String? lastName;
  String? fullName;
  String? profileImage;

  User({
    this.userId,
    this.username,
    this.firstName,
    this.lastName,
    this.fullName,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: json["user_id"],
    username: json["username"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    fullName: json["full_name"],
    profileImage: json["profile_image"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "username": username,
    "first_name": firstName,
    "last_name": lastName,
    "full_name": fullName,
    "profile_image": profileImage,
  };
}

class Pagination {
  int? currentPage;
  int? totalPages;
  String? totalComments;
  int? commentsPerPage;
  bool? hasNextPage;
  bool? hasPrevPage;

  Pagination({
    this.currentPage,
    this.totalPages,
    this.totalComments,
    this.commentsPerPage,
    this.hasNextPage,
    this.hasPrevPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    totalPages: json["total_pages"],
    totalComments: json["total_comments"],
    commentsPerPage: json["comments_per_page"],
    hasNextPage: json["has_next_page"],
    hasPrevPage: json["has_prev_page"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "total_pages": totalPages,
    "total_comments": totalComments,
    "comments_per_page": commentsPerPage,
    "has_next_page": hasNextPage,
    "has_prev_page": hasPrevPage,
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
