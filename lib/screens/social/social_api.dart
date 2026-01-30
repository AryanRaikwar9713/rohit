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

respPrinter(int st, String body,{String? uri}) {
  if(uri!=null)
    {
      Logger().i(uri);
    }
  if (st == 200 || st == 201) {
    Logger().i(jsonDecode(body));
  } else {
    Logger().e('${st}\n$body');
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
      Map<String, String> head = await DB().getHeaderForRow();

      UserData? userData = await DB().getUser();

      String uri =
          'https://app.wamims.world/social/get_posts.php?logged_in_user_id=${userData?.id ?? 0}&page=$page';

      var resp = await http.get(Uri.parse(uri), headers: head);

      respPrinter(resp.statusCode, resp.body,uri: uri);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        var d = jsonDecode(resp.body);
        var s = GetSocialPostResponceModel.fromJson(d);
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
      String uri = 'https://app.wamims.world/social/post_likes.php';
      var head = await DB().getHeaderForRow();
      var user = await DB().getUser();
      var data = {
        "user_id": user?.id??0,
        "post_id": postId,
      };
      var resp = await http.post(Uri.parse(uri),
          headers: head, body: jsonEncode(data));

      respPrinter(resp.statusCode, resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        var d = jsonDecode(resp.body);
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
      String uri = 'https://app.wamims.world/social/post_comments.php';
      var head = await DB().getHeaderForRow();
      var user = await DB().getUser();

      var data = {
        "user_id":user?.id??0,
        "post_id": postId,
        "comment": comment,
      };
      var resp = await http.post(Uri.parse(uri),
          headers: head, body: jsonEncode(data));

      respPrinter(resp.statusCode, resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        var d = jsonDecode(resp.body);
        SocialPostComment c = SocialPostComment.fromJson(d['data']);
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
      var head = await DB().getHeaderForRow();
      var user = await DB().getUser();

      String uri =
          'https://app.wamims.world/public/social/get_comments.php?post_id=$post_id&logged_in_user_id=${user?.id??0}&page=$page&limit=10';

      var resp = await http.get(
        Uri.parse(uri),
        headers: head,
      );

      respPrinter(resp.statusCode, resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        var d = jsonDecode(resp.body);
        var data = SocialPostCommnetResponceModel.fromJson(d);
        onSuccess(data);
      } else {
        onFailure(resp);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> createPost({
    required String title,
    required String caption,
    String? mediaUrl,
    required List<String> hashtags,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(int) onSuccess,
  }) async {
    try {
      String uri = 'https://app.wamims.world/social/upload_posts.php';
      var head = await DB().getHeaderForRow();
      var user = await DB().getUser();

      print('Header ${head}');

      var data = {
        "user_id": user?.id ?? 0,
        "caption": caption,
        'title': title,
        'hashtags': hashtags.join(','),
        'location': 'Bhopal',
      };
      Logger().i(data);

      final Map<String, String> fd = {};

      for (var i in data.keys) {
        fd[i] = data[i].toString();
      }

      final request = http.MultipartRequest("POST", Uri.parse(uri));

      if(mediaUrl!=null)
        {
          request.files.add(await http.MultipartFile.fromPath('image', mediaUrl));
        }

      request.headers.addAll(head);

      request.fields.addAll(fd);

      var resp = await request.send();
      final String fbudy = await resp.stream.bytesToString();

      respPrinter(resp.statusCode, fbudy);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        var d = jsonDecode(await fbudy);
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
      String uri = 'https://app.wamims.world/public/social/follow_api.php';
      var head = await DB().getHeaderForRow();
      var user = await DB().getUser();

      var data = {
        "current_user_id": user?.id??0,
        "target_user_id": targetUserId,
      };

      final resp = await http.post(
        Uri.parse(uri),
        headers: head,
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
