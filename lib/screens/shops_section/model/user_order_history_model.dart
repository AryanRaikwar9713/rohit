// To parse this JSON data, do
//
//     final userOrderHistorytReponceModel = userOrderHistorytReponceModelFromJson(jsonString);

import 'dart:convert';

UserOrderHistorytReponceModel userOrderHistorytReponceModelFromJson(String str) => UserOrderHistorytReponceModel.fromJson(json.decode(str));

String userOrderHistorytReponceModelToJson(UserOrderHistorytReponceModel data) => json.encode(data.toJson());

class UserOrderHistorytReponceModel {
  bool? success;
  Data? data;

  UserOrderHistorytReponceModel({
    this.success,
    this.data,
  });

  factory UserOrderHistorytReponceModel.fromJson(Map<String, dynamic> json) => UserOrderHistorytReponceModel(
    success: json["success"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
  };
}

class Data {
  List<UserOrder>? orders;
  int? totalOrders;

  Data({
    this.orders,
    this.totalOrders,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    orders: json["orders"] == null ? [] : List<UserOrder>.from(json["orders"]!.map((x) => UserOrder.fromJson(x))),
    totalOrders: json["total_orders"],
  );

  Map<String, dynamic> toJson() => {
    "orders": orders == null ? [] : List<dynamic>.from(orders!.map((x) => x.toJson())),
    "total_orders": totalOrders,
  };
}

class UserOrder {
  int? id;
  String? orderNumber;
  int? userId;
  int? shopId;
  String? totalAmount;
  String? shippingAmount;
  String? taxAmount;
  String? discountAmount;
  String? finalAmount;
  String? status;
  String? paymentStatus;
  String? paymentMethod;
  IngAddress? shippingAddress;
  IngAddress? billingAddress;
  String? customerNote;
  dynamic adminNote;
  dynamic estimatedDelivery;
  dynamic deliveredAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? shopName;
  String? shopLogo;
  int? itemsCount;

  UserOrder({
    this.id,
    this.orderNumber,
    this.userId,
    this.shopId,
    this.totalAmount,
    this.shippingAmount,
    this.taxAmount,
    this.discountAmount,
    this.finalAmount,
    this.status,
    this.paymentStatus,
    this.paymentMethod,
    this.shippingAddress,
    this.billingAddress,
    this.customerNote,
    this.adminNote,
    this.estimatedDelivery,
    this.deliveredAt,
    this.createdAt,
    this.updatedAt,
    this.shopName,
    this.shopLogo,
    this.itemsCount,
  });

  factory UserOrder.fromJson(Map<String, dynamic> json) => UserOrder(
    id: json["id"],
    orderNumber: json["order_number"],
    userId: json["user_id"],
    shopId: json["shop_id"],
    totalAmount: json["total_amount"],
    shippingAmount: json["shipping_amount"],
    taxAmount: json["tax_amount"],
    discountAmount: json["discount_amount"],
    finalAmount: json["final_amount"],
    status: json["status"],
    paymentStatus: json["payment_status"],
    paymentMethod: json["payment_method"],
    shippingAddress: json["shipping_address"] == null ? null : IngAddress.fromJson(json["shipping_address"]),
    billingAddress: json["billing_address"] == null ? null : IngAddress.fromJson(json["billing_address"]),
    customerNote: json["customer_note"],
    adminNote: json["admin_note"],
    estimatedDelivery: json["estimated_delivery"],
    deliveredAt: json["delivered_at"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    shopName: json["shop_name"],
    shopLogo: json["shop_logo"],
    itemsCount: json["items_count"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_number": orderNumber,
    "user_id": userId,
    "shop_id": shopId,
    "total_amount": totalAmount,
    "shipping_amount": shippingAmount,
    "tax_amount": taxAmount,
    "discount_amount": discountAmount,
    "final_amount": finalAmount,
    "status": status,
    "payment_status": paymentStatus,
    "payment_method": paymentMethod,
    "shipping_address": shippingAddress?.toJson(),
    "billing_address": billingAddress?.toJson(),
    "customer_note": customerNote,
    "admin_note": adminNote,
    "estimated_delivery": estimatedDelivery,
    "delivered_at": deliveredAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "shop_name": shopName,
    "shop_logo": shopLogo,
    "items_count": itemsCount,
  };
}

class IngAddress {
  String? city;
  String? name;
  String? state;
  String? country;
  String? postalCode;
  String? addressLine1;
  String? phone;
  String? addressLine2;

  IngAddress({
    this.city,
    this.name,
    this.state,
    this.country,
    this.postalCode,
    this.addressLine1,
    this.phone,
    this.addressLine2,
  });

  factory IngAddress.fromJson(Map<String, dynamic> json) => IngAddress(
    city: json["city"],
    name: json["name"],
    state: json["state"],
    country: json["country"],
    postalCode: json["postal_code"],
    addressLine1: json["address_line_1"],
    phone: json["phone"],
    addressLine2: json["address_line_2"],
  );

  Map<String, dynamic> toJson() => {
    "city": city,
    "name": name,
    "state": state,
    "country": country,
    "postal_code": postalCode,
    "address_line_1": addressLine1,
    "phone": phone,
    "address_line_2": addressLine2,
  };
}
