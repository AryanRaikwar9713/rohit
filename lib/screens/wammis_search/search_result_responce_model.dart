// To parse this JSON data, do
//
//     final searchResultReponceModel = searchResultReponceModelFromJson(jsonString);

import 'dart:convert';

/// API may return numbers as int or double; avoid 'double is not a subtype of int'.
int? _safeInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

SearchResultReponceModel searchResultReponceModelFromJson(String str) => SearchResultReponceModel.fromJson(json.decode(str));

String searchResultReponceModelToJson(SearchResultReponceModel data) => json.encode(data.toJson());

class SearchResultReponceModel {
  bool? success;
  SearchData? data;
  String? message;

  SearchResultReponceModel({
    this.success,
    this.data,
    this.message,
  });

  factory SearchResultReponceModel.fromJson(Map<String, dynamic> json) => SearchResultReponceModel(
    success: json["success"],
    data: json["data"] == null ? null : SearchData.fromJson(json["data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
    "message": message,
  };
}

class SearchData {
  List<Result>? results;
  SearchMetadata? searchMetadata;

  SearchData({
    this.results,
    this.searchMetadata,
  });

  factory SearchData.fromJson(Map<String, dynamic> json) => SearchData(
    results: json["results"] == null ? [] : List<Result>.from((json["results"] as List).map((x) => Result.fromJson(x as Map<String, dynamic>))),
    searchMetadata: json["search_metadata"] == null ? null : SearchMetadata.fromJson(json["search_metadata"]),
  );

  Map<String, dynamic> toJson() => {
    "results": results == null ? [] : List<dynamic>.from(results!.map((x) => x.toJson())),
    "search_metadata": searchMetadata?.toJson(),
  };
}

class Result {
  String? contentType;   //user,reel,post,project
  int? contentId;
  String? contentTitle;
  String? contentDescription;
  String? imageUrl;
  /// User avatar URL (API may send avatar_url for user type)
  String? avatarUrl;
  ExtraData? extraData;

  Result({
    this.contentType,
    this.contentId,
    this.contentTitle,
    this.contentDescription,
    this.imageUrl,
    this.avatarUrl,
    this.extraData,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    contentType: json["content_type"]?.toString(),
    contentId: _safeInt(json["content_id"]),
    contentTitle: json["content_title"]?.toString(),
    contentDescription: json["content_description"],
    imageUrl: json["image_url"]?.toString(),
    avatarUrl: json["avatar_url"]?.toString(),
    extraData: json["extra_data"] == null ? null : ExtraData.fromJson(json["extra_data"]),
  );

  Map<String, dynamic> toJson() => {
    "content_type": contentType,
    "content_id": contentId,
    "content_title": contentTitle,
    "content_description": contentDescription,
    "image_url": imageUrl,
    "avatar_url": avatarUrl,
    "extra_data": extraData?.toJson(),
  };
}

class ExtraData {
  String? email;
  int? reelsCount;
  int? followersCount;
  int? followingCount;
  DateTime? joinedDate;
  String? hashtags;
  int? likesCount;
  int? commentsCount;
  int? sharesCount;
  DateTime? createdAt;
  Author? author;
  String? videoUrl;
  int? viewsCount;
  int? fundingGoal;
  double? fundingRaised;
  int? fundingPercentage;
  int? donorsCount;
  String? projectStatus;

  ExtraData({
    this.email,
    this.reelsCount,
    this.followersCount,
    this.followingCount,
    this.joinedDate,
    this.hashtags,
    this.likesCount,
    this.commentsCount,
    this.sharesCount,
    this.createdAt,
    this.author,
    this.videoUrl,
    this.viewsCount,
    this.fundingGoal,
    this.fundingRaised,
    this.fundingPercentage,
    this.donorsCount,
    this.projectStatus,
  });

  factory ExtraData.fromJson(Map<String, dynamic> json) => ExtraData(
    email: json["email"]?.toString(),
    reelsCount: _safeInt(json["reels_count"]),
    followersCount: _safeInt(json["followers_count"]),
    followingCount: _safeInt(json["following_count"]),
    joinedDate: json["joined_date"] == null ? null : DateTime.tryParse(json["joined_date"].toString()),
    hashtags: json["hashtags"]?.toString(),
    likesCount: _safeInt(json["likes_count"]),
    commentsCount: _safeInt(json["comments_count"]),
    sharesCount: _safeInt(json["shares_count"]),
    createdAt: json["created_at"] == null ? null : DateTime.tryParse(json["created_at"].toString()),
    author: json["author"] == null ? null : Author.fromJson(json["author"] as Map<String, dynamic>),
    videoUrl: json["video_url"]?.toString(),
    viewsCount: _safeInt(json["views_count"]),
    fundingGoal: _safeInt(json["funding_goal"]),
    fundingRaised: (json["funding_raised"] is num) ? (json["funding_raised"] as num).toDouble() : null,
    fundingPercentage: _safeInt(json["funding_percentage"]),
    donorsCount: _safeInt(json["donors_count"]),
    projectStatus: json["project_status"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "reels_count": reelsCount,
    "followers_count": followersCount,
    "following_count": followingCount,
    "joined_date": joinedDate?.toIso8601String(),
    "hashtags": hashtags,
    "likes_count": likesCount,
    "comments_count": commentsCount,
    "shares_count": sharesCount,
    "created_at": createdAt?.toIso8601String(),
    "author": author?.toJson(),
    "video_url": videoUrl,
    "views_count": viewsCount,
    "funding_goal": fundingGoal,
    "funding_raised": fundingRaised,
    "funding_percentage": fundingPercentage,
    "donors_count": donorsCount,
    "project_status": projectStatus,
  };
}

class Author {
  int? userId;
  String? username;
  String? fullName;
  String? avatarUrl;

  Author({
    this.userId,
    this.username,
    this.fullName,
    this.avatarUrl,
  });

  factory Author.fromJson(Map<String, dynamic> json) => Author(
    userId: _safeInt(json["user_id"]),
    username: json["username"]?.toString(),
    fullName: json["full_name"]?.toString(),
    avatarUrl: json["avatar_url"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "username": username,
    "full_name": fullName,
    "avatar_url": avatarUrl,
  };
}

class SearchMetadata {
  String? query;
  String? type;
  int? totalResults;
  ResultsByType? resultsByType;
  int? page;
  int? limit;
  bool? hasMore;
  int? offset;

  SearchMetadata({
    this.query,
    this.type,
    this.totalResults,
    this.resultsByType,
    this.page,
    this.limit,
    this.hasMore,
    this.offset,
  });

  factory SearchMetadata.fromJson(Map<String, dynamic> json) => SearchMetadata(
    query: json["query"]?.toString(),
    type: json["type"]?.toString(),
    totalResults: _safeInt(json["total_results"]),
    resultsByType: json["results_by_type"] == null ? null : ResultsByType.fromJson(json["results_by_type"] as Map<String, dynamic>),
    page: _safeInt(json["page"]),
    limit: _safeInt(json["limit"]),
    hasMore: json["has_more"] == true,
    offset: _safeInt(json["offset"]),
  );

  Map<String, dynamic> toJson() => {
    "query": query,
    "type": type,
    "total_results": totalResults,
    "results_by_type": resultsByType?.toJson(),
    "page": page,
    "limit": limit,
    "has_more": hasMore,
    "offset": offset,
  };
}

class ResultsByType {
  int? users;
  int? posts;
  int? reels;
  int? projects;

  ResultsByType({
    this.users,
    this.posts,
    this.reels,
    this.projects,
  });

  factory ResultsByType.fromJson(Map<String, dynamic> json) => ResultsByType(
    users: _safeInt(json["users"]),
    posts: _safeInt(json["posts"]),
    reels: _safeInt(json["reels"]),
    projects: _safeInt(json["projects"]),
  );

  Map<String, dynamic> toJson() => {
    "users": users,
    "posts": posts,
    "reels": reels,
    "projects": projects,
  };
}
