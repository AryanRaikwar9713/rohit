// To parse this JSON data, do
//
//     final donationHistoryReponceModel = donationHistoryReponceModelFromJson(jsonString);

import 'dart:convert';

DonationHistoryReponceModel donationHistoryReponceModelFromJson(String str) => DonationHistoryReponceModel.fromJson(json.decode(str));

String donationHistoryReponceModelToJson(DonationHistoryReponceModel data) => json.encode(data.toJson());

class DonationHistoryReponceModel {
  bool? success;
  String? message;
  Data? data;
  int? timestamp;

  DonationHistoryReponceModel({
    this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory DonationHistoryReponceModel.fromJson(Map<String, dynamic> json) => DonationHistoryReponceModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    timestamp: json["timestamp"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
    "timestamp": timestamp,
  };
}

class Data {
  UserStats? userStats;
  List<Donation>? donations;
  Pagination? pagination;

  Data({
    this.userStats,
    this.donations,
    this.pagination,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    userStats: json["user_stats"] == null ? null : UserStats.fromJson(json["user_stats"]),
    donations: json["donations"] == null ? [] : List<Donation>.from(json["donations"]!.map((x) => Donation.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "user_stats": userStats?.toJson(),
    "donations": donations == null ? [] : List<dynamic>.from(donations!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class Donation {
  int? donationId;
  DonationDetails? donationDetails;
  ProjectDetails? projectDetails;
  ProjectOwner? projectOwner;
  Navigation? navigation;

  Donation({
    this.donationId,
    this.donationDetails,
    this.projectDetails,
    this.projectOwner,
    this.navigation,
  });

  factory Donation.fromJson(Map<String, dynamic> json) => Donation(
    donationId: json["donation_id"],
    donationDetails: json["donation_details"] == null ? null : DonationDetails.fromJson(json["donation_details"]),
    projectDetails: json["project_details"] == null ? null : ProjectDetails.fromJson(json["project_details"]),
    projectOwner: json["project_owner"] == null ? null : ProjectOwner.fromJson(json["project_owner"]),
    navigation: json["navigation"] == null ? null : Navigation.fromJson(json["navigation"]),
  );

  Map<String, dynamic> toJson() => {
    "donation_id": donationId,
    "donation_details": donationDetails?.toJson(),
    "project_details": projectDetails?.toJson(),
    "project_owner": projectOwner?.toJson(),
    "navigation": navigation?.toJson(),
  };
}

class DonationDetails {
  double? donatedAmountUsd;
  double? donatedBolts;
  String? donatedBoltsDisplay;
  String? message;
  bool? isAnonymous;
  DateTime? donatedAt;
  String? donationStatus;

  DonationDetails({
    this.donatedAmountUsd,
    this.donatedBolts,
    this.donatedBoltsDisplay,
    this.message,
    this.isAnonymous,
    this.donatedAt,
    this.donationStatus,
  });

  factory DonationDetails.fromJson(Map<String, dynamic> json) => DonationDetails(
    donatedAmountUsd: json["donated_amount_usd"]?.toDouble(),
    donatedBolts: json["donated_bolts"]?.toDouble(),
    donatedBoltsDisplay: json["donated_bolts_display"],
    message: json["message"],
    isAnonymous: json["is_anonymous"],
    donatedAt: json["donated_at"] == null ? null : DateTime.parse(json["donated_at"]),
    donationStatus: json["donation_status"],
  );

  Map<String, dynamic> toJson() => {
    "donated_amount_usd": donatedAmountUsd,
    "donated_bolts": donatedBolts,
    "donated_bolts_display": donatedBoltsDisplay,
    "message": message,
    "is_anonymous": isAnonymous,
    "donated_at": donatedAt?.toIso8601String(),
    "donation_status": donationStatus,
  };
}

class Navigation {
  String? projectUrl;
  String? ownerProfileUrl;

  Navigation({
    this.projectUrl,
    this.ownerProfileUrl,
  });

  factory Navigation.fromJson(Map<String, dynamic> json) => Navigation(
    projectUrl: json["project_url"],
    ownerProfileUrl: json["owner_profile_url"],
  );

  Map<String, dynamic> toJson() => {
    "project_url": projectUrl,
    "owner_profile_url": ownerProfileUrl,
  };
}

class ProjectDetails {
  int? projectId;
  String? title;
  String? description;
  int? fundingGoal;
  double? fundingRaised;
  double? progressPercentage;
  String? projectStatus;
  String? location;
  DateTime? startDate;
  DateTime? endDate;
  int? daysRemaining;
  int? viewsCount;
  int? donorsCount;

  ProjectDetails({
    this.projectId,
    this.title,
    this.description,
    this.fundingGoal,
    this.fundingRaised,
    this.progressPercentage,
    this.projectStatus,
    this.location,
    this.startDate,
    this.endDate,
    this.daysRemaining,
    this.viewsCount,
    this.donorsCount,
  });

  factory ProjectDetails.fromJson(Map<String, dynamic> json) => ProjectDetails(
    projectId: json["project_id"],
    title: json["title"],
    description: json["description"],
    fundingGoal: json["funding_goal"],
    fundingRaised: json["funding_raised"]?.toDouble(),
    progressPercentage: double.parse((json["progress_percentage"]??"0").toString()),
    projectStatus: json["project_status"],
    location: json["location"],
    startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
    endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
    daysRemaining: json["days_remaining"],
    viewsCount: json["views_count"],
    donorsCount: json["donors_count"],
  );

  Map<String, dynamic> toJson() => {
    "project_id": projectId,
    "title": title,
    "description": description,
    "funding_goal": fundingGoal,
    "funding_raised": fundingRaised,
    "progress_percentage": progressPercentage,
    "project_status": projectStatus,
    "location": location,
    "start_date": startDate?.toIso8601String(),
    "end_date": endDate?.toIso8601String(),
    "days_remaining": daysRemaining,
    "views_count": viewsCount,
    "donors_count": donorsCount,
  };
}

class ProjectOwner {
  int? userId;
  String? username;
  String? fullName;
  String? avatarUrl;

  ProjectOwner({
    this.userId,
    this.username,
    this.fullName,
    this.avatarUrl,
  });

  factory ProjectOwner.fromJson(Map<String, dynamic> json) => ProjectOwner(
    userId: json["user_id"],
    username: json["username"],
    fullName: json["full_name"],
    avatarUrl: json["avatar_url"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "username": username,
    "full_name": fullName,
    "avatar_url": avatarUrl,
  };
}

class Pagination {
  int? currentPage;
  int? totalPages;
  int? totalDonations;
  int? perPage;
  bool? hasNextPage;
  bool? hasPrevPage;

  Pagination({
    this.currentPage,
    this.totalPages,
    this.totalDonations,
    this.perPage,
    this.hasNextPage,
    this.hasPrevPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    totalPages: json["total_pages"],
    totalDonations: json["total_donations"],
    perPage: json["per_page"],
    hasNextPage: json["has_next_page"],
    hasPrevPage: json["has_prev_page"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "total_pages": totalPages,
    "total_donations": totalDonations,
    "per_page": perPage,
    "has_next_page": hasNextPage,
    "has_prev_page": hasPrevPage,
  };
}

class UserStats {
  int? totalDonations;
  double? totalBoltsDonated;
  String? totalBoltsDonatedDisplay;
  double? totalUsdDonated;
  int? uniqueProjectsSupported;
  DateTime? firstDonationDate;
  DateTime? lastDonationDate;

  UserStats({
    this.totalDonations,
    this.totalBoltsDonated,
    this.totalBoltsDonatedDisplay,
    this.totalUsdDonated,
    this.uniqueProjectsSupported,
    this.firstDonationDate,
    this.lastDonationDate,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    totalDonations: json["total_donations"],
    totalBoltsDonated: json["total_bolts_donated"]?.toDouble(),
    totalBoltsDonatedDisplay: json["total_bolts_donated_display"],
    totalUsdDonated: json["total_usd_donated"]?.toDouble(),
    uniqueProjectsSupported: json["unique_projects_supported"],
    firstDonationDate: json["first_donation_date"] == null ? null : DateTime.parse(json["first_donation_date"]),
    lastDonationDate: json["last_donation_date"] == null ? null : DateTime.parse(json["last_donation_date"]),
  );

  Map<String, dynamic> toJson() => {
    "total_donations": totalDonations,
    "total_bolts_donated": totalBoltsDonated,
    "total_bolts_donated_display": totalBoltsDonatedDisplay,
    "total_usd_donated": totalUsdDonated,
    "unique_projects_supported": uniqueProjectsSupported,
    "first_donation_date": firstDonationDate?.toIso8601String(),
    "last_donation_date": lastDonationDate?.toIso8601String(),
  };
}
