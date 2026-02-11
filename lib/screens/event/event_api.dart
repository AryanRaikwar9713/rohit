import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/event/get_event_responce_modle.dart';
import 'package:streamit_laravel/screens/shops_section/p/order_api.dart';

class Event {

  //
  Future<void> createEvent({
    required void Function(double) onProgress,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(int) onSuccess,
    required String eventTitle,
    required String eventType,
    required String description,
    required String startDate,
    required String endDate,
    required String resultDate,
    required String maxParticipants,
    required String entryFee,
    required String isFeatured,
    required List<String> eventRules,
    required String coverImage,
    required List<Map<String, String>> prizes,
  }) async
  {
    final url = Uri.parse(
      "https://app.wamims.world/public/social/shop/event_create.php",
    );

    final request = http.MultipartRequest("POST", url);

    final head = await DB().getHeaderForForm();
    request.headers.addAll(head ?? {});

    final user = await DB().getUser();

    final data = {
      "user_id": user?.id ?? 0,
      "event_title": eventTitle,
      "event_type": 'contest',
      // "event_type": eventType,
      "description": description,
      "start_date": startDate,
      "end_date": endDate,
      "result_date": resultDate,
      "max_participants": maxParticipants,
      "entry_fee": entryFee,
      "is_featured": isFeatured,
    };

    request.fields.addAll(data.map(
      (key, value) => MapEntry(key, value.toString()),
    ),);

    /// ------------ EVENT RULES ARRAY --------------
    for (int i = 0; i < eventRules.length; i++) {
      request.fields['event_rules[$i]'] = eventRules[i];
    }

    /// ------------ COVER IMAGE FILE --------------
    // video file
    final file = File(coverImage);
    final totalBytes = await file.length();

    var bytesSent = 0;

    final stream = http.ByteStream(file.openRead().transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          bytesSent += data.length;
          onProgress(bytesSent / totalBytes);
          sink.add(data);
        },
      ),
    ),);

    final multipartFile = http.MultipartFile(
      'cover_image',
      stream,
      totalBytes,
      filename: coverImage.split('/').last,
    );

    request.files.add(multipartFile);

    /// ------------ PRIZES ARRAY -------------------
    for (int i = 0; i < prizes.length; i++) {
      final prize = prizes[i];
      request.fields['prizes[$i][position]'] = prize['position'] ?? '';
      request.fields['prizes[$i][prize_type]'] = prize['prize_type'] ?? '';
      request.fields['prizes[$i][prize_title]'] = prize['prize_title'] ?? '';
      request.fields['prizes[$i][prize_description]'] =
          prize['prize_description'] ?? '';
      request.fields['prizes[$i][prize_value]'] = prize['prize_value'] ?? '';
      final productId = prize['product_id']?.toString();
      if (productId != null && productId.isNotEmpty) {
        request.fields['prizes[$i][product_id]'] = productId;
      }
    }

    /// ------------- SEND REQUEST ------------------
    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      print("akjkhsjkdf");

      respPrinter(response.statusCode, respStr);

      // return ;

      if (response.statusCode == 200) {

        try {
          final responseData = json.decode(respStr);
          final eventId = responseData['event_id'] ?? responseData['id'] ?? 0;
          onSuccess(eventId as int);
        } catch (e) {
          // If parsing fails, just return 0
          onSuccess(0);
        }
      } else {
        onFailure(http.Response(respStr,response.statusCode));
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  //
  Future<void> getEvents({
    int page = 0,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(GetEventsResponcModel data) onSuccess, // Change to your model
  }) async
  {
    try {
      final head = await DB().getHeaderForRow();
      final user = await DB().getUser();

      final String uri =
          "https://app.wamims.world/public/social/shop/get_events.php?user_id=${user?.id ?? 0}&page=$page&limit=10";

      final resp = await http.get(
        Uri.parse(uri),
        headers: head ?? {},
      );

      respPrinter(resp.statusCode, resp.body);

      // return ;

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        try {
          final d = jsonDecode(resp.body);
          onSuccess(GetEventsResponcModel.fromJson(d)); // replace `d` with model
        } catch (e) {
          onError("JSON Parse Error: $e");
        }
      } else {
        onFailure(resp);
      }
    } catch (e) {
      onError(e.toString());
    }
  }


  //
  Future<void> couponRedeem({
    required int shopId,
    required int eventId,
    required String couponCode,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(bool status, String message) onSuccess,
  }) async
  {
    try {
      const String uri =
          "https://app.wamims.world/public/social/shop/coupon_redeem.php";

      final head = await DB().getHeaderForRow();
      final user = await DB().getUser();

      final data = {
        "user_id": user?.id ?? 0,
        "shop_id": shopId,
        "event_id": eventId,
        "coupon_code": couponCode,
      };

      final resp = await http.post(
        Uri.parse(uri),
        headers: head ?? {},
        body: jsonEncode(data),
      );

      respPrinter(resp.statusCode, resp.body);
      // return ;

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final d = jsonDecode(resp.body);

        final bool status = d["status"] == true;
        final String msg = d["message"] ?? "";

        onSuccess(status, msg);
      } else {
        onFailure(resp);
      }
    } catch (e) {
      onError(e.toString());
    }
  }





}
