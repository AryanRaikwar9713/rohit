// To parse this JSON data, do
//
//     final boltTrasectionApiResponce = boltTrasectionApiResponceFromJson(jsonString);

import 'dart:convert';

BoltTrasectionApiResponce boltTrasectionApiResponceFromJson(String str) => BoltTrasectionApiResponce.fromJson(json.decode(str));

String boltTrasectionApiResponceToJson(BoltTrasectionApiResponce data) => json.encode(data.toJson());

class BoltTrasectionApiResponce {
  bool? success;
  String? message;
  Data? data;
  DateTime? timestamp;

  BoltTrasectionApiResponce({
    this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory BoltTrasectionApiResponce.fromJson(Map<String, dynamic> json) => BoltTrasectionApiResponce(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    timestamp: json["timestamp"] == null ? null : DateTime.parse(json["timestamp"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
    "timestamp": timestamp?.toIso8601String(),
  };
}

class Data {
  List<BolTransection>? transactions;
  Pagination? pagination;

  Data({
    this.transactions,
    this.pagination,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    transactions: json["transactions"] == null ? [] : List<BolTransection>.from(json["transactions"]!.map((x) => BolTransection.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "transactions": transactions == null ? [] : List<dynamic>.from(transactions!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class Pagination {
  int? currentPage;
  int? totalPages;
  int? totalTransactions;
  int? perPage;
  bool? hasNext;
  bool? hasPrev;

  Pagination({
    this.currentPage,
    this.totalPages,
    this.totalTransactions,
    this.perPage,
    this.hasNext,
    this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    totalPages: json["total_pages"],
    totalTransactions: json["total_transactions"],
    perPage: json["per_page"],
    hasNext: json["has_next"],
    hasPrev: json["has_prev"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "total_pages": totalPages,
    "total_transactions": totalTransactions,
    "per_page": perPage,
    "has_next": hasNext,
    "has_prev": hasPrev,
  };
}

class BolTransection {
  int? id;
  String? actionType;
  double? boltAmount;
  String? contentType;
  int? contentId;
  String? description;
  DateTime? createdAt;
  String? formattedDate;

  BolTransection({
    this.id,
    this.actionType,
    this.boltAmount,
    this.contentType,
    this.contentId,
    this.description,
    this.createdAt,
    this.formattedDate,
  });

  factory BolTransection.fromJson(Map<String, dynamic> json) => BolTransection(
    id: json["id"],
    actionType: json["action_type"],
    boltAmount: json["bolt_amount"]?.toDouble(),
    contentType: json["content_type"],
    contentId: json["content_id"],
    description: json["description"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    formattedDate: json["formatted_date"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "action_type": actionType,
    "bolt_amount": boltAmount,
    "content_type": contentType,
    "content_id": contentId,
    "description": description,
    "created_at": createdAt?.toIso8601String(),
    "formatted_date": formattedDate,
  };
}
