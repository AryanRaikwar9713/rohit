// To parse this JSON data, do
//
//     final reelsCommentResponceModel = reelsCommentResponceModelFromJson(jsonString);

import 'dart:convert';

ReelsCommentResponceModel reelsCommentResponceModelFromJson(String str) => ReelsCommentResponceModel.fromJson(json.decode(str));

String reelsCommentResponceModelToJson(ReelsCommentResponceModel data) => json.encode(data.toJson());

class ReelsCommentResponceModel {
  bool? success;
  Data? data;

  ReelsCommentResponceModel({
    this.success,
    this.data,
  });

  factory ReelsCommentResponceModel.fromJson(Map<String, dynamic> json) => ReelsCommentResponceModel(
    success: json["success"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
  };
}

class Data {
  List<ReelComment>? comments;
  Pagination? pagination;

  Data({
    this.comments,
    this.pagination,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    comments: json["comments"] == null ? [] : List<ReelComment>.from(json["comments"]!.map((x) => ReelComment.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "comments": comments == null ? [] : List<dynamic>.from(comments!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class ReelComment {
  int? id;
  String? comment;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? likesCount;
  bool? isActive;
  User? user;

  ReelComment({
    this.id,
    this.comment,
    this.createdAt,
    this.updatedAt,
    this.likesCount,
    this.isActive,
    this.user,
  });

  factory ReelComment.fromJson(Map<String, dynamic> json) => ReelComment(
    id: json["id"],
    comment: json["comment"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    likesCount: json["likes_count"],
    isActive: json["is_active"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "comment": comment,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "likes_count": likesCount,
    "is_active": isActive,
    "user": user?.toJson(),
  };
}

class User {
  int? id;
  String? username;
  String? profilePicture;
  String? fullName;

  User({
    this.id,
    this.username,
    this.profilePicture,
    this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    username: json["username"],
    profilePicture: json["profile_picture"],
    fullName: json["full_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "profile_picture": profilePicture,
    "full_name": fullName,
  };
}

class Pagination {
  int? currentPage;
  int? totalPages;
  int? totalComments;
  bool? hasNext;
  bool? hasPrev;
  int? limit;

  Pagination({
    this.currentPage,
    this.totalPages,
    this.totalComments,
    this.hasNext,
    this.hasPrev,
    this.limit,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    totalPages: json["total_pages"],
    totalComments: json["total_comments"],
    hasNext: json["has_next"],
    hasPrev: json["has_prev"],
    limit: json["limit"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "total_pages": totalPages,
    "total_comments": totalComments,
    "has_next": hasNext,
    "has_prev": hasPrev,
    "limit": limit,
  };
}
