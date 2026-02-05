// To parse this JSON data, do
//
//     final projectDetailResponcModel = projectDetailResponcModelFromJson(jsonString);

import 'dart:convert';

ProjectDetailResponcModel projectDetailResponcModelFromJson(String str) => ProjectDetailResponcModel.fromJson(json.decode(str));

String projectDetailResponcModelToJson(ProjectDetailResponcModel data) => json.encode(data.toJson());

class ProjectDetailResponcModel {
  bool? success;
  String? message;
  Data? data;
  DateTime? timestamp;

  ProjectDetailResponcModel({
    this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory ProjectDetailResponcModel.fromJson(Map<String, dynamic> json) => ProjectDetailResponcModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    timestamp: DateTime.parse(json["timestamp"].toString()),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
    "timestamp": timestamp,
  };
}

class Data {
  ProjectDetail? project;
  dynamic userData;

  Data({
    this.project,
    this.userData,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    project: json["project"] == null ? null : ProjectDetail.fromJson(json["project"]),
    userData: json["user_data"],
  );

  Map<String, dynamic> toJson() => {
    "project": project?.toJson(),
    "user_data": userData,
  };
}

class ProjectDetail {
  int? id;
  String? title;
  String? description;
  double? fundingGoal;
  double? fundingRaised;
  double? progressPercentage;
  int? daysRemaining;
  int? durationDays;
  String? location;
  bool? isFeatured;
  bool? isVerified;
  int? viewsCount;
  int? donorsCount;
  int? likesCount;
  int? commentsCount;
  DateTime? createdAt;
  DateTime? startDate;
  DateTime? endDate;
  Category? category;
  Creator? creator;
  List<String>? images;
  List<dynamic>? videos;
  List<String>? tags;
  UserInteraction? userInteraction;
  String? mainImage;
  String? story;
  List<RecentDonation>? recentDonors;
  dynamic latitude;
  dynamic longitude;
  String? accountHolderName;

  ProjectDetail({
    this.id,
    this.title,
    this.description,
    this.fundingGoal,
    this.fundingRaised,
    this.progressPercentage,
    this.daysRemaining,
    this.durationDays,
    this.location,
    this.isFeatured,
    this.isVerified,
    this.viewsCount,
    this.donorsCount,
    this.likesCount,
    this.commentsCount,
    this.createdAt,
    this.startDate,
    this.endDate,
    this.category,
    this.creator,
    this.images,
    this.videos,
    this.tags,
    this.userInteraction,
    this.mainImage,
    this.story,
    this.recentDonors,
    this.latitude,
    this.longitude,
    this.accountHolderName,
  });

