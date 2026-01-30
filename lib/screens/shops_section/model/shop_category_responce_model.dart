// To parse this JSON data, do
//
//     final shopCategoryReponceModel = shopCategoryReponceModelFromJson(jsonString);

import 'dart:convert';

ShopCategoryReponceModel shopCategoryReponceModelFromJson(String str) => ShopCategoryReponceModel.fromJson(json.decode(str));

String shopCategoryReponceModelToJson(ShopCategoryReponceModel data) => json.encode(data.toJson());

class ShopCategoryReponceModel {
  bool? success;
  shotCategoryData? data;

  ShopCategoryReponceModel({
    this.success,
    this.data,
  });

  factory ShopCategoryReponceModel.fromJson(Map<String, dynamic> json) => ShopCategoryReponceModel(
    success: json["success"],
    data: json["data"] == null ? null : shotCategoryData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
  };
}

class shotCategoryData {
  List<ShopCategory>? categories;

  shotCategoryData({
    this.categories,
  });

  factory shotCategoryData.fromJson(Map<String, dynamic> json) => shotCategoryData(
    categories: json["categories"] == null ? [] : List<ShopCategory>.from(json["categories"]!.map((x) => ShopCategory.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "categories": categories == null ? [] : List<dynamic>.from(categories!.map((x) => x.toJson())),
  };
}

class ShopCategory {
  int? id;
  String? name;
  String? slug;
  String? description;
  String? icon;

  ShopCategory({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.icon,
  });

  factory ShopCategory.fromJson(Map<String, dynamic> json) => ShopCategory(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    description: json["description"],
    icon: json["icon"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "description": description,
    "icon": icon,
  };
}
