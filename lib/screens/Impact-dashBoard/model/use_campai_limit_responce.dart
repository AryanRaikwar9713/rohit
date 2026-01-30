// To parse this JSON data, do
//
//     final userCampainLimitResponcModel = userCampainLimitResponcModelFromJson(jsonString);

import 'dart:convert';

UserCampainLimitResponcModel userCampainLimitResponcModelFromJson(String str) => UserCampainLimitResponcModel.fromJson(json.decode(str));

String userCampainLimitResponcModelToJson(UserCampainLimitResponcModel data) => json.encode(data.toJson());

class UserCampainLimitResponcModel {
  bool? success;
  String? message;
  Data? data;
  int? timestamp;

  UserCampainLimitResponcModel({
    this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory UserCampainLimitResponcModel.fromJson(Map<String, dynamic> json) => UserCampainLimitResponcModel(
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
  bool? hasAccount;
  Limits? limits;

  Data({
    this.hasAccount,
    this.limits,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    hasAccount: json["has_account"],
    limits: json["limits"] == null ? null : Limits.fromJson(json["limits"]),
  );

  Map<String, dynamic> toJson() => {
    "has_account": hasAccount,
    "limits": limits?.toJson(),
  };
}

class Limits {
  String? maxFundingLimit;
  String? currentFundingUsed;
  String? fundingRemaining;
  int? approvedProjectsLimit;
  int? currentProjectsCount;
  int? maxProjectsLimit;
  int? projectsRemaining;
  String? accountType;

  Limits({
    this.maxFundingLimit,
    this.currentFundingUsed,
    this.fundingRemaining,
    this.approvedProjectsLimit,
    this.currentProjectsCount,
    this.maxProjectsLimit,
    this.projectsRemaining,
    this.accountType,
  });

  factory Limits.fromJson(Map<String, dynamic> json) => Limits(
    maxFundingLimit: json["max_funding_limit"],
    currentFundingUsed: json["current_funding_used"],
    fundingRemaining: json["funding_remaining"],
    approvedProjectsLimit: json["approved_projects_limit"],
    currentProjectsCount: json["current_projects_count"],
    maxProjectsLimit: json["max_projects_limit"],
    projectsRemaining: json["projects_remaining"],
    accountType: json["account_type"],
  );

  Map<String, dynamic> toJson() => {
    "max_funding_limit": maxFundingLimit,
    "current_funding_used": currentFundingUsed,
    "funding_remaining": fundingRemaining,
    "approved_projects_limit": approvedProjectsLimit,
    "current_projects_count": currentProjectsCount,
    "max_projects_limit": maxProjectsLimit,
    "projects_remaining": projectsRemaining,
    "account_type": accountType,
  };
}
