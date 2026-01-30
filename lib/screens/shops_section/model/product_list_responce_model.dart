// To parse this JSON data, do
//
//     final productListReponceModel = productListReponceModelFromJson(jsonString);

import 'dart:convert';

ProductListReponceModel productListReponceModelFromJson(String str) => ProductListReponceModel.fromJson(json.decode(str));

String productListReponceModelToJson(ProductListReponceModel data) => json.encode(data.toJson());

class ProductListReponceModel {
  bool? success;
  ProductListData? data;

  ProductListReponceModel({
    this.success,
    this.data,
  });

  factory ProductListReponceModel.fromJson(Map<String, dynamic> json) => ProductListReponceModel(
    success: json["success"],
    data: json["data"] == null ? null : ProductListData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
  };
}

class ProductListData {
  List<Product>? products;
  Pagination? pagination;
  Filters? filters;
  List<Shop>? shops;

  ProductListData({
    this.products,
    this.pagination,
    this.filters,
    this.shops,
  });

  factory ProductListData.fromJson(Map<String, dynamic> json) => ProductListData(
    products: json["products"] == null ? [] : List<Product>.from(json["products"]!.map((x) => Product.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
    filters: json["filters"] == null ? null : Filters.fromJson(json["filters"]),
    shops: json["shops"] == null ? [] : List<Shop>.from(json["shops"]!.map((x) => Shop.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "products": products == null ? [] : List<dynamic>.from(products!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
    "filters": filters?.toJson(),
  };
}

class Filters {
  List<Category>? categories;
  List<SortOption>? sortOptions;

  Filters({
    this.categories,
    this.sortOptions,
  });

  factory Filters.fromJson(Map<String, dynamic> json) => Filters(
    categories: json["categories"] == null ? [] : List<Category>.from(json["categories"]!.map((x) => Category.fromJson(x))),
    sortOptions: json["sort_options"] == null ? [] : List<SortOption>.from(json["sort_options"]!.map((x) => SortOption.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "categories": categories == null ? [] : List<dynamic>.from(categories!.map((x) => x.toJson())),
    "sort_options": sortOptions == null ? [] : List<dynamic>.from(sortOptions!.map((x) => x.toJson())),
  };
}

class Category {
  int? id;
  String? name;

  Category({
    this.id,
    this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

class SortOption {
  String? value;
  String? label;

  SortOption({
    this.value,
    this.label,
  });

  factory SortOption.fromJson(Map<String, dynamic> json) => SortOption(
    value: json["value"],
    label: json["label"],
  );

  Map<String, dynamic> toJson() => {
    "value": value,
    "label": label,
  };
}

class Pagination {
  int? currentPage;
  int? perPage;
  int? totalItems;
  int? totalPages;
  bool? hasNext;
  bool? hasPrev;

  Pagination({
    this.currentPage,
    this.perPage,
    this.totalItems,
    this.totalPages,
    this.hasNext,
    this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    perPage: json["per_page"],
    totalItems: json["total_items"],
    totalPages: json["total_pages"],
    hasNext: json["has_next"],
    hasPrev: json["has_prev"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "per_page": perPage,
    "total_items": totalItems,
    "total_pages": totalPages,
    "has_next": hasNext,
    "has_prev": hasPrev,
  };
}

class Product {
  int? id;
  String? name;
  String? slug;
  String? description;
  String? shortDescription;
  double? price;
  double? comparePrice;
  double? costPrice;
  String? sku;
  String? barcode;
  int? quantity;
  bool? trackQuantity;
  bool? allowBackorders;
  double? weight;
  dynamic dimensions;
  String? featuredImage;
  List<String>? imageGallery;
  bool? isFeatured;
  bool? isActive;
  bool? isDigital;
  List<dynamic>? downloadFiles;
  List<String>? tags;
  int? viewsCount;
  int? salesCount;
  Shop? shop;
  Category? category;
  List<Variant>? variants;
  DateTime? createdAt;
  DateTime? updatedAt;

  Product({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.shortDescription,
    this.price,
    this.comparePrice,
    this.costPrice,
    this.sku,
    this.barcode,
    this.quantity,
    this.trackQuantity,
    this.allowBackorders,
    this.weight,
    this.dimensions,
    this.featuredImage,
    this.imageGallery,
    this.isFeatured,
    this.isActive,
    this.isDigital,
    this.downloadFiles,
    this.tags,
    this.viewsCount,
    this.salesCount,
    this.shop,
    this.category,
    this.variants,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    description: json["description"],
    shortDescription: json["short_description"],
    price: json["price"]?.toDouble(),
    comparePrice: json["compare_price"]?.toDouble(),
    costPrice: json["cost_price"]?.toDouble(),
    sku: json["sku"],
    barcode: json["barcode"],
    quantity: json["quantity"],
    trackQuantity: json["track_quantity"],
    allowBackorders: json["allow_backorders"],
    weight: json["weight"]?.toDouble(),
    dimensions: json["dimensions"],
    featuredImage: json["featured_image"],
    imageGallery: json["image_gallery"] == null ? [] : List<String>.from(json["image_gallery"]!.map((x) => x)),
    isFeatured: json["is_featured"],
    isActive: json["is_active"],
    isDigital: json["is_digital"],
    downloadFiles: json["download_files"] == null ? [] : List<dynamic>.from(json["download_files"]!.map((x) => x)),
    tags: json["tags"] == null ? [] : List<String>.from(json["tags"]!.map((x) => x)),
    viewsCount: json["views_count"],
    salesCount: json["sales_count"],
    shop: json["shop"] == null ? null : Shop.fromJson(json["shop"]),
    category: json["category"] == null ? null : Category.fromJson(json["category"]),
    variants: json["variants"] == null ? [] : List<Variant>.from(json["variants"]!.map((x) => Variant.fromJson(x))),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "description": description,
    "short_description": shortDescription,
    "price": price,
    "compare_price": comparePrice,
    "cost_price": costPrice,
    "sku": sku,
    "barcode": barcode,
    "quantity": quantity,
    "track_quantity": trackQuantity,
    "allow_backorders": allowBackorders,
    "weight": weight,
    "dimensions": dimensions,
    "featured_image": featuredImage,
    "image_gallery": imageGallery == null ? [] : List<dynamic>.from(imageGallery!.map((x) => x)),
    "is_featured": isFeatured,
    "is_active": isActive,
    "is_digital": isDigital,
    "download_files": downloadFiles == null ? [] : List<dynamic>.from(downloadFiles!.map((x) => x)),
    "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
    "views_count": viewsCount,
    "sales_count": salesCount,
    "shop": shop?.toJson(),
    "category": category?.toJson(),
    "variants": variants == null ? [] : List<dynamic>.from(variants!.map((x) => x.toJson())),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class DimensionsClass {
  int? width;
  int? height;
  int? length;

  DimensionsClass({
    this.width,
    this.height,
    this.length,
  });

  factory DimensionsClass.fromJson(Map<String, dynamic> json) => DimensionsClass(
    width: json["width"],
    height: json["height"],
    length: json["length"],
  );

  Map<String, dynamic> toJson() => {
    "width": width,
    "height": height,
    "length": length,
  };
}

class Shop {
  int? id;
  String? name;
  String? slug;
  String? logo;
  String? status;

  Shop({
    this.id,
    this.name,
    this.slug,
    this.logo,
    this.status,
  });

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    logo: json["logo"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "logo": logo,
    "status": status,
  };
}

class Variant {
  int? id;
  String? name;
  double? price;
  int? comparePrice;
  int? costPrice;
  String? sku;
  String? barcode;
  int? quantity;
  int? weight;
  String? image;
  Options? options;
  bool? isDefault;

  Variant({
    this.id,
    this.name,
    this.price,
    this.comparePrice,
    this.costPrice,
    this.sku,
    this.barcode,
    this.quantity,
    this.weight,
    this.image,
    this.options,
    this.isDefault,
  });

  factory Variant.fromJson(Map<String, dynamic> json) => Variant(
    id: json["id"],
    name: json["name"],
    price: json["price"]?.toDouble(),
    comparePrice: json["compare_price"],
    costPrice: json["cost_price"],
    sku: json["sku"],
    barcode: json["barcode"],
    quantity: json["quantity"],
    weight: json["weight"],
    image: json["image"],
    options: json["options"] == null ? null : Options.fromJson(json["options"]),
    isDefault: json["is_default"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "price": price,
    "compare_price": comparePrice,
    "cost_price": costPrice,
    "sku": sku,
    "barcode": barcode,
    "quantity": quantity,
    "weight": weight,
    "image": image,
    "options": options?.toJson(),
    "is_default": isDefault,
  };
}

class Options {
  String? size;
  String? color;

  Options({
    this.size,
    this.color,
  });

  factory Options.fromJson(Map<String, dynamic> json) => Options(
    size: json["size"],
    color: json["color"],
  );

  Map<String, dynamic> toJson() => {
    "size": size,
    "color": color,
  };
}
