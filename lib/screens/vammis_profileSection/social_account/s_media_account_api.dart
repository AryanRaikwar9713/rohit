import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/shops_section/p/order_api.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/social_account/socila_media_account_model.dart';


class SocialMediaApi {

  Future<void> getSocialMedia({
    required void Function(GetSocialMediaAccountResponceModel data) onSuccess,
    required void Function(String) onError,
    required void Function(http.Response) onFail,
  }) async {
    try {

      final user = await DB().getUser();
      final String uri =
          'https://app.wamims.world/public/social/social_media_api.php'
          '?action=get_social_media'
          '&current_user_id=${user?.id}';

      final head = await DB().getHeaderForForm();

      final resp = await http.get(Uri.parse(uri), headers: head ?? {});
      respPrinter(resp.statusCode, resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = jsonDecode(resp.body);
        onSuccess(GetSocialMediaAccountResponceModel.fromJson(data));
      } else {
        onFail(resp);
      }
    } catch (e) {
      Logger().e(e);
      onError(e.toString());
    }
  }


  Future<void> addSocialMedia({
    required String platform,
    required String url,
    required void Function() onSuccess,
    required void Function(String) onError,
    required void Function(http.Response) onFail,
  }) async {
    try {
      final head = await DB().getHeaderForForm();
      final user = await DB().getUser();

      final resp = await http.post(
        Uri.parse('https://app.wamims.world/public/social/social_media_api.php'),
        headers: head ?? {},
        body: {
          'action': 'add_social_media',
          'current_user_id': user?.id,
          'platform': platform,
          'username': "username",
          'url': url,
        },
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        onSuccess();
      } else {
        onFail(resp);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

}
