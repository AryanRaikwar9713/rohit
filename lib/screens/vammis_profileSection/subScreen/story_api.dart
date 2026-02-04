import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/shops_section/p/order_api.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/get_story_responce_model.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/my_story_responce_model.dart';

class StoryApi {


  Future<void> createStory({
    required String mediaUrl,
    String? caption,
    required void Function() onSuccess,
    required void Function(String) onError,
    required void Function(http.Response) onFail,
  }) async
  {
    try {
      // String uri = 'https://app.wamims.world/public/social/story_api.php?action=create_story';
      final String uri =
          'https://app.wamims.world/public/social/story_api.php?action=create_story';

      final head = await DB().getHeaderForForm();

      final request = http.MultipartRequest('POST', Uri.parse(uri));
      request.headers.addAll(head ?? {});

      request.files.add(await http.MultipartFile.fromPath('media', mediaUrl));

      if (caption != null) {
        request.fields.addAll({
          'caption': caption ?? '',
        });
      }

      final response = await request.send();

      print("Response ${response.statusCode}");
      final res = await response.stream.bytesToString();
      print("Response $res");
      respPrinter(response.statusCode, res ?? '');
      print("Response $res");
      if (response.statusCode == 200 || response.statusCode == 201) {
        onSuccess();
      } else {
        onFail(http.Response(res, response.statusCode));
      }
    } catch (e) {
      print("Error in Api");
      Logger().e(e);
    }
  }


  Future<void> getStories({
    required void Function(GetStoryResponceModel data) onSuccess,
    required void Function(String) onError,
    required void Function(http.Response) onFail,
  }) async
  {
    try {
      final String uri = 'https://app.wamims.world/public/social/story_api.php?action=get_stories';

      final head = await DB().getHeaderForForm();

      final resp = await http.get(Uri.parse(uri), headers: head ?? {});
      respPrinter(resp.statusCode, resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final d = jsonDecode(resp.body);
        onSuccess(GetStoryResponceModel.fromJson(d));
      }
      else {
        onFail(resp);
      }
    }
    catch (e) {
      print("Error in api ");
      Logger().e(e);
    }
  }

  Future<void> getOwnStories(
      {
        required void Function(GetMyStoryResponceModel data) onSuccess,
        required void Function(String) onError,
        required void Function(http.Response) onFail,
      }
      ) async
  {
    try
        {
          final String? t = await DB.getUserToke();
          final String uri = 'https://app.wamims.world/social/my_stories_api.php';

          final head = await DB().getHeaderForForm();

          print(head);

          final resp = await http.get(Uri.parse(uri), headers: head ?? {});
          respPrinter(resp.statusCode, resp.body);

          if (resp.statusCode == 200 || resp.statusCode == 201) {
            final d = jsonDecode(resp.body);
            onSuccess(GetMyStoryResponceModel.fromJson(d));
          }
          else {
            onFail(resp);
          }
        }
        catch(e){
          print("Error in api ");
          Logger().e(e);
        }
  }
}
