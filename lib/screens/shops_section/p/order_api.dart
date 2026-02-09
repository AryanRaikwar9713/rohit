import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/shops_section/model/user_order_history_model.dart';

void respPrinter(int st, String body) {
  if (st == 200 || st == 201) {
    Logger().i(jsonDecode(body));
  } else {
    if(body.isNotEmpty)
      {
        Logger().e('$st\n$body');
      }
  }
}

class OrderApi {

  Future<void> placeOrder({
    required int shopId,
    required String paymentMethod,
    required double shippingAmount,
    required double taxAmount,
    required double discountAmount,
    String? customerNote,
    required Map<String, dynamic> shippingAddress,
    required Map<String, dynamic> billingAddress,
    required List<Map<String, dynamic>> items,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(dynamic data) onSuccess,
  }) async
  {
    try {
      final uri = Uri.parse(
        "https://app.wamims.world/public/social/shopping/product_order.php",
      );

      final head = await DB().getHeaderForRow();
      final user = await DB().getUser();

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        "user_id":user?.id??0,
        "shop_id": shopId,
        "payment_method": paymentMethod,
        "shipping_amount": shippingAmount,
        "tax_amount": taxAmount,
        "discount_amount": discountAmount,
        "shipping_address": shippingAddress,
        "billing_address": billingAddress,
        "items": items,
      };

      // Add customer note if provided
      if (customerNote != null && customerNote.isNotEmpty) {
        requestBody["customer_note"] = customerNote;
      }

      final response = await http.post(
        uri,
        headers: {
          ...?head,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      respPrinter(response.statusCode, response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        onSuccess(body);
      } else {
        onFailure(response);
      }
    } catch (e) {
      onError(e.toString());
    }
  }



  //
  Future<void> getUserProductOrders({
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(UserOrderHistorytReponceModel data) onSuccess,
  }) async {
    try {

      final user = await DB().getUser();
      final url = Uri.parse(
        "https://app.wamims.world/public/social/shopping/product_order.php?user_id=${user?.id}",
      );

      final headers = await DB().getHeaderForRow();

      final response = await http.get(url, headers: headers ?? {});

      respPrinter(response.statusCode, response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        onSuccess(UserOrderHistorytReponceModel.fromJson(data));
      } else {
        onFailure(response);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

}