  // Helper function to safely convert to int
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is bool) return value ? 1 : 0;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  factory ProjectDetail.fromJson(Map<String, dynamic> json) => ProjectDetail(
    id: _toInt(json["id"]),
    title: json["title"],
    description: json["description"],
    fundingGoal: double.parse((json["funding_goal"]??'0').toString()),
    fundingRaised: double.parse((json["funding_raised"]??'0').toString()),
    progressPercentage: double.parse((json["progress_percentage"]??'0').toString()),
    daysRemaining: _toInt(json["days_remaining"]),
    durationDays: _toInt(json["duration_days"]),
    location: json["location"],
    isFeatured: json["is_featured"] is bool ? json["is_featured"] : (json["is_featured"] == 1 || json["is_featured"] == "1"),
    isVerified: json["is_verified"] is bool ? json["is_verified"] : (json["is_verified"] == 1 || json["is_verified"] == "1"),
    viewsCount: _toInt(json["views_count"]),
    donorsCount: _toInt(json["donors_count"]),
    likesCount: _toInt(json["likes_count"]),
    commentsCount: _toInt(json["comments_count"]),
    createdAt: json["created_at"] == null ? null : DateTime.tryParse(json["created_at"]),
    startDate: json["start_date"] == null ? null : DateTime.tryParse(json["start_date"]),
    endDate: json["end_date"] == null ? null : DateTime.tryParse(json["end_date"]),
    category: json["category"] == null ? null : Category.fromJson(json["category"]),
    creator: json["creator"] == null ? null : Creator.fromJson(json["creator"]),
    images: json["images"] == null ? [] : List<String>.from(json["images"]!.map((x) => x)),
    videos: json["videos"] == null ? [] : List<dynamic>.from(json["videos"]!.map((x) => x)),
    tags: json["tags"] == null ? [] : List<String>.from(json["tags"]!.map((x) => x)),
    userInteraction: json["user_interaction"] == null ? null : UserInteraction.fromJson(json["user_interaction"]),
    mainImage: json["main_image"],
    story: json["story"],
    recentDonors: json["recent_donors"] == null ? [] : List<RecentDonation>.from(json["recent_donors"]!.map((x) => RecentDonation.fromJson(x))),
    latitude: json["latitude"],
    longitude: json["longitude"],
    accountHolderName: json["account_holder_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "funding_goal": fundingGoal,
    "funding_raised": fundingRaised,
    "progress_percentage": progressPercentage,
    "days_remaining": daysRemaining,
    "duration_days": durationDays,
    "location": location,
    "is_featured": isFeatured,
    "is_verified": isVerified,
    "views_count": viewsCount,
    "donors_count": donorsCount,
    "likes_count": likesCount,
    "comments_count": commentsCount,
    "created_at": createdAt?.toIso8601String(),
    "start_date": startDate?.toIso8601String(),
    "end_date": endDate?.toIso8601String(),
    "category": category?.toJson(),
    "creator": creator?.toJson(),
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
    "videos": videos == null ? [] : List<dynamic>.from(videos!.map((x) => x)),
    "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
    "user_interaction": userInteraction?.toJson(),
    "main_image": mainImage,
    "story": story,
    "recent_donors": recentDonors == null ? [] : List<dynamic>.from(recentDonors!.map((x) => x)),
    "latitude": latitude,
    "longitude": longitude,
    "account_holder_name": accountHolderName,
  };
}

class Category {
  int? id;
  String? name;
  String? icon;

  Category({
    this.id,
    this.name,
    this.icon,
  });

  // Helper function to safely convert to int
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is bool) return value ? 1 : 0;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: _toInt(json["id"]),
    name: json["name"],
    icon: json["icon"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "icon": icon,
  };
}

class Creator {
  int? id;
  String? username;
  String? firstName;
  String? lastName;
  String? avatar;
  String? accountType;

  Creator({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.avatar,
    this.accountType,
  });

  // Helper function to safely convert to int
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is bool) return value ? 1 : 0;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  factory Creator.fromJson(Map<String, dynamic> json) => Creator(
    id: _toInt(json["id"]),
    username: json["username"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    avatar: json["avatar"],
    accountType: json["account_type"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "first_name": firstName,
    "last_name": lastName,
    "avatar": avatar,
    "account_type": accountType,
  };
}

class UserInteraction {
  bool? hasLiked;
  bool? hasDonated;
  int? totalDonation;

  UserInteraction({
    this.hasLiked,
    this.hasDonated,
    this.totalDonation,
  });

  factory UserInteraction.fromJson(Map<String, dynamic> json) => UserInteraction(
    hasLiked: json["has_liked"],
    hasDonated: json["has_donated"],
    totalDonation: json["total_donation"],
  );

  Map<String, dynamic> toJson() => {
    "has_liked": hasLiked,
    "has_donated": hasDonated,
    "total_donation": totalDonation,
  };
}


class RecentDonation {
  int? id;
  double? amount;
  String? avatar;
  String? username;
  DateTime? donatedAt;
  int? isAnonymous;

  RecentDonation({
    this.id,
    this.amount,
    this.avatar,
    this.username,
    this.donatedAt,
    this.isAnonymous,
  });

  // Helper function to safely convert to int
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is bool) return value ? 1 : 0;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  factory RecentDonation.fromJson(Map<String, dynamic> json) => RecentDonation(
    id: _toInt(json["id"]),
    amount: json["amount"]?.toDouble(),
    avatar: json["avatar"],
    username: json["username"],
    donatedAt: json["donated_at"] == null ? null : DateTime.tryParse(json["donated_at"].toString()),
    isAnonymous: _toInt(json["is_anonymous"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "amount": amount,
    "avatar": avatar,
    "username": username,
    "donated_at": donatedAt?.toIso8601String(),
    "is_anonymous": isAnonymous,
  };
}

