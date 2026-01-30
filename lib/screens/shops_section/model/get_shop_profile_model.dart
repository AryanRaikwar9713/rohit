// To parse this JSON data, do
//
//     final shopProfileReponceModel = shopProfileReponceModelFromJson(jsonString);

import 'dart:convert';

import 'package:streamit_laravel/screens/shops_section/model/shop_category_responce_model.dart';

ShopProfileResponceModel shopProfileReponceModelFromJson(String str) => ShopProfileResponceModel.fromJson(json.decode(str));

String shopProfileReponceModelToJson(ShopProfileResponceModel data) => json.encode(data.toJson());

class ShopProfileResponceModel {
  bool? success;
  bool? hasShop;
  String? shopStatus;
  ShopData? shopData;
  String? message;

  ShopProfileResponceModel({
    this.success,
    this.hasShop,
    this.shopStatus,
    this.shopData,
    this.message,
  });

  factory ShopProfileResponceModel.fromJson(Map<String, dynamic> json) => ShopProfileResponceModel(
    success: json["success"],
    hasShop: json["has_shop"],
    shopStatus: json["shop_status"],
    shopData: json["shop_data"] == null ? null : ShopData.fromJson(json["shop_data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "has_shop": hasShop,
    "shop_status": shopStatus,
    "shop_data": shopData?.toJson(),
    "message": message,
  };
}

class ShopData {
  int? id;
  String? name;
  String? slug;
  String? description;
  String? logo;
  String? coverImage;
  Address? address;
  Contact? contact;
  Location? location;
  ShopCategory? category;
  String? status;
  bool? isFeatured;
  dynamic verifiedAt;
  DateTime? createdAt;
  DateTime? updatedAt;

  ShopData({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.logo,
    this.coverImage,
    this.address,
    this.contact,
    this.location,
    this.category,
    this.status,
    this.isFeatured,
    this.verifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ShopData.fromJson(Map<String, dynamic> json) => ShopData(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    description: json["description"],
    logo: json["logo"],
    coverImage: json["cover_image"],
    address: json["address"] == null ? null : Address.fromJson(json["address"]),
    contact: json["contact"] == null ? null : Contact.fromJson(json["contact"]),
    location: json["location"] == null ? null : Location.fromJson(json["location"]),
    category: json["category"] == null ? null : ShopCategory.fromJson(json["category"]),
    status: json["status"],
    isFeatured: json["is_featured"],
    verifiedAt: json["verified_at"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "description": description,
    "logo": logo,
    "cover_image": coverImage,
    "address": address?.toJson(),
    "contact": contact?.toJson(),
    "location": location?.toJson(),
    "category": category?.toJson(),
    "status": status,
    "is_featured": isFeatured,
    "verified_at": verifiedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class Address {
  String? line1;
  String? line2;
  String? city;
  String? state;
  String? country;
  String? postalCode;
  dynamic latitude;
  dynamic longitude;

  Address({
    this.line1,
    this.line2,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.latitude,
    this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    line1: json["line_1"],
    line2: json["line_2"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
    postalCode: json["postal_code"],
    latitude: json["latitude"],
    longitude: json["longitude"],
  );

  Map<String, dynamic> toJson() => {
    "line_1": line1,
    "line_2": line2,
    "city": city,
    "state": state,
    "country": country,
    "postal_code": postalCode,
    "latitude": latitude,
    "longitude": longitude,
  };
}


class Contact {
  String? phone;
  String? email;
  String? website;

  Contact({
    this.phone,
    this.email,
    this.website,
  });

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
    phone: json["phone"],
    email: json["email"],
    website: json["website"],
  );

  Map<String, dynamic> toJson() => {
    "phone": phone,
    "email": email,
    "website": website,
  };
}

class Location {
  String? city;
  String? state;
  String? country;
  String? postalCode;
  Coordinates? coordinates;

  Location({
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    city: json["city"],
    state: json["state"],
    country: json["country"],
    postalCode: json["postal_code"],
    coordinates: json["coordinates"] == null ? null : Coordinates.fromJson(json["coordinates"]),
  );

  Map<String, dynamic> toJson() => {
    "city": city,
    "state": state,
    "country": country,
    "postal_code": postalCode,
    "coordinates": coordinates?.toJson(),
  };
}

class Coordinates {
  dynamic latitude;
  dynamic longitude;

  Coordinates({
    this.latitude,
    this.longitude,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) => Coordinates(
    latitude: json["latitude"],
    longitude: json["longitude"],
  );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
  };
}
