// To parse this JSON data, do
//
//     final getFollowingListResponcModel = getFollowingListResponcModelFromJson(jsonString);

import 'dart:convert';

GetFollowingListResponcModel getFollowingListResponcModelFromJson(String str) => GetFollowingListResponcModel.fromJson(json.decode(str));

String getFollowingListResponcModelToJson(GetFollowingListResponcModel data) => json.encode(data.toJson());

class GetFollowingListResponcModel {
  bool? success;
  bool? error;
  String? message;
  int? code;
  Data? data;
  Meta? meta;

  GetFollowingListResponcModel({
    this.success,
    this.error,
    this.message,
    this.code,
    this.data,
    this.meta,
  });

  factory GetFollowingListResponcModel.fromJson(Map<String, dynamic> json) => GetFollowingListResponcModel(
    success: json["success"],
    error: json["error"],
    message: json["message"],
    code: json["code"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "error": error,
    "message": message,
    "code": code,
    "data": data?.toJson(),
    "meta": meta?.toJson(),
  };
}

class Data {
  List<FollwerOrFlollowingUser>? following;
  List<FollwerOrFlollowingUser>? followers;
  UserInfo? userInfo;

  Data({
    this.followers,
    this.following,
    this.userInfo,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    followers: json["followers"] == null ? [] : List<FollwerOrFlollowingUser>.from(json["followers"]!.map((x) => FollwerOrFlollowingUser.fromJson(x))),
    following: json["following"] == null ? [] : List<FollwerOrFlollowingUser>.from(json["following"]!.map((x) => FollwerOrFlollowingUser.fromJson(x))),
    userInfo: json["userInfo"] == null ? null : UserInfo.fromJson(json["userInfo"]),
  );

  Map<String, dynamic> toJson() => {
    "following": following == null ? [] : List<dynamic>.from(following!.map((x) => x.toJson())),
    "userInfo": userInfo?.toJson(),
  };
}

class FollwerOrFlollowingUser {
  int? id;
  String? username;
  String? firstName;
  String? lastName;
  String? fullName;
  String? avatar;
  int? followersCount;
  int? followingCount;
  DateTime? memberSince;
  DateTime? followedAt;
  bool? isFollowingBack;
  bool? isFollowing;
  bool? isCurrentUser;

  FollwerOrFlollowingUser({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.fullName,
    this.avatar,
    this.followersCount,
    this.followingCount,
    this.memberSince,
    this.followedAt,
    this.isFollowingBack,
    this.isFollowing,
    this.isCurrentUser,
  });

  factory FollwerOrFlollowingUser.fromJson(Map<String, dynamic> json) => FollwerOrFlollowingUser(
    id: json["id"],
    username: json["username"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    fullName: json["fullName"],
    avatar: json["avatar"],
    followersCount: json["followersCount"],
    followingCount: json["followingCount"],
    memberSince: json["memberSince"] == null ? null : DateTime.parse(json["memberSince"]),
    followedAt: json["followedAt"] == null ? null : DateTime.parse(json["followedAt"]),
    isFollowingBack: json["isFollowingBack"],
    isFollowing: json["isFollowing"],
    isCurrentUser: json["isCurrentUser"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "firstName": firstName,
    "lastName": lastName,
    "fullName": fullName,
    "avatar": avatar,
    "followersCount": followersCount,
    "followingCount": followingCount,
    "memberSince": memberSince?.toIso8601String(),
    "followedAt": followedAt?.toIso8601String(),
    "isFollowingBack": isFollowingBack,
    "isFollowing": isFollowing,
    "isCurrentUser": isCurrentUser,
  };
}

class UserInfo {
  int? id;
  String? username;
  String? firstName;
  String? lastName;
  String? fullName;
  String? avatar;
  FollowCounts? followCounts;
  bool? isCurrentUser;

  UserInfo({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.fullName,
    this.avatar,
    this.followCounts,
    this.isCurrentUser,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
    id: json["id"],
    username: json["username"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    fullName: json["fullName"],
    avatar: json["avatar"],
    followCounts: json["followCounts"] == null ? null : FollowCounts.fromJson(json["followCounts"]),
    isCurrentUser: json["isCurrentUser"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "firstName": firstName,
    "lastName": lastName,
    "fullName": fullName,
    "avatar": avatar,
    "followCounts": followCounts?.toJson(),
    "isCurrentUser": isCurrentUser,
  };
}

class FollowCounts {
  int? followers;
  int? following;

  FollowCounts({
    this.followers,
    this.following,
  });

  factory FollowCounts.fromJson(Map<String, dynamic> json) => FollowCounts(
    followers: json["followers"],
    following: json["following"],
  );

  Map<String, dynamic> toJson() => {
    "followers": followers,
    "following": following,
  };
}

class Meta {
  Pagination? pagination;
  Search? search;

  Meta({
    this.pagination,
    this.search,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
    search: json["search"] == null ? null : Search.fromJson(json["search"]),
  );

  Map<String, dynamic> toJson() => {
    "pagination": pagination?.toJson(),
    "search": search?.toJson(),
  };
}

class Pagination {
  int? currentPage;
  int? perPage;
  int? totalItems;
  int? totalPages;
  bool? hasNextPage;
  bool? hasPreviousPage;

  Pagination({
    this.currentPage,
    this.perPage,
    this.totalItems,
    this.totalPages,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["currentPage"],
    perPage: json["perPage"],
    totalItems: json["totalItems"],
    totalPages: json["totalPages"],
    hasNextPage: json["hasNextPage"],
    hasPreviousPage: json["hasPreviousPage"],
  );

  Map<String, dynamic> toJson() => {
    "currentPage": currentPage,
    "perPage": perPage,
    "totalItems": totalItems,
    "totalPages": totalPages,
    "hasNextPage": hasNextPage,
    "hasPreviousPage": hasPreviousPage,
  };
}

class Search {
  String? query;
  bool? hasSearch;

  Search({
    this.query,
    this.hasSearch,
  });

  factory Search.fromJson(Map<String, dynamic> json) => Search(
    query: json["query"],
    hasSearch: json["hasSearch"],
  );

  Map<String, dynamic> toJson() => {
    "query": query,
    "hasSearch": hasSearch,
  };
}
