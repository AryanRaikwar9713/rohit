// To parse this JSON data, do
//
//     final walletResponce = walletResponceFromJson(jsonString);

import 'dart:convert';

WalletResponce walletResponceFromJson(String str) => WalletResponce.fromJson(json.decode(str));

String walletResponceToJson(WalletResponce data) => json.encode(data.toJson());

class WalletResponce {
  bool? success;
  String? message;
  WalletData? data;
  DateTime? timestamp;

  WalletResponce({
    this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory WalletResponce.fromJson(Map<String, dynamic> json) => WalletResponce(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : WalletData.fromJson(json["data"]),
    timestamp: json["timestamp"] == null ? null : DateTime.parse(json["timestamp"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
    "timestamp": timestamp?.toIso8601String(),
  };
}

class WalletData {
  int? userId;
  int? points;
  String? pointsSymbol;
  String? formattedPoints;
  Stats? stats;

  WalletData({
    this.userId,
    this.points,
    this.pointsSymbol,
    this.formattedPoints,
    this.stats,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) => WalletData(
    userId: json["user_id"],
    points: json["points"],
    pointsSymbol: json["points_symbol"],
    formattedPoints: json["formatted_points"],
    stats: json["stats"] == null ? null : Stats.fromJson(json["stats"]),
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "points": points,
    "points_symbol": pointsSymbol,
    "formatted_points": formattedPoints,
    "stats": stats?.toJson(),
  };
}

class Stats {
  int? totalTransactions;
  int? totalCredited;
  int? totalDebited;
  int? pendingTransactions;
  int? netFlow;

  Stats({
    this.totalTransactions,
    this.totalCredited,
    this.totalDebited,
    this.pendingTransactions,
    this.netFlow,
  });

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
    totalTransactions: json["total_transactions"],
    totalCredited: json["total_credited"],
    totalDebited: json["total_debited"],
    pendingTransactions: json["pending_transactions"],
    netFlow: json["net_flow"],
  );

  Map<String, dynamic> toJson() => {
    "total_transactions": totalTransactions,
    "total_credited": totalCredited,
    "total_debited": totalDebited,
    "pending_transactions": pendingTransactions,
    "net_flow": netFlow,
  };
}
