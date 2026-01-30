// To parse this JSON data, do
//
//     final getEventsResponcModel = getEventsResponcModelFromJson(jsonString);

import 'dart:convert';

GetEventsResponcModel getEventsResponcModelFromJson(String str) => GetEventsResponcModel.fromJson(json.decode(str));

String getEventsResponcModelToJson(GetEventsResponcModel data) => json.encode(data.toJson());

class GetEventsResponcModel {
  String? status;
  String? message;
  List<ShopEvents>? data;
  Pagination? pagination;
  EventInfo? eventInfo;

  GetEventsResponcModel({
    this.status,
    this.message,
    this.data,
    this.pagination,
    this.eventInfo,
  });

  factory GetEventsResponcModel.fromJson(Map<String, dynamic> json) => GetEventsResponcModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<ShopEvents>.from(json["data"]!.map((x) => ShopEvents.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
    eventInfo: json["event_info"] == null ? null : EventInfo.fromJson(json["event_info"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
    "event_info": eventInfo?.toJson(),
  };
}

class ShopEvents {
  int? id;
  int? shopId;
  int? userId;
  String? title;
  String? description;
  String? eventType;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? resultDate;
  String? status;
  int? maxParticipants;
  int? currentParticipants;
  String? entryFee;
  String? eventRules;
  String? coverImage;
  String? cover_image_url;
  int? isFeatured;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? shopName;
  String? shopLogo;
  String? shopOwnerName;

  List<Prize>? prizes;

  ShopEvents({
    this.id,
    this.shopId,
    this.userId,
    this.title,
    this.description,
    this.eventType,
    this.startDate,
    this.endDate,
    this.resultDate,
    this.status,
    this.maxParticipants,
    this.currentParticipants,
    this.entryFee,
    this.eventRules,
    this.coverImage,
    this.isFeatured,
    this.createdAt,
    this.updatedAt,
    this.shopName,
    this.shopLogo,
    this.shopOwnerName,
    this.prizes,
    this.cover_image_url,
  });

  factory ShopEvents.fromJson(Map<String, dynamic> json) => ShopEvents(
    id: json["id"],
    shopId: json["shop_id"],
    userId: json["user_id"],
    title: json["title"],
    description: json["description"],
    eventType: json["event_type"],
    startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
    endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
    resultDate: json["result_date"] == null ? null : DateTime.parse(json["result_date"]),
    status: json["status"],
    maxParticipants: json["max_participants"],
    currentParticipants: json["current_participants"],
    entryFee: json["entry_fee"],
    eventRules: json["event_rules"],
    coverImage: json["cover_image"],
    isFeatured: json["is_featured"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    shopName: json["shop_name"],
    shopLogo: json["shop_logo"],
    shopOwnerName: json["shop_owner_name"],
    cover_image_url: json["cover_image_url"],
    prizes: json["prizes"] == null ? [] : List<Prize>.from(json["prizes"]!.map((x) => Prize.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "shop_id": shopId,
    "user_id": userId,
    "title": title,
    "description": description,
    "event_type": eventType,
    "start_date": startDate?.toIso8601String(),
    "end_date": endDate?.toIso8601String(),
    "result_date": resultDate?.toIso8601String(),
    "status": status,
    "max_participants": maxParticipants,
    "current_participants": currentParticipants,
    "entry_fee": entryFee,
    "event_rules": eventRules,
    "cover_image": coverImage,
    "cover_image_url": cover_image_url,
    "is_featured": isFeatured,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "shop_name": shopName,
    "shop_logo": shopLogo,
    "shop_owner_name": shopOwnerName,
    "prizes": prizes == null ? [] : List<dynamic>.from(prizes!.map((x) => x.toJson())),
  };
}

class Prize {
  int? id;
  int? eventId;
  int? position;
  String? prizeType;
  String? prizeTitle;
  String? prizeDescription;
  String? prizeValue;
  int? productId;
  String? couponCode;
  int? pointsValue;
  dynamic imageUrl;
  DateTime? createdAt;

  Prize({
    this.id,
    this.eventId,
    this.position,
    this.prizeType,
    this.prizeTitle,
    this.prizeDescription,
    this.prizeValue,
    this.productId,
    this.couponCode,
    this.pointsValue,
    this.imageUrl,
    this.createdAt,
  });

  factory Prize.fromJson(Map<String, dynamic> json) => Prize(
    id: json["id"],
    eventId: json["event_id"],
    position: json["position"],
    prizeType: json["prize_type"],
    prizeTitle: json["prize_title"],
    prizeDescription: json["prize_description"],
    prizeValue: json["prize_value"],
    productId: json["product_id"],
    couponCode: json["coupon_code"],
    pointsValue: json["points_value"],
    imageUrl: json["image_url"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "event_id": eventId,
    "position": position,
    "prize_type": prizeType,
    "prize_title": prizeTitle,
    "prize_description": prizeDescription,
    "prize_value": prizeValue,
    "product_id": productId,
    "coupon_code": couponCode,
    "points_value": pointsValue,
    "image_url": imageUrl,
    "created_at": createdAt?.toIso8601String(),
  };
}

class EventInfo {
  List<String>? validEventTypes;
  List<String>? validPrizeTypes;
  List<String>? statusTypes;

  EventInfo({
    this.validEventTypes,
    this.validPrizeTypes,
    this.statusTypes,
  });

  factory EventInfo.fromJson(Map<String, dynamic> json) => EventInfo(
    validEventTypes: json["valid_event_types"] == null ? [] : List<String>.from(json["valid_event_types"]!.map((x) => x)),
    validPrizeTypes: json["valid_prize_types"] == null ? [] : List<String>.from(json["valid_prize_types"]!.map((x) => x)),
    statusTypes: json["status_types"] == null ? [] : List<String>.from(json["status_types"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "valid_event_types": validEventTypes == null ? [] : List<dynamic>.from(validEventTypes!.map((x) => x)),
    "valid_prize_types": validPrizeTypes == null ? [] : List<dynamic>.from(validPrizeTypes!.map((x) => x)),
    "status_types": statusTypes == null ? [] : List<dynamic>.from(statusTypes!.map((x) => x)),
  };
}

class Pagination {
  int? currentPage;
  int? perPage;
  int? totalEvents;
  int? totalPages;
  bool? hasNextPage;
  bool? hasPrevPage;

  Pagination({
    this.currentPage,
    this.perPage,
    this.totalEvents,
    this.totalPages,
    this.hasNextPage,
    this.hasPrevPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    perPage: json["per_page"],
    totalEvents: json["total_events"],
    totalPages: json["total_pages"],
    hasNextPage: json["has_next_page"],
    hasPrevPage: json["has_prev_page"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "per_page": perPage,
    "total_events": totalEvents,
    "total_pages": totalPages,
    "has_next_page": hasNextPage,
    "has_prev_page": hasPrevPage,
  };
}
