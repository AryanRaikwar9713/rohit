import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/shops_section/p/order_api.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/get_story_responce_model.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/my_story_responce_model.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/my_story_controller.dart';

class StoryApi {


  Future<void> createStory({
    required String mediaUrl,
    String? caption,
    List<int>? taggedUserIds,
    required void Function() onSuccess,
    required void Function(String) onError,
    required void Function(http.Response) onFail,
  }) async {
    try {
      // String uri = 'https://wamims.international/public/social/story_api.php?action=create_story';
      const String uri =
          'https://wamims.international/public/social/story_api.php?action=create_story';

      final head = await DB().getHeaderForForm();

      final request = http.MultipartRequest('POST', Uri.parse(uri));
      request.headers.addAll(head ?? {});

      request.files.add(await http.MultipartFile.fromPath('media', mediaUrl));

      if (caption != null) {
        request.fields['caption'] = caption;
      }
      if (taggedUserIds != null && taggedUserIds.isNotEmpty) {
        // Backend can accept either CSV or JSON array; here we send CSV for simplicity.
        request.fields['tag_user_ids'] = taggedUserIds.join(',');
      }

      final response = await request.send();

      print("Response ${response.statusCode}");
      final res = await response.stream.bytesToString();
      print("Response $res");
      respPrinter(response.statusCode, res);
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
      // Backend should return only stories of users whom current user follows (when followed_only=1)
      const String uri = 'https://wamims.international/public/social/story_api.php?action=get_stories&followed_only=1';

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
          await DB.getUserToke();
          const String uri = 'https://wamims.international/social/my_stories_api.php';

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

  /// Like / unlike a story. Safe to call even if backend endpoint is not live yet.
  Future<void> likeStory({
    required int storyId,
    required bool isLike,
    required void Function(String) onError,
    required void Function(http.Response) onFail,
  }) async {
    try {
      const String uri =
          'https://wamims.international/public/social/story_like_api.php';

      final head = await DB().getHeaderForForm();
      final resp = await http.post(
        Uri.parse(uri),
        headers: head ?? {},
        body: {
          'story_id': '$storyId',
          'action': isLike ? 'like' : 'unlike',
        },
      );

      respPrinter(resp.statusCode, resp.body);
      if (resp.statusCode != 200 && resp.statusCode != 201) {
        onFail(resp);
      }
    } catch (e) {
      Logger().e('Error in likeStory: $e');
      onError(e.toString());
    }
  }

  /// Record that current user viewed a story. Backend must implement
  /// record_story_view_api.php – inserts into story_views for getStoryViewers.
  Future<void> recordStoryView({
    required int storyId,
    required void Function(String) onError,
    required void Function(http.Response) onFail,
  }) async {
    if (storyId <= 0) return;
    try {
      const String uri =
          'https://wamims.international/public/social/record_story_view_api.php';
      final head = await DB().getHeaderForForm();
      final resp = await http.post(
        Uri.parse(uri),
        headers: head ?? {},
        body: {'story_id': '$storyId'},
      );
      respPrinter(resp.statusCode, resp.body);
      if (resp.statusCode != 200 && resp.statusCode != 201) {
        onFail(resp);
      }
    } catch (e) {
      Logger().e('Error in recordStoryView: $e');
      onError(e.toString());
    }
  }

  /// Get viewers for a story (who viewed my story).
  Future<void> getStoryViewers({
    required int storyId,
    required void Function(List<StoryViewer> viewers) onSuccess,
    required void Function(String) onError,
    required void Function(http.Response) onFail,
  }) async {
    try {
      final String uri =
          'https://wamims.international/public/social/story_viewers_api.php?story_id=$storyId';

      final head = await DB().getHeaderForForm();
      final resp = await http.get(Uri.parse(uri), headers: head ?? {});
      respPrinter(resp.statusCode, resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = jsonDecode(resp.body);
        final List<dynamic> rawViewers = data['viewers'] ?? [];
        final viewers = rawViewers
            .map((e) => StoryViewer.fromJson(e as Map<String, dynamic>))
            .toList();
        onSuccess(viewers);
      } else {
        onFail(resp);
      }
    } catch (e) {
      Logger().e('Error in getStoryViewers: $e');
      onError(e.toString());
    }
  }

  /// Search users to tag in story (used on Add Story screen).
  /// Safe even if backend endpoint is not available – will just return [].
  Future<List<Map<String, dynamic>>> searchUsersForTag({
    required String query,
  }) async {
    try {
      final uri =
          'https://wamims.international/social/search_users_for_tag.php?q=$query';

      final head = await DB().getHeaderForForm();
      final resp = await http.get(Uri.parse(uri), headers: head ?? {});
      if (resp.statusCode != 200 && resp.statusCode != 201) {
        return [];
      }
      final data = jsonDecode(resp.body);
      final List<dynamic> users = data['users'] ?? [];
      return users
          .whereType<Map<String, dynamic>>()
          .map((e) => {
                'id': e['id'] ?? 0,
                'username': e['username'] ?? '',
                'name': e['name'] ?? '',
              })
          .toList();
    } catch (e) {
      Logger().e('Error in searchUsersForTag: $e');
      return [];
    }
  }
}
