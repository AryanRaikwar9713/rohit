import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/auth/model/login_response.dart';
import 'package:streamit_laravel/screens/shops_section/model/get_shop_profile_model.dart';
import 'package:streamit_laravel/screens/shops_section/model/shop_category_responce_model.dart';

void respPrinter(int st, String body) {
  if (st == 200 || st == 201) {
    Logger().i(jsonDecode(body));
  } else {
    Logger().e('$st\n$body');
  }
}

class ShopApi {
  /// Get shop profile
  Future<void> getShopProfile({
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(ShopProfileResponceModel) onSuccess,
  }) async {
    try {
      final head = await DB().getHeaderForRow();
      final UserData? userData = await DB().getUser();

      final String uri =
          'https://app.wamims.world/public/social/shopping/shop_register.php?user_id=${userData?.id ?? 0}';

      final resp = await http.get(Uri.parse(uri), headers: head ?? {});

      respPrinter(resp.statusCode, resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final d = jsonDecode(resp.body);
        final s = ShopProfileResponceModel.fromJson(d);
        onSuccess(s);
      } else {
        onFailure(resp);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Register shop
  Future<void> registerShop({
    required String shopName,
    required String description,
    required int categoryId,
    required String city,
    required String country,
    required String phone,
    required String email,
    required String addressLine1,
    required String state,
    required String postalCode,
    String? website,
    String? latitude,
    String? longitude,
    File? logo,
    File? coverImage,
    required void Function(double) onProgress,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(ShopProfileResponceModel) onSuccess,
  }) async {
    try {
      const String uri =
          'https://app.wamims.world/public/social/shopping/shop_register.php';
      final head = await DB().getHeaderForRow();
      final user = await DB().getUser();

      final data = {
        "user_id": user?.id ?? 0,
        "shop_name": shopName,
        "description": description,
        "category_id": categoryId,
        "city": city,
        "country": country,
        "phone": phone,
        "email": email,
        "address_line_1": addressLine1,
        "state": state,
        "postal_code": postalCode,
        if (website != null && website.isNotEmpty) "website": website,
        if (latitude != null && latitude.isNotEmpty) "latitude": latitude,
        if (longitude != null && longitude.isNotEmpty) "longitude": longitude,
      };

      Logger().i(data);

      final Map<String, String> fd = {};
      for (final i in data.keys) {
        fd[i] = data[i].toString();
      }

      final request = http.MultipartRequest("POST", Uri.parse(uri));

      // Calculate total bytes for progress tracking
      int totalBytes = 0;
      if (logo != null) {
        totalBytes += await logo.length();
      }
      if (coverImage != null) {
        totalBytes += await coverImage.length();
      }

      int bytesSent = 0;

      // Add logo file with progress tracking
      if (logo != null) {
        final logoLength = await logo.length();
        final logoStream = http.ByteStream(logo.openRead().transform(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              bytesSent += data.length;
              if (totalBytes > 0) {
                onProgress(bytesSent / totalBytes);
              }
              sink.add(data);
            },
          ),
        ),);
        final logoFile = http.MultipartFile(
          'logo',
          logoStream,
          logoLength,
          filename: logo.path.split('/').last,
        );
        request.files.add(logoFile);
      }

      // Add cover image file with progress tracking
      if (coverImage != null) {
        final coverLength = await coverImage.length();
        final coverStream = http.ByteStream(coverImage.openRead().transform(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              bytesSent += data.length;
              if (totalBytes > 0) {
                onProgress(bytesSent / totalBytes);
              }
              sink.add(data);
            },
          ),
        ),);
        final coverFile = http.MultipartFile(
          'cover_image',
          coverStream,
          coverLength,
          filename: coverImage.path.split('/').last,
        );
        request.files.add(coverFile);
      }

      request.fields.addAll(fd);
      request.headers.addAll(head ?? {});

      final resp = await request.send();
      final String body = await resp.stream.bytesToString();

      respPrinter(resp.statusCode, body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final d = jsonDecode(body);
        final s = ShopProfileResponceModel.fromJson(d);
        onSuccess(s);
      } else {
        onFailure(http.Response(body, resp.statusCode));
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Get shop categories
  Future<void> getShopCategories({
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(ShopCategoryReponceModel) onSuccess,
  }) async {
    try {
      final head = await DB().getHeaderForRow();

      const String uri =
          'https://app.wamims.world/public/social/shopping/get_shop_categories.php';

      final resp = await http.get(Uri.parse(uri), headers: head ?? {});

      respPrinter(resp.statusCode, resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final d = jsonDecode(resp.body);
        final s = ShopCategoryReponceModel.fromJson(d);
        onSuccess(s);
      } else {
        onFailure(resp);
      }
    } catch (e) {
      onError(e.toString());
    }
  }
}
