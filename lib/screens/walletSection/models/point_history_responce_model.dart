// To parse this JSON data, do
//
//     final pointsHistoryResponceModel = pointsHistoryResponceModelFromJson(jsonString);

import 'dart:convert';

PointsHistoryResponceModel pointsHistoryResponceModelFromJson(String str) => PointsHistoryResponceModel.fromJson(json.decode(str));

String pointsHistoryResponceModelToJson(PointsHistoryResponceModel data) => json.encode(data.toJson());

class PointsHistoryResponceModel {
  bool? success;
  String? message;
  PointsHistoryData? data;
  DateTime? timestamp;

  PointsHistoryResponceModel({
    this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory PointsHistoryResponceModel.fromJson(Map<String, dynamic> json) => PointsHistoryResponceModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : PointsHistoryData.fromJson(json["data"]),
    timestamp: json["timestamp"] == null ? null : DateTime.parse(json["timestamp"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
    "timestamp": timestamp?.toIso8601String(),
  };
}

class PointsHistoryData {
  List<PointHistory>? history;
  String? pointsSymbol;
  int? totalPoints;

  PointsHistoryData({
    this.history,
    this.pointsSymbol,
    this.totalPoints,
  });

  factory PointsHistoryData.fromJson(Map<String, dynamic> json) => PointsHistoryData(
    history: json["history"] == null ? [] : List<PointHistory>.from(json["history"]!.map((x) => PointHistory.fromJson(x))),
    pointsSymbol: json["points_symbol"],
    totalPoints: json["total_points"],
  );

  Map<String, dynamic> toJson() => {
    "history": history == null ? [] : List<dynamic>.from(history!.map((x) => x.toJson())),
    "points_symbol": pointsSymbol,
    "total_points": totalPoints,
  };
}

class PointHistory {
  String? actionType;
  int? pointsEarned;
  String? contentType;
  DateTime? createdAt;

  PointHistory({
    this.actionType,
    this.pointsEarned,
    this.contentType,
    this.createdAt,
  });

  factory PointHistory.fromJson(Map<String, dynamic> json) => PointHistory(
    actionType: json["action_type"],
    pointsEarned: json["points_earned"],
    contentType: json["content_type"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "action_type": actionType,
    "points_earned": pointsEarned,
    "content_type": contentType,
    "created_at": createdAt?.toIso8601String(),
  };
}
