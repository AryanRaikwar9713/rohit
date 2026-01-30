// To parse this JSON data, do
//
//     final impactProfileResponce = impactProfileResponceFromJson(jsonString);

import 'dart:convert';

ImpactProfileResponce impactProfileResponceFromJson(String str) =>
    ImpactProfileResponce.fromJson(json.decode(str));

String impactProfileResponceToJson(ImpactProfileResponce data) =>
    json.encode(data.toJson());

class ImpactProfileResponce {
  bool? success;
  String? message;
  ImpactProfile? data;
  int? timestamp;

  ImpactProfileResponce({
    this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory ImpactProfileResponce.fromJson(Map<String, dynamic> json) =>
      ImpactProfileResponce(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : ImpactProfile.fromJson(json["data"]),
        timestamp: int.tryParse(json["timestamp"]?.toString() ?? ''),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
    "timestamp": timestamp,
  };
}

class ImpactProfile {
  bool? hasAccount;
  AccountDetails? accountDetails;
  Limits? limits;
  ProjectsSummary? projectsSummary;
  String? message;
  String? nextAction;

  ImpactProfile({
    this.hasAccount,
    this.accountDetails,
    this.limits,
    this.projectsSummary,
    this.message,
    this.nextAction,
  });

  factory ImpactProfile.fromJson(Map<String, dynamic> json) => ImpactProfile(
    hasAccount: json["has_account"],
    accountDetails: json["account_details"] == null
        ? null
        : AccountDetails.fromJson(json["account_details"]),
    limits:
    json["limits"] == null ? null : Limits.fromJson(json["limits"]),
    projectsSummary: json["projects_summary"] == null
        ? null
        : ProjectsSummary.fromJson(json["projects_summary"]),
    message: json["message"],
    nextAction: json["next_action"],
  );

  Map<String, dynamic> toJson() => {
    "has_account": hasAccount,
    "account_details": accountDetails?.toJson(),
    "limits": limits?.toJson(),
    "projects_summary": projectsSummary?.toJson(),
    "message": message,
    "next_action": nextAction,
  };
}

class AccountDetails {
  int? accountId;
  String? accountType;
  String? accountStatus;
  String? title;
  String? description;
  String? fundingPurpose;
  ContactInfo? contactInfo;
  Media? media;
  FinancialLimits? financialLimits;
  ProjectLimits? projectLimits;
  Dates? dates;

  AccountDetails({
    this.accountId,
    this.accountType,
    this.accountStatus,
    this.title,
    this.description,
    this.fundingPurpose,
    this.contactInfo,
    this.media,
    this.financialLimits,
    this.projectLimits,
    this.dates,
  });

  factory AccountDetails.fromJson(Map<String, dynamic> json) => AccountDetails(
    accountId: int.tryParse(json["account_id"]?.toString() ?? ''),
    accountType: json["account_type"],
    accountStatus: json["account_status"],
    title: json["title"],
    description: json["description"],
    fundingPurpose: json["funding_purpose"],
    contactInfo: json["contact_info"] == null
        ? null
        : ContactInfo.fromJson(json["contact_info"]),
    media: json["media"] == null ? null : Media.fromJson(json["media"]),
    financialLimits: json["financial_limits"] == null
        ? null
        : FinancialLimits.fromJson(json["financial_limits"]),
    projectLimits: json["project_limits"] == null
        ? null
        : ProjectLimits.fromJson(json["project_limits"]),
    dates: json["dates"] == null ? null : Dates.fromJson(json["dates"]),
  );

  Map<String, dynamic> toJson() => {
    "account_id": accountId,
    "account_type": accountType,
    "account_status": accountStatus,
    "title": title,
    "description": description,
    "funding_purpose": fundingPurpose,
    "contact_info": contactInfo?.toJson(),
    "media": media?.toJson(),
    "financial_limits": financialLimits?.toJson(),
    "project_limits": projectLimits?.toJson(),
    "dates": dates?.toJson(),
  };
}

class ContactInfo {
  String? fullName;
  String? email;
  String? phone;

  ContactInfo({
    this.fullName,
    this.email,
    this.phone,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) => ContactInfo(
    fullName: json["full_name"],
    email: json["email"],
    phone: json["phone"],
  );

  Map<String, dynamic> toJson() => {
    "full_name": fullName,
    "email": email,
    "phone": phone,
  };
}

class Dates {
  DateTime? createdAt;
  dynamic reviewedAt;
  dynamic reviewedBy;

  Dates({
    this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
  });

  factory Dates.fromJson(Map<String, dynamic> json) => Dates(
    createdAt: json["created_at"] == null
        ? null
        : DateTime.tryParse(json["created_at"]),
    reviewedAt: json["reviewed_at"],
    reviewedBy: json["reviewed_by"],
  );

  Map<String, dynamic> toJson() => {
    "created_at": createdAt?.toIso8601String(),
    "reviewed_at": reviewedAt,
    "reviewed_by": reviewedBy,
  };
}

class FinancialLimits {
  double? maxFundingLimit;
  double? currentFundingUsed;
  double? fundingRemaining;

  FinancialLimits({
    this.maxFundingLimit,
    this.currentFundingUsed,
    this.fundingRemaining,
  });

  factory FinancialLimits.fromJson(Map<String, dynamic> json) =>
      FinancialLimits(
        maxFundingLimit:
        double.tryParse(json["max_funding_limit"]?.toString() ?? '0'),
        currentFundingUsed:
        double.tryParse(json["current_funding_used"]?.toString() ?? '0'),
        fundingRemaining:
        double.tryParse(json["funding_remaining"]?.toString() ?? '0'),
      );

  Map<String, dynamic> toJson() => {
    "max_funding_limit": maxFundingLimit,
    "current_funding_used": currentFundingUsed,
    "funding_remaining": fundingRemaining,
  };
}

class Media {
  String? profileImage;
  String? coverImage;

  Media({
    this.profileImage,
    this.coverImage,
  });

  factory Media.fromJson(Map<String, dynamic> json) => Media(
    profileImage: json["profile_image"],
    coverImage: json["cover_image"],
  );

  Map<String, dynamic> toJson() => {
    "profile_image": profileImage,
    "cover_image": coverImage,
  };
}

class ProjectLimits {
  double? approvedProjectsLimit;
  double? currentProjectsCount;
  double? maxProjectsLimit;
  double? projectsRemaining;

  ProjectLimits({
    this.approvedProjectsLimit,
    this.currentProjectsCount,
    this.maxProjectsLimit,
    this.projectsRemaining,
  });

  factory ProjectLimits.fromJson(Map<String, dynamic> json) => ProjectLimits(
    approvedProjectsLimit:
    double.tryParse(json["approved_projects_limit"]?.toString() ?? '0'),
    currentProjectsCount:
    double.tryParse(json["current_projects_count"]?.toString() ?? '0'),
    maxProjectsLimit:
    double.tryParse(json["max_projects_limit"]?.toString() ?? '0'),
    projectsRemaining:
    double.tryParse(json["projects_remaining"]?.toString() ?? '0'),
  );

  Map<String, dynamic> toJson() => {
    "approved_projects_limit": approvedProjectsLimit,
    "current_projects_count": currentProjectsCount,
    "max_projects_limit": maxProjectsLimit,
    "projects_remaining": projectsRemaining,
  };
}

class Limits {
  bool? canCreateProjects;
  bool? canReceiveFunding;
  double? financialUsagePercentage;
  double? projectUsagePercentage;
  StatusSummary? statusSummary;

  Limits({
    this.canCreateProjects,
    this.canReceiveFunding,
    this.financialUsagePercentage,
    this.projectUsagePercentage,
    this.statusSummary,
  });

  factory Limits.fromJson(Map<String, dynamic> json) => Limits(
    canCreateProjects: json["can_create_projects"],
    canReceiveFunding: json["can_receive_funding"],
    financialUsagePercentage:
    double.tryParse(json["financial_usage_percentage"]?.toString() ?? '0'),
    projectUsagePercentage:
    double.tryParse(json["project_usage_percentage"]?.toString() ?? '0'),
    statusSummary: json["status_summary"] == null
        ? null
        : StatusSummary.fromJson(json["status_summary"]),
  );

  Map<String, dynamic> toJson() => {
    "can_create_projects": canCreateProjects,
    "can_receive_funding": canReceiveFunding,
    "financial_usage_percentage": financialUsagePercentage,
    "project_usage_percentage": projectUsagePercentage,
    "status_summary": statusSummary?.toJson(),
  };
}

class StatusSummary {
  String? message;
  String? description;
  String? color;
  bool? canProceed;

  StatusSummary({
    this.message,
    this.description,
    this.color,
    this.canProceed,
  });

  factory StatusSummary.fromJson(Map<String, dynamic> json) => StatusSummary(
    message: json["message"],
    description: json["description"],
    color: json["color"],
    canProceed: json["can_proceed"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "description": description,
    "color": color,
    "can_proceed": canProceed,
  };
}

class ProjectsSummary {
  double? totalProjects;
  double? activeProjects;
  double? totalRaised;
  List<dynamic>? byStatus;

  ProjectsSummary({
    this.totalProjects,
    this.activeProjects,
    this.totalRaised,
    this.byStatus,
  });

  factory ProjectsSummary.fromJson(Map<String, dynamic> json) => ProjectsSummary(
    totalProjects:
    double.tryParse(json["total_projects"]?.toString() ?? '0'),
    activeProjects:
    double.tryParse(json["active_projects"]?.toString() ?? '0'),
    totalRaised: double.tryParse(json["total_raised"]?.toString() ?? '0'),
    byStatus: json["by_status"] == null
        ? []
        : List<dynamic>.from(json["by_status"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "total_projects": totalProjects,
    "active_projects": activeProjects,
    "total_raised": totalRaised,
    "by_status":
    byStatus == null ? [] : List<dynamic>.from(byStatus!.map((x) => x)),
  };
}
