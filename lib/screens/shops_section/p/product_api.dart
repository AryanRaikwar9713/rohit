import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/shops_section/model/product_category_responce_model.dart';
import 'package:streamit_laravel/screens/shops_section/model/product_list_responce_model.dart';

void respPrinter(int st, String body) {
  if (st == 200 || st == 201) {
    Logger().i(jsonDecode(body));
  } else {
    Logger().e('$st\n$body');
  }
}

class ProductAPi {
  Future<void> getProductCategories({
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(ProductCategoryReponceModel data) onSuccess,
  }) async {
    try {
      final uri = Uri.parse(
        "https://app.wamims.world/public/social/shopping/get_product_categories.php",
      );

      final head = await DB().getHeaderForRow();

      final response = await http.get(
        uri,
        headers: head ?? {},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        onSuccess(ProductCategoryReponceModel.fromJson(body));
      } else {
        onFailure(response);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  //
  Future<void> getProductsList({
    required int page,
    int limit = 10,
    int? shopId,
    int? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
    bool? featured, //true,false
    bool? inStock, //true,false
    String? sortBy, //price,name,view_count
    String? sortOrder, //asc,desc

    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(ProductListReponceModel data) onSuccess,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        "page": page.toString(),
        "limit": limit.toString(),
      };

      // Add only non-null filters
      if (shopId != null) queryParams["shop_id"] = shopId.toString();
      if (categoryId != null) {
        queryParams["category_id"] = categoryId.toString();
      }
      if (search != null) queryParams["search"] = search;
      if (minPrice != null) queryParams["min_price"] = minPrice.toString();
      if (maxPrice != null) queryParams["max_price"] = maxPrice.toString();
      if (featured != null) queryParams["featured"] = featured.toString();
      if (inStock != null) queryParams["in_stock"] = inStock.toString();
      if (sortBy != null) queryParams["sort_by"] = sortBy;
      if (sortOrder != null) queryParams["sort_order"] = sortOrder;

      print("askdf");
      final uri = Uri.http(
        "app.wamims.world",
        "/social/shopping/get_products.php",
        queryParams,
      );
      print('asf');

      final head = await DB().getHeaderForRow();

      final response = await http.get(
        uri,
        headers: head ?? {},
      );

      respPrinter(response.statusCode, response.body);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        onSuccess(ProductListReponceModel.fromJson(body));
      } else {
        onFailure(response);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Create shop product
  Future<void> createShopProduct({
    required int shopId,
    required String name,
    required String description,
    required String shortDescription,
    required String price,
    required String comparePrice,
    required String costPrice,
    required String quantity,
    required int categoryId,
    required String sku,
    required String barcode,
    required String pointPrice,
    String? weight,
    File? featuredImage,
    List<File>? imageGallery,
    required void Function(double) onProgress,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(dynamic) onSuccess,
  }) async
  {
    try {
      final uri = Uri.parse(
        "https://app.wamims.world/social/shopping/shop_product_create.php",
      );

      final head = await DB().getHeaderForForm();
      final user = await DB().getUser();

      final request = http.MultipartRequest("POST", uri);

      // Add form fields
      request.fields.addAll({
        "user_id": (user?.id ?? 0).toString(),
        "shop_id": shopId.toString(),
        "name": name,
        "description": description,
        "short_description": shortDescription,
        "price": price,
        "compare_price": comparePrice,
        "cost_price": costPrice,
        "quantity": quantity,
        "category_id": categoryId.toString(),
        "sku": sku,
        "barcode": barcode,
        'points':pointPrice,
        if (weight != null && weight.isNotEmpty) "weight": weight,
      });

      // Calculate total bytes for progress tracking
      int totalBytes = 0;
      if (featuredImage != null) {
        totalBytes += await featuredImage.length();
      }
      if (imageGallery != null) {
        for (final image in imageGallery) {
          totalBytes += await image.length();
        }
      }

      int bytesSent = 0;

      // Add featured image with progress tracking
      if (featuredImage != null) {
        final featuredLength = await featuredImage.length();
        final featuredStream = http.ByteStream(
          featuredImage.openRead().transform(
            StreamTransformer.fromHandlers(
              handleData: (data, sink) {
                bytesSent += data.length;
                if (totalBytes > 0) {
                  onProgress(bytesSent / totalBytes);
                }
                sink.add(data);
              },
            ),
          ),
        );
        final featuredFile = http.MultipartFile(
          'featured_image',
          featuredStream,
          featuredLength,
          filename: featuredImage.path.split('/').last,
        );
        request.files.add(featuredFile);
      }

      Logger().i(featuredImage);
      Logger().i(imageGallery);

      // Add gallery images with progress tracking
      if (imageGallery != null) {
        for (int i=0;i<imageGallery.length; i++) {
          final image = imageGallery[i];
          final imageLength = await image.length();
          final imageStream = http.ByteStream(
            image.openRead().transform(
              StreamTransformer.fromHandlers(
                handleData: (data, sink) {
                  bytesSent += data.length;
                  if (totalBytes > 0) {
                    onProgress(bytesSent / totalBytes);
                  }
                  sink.add(data);
                },
              ),
            ),
          );
          final imageFile = http.MultipartFile(
            'image_gallery[]',
            imageStream,
            imageLength,
            filename: image.path.split('/').last,
          );
          request.files.add(imageFile);
        }
      }

      request.headers.addAll(head ?? {});

      final resp = await request.send();
      final String body = await resp.stream.bytesToString();

      respPrinter(resp.statusCode, body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final d = jsonDecode(body);
        onSuccess(d);
      } else {
        onFailure(http.Response(body, resp.statusCode));
      }
    } catch (e) {
      onError(e.toString());
    }
  }
}
