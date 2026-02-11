import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/auth/model/login_response.dart';
import 'package:streamit_laravel/screens/social/comment_responce_model.dart';
import 'package:streamit_laravel/screens/social/social_controller.dart';
import 'package:streamit_laravel/screens/social/social_post_responce_Model.dart';

void respPrinter(int st, String body,{String? uri}) {
  if(uri!=null)
    {
      Logger().i(uri);
    }
  if (st == 200 || st == 201) {
    Logger().i(jsonDecode(body));
  } else {
    Logger().e('$st\n$body');
  }
}

class SocialApi {
  //
  Future<void> getSocialPost(
    int page, {
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(GetSocialPostResponceModel) onSuccess,
  }) async
  {
    try {
      // String uri = 'https://app.wamims.world/api/posts/feed?offset=$page';
      final head = await DB().getHeaderForRow();

      final UserData? userData = await DB().getUser();

      final String uri =
          'https://app.wamims.world/social/get_posts.php?logged_in_user_id=${userData?.id ?? 0}&page=$page';

      final resp = await http.get(Uri.parse(uri), headers: head ?? {});

      respPrinter(resp.statusCode, resp.body,uri: uri);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final d = jsonDecode(resp.body);
        final s = GetSocialPostResponceModel.fromJson(d);
        onSuccess(s);
      } else {
        onFailure(resp);
      }
    } catch (e) {
      onError(e.toString());
    }
  }


  //Like Post
  Future<void> likePost({
    required int postId,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(bool isLiked, int likeCount) onSuccess,
  }) async {
    try {
      const String uri = 'https://app.wamims.world/social/post_likes.php';
      final head = await DB().getHeaderForRow();
      final user = await DB().getUser();
      final data = {
        "user_id": user?.id??0,
        "post_id": postId,
      };
      final resp = await http.post(Uri.parse(uri),
          headers: head ?? {}, body: jsonEncode(data),);

      respPrinter(resp.statusCode, resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final d = jsonDecode(resp.body);
        onSuccess(d['data']['is_liked'], int.parse(d['data']['likes_count'] ?? '0'));
      } else {
        onFailure(resp);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> addCommentOnPost({
    required int postId,
    required String comment,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(SocialPostComment) onSuccess,
  }) async {
    try {
      const String uri = 'https://app.wamims.world/social/post_comments.php';
      final head = await DB().getHeaderForRow();
      final user = await DB().getUser();

      final data = {
        "user_id":user?.id??0,
        "post_id": postId,
        "comment": comment,
      };
      final resp = await http.post(Uri.parse(uri),
          headers: head ?? {}, body: jsonEncode(data),);

      respPrinter(resp.statusCode, resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final d = jsonDecode(resp.body);
        final SocialPostComment c = SocialPostComment.fromJson(d['data']);
        onSuccess(c);
      } else {
        onFailure(resp);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> getPostComment({
    int page = 0,
    required int post_id,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(SocialPostCommnetResponceModel) onSuccess,
  }) async
  {
    try {
      final head = await DB().getHeaderForRow();
      final user = await DB().getUser();

      final String uri =
          'https://app.wamims.world/public/social/get_comments.php?post_id=$post_id&logged_in_user_id=${user?.id??0}&page=$page&limit=10';

      final resp = await http.get(
        Uri.parse(uri),
        headers: head ?? {},
      );

      respPrinter(resp.statusCode, resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final d = jsonDecode(resp.body);
        final data = SocialPostCommnetResponceModel.fromJson(d);
        onSuccess(data);
      } else {
        onFailure(resp);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  /// API: Backend should store [showDonateButton] per post and return it in get_posts as "show_donate_button" (1/0 or bool).
  /// When true, app shows Donate button on that post in feed; when false, Donate button is hidden.
  Future<void> createPost({
    required String title,
    required String caption,
    String? mediaUrl,
    required List<String> hashtags,
    bool showDonateButton = false,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(int) onSuccess,
  }) async {
    try {
      const String uri = 'https://app.wamims.world/social/upload_posts.php';
      final head = await DB().getHeaderForRow();
      final user = await DB().getUser();

      print('Header $head');

      final data = {
        "user_id": user?.id ?? 0,
        "caption": caption,
        'title': title,
        'hashtags': hashtags.join(','),
        'location': 'Bhopal',
        'show_donate_button': showDonateButton ? '1' : '0',
      };
      Logger().i(data);

      final Map<String, String> fd = {};

      for (final i in data.keys) {
        fd[i] = data[i].toString();
      }

      final request = http.MultipartRequest("POST", Uri.parse(uri));

      if(mediaUrl!=null)
        {
          request.files.add(await http.MultipartFile.fromPath('image', mediaUrl));
        }

      request.headers.addAll(head ?? {});

      request.fields.addAll(fd);

      final resp = await request.send();
      final String fbudy = await resp.stream.bytesToString();

      respPrinter(resp.statusCode, fbudy);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final d = jsonDecode(fbudy);
        onSuccess(int.parse((d['post_id']??'0').toString())); 
      } else {
        onFailure(http.Response(fbudy, resp.statusCode));
      }
    } catch (e) {
      onError(e.toString());
    }
  }


  Future<void> followUser({
    required int targetUserId,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(bool isFollowing) onSuccess,
  }) async
  {
    try {
      const String uri = 'https://app.wamims.world/public/social/follow_api.php';
      final head = await DB().getHeaderForRow();
      final user = await DB().getUser();

      final data = {
        "current_user_id": user?.id??0,
        "target_user_id": targetUserId,
      };

      final resp = await http.post(
        Uri.parse(uri),
        headers: head ?? {},
        body: jsonEncode(data),
      );

      respPrinter(resp.statusCode, resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final d = jsonDecode(resp.body);

        if (d['is_following'] != null) {
          onSuccess(
            d['is_following'] ?? false,
          );
        } else {
          onError("Invalid response format");
        }
      } else {
        onFailure(resp);
      }
    } catch (e) {
      onError(e.toString());
    }
  }
}
