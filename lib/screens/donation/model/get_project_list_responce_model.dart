// To parse this JSON data, do
//
//     final getProjectListResponcModel = getProjectListResponcModelFromJson(jsonString);

import 'dart:convert';

GetProjectListResponcModel getProjectListResponcModelFromJson(String str) => GetProjectListResponcModel.fromJson(json.decode(str));

String getProjectListResponcModelToJson(GetProjectListResponcModel data) => json.encode(data.toJson());

class GetProjectListResponcModel {
  bool? success;
  ProjectListData? data;
  String? message;
  DateTime? timestamp;

  GetProjectListResponcModel({
    this.success,
    this.data,
    this.message,
    this.timestamp,
  });

  factory GetProjectListResponcModel.fromJson(Map<String, dynamic> json) => GetProjectListResponcModel(
    success: json["success"],
    data: json["data"] == null ? null : ProjectListData.fromJson(json["data"]),
    message: json["message"],
    timestamp: json["timestamp"] == null ? null : DateTime.parse(json["timestamp"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
    "message": message,
    "timestamp": timestamp?.toIso8601String(),
  };
}

class ProjectListData {
  List<Project>? projects;
  Pagination? pagination;

  ProjectListData({
    this.projects,
    this.pagination,
  });

  factory ProjectListData.fromJson(Map<String, dynamic> json) => ProjectListData(
    projects: json["projects"] == null ? [] : List<Project>.from(json["projects"]!.map((x) => Project.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "projects": projects == null ? [] : List<dynamic>.from(projects!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class Pagination {
  int? currentPage;
  int? perPage;
  int? totalProjects;
  int? totalPages;
  bool? hasNextPage;
  bool? hasPrevPage;

  Pagination({
    this.currentPage,
    this.perPage,
    this.totalProjects,
    this.totalPages,
    this.hasNextPage,
    this.hasPrevPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    perPage: json["per_page"],
    totalProjects: json["total_projects"],
    totalPages: json["total_pages"],
    hasNextPage: json["has_next_page"],
    hasPrevPage: json["has_prev_page"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "per_page": perPage,
    "total_projects": totalProjects,
    "total_pages": totalPages,
    "has_next_page": hasNextPage,
    "has_prev_page": hasPrevPage,
  };
}

class Project {
  int? id;
  String? title;
  String? description;
  String? story;
  int? fundingGoal;
  double? fundingRaised;
  double? fundingPercentage;
  int? durationDays;
  int? daysRemaining;
  List<String>? projectImages;
  List<dynamic>? projectVideos;
  List<dynamic>? projectDocuments;
  String? location;
  dynamic latitude;
  dynamic longitude;
  List<String>? tags;
  bool? isFeatured;
  bool? isVerified;
  int? viewsCount;
  int? donorsCount;
  int? likesCount;
  int? commentsCount;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? createdAt;
  DateTime? updatedAt;
  Category? category;
  Account? account;
  Creator? creator;
  Progress? progress;

  Project({
    this.id,
    this.title,
    this.description,
    this.story,
    this.fundingGoal,
    this.fundingRaised,
    this.fundingPercentage,
    this.durationDays,
    this.daysRemaining,
    this.projectImages,
    this.projectVideos,
    this.projectDocuments,
    this.location,
    this.latitude,
    this.longitude,
    this.tags,
    this.isFeatured,
    this.isVerified,
    this.viewsCount,
    this.donorsCount,
    this.likesCount,
    this.commentsCount,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.account,
    this.creator,
    this.progress,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    story: json["story"],
    fundingGoal: json["funding_goal"],
    fundingRaised: double.parse((json["funding_raised"]??'0').toString()),
    fundingPercentage: double.parse((json["funding_percentage"]??'0').toString()),
    durationDays: json["duration_days"],
    daysRemaining: json["days_remaining"],
    projectImages: json["project_images"] == null ? [] : List<String>.from(json["project_images"]!.map((x) => x)),
    projectVideos: json["project_videos"] == null ? [] : List<dynamic>.from(json["project_videos"]!.map((x) => x)),
    projectDocuments: json["project_documents"] == null ? [] : List<dynamic>.from(json["project_documents"]!.map((x) => x)),
    location: json["location"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    tags: json["tags"] == null ? [] : List<String>.from(json["tags"]!.map((x) => x)),
    isFeatured: json["is_featured"],
    isVerified: json["is_verified"],
    viewsCount: json["views_count"],
    donorsCount: json["donors_count"],
    likesCount: json["likes_count"],
    commentsCount: json["comments_count"],
    startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
    endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    category: json["category"] == null ? null : Category.fromJson(json["category"]),
    account: json["account"] == null ? null : Account.fromJson(json["account"]),
    creator: json["creator"] == null ? null : Creator.fromJson(json["creator"]),
    progress: json["progress"] == null ? null : Progress.fromJson(json["progress"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "story": story,
    "funding_goal": fundingGoal,
    "funding_raised": fundingRaised,
    "funding_percentage": fundingPercentage,
    "duration_days": durationDays,
    "days_remaining": daysRemaining,
    "project_images": projectImages == null ? [] : List<dynamic>.from(projectImages!.map((x) => x)),
    "project_videos": projectVideos == null ? [] : List<dynamic>.from(projectVideos!.map((x) => x)),
    "project_documents": projectDocuments == null ? [] : List<dynamic>.from(projectDocuments!.map((x) => x)),
    "location": location,
    "latitude": latitude,
    "longitude": longitude,
    "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
    "is_featured": isFeatured,
    "is_verified": isVerified,
    "views_count": viewsCount,
    "donors_count": donorsCount,
    "likes_count": likesCount,
    "comments_count": commentsCount,
    "start_date": startDate?.toIso8601String(),
    "end_date": endDate?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "category": category?.toJson(),
    "account": account?.toJson(),
    "creator": creator?.toJson(),
    "progress": progress?.toJson(),
  };
}

class Account {
  int? id;
  String? title;
  String? fullName;
  String? email;
  String? phone;
  String? accountType;
  dynamic profileImage;
  dynamic coverImage;

  Account({
    this.id,
    this.title,
    this.fullName,
    this.email,
    this.phone,
    this.accountType,
    this.profileImage,
    this.coverImage,
  });

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    id: json["id"],
    title: json["title"],
    fullName: json["full_name"],
    email: json["email"],
    phone: json["phone"],
    accountType: json["account_type"],
    profileImage: json["profile_image"],
    coverImage: json["cover_image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "full_name": fullName,
    "email": email,
    "phone": phone,
    "account_type": accountType,
    "profile_image": profileImage,
    "cover_image": coverImage,
  };
}

class Category {
  int? id;
  String? name;

  Category({
    this.id,
    this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

class Creator {
  int? id;
  String? username;
  String? firstName;
  String? lastName;
  String? email;
  String? profileImage;
  DateTime? joinedDate;

  Creator({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.profileImage,
    this.joinedDate,
  });

  factory Creator.fromJson(Map<String, dynamic> json) => Creator(
    id: json["id"],
    username: json["username"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"],
    profileImage: json["profile_image"],
    joinedDate: json["joined_date"] == null ? null : DateTime.parse(json["joined_date"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "profile_image": profileImage,
    "joined_date": joinedDate?.toIso8601String(),
  };
}

class Progress {
  double? raisedAmount;
  double? goalAmount;
  double? percentage;
  int? donorsCount;
  int? daysRemaining;

  Progress({
    this.raisedAmount,
    this.goalAmount,
    this.percentage,
    this.donorsCount,
    this.daysRemaining,
  });

  factory Progress.fromJson(Map<String, dynamic> json) => Progress(
    raisedAmount: double.parse((json["raised_amount"]??'0').toString()),
    goalAmount: double.parse((json["goal_amount"]??'0').toString()),
    percentage: double.parse((json["percentage"]??'0').toString()),
    donorsCount: json["donors_count"],
    daysRemaining: json["days_remaining"],
  );

  Map<String, dynamic> toJson() => {
    "raised_amount": raisedAmount,
    "goal_amount": goalAmount,
    "percentage": percentage,
    "donors_count": donorsCount,
    "days_remaining": daysRemaining,
  };
}
