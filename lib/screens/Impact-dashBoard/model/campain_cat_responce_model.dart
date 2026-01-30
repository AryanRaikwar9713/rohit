// To parse this JSON data, do
//
//     final campainCategoryResponce = campainCategoryResponceFromJson(jsonString);

import 'dart:convert';

CampainCategoryResponce campainCategoryResponceFromJson(String str) => CampainCategoryResponce.fromJson(json.decode(str));

String campainCategoryResponceToJson(CampainCategoryResponce data) => json.encode(data.toJson());

class CampainCategoryResponce {
  bool? success;
  String? message;
  List<Datum>? data;
  int? timestamp;

  CampainCategoryResponce({
    this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory CampainCategoryResponce.fromJson(Map<String, dynamic> json) => CampainCategoryResponce(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    timestamp: json["timestamp"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "timestamp": timestamp,
  };
}

class Datum {
  int? id;
  String? name;
  String? description;
  String? icon;

  Datum({
    this.id,
    this.name,
    this.description,
    this.icon,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    icon: json["icon"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "icon": icon,
  };
}
