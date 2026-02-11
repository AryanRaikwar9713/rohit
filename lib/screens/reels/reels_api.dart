import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/auth/model/login_response.dart';
import 'package:streamit_laravel/screens/reels/reel_response_model.dart';
import 'package:streamit_laravel/screens/reels/reel_comment_response_model.dart';

void respPrinter(int st, String body,{String? url}) {
  print(url);
  if (st == 200 || st == 201) {
    Logger().i(jsonDecode(body));
  } else {
    Logger().e('$st\n$body');
  }
}

class ReelsApi {
  //
  Future<void> getReels(
    int page, {
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(GetReelsResponceModel) onSuccess,
  }) async
  {
    try {
      final head = await DB().getHeaderForRow();
      final UserData? userData = await DB().getUser();

      final String uri =
          'https://app.wamims.world/public/social/reels/get_reels.php?user_id=${userData?.id??0}&page=$page&limit=10';

      final resp = await http.get(Uri.parse(uri), headers: head ?? {});

      respPrinter(resp.statusCode, resp.body,url: uri);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final d = jsonDecode(resp.body);
        final s = GetReelsResponceModel.fromJson(d);
        onSuccess(s);
      } else {
        onFailure(resp);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  //Like Reel
  Future<void> likeReel({
    required int reelId,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(bool isLiked, int likeCount) onSuccess,
  }) async
  {
    try {
      const String uri = 'https://app.wamims.world/public/social/reels/reel_like.php';
      final head = await DB().getHeaderForRow();
      final user = await DB().getUser();

      final data = {
        "user_id": user?.id ?? 0,
        "reel_id": reelId,
      };

      final resp = await http.post(
        Uri.parse(uri),
        headers: head ?? {},
        body: jsonEncode(data),
      );

      respPrinter(resp.statusCode, resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final d = jsonDecode(resp.body);
        onSuccess(
            d['data']['is_liked'], d['data']['likes_count'],);
      } else {
        onFailure(resp);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> addCommentOnReel({
    required int reelId,
    required String comment,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(ReelComment) onSuccess,
  }) async {
    try {
      const String uri =
          'https://app.wamims.world/social/reels/add_comment.php';
      final head = await DB().getHeaderForRow();
      final user = await DB().getUser();

      final data = {
        "user_id": user?.id ?? 0,
        "reel_id": reelId,
        "comment": comment,
      };

      final resp = await http.post(
        Uri.parse(uri),
        headers: head ?? {},
        body: jsonEncode(data),
      );

      respPrinter(resp.statusCode, resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final d = jsonDecode(resp.body);
        final ReelComment c = ReelComment.fromJson(d['data']['comment']);
        onSuccess(c);
      } else {
        onFailure(resp);
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> getReelComments({
    int page = 0,
    required int reel_id,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(ReelsCommentResponceModel) onSuccess,
  }) async {
    try {
      final head = await DB().getHeaderForRow();
      final user = await DB().getUser();

      final String uri =
          'https://app.wamims.world/public/social/reels/get_comments.php?reel_id=$reel_id&logged_in_user_id=${user?.id ?? 0}&page=$page&limit=10';

      final resp = await http.get(
        Uri.parse(uri),
        headers: head ?? {},
      );

      respPrinter(resp.statusCode, resp.body,url: uri);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final d = jsonDecode(resp.body);
        final data = ReelsCommentResponceModel.fromJson(d);
        onSuccess(data);
      } else {
        onFailure(resp);
      }
    } catch (e) {
      onError(e.toString());
    }
  }


  Future<void> createReel({
    required String caption,
    required String videoPath,
    String? hashtags,
    required void Function(double) onProgress, // 👈 new callback
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(int) onSuccess,
  }) async
  {
    try {
      const String uri =
          'https://app.wamims.world/public/social/reels/create_reel.php';
      final head = await DB().getHeaderForRow();
      final user = await DB().getUser();

      final data = {
        "user_id": user?.id ?? 0,
        "caption": caption,
        "hashtags": hashtags ?? '',
        "location": 'Unknown',
      };

      Logger().i(data);

      final Map<String, String> fd = {};
      for (final i in data.keys) {
        fd[i] = data[i].toString();
      }

      final request = http.MultipartRequest("POST", Uri.parse(uri));

      // video file
      final file = File(videoPath);
      final totalBytes = await file.length();

      var bytesSent = 0;

      final  stream = http.ByteStream(file.openRead().transform(
        StreamTransformer.fromHandlers(
          handleData: (data, sink) {
            bytesSent += data.length;
            onProgress(bytesSent / totalBytes);

                      sink.add(data);
          },
        ),
      ),);


      final multipartFile = http.MultipartFile(
        'video',
        stream,
        totalBytes,
        filename: videoPath.split('/').last,
      );

      request.files.add(multipartFile);
      request.fields.addAll(fd);
      // request.headers.addAll(head);

      final resp = await request.send();

      final String body = await resp.stream.bytesToString();

      respPrinter(resp.statusCode, body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final d = jsonDecode(body);
        // var s = Reel.fromJson(d['data']);
        onSuccess(int.parse(d['data']['reel_id']??0));
      } else {
        onFailure(http.Response(body, resp.statusCode));
      }
    } catch (e) {
      Logger().e(e.toString());
      onError(e.toString());
    }
  }



  //Follow User
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
