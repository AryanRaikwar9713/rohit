
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:streamit_laravel/screens/shops_section/p/order_api.dart';
import 'package:streamit_laravel/screens/wammis_search/search_result_responce_model.dart';

class SearchApi {

  Future<void> searchApi(String query,{
    int page = 1,
    int limit = 10,
    required Future<void> Function(SearchResultReponceModel responce) onSuccess,
    required Future<void> Function(String e) onError,
    required Future<void> Function(http.Response responce) onFailed,
  }) async
  {
    try {

      final String url = "https://app.wamims.world/public/social/search_content.php?q=$query&type=all&limit=10";

      final responce = await http.get(Uri.parse(url));

      respPrinter(responce.statusCode, responce.body);

      if(responce.statusCode == 200)
      {
        onSuccess(SearchResultReponceModel.fromJson(jsonDecode(responce.body)));
      }
      else
      {
        onFailed(responce);
        Logger().e("Error in Search ${responce.statusCode}");
      }

    } catch (e) {
      onError(e.toString());
      Logger().e("Error in Search $e");
    }
  }

}