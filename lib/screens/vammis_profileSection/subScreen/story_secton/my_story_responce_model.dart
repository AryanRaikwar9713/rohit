// To parse this JSON data, do
//
//     final getMyStoryResponceModel = getMyStoryResponceModelFromJson(jsonString);

import 'dart:convert';

GetMyStoryResponceModel getMyStoryResponceModelFromJson(String str) => GetMyStoryResponceModel.fromJson(json.decode(str));

String getMyStoryResponceModelToJson(GetMyStoryResponceModel data) => json.encode(data.toJson());

class GetMyStoryResponceModel {
  bool? success;
  String? apiFile;
  String? message;
  User? user;
  Statistics? statistics;
  List<ActiveStory>? activeStories;
  List<dynamic>? expiredStories;
  List<ExpiryInfo>? expiryInfo;
  Pagination? pagination;
  Summary? summary;
  String? note;

  GetMyStoryResponceModel({
    this.success,
    this.apiFile,
    this.message,
    this.user,
    this.statistics,
    this.activeStories,
    this.expiredStories,
    this.expiryInfo,
    this.pagination,
    this.summary,
    this.note,
  });

  factory GetMyStoryResponceModel.fromJson(Map<String, dynamic> json) => GetMyStoryResponceModel(
    success: json["success"],
    apiFile: json["api_file"],
    message: json["message"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    statistics: json["statistics"] == null ? null : Statistics.fromJson(json["statistics"]),
    activeStories: json["active_stories"] == null ? [] : List<ActiveStory>.from(json["active_stories"]!.map((x) => ActiveStory.fromJson(x))),
    expiredStories: json["expired_stories"] == null ? [] : List<dynamic>.from(json["expired_stories"]!.map((x) => x)),
    expiryInfo: json["expiry_info"] == null ? [] : List<ExpiryInfo>.from(json["expiry_info"]!.map((x) => ExpiryInfo.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
    summary: json["summary"] == null ? null : Summary.fromJson(json["summary"]),
    note: json["note"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "api_file": apiFile,
    "message": message,
    "user": user?.toJson(),
    "statistics": statistics?.toJson(),
    "active_stories": activeStories == null ? [] : List<dynamic>.from(activeStories!.map((x) => x.toJson())),
    "expired_stories": expiredStories == null ? [] : List<dynamic>.from(expiredStories!.map((x) => x)),
    "expiry_info": expiryInfo == null ? [] : List<dynamic>.from(expiryInfo!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
    "summary": summary?.toJson(),
    "note": note,
  };
}

class ActiveStory {
  int? id;
  int? userId;
  dynamic text;
  String? mediaUrl;
  String? mediaType;
  DateTime? createdAt;
  DateTime? expiresAt;
  String? status;
  TimeRemaining? timeRemaining;
  DateTimeInfo? dateTimeInfo;
  User? user;
  UiInfo? uiInfo;

  ActiveStory({
    this.id,
    this.userId,
    this.text,
    this.mediaUrl,
    this.mediaType,
    this.createdAt,
    this.expiresAt,
    this.status,
    this.timeRemaining,
    this.dateTimeInfo,
    this.user,
    this.uiInfo,
  });

  factory ActiveStory.fromJson(Map<String, dynamic> json) => ActiveStory(
    id: json["id"],
    userId: json["user_id"],
    text: json["text"],
    mediaUrl: json["media_url"],
    mediaType: json["media_type"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    expiresAt: json["expires_at"] == null ? null : DateTime.parse(json["expires_at"]),
    status: json["status"],
    timeRemaining: json["time_remaining"] == null ? null : TimeRemaining.fromJson(json["time_remaining"]),
    dateTimeInfo: json["date_time_info"] == null ? null : DateTimeInfo.fromJson(json["date_time_info"]),
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    uiInfo: json["ui_info"] == null ? null : UiInfo.fromJson(json["ui_info"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "text": text,
    "media_url": mediaUrl,
    "media_type": mediaType,
    "created_at": createdAt?.toIso8601String(),
    "expires_at": expiresAt?.toIso8601String(),
    "status": status,
    "time_remaining": timeRemaining?.toJson(),
    "date_time_info": dateTimeInfo?.toJson(),
    "user": user?.toJson(),
    "ui_info": uiInfo?.toJson(),
  };
}

class DateTimeInfo {
  DateTime? original;
  String? formatted;
  String? timeAgo;
  DateTime? date;
  String? time;
  int? timestamp;

  DateTimeInfo({
    this.original,
    this.formatted,
    this.timeAgo,
    this.date,
    this.time,
    this.timestamp,
  });

  factory DateTimeInfo.fromJson(Map<String, dynamic> json) => DateTimeInfo(
    original: json["original"] == null ? null : DateTime.parse(json["original"]),
    formatted: json["formatted"],
    timeAgo: json["time_ago"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    time: json["time"],
    timestamp: json["timestamp"],
  );

  Map<String, dynamic> toJson() => {
    "original": original?.toIso8601String(),
    "formatted": formatted,
    "time_ago": timeAgo,
    "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "time": time,
    "timestamp": timestamp,
  };
}

class TimeRemaining {
  int? hours;
  int? minutes;
  int? seconds;
  int? totalSeconds;
  bool? isExpired;
  String? formatted;
  double? percentage;

  TimeRemaining({
    this.hours,
    this.minutes,
    this.seconds,
    this.totalSeconds,
    this.isExpired,
    this.formatted,
    this.percentage,
  });

  factory TimeRemaining.fromJson(Map<String, dynamic> json) => TimeRemaining(
    hours: json["hours"],
    minutes: json["minutes"],
    seconds: json["seconds"],
    totalSeconds: json["total_seconds"],
    isExpired: json["is_expired"],
    formatted: json["formatted"],
    percentage: json["percentage"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "hours": hours,
    "minutes": minutes,
    "seconds": seconds,
    "total_seconds": totalSeconds,
    "is_expired": isExpired,
    "formatted": formatted,
    "percentage": percentage,
  };
}

class UiInfo {
  bool? isExpired;
  String? displayText;
  String? mediaTypeIcon;
  String? timeDisplay;

  UiInfo({
    this.isExpired,
    this.displayText,
    this.mediaTypeIcon,
    this.timeDisplay,
  });

  factory UiInfo.fromJson(Map<String, dynamic> json) => UiInfo(
    isExpired: json["is_expired"],
    displayText: json["display_text"],
    mediaTypeIcon: json["media_type_icon"],
    timeDisplay: json["time_display"],
  );

  Map<String, dynamic> toJson() => {
    "is_expired": isExpired,
    "display_text": displayText,
    "media_type_icon": mediaTypeIcon,
    "time_display": timeDisplay,
  };
}

class User {
  int? id;
  String? username;
  String? name;
  String? avatar;

  User({
    this.id,
    this.username,
    this.name,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
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

class ExpiryInfo {
  int? storyId;
  String? expiresIn;
  DateTime? expiresAt;
  double? percentageComplete;

  ExpiryInfo({
    this.storyId,
    this.expiresIn,
    this.expiresAt,
    this.percentageComplete,
  });

  factory ExpiryInfo.fromJson(Map<String, dynamic> json) => ExpiryInfo(
    storyId: json["story_id"],
    expiresIn: json["expires_in"],
    expiresAt: json["expires_at"] == null ? null : DateTime.parse(json["expires_at"]),
    percentageComplete: json["percentage_complete"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "story_id": storyId,
    "expires_in": expiresIn,
    "expires_at": expiresAt?.toIso8601String(),
    "percentage_complete": percentageComplete,
  };
}

class Pagination {
  int? currentPage;
  int? totalPages;
  int? totalStories;
  int? storiesPerPage;
  bool? hasNextPage;
  bool? hasPreviousPage;

  Pagination({
    this.currentPage,
    this.totalPages,
    this.totalStories,
    this.storiesPerPage,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    totalPages: json["total_pages"],
    totalStories: json["total_stories"],
    storiesPerPage: json["stories_per_page"],
    hasNextPage: json["has_next_page"],
    hasPreviousPage: json["has_previous_page"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "total_pages": totalPages,
    "total_stories": totalStories,
    "stories_per_page": storiesPerPage,
    "has_next_page": hasNextPage,
    "has_previous_page": hasPreviousPage,
  };
}

class Statistics {
  int? totalCreated;
  int? activeStories;
  int? expiredStories;
  DateTime? firstStoryDate;
  DateTime? lastStoryDate;
  int? storiesToday;

  Statistics({
    this.totalCreated,
    this.activeStories,
    this.expiredStories,
    this.firstStoryDate,
    this.lastStoryDate,
    this.storiesToday,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) => Statistics(
    totalCreated: json["total_created"],
    activeStories: json["active_stories"],
    expiredStories: json["expired_stories"],
    firstStoryDate: json["first_story_date"] == null ? null : DateTime.parse(json["first_story_date"]),
    lastStoryDate: json["last_story_date"] == null ? null : DateTime.parse(json["last_story_date"]),
    storiesToday: json["stories_today"],
  );

  Map<String, dynamic> toJson() => {
    "total_created": totalCreated,
    "active_stories": activeStories,
    "expired_stories": expiredStories,
    "first_story_date": firstStoryDate?.toIso8601String(),
    "last_story_date": lastStoryDate?.toIso8601String(),
    "stories_today": storiesToday,
  };
}

class Summary {
  int? totalActive;
  int? totalExpired;
  int? totalAll;

  Summary({
    this.totalActive,
    this.totalExpired,
    this.totalAll,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    totalActive: json["total_active"],
    totalExpired: json["total_expired"],
    totalAll: json["total_all"],
  );

  Map<String, dynamic> toJson() => {
    "total_active": totalActive,
    "total_expired": totalExpired,
    "total_all": totalAll,
  };
}
