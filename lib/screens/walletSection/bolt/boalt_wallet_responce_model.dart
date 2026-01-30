// To parse this JSON data, do
//
//     final boltWalletApiResponce = boltWalletApiResponceFromJson(jsonString);

import 'dart:convert';

BoltWalletApiResponce boltWalletApiResponceFromJson(String str) => BoltWalletApiResponce.fromJson(json.decode(str));

String boltWalletApiResponceToJson(BoltWalletApiResponce data) => json.encode(data.toJson());

class BoltWalletApiResponce {
  bool? success;
  String? message;
  BoltWalletData? data;
  DateTime? timestamp;

  BoltWalletApiResponce({
    this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory BoltWalletApiResponce.fromJson(Map<String, dynamic> json) => BoltWalletApiResponce(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : BoltWalletData.fromJson(json["data"]),
    timestamp: json["timestamp"] == null ? null : DateTime.parse(json["timestamp"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
    "timestamp": timestamp?.toIso8601String(),
  };
}

class BoltWalletData {
  UserInfo? userInfo;
  Wallet? wallet;
  Earnings? earnings;
  List<RecentTransaction>? recentTransactions;
  List<MonthlyGraph>? monthlyGraph;
  Stats? stats;

  BoltWalletData({
    this.userInfo,
    this.wallet,
    this.earnings,
    this.recentTransactions,
    this.monthlyGraph,
    this.stats,
  });

  factory BoltWalletData.fromJson(Map<String, dynamic> json) => BoltWalletData(
    userInfo: json["user_info"] == null ? null : UserInfo.fromJson(json["user_info"]),
    wallet: json["wallet"] == null ? null : Wallet.fromJson(json["wallet"]),
    earnings: json["earnings"] == null ? null : Earnings.fromJson(json["earnings"]),
    recentTransactions: json["recent_transactions"] == null ? [] : List<RecentTransaction>.from(json["recent_transactions"]!.map((x) => RecentTransaction.fromJson(x))),
    monthlyGraph: json["monthly_graph"] == null ? [] : List<MonthlyGraph>.from(json["monthly_graph"]!.map((x) => MonthlyGraph.fromJson(x))),
    stats: json["stats"] == null ? null : Stats.fromJson(json["stats"]),
  );

  Map<String, dynamic> toJson() => {
    "user_info": userInfo?.toJson(),
    "wallet": wallet?.toJson(),
    "earnings": earnings?.toJson(),
    "recent_transactions": recentTransactions == null ? [] : List<dynamic>.from(recentTransactions!.map((x) => x.toJson())),
    "monthly_graph": monthlyGraph == null ? [] : List<dynamic>.from(monthlyGraph!.map((x) => x.toJson())),
    "stats": stats?.toJson(),
  };
}

class Earnings {
  double? today;
  double? thisMonth;
  double? total;

  Earnings({
    this.today,
    this.thisMonth,
    this.total,
  });

  factory Earnings.fromJson(Map<String, dynamic> json) => Earnings(
    today: double.parse((json["today"]??'0').toString()),
    thisMonth: json["this_month"]?.toDouble(),
    total: json["total"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "today": today,
    "this_month": thisMonth,
    "total": total,
  };
}

class MonthlyGraph {
  String? month;
  double? bolts;
  double? inrValue;

  MonthlyGraph({
    this.month,
    this.bolts,
    this.inrValue,
  });

  factory MonthlyGraph.fromJson(Map<String, dynamic> json) => MonthlyGraph(
    month: json["month"],
    bolts: json["bolts"]?.toDouble(),
    inrValue: json["inr_value"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "month": month,
    "bolts": bolts,
    "inr_value": inrValue,
  };
}

class RecentTransaction {
  String? actionType;
  double? boltAmount;
  String? contentType;
  String? description;
  DateTime? createdAt;
  String? timeAgo;

  RecentTransaction({
    this.actionType,
    this.boltAmount,
    this.contentType,
    this.description,
    this.createdAt,
    this.timeAgo,
  });

  factory RecentTransaction.fromJson(Map<String, dynamic> json) => RecentTransaction(
    actionType: json["action_type"],
    boltAmount: json["bolt_amount"]?.toDouble(),
    contentType: json["content_type"],
    description: json["description"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    timeAgo: json["time_ago"],
  );

  Map<String, dynamic> toJson() => {
    "action_type": actionType,
    "bolt_amount": boltAmount,
    "content_type": contentType,
    "description": description,
    "created_at": createdAt?.toIso8601String(),
    "time_ago": timeAgo,
  };
}

class Stats {
  int? dailyLimitUsed;
  int? dailyLimitRemaining;

  Stats({
    this.dailyLimitUsed,
    this.dailyLimitRemaining,
  });

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
    dailyLimitUsed: json["daily_limit_used"],
    dailyLimitRemaining: json["daily_limit_remaining"],
  );

  Map<String, dynamic> toJson() => {
    "daily_limit_used": dailyLimitUsed,
    "daily_limit_remaining": dailyLimitRemaining,
  };
}

class UserInfo {
  int? id;
  String? username;
  String? fullName;
  String? email;
  String? avatar;

  UserInfo({
    this.id,
    this.username,
    this.fullName,
    this.email,
    this.avatar,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
    id: json["id"],
    username: json["username"],
    fullName: json["full_name"],
    email: json["email"],
    avatar: json["avatar"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "full_name": fullName,
    "email": email,
    "avatar": avatar,
  };
}

class Wallet {
  double? totalBolt;
  String? boltSymbol;
  int? conversionRate;
  double? inrValue;
  String? displayValue;

  Wallet({
    this.totalBolt,
    this.boltSymbol,
    this.conversionRate,
    this.inrValue,
    this.displayValue,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    totalBolt: json["total_bolt"]?.toDouble(),
    boltSymbol: json["bolt_symbol"],
    conversionRate: json["conversion_rate"],
    inrValue: json["inr_value"]?.toDouble(),
    displayValue: json["display_value"],
  );

  Map<String, dynamic> toJson() => {
    "total_bolt": totalBolt,
    "bolt_symbol": boltSymbol,
    "conversion_rate": conversionRate,
    "inr_value": inrValue,
    "display_value": displayValue,
  };
}
