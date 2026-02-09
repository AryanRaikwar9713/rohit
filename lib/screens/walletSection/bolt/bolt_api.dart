import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/local_db.dart';

import 'package:streamit_laravel/screens/social/social_api.dart';
import 'package:streamit_laravel/screens/walletSection/bolt/boalt_wallet_responce_model.dart';
import 'package:streamit_laravel/screens/walletSection/bolt/bolt_transection_responce_model.dart';

class BoltApi {
  /// Generic function to call Bolt API
  Future<void> _postBolt({
    required String url,
    required Map<String, dynamic> body,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(Map<String, dynamic>) onSuccess,
    bool showToast = true, // Add parameter to control toast
  }) async {
    try {
      final head = await DB().getHeaderForRow();
      Logger().i("Bolt API URL: $url");
      Logger().i("Body: $body");

      final response = await http.post(
        Uri.parse(url),
        headers: head ?? {},
        body: jsonEncode(body),
      );

      respPrinter(response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (showToast) {
          toast(
            'Bolt Points Earn ${data['data']['bolt_earned']}',
          );
        }
        onSuccess(data);
      } else {
        onFailure(response);
      }
    } catch (e) {
      onError("Request failed: $e");
    }
  }

  /// 🔹 Post Like Bolt
  Future<void> likeBolt({
    required int postId,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(Map<String, dynamic>) onSuccess,
    bool showToast = true,
  }) async {
    final user = await DB().getUser();
    await _postBolt(
      url: 'https://app.wamims.world/public/social/ads/social_like_bolt.php',
      body: {
        "user_id": user?.id ?? 0,
        "post_id": postId,
      },
      onError: onError,
      onFailure: onFailure,
      onSuccess: onSuccess,
      showToast: showToast,
    );
  }

  /// 🔹 Post Comment Bolt
  Future<void> commentBolt({
    required int postId,
    required int commentId,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(Map<String, dynamic>) onSuccess,
    bool showToast = true,
  }) async {
    final user = await DB().getUser();
    await _postBolt(
      url:
          'https://app.wamims.world/public/social/bolt/social_comment_bolt.php',
      body: {
        "user_id": user?.id ?? 0,
        "post_id": postId,
        "comment_id": commentId,
      },
      onError: onError,
      onFailure: onFailure,
      onSuccess: onSuccess,
      showToast: showToast,
    );
  }

  /// 🔹 Post View Bolt
  Future<void> postViewBolt({
    required int postId,
    required int viewDuration,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(Map<String, dynamic>) onSuccess,
    bool showToast = true,
  }) async {
    final user = await DB().getUser();
    await _postBolt(
      url:
          'https://app.wamims.world/public/social/bolt/social_post_view_bolt.php',
      body: {
        "user_id": user?.id ?? 0,
        "post_id": postId,
        "view_duration": viewDuration,
      },
      onError: onError,
      onFailure: onFailure,
      onSuccess: onSuccess,
      showToast: showToast,
    );
  }

  /// 🔹 Post Upload Bolt
  Future<void> postUploadBolt({
    required int postId,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(Map<String, dynamic>) onSuccess,
    bool showToast = true,
  }) async {
    final user = await DB().getUser();
    await _postBolt(
      url:
          'https://app.wamims.world/public/social/bolt/social_post_upload_bolt.php',
      body: {
        "user_id": user?.id ?? 0,
        "post_id": postId,
      },
      onError: onError,
      onFailure: onFailure,
      onSuccess: onSuccess,
      showToast: showToast,
    );
  }

  /// 🔹 Reel Upload Bolt
  Future<void> reelUploadBolt({
    required int reelId,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(Map<String, dynamic>) onSuccess,
    bool showToast = true,
  }) async {
    final user = await DB().getUser();
    await _postBolt(
      url:
          'https://app.wamims.world/public/social/bolt/social_reel_upload_bolt.php',
      body: {
        "user_id": user?.id ?? 0,
        "reel_id": reelId,
      },
      onError: onError,
      onFailure: onFailure,
      onSuccess: onSuccess,
      showToast: showToast,
    );
  }

  /// 🔹 Reel Watch Bolt
  Future<void> reelWatchBolt({
    required int reelId,
    required int watchDuration,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(Map<String, dynamic>) onSuccess,
    bool showToast = true,
  }) async {
    final user = await DB().getUser();
    await _postBolt(
      url:
          'https://app.wamims.world/public/social/bolt/social_reel_watch_bolt.php',
      body: {
        "user_id": user?.id ?? 0,
        "reel_id": reelId,
        "watch_duration": watchDuration,
      },
      onError: onError,
      onFailure: onFailure,
      onSuccess: onSuccess,
      showToast: showToast,
    );
  }

  /// 🔹 Watch Ad Reward Bolt (0.01 bolt for watching rewarded ad)
  /// API: public/social/ads/watch_ad_reward_bolt.php
  Future<void> watchAdRewardBolt({
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(Map<String, dynamic>) onSuccess,
    bool showToast = true,
  }) async {
    final user = await DB().getUser();
    await _postBolt(
      url:
          'https://app.wamims.world/public/social/ads/watch_ad_reward_bolt.php',
      body: {
        "user_id": user?.id ?? 0,
        "ad_type": "rewarded",
        "bolt_amount": 0.01,
        "ad_source": "admob",
      },
      onError: onError,
      onFailure: onFailure,
      onSuccess: onSuccess,
      showToast: showToast,
    );
  }

  // get Boalt Dash Board

  Future<void> getBoltDashboard({
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(BoltWalletApiResponce data) onSuccess,
  }) async {
    // try {
    final user = await DB().getUser();

    final String url =
        'https://app.wamims.world/public/social/bolt/bolt_wallet.php?user_id=${user?.id}&action=dashboard';
    final head =
        await DB().getHeaderForRow(); // agar tu header function use karta hai

    final response = await http.get(Uri.parse(url), headers: head ?? {});

    respPrinter(response.statusCode, response.body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      onSuccess(BoltWalletApiResponce.fromJson(data));
    } else {
      onFailure(response);
    }
    // } catch (e) {
    //   onError(e.toString());
    // }
  }

  Future<void> getBoltTransactions({
    required int page,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(BoltTrasectionApiResponce r) onSuccess,
  }) async {
    try {
      final head = await DB().getHeaderForRow();
      final user = await DB().getUser();

      final String url =
          'https://app.wamims.world/public/social/bolt/bolt_wallet.php?user_id=${user?.id}&action=transactions&page=$page&limit=10';

      final response = await http.get(Uri.parse(url), headers: head ?? {});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        onSuccess(BoltTrasectionApiResponce.fromJson(data));
      } else {
        onFailure(response);
      }
    } catch (e) {
      onError(e.toString());
    }
  }
}
