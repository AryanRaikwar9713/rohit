// To parse this JSON data, do
//
//     final productCategoryReponceModel = productCategoryReponceModelFromJson(jsonString);

import 'dart:convert';

ProductCategoryReponceModel productCategoryReponceModelFromJson(String str) => ProductCategoryReponceModel.fromJson(json.decode(str));

String productCategoryReponceModelToJson(ProductCategoryReponceModel data) => json.encode(data.toJson());

class ProductCategoryReponceModel {
  bool? success;
  ProductData? data;

  ProductCategoryReponceModel({
    this.success,
    this.data,
  });

  factory ProductCategoryReponceModel.fromJson(Map<String, dynamic> json) => ProductCategoryReponceModel(
    success: json["success"],
    data: json["data"] == null ? null : ProductData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
  };
}

class ProductData {
  List<ProductCategory>? categories;

  ProductData({
    this.categories,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) => ProductData(
    categories: json["categories"] == null ? [] : List<ProductCategory>.from(json["categories"]!.map((x) => ProductCategory.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "categories": categories == null ? [] : List<dynamic>.from(categories!.map((x) => x.toJson())),
  };
}

class ProductCategory {
  int? id;
  String? name;
  String? slug;
  String? description;
  String? icon;

  ProductCategory({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.icon,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) => ProductCategory(
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
