import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/auth/model/login_response.dart';
import 'package:streamit_laravel/screens/social/social_api.dart';
import 'package:streamit_laravel/screens/walletSection/models/point_history_responce_model.dart';
import 'package:streamit_laravel/screens/walletSection/models/walletModel.dart';
import 'package:streamit_laravel/screens/walletSection/bolt/bolt_api.dart';
import 'package:get/get.dart';

class WalletApi {
  Future<void> getWallet({
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(WalletData) onSuccess,
  }) async {
    try {
      final head = await DB().getHeaderForRow();
      final UserData? userId = await DB().getUser();

      final String url =
          'https://app.wamims.world/social/get_wallet.php?action=summary&user_id=${userId?.id ?? 0}';

      final response = await http.get(Uri.parse(url), headers: head ?? {});

      respPrinter(response.statusCode, response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        onSuccess(WalletData.fromJson(jsonDecode(response.body)['data']));
      } else {
        onFailure(response);
      }
    } catch (e) {
      onError("Request failed: $e");
    }
  }

  //get Point
  Future<void> getPoint({
    int commentId = 0,
    int duration = 0,
    required String action, // like, comment, share, follow, etc.
    required int targetId, // post_id, reel_id, etc.
    required String contentType, // post, reel, video, etc.
    required void Function(String) onError,
    void Function(double point)? onDone,
    required void Function(http.Response) onFailure,
    bool showToast = true, // Add parameter to control toast
  }) async {
    try {
      final String uri =
          'https://app.wamims.world/public/social/point/index.php?action=$action';
      final head = await DB().getHeaderForRow();
      final UserData? userId = await DB().getUser();

      print("Getting Coine");

      Map<String, dynamic> body;

      if (action == PointAction.like) {
        body = {
          "user_id": userId?.id ?? 0,
          "post_id": targetId,
          "content_type": contentType,
        };
      } else if (action == PointAction.comment) {
        body = {
          "user_id": userId?.id ?? 0,
          "post_id": targetId,
          "comment_id": action == PointAction.comment ? commentId : 0,
          "content_type": contentType,
        };
      } else if (action == PointAction.share) {
        body = {
          "user_id": userId?.id ?? 0,
          "post_id": targetId,
          "content_type": contentType,
        };
      } else if (action == PointAction.follow) {
        body = {
          "user_id": userId?.id ?? 0,
          "video_id": targetId,
          "content_type": contentType,
        };
      } else if (action == PointAction.reelUpload) {
        body = {
          "user_id": userId?.id ?? 0,
          "reel_id": targetId,
        };
      } else if (action == PointAction.reelWatch) {
        body = {
          "user_id": userId?.id,
          "reels_id": targetId,
          "watch_duration": 30,
        };
      } else if (action == PointAction.postUpload) {
        body = {
          "user_id": userId?.id,
          "post_id": targetId,
        };
      } else if (action == PointAction.postView) {
        body = {
          "user_id": userId?.id,
          "post_id": targetId,
          "view_duration": 20,
        };
      } else {
        body = {
          "user_id": userId?.id ?? 0,
          "post_id": targetId,
          "comment_id": action == PointAction.comment ? commentId : 0,
          "content_type": contentType,
        };
      }

      Logger().i(body);
      final response = await http.post(
        Uri.parse(uri),
        headers: head ?? {},
        body: jsonEncode(body),
      );

      respPrinter(response.statusCode, response.body);

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['message'].contains("Points earned for") && showToast) {
            toast(
                "Earn ${data['data']['points_symbol']} ${data['data']['points_earned']}",);
          }
          if (onDone != null && data['data']['points_earned'] != null) {
            onDone(data['data']['points_earned'].toDouble());
          }
        } catch (e) {
          onError("Response parsing failed: $e");
        }
      } else {
        onFailure(response);
      }
    } catch (e) {
      onError("Request failed: $e");
    }
  }

  /// Combined method to get both Points and Bolt
  /// This method calls both APIs and shows a single combined toast
  Future<void> getPointsAndBolt({
    int commentId = 0,
    int duration = 0,
    int viewDuration = 20,
    bool getPoints = true,
    required bool getBolt,
    required String action, // like, comment, share, follow, etc.
    required int targetId, // post_id, reel_id, etc.
    required String contentType, // post, reel, video, etc.
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
  }) async {
    try {
      String? pointsSymbol;
      double? pointsEarned;
      double? boltEarned;
      bool pointsSuccess = false;
      bool boltSuccess = false;

      // Call Points API
      try {

        print("Getting Points");

        final String uri =
            'https://app.wamims.world/public/social/point/index.php?action=$action';
        final head = await DB().getHeaderForRow();
        final UserData? userId = await DB().getUser();

        Map<String, dynamic> body;
        if (action == PointAction.like) {
          body = {
            "user_id": userId?.id ?? 0,
            "post_id": targetId,
            "content_type": contentType,
          };
        } else if (action == PointAction.comment) {
          body = {
            "user_id": userId?.id ?? 0,
            "post_id": targetId,
            "comment_id": commentId,
            "content_type": contentType,
          };
        } else if (action == PointAction.share) {
          body = {
            "user_id": userId?.id ?? 0,
            "post_id": targetId,
            "content_type": contentType,
          };
        } else if (action == PointAction.follow) {
          body = {
            "user_id": userId?.id ?? 0,
            "video_id": targetId,
            "content_type": contentType,
          };
        } else if (action == PointAction.reelUpload) {
          body = {
            "user_id": userId?.id ?? 0,
            "reel_id": targetId,
          };
        } else if (action == PointAction.reelWatch) {
          body = {
            "user_id": userId?.id,
            "reels_id": targetId,
            "watch_duration": duration > 0 ? duration : 30,
          };
        } else if (action == PointAction.postUpload) {
          body = {
            "user_id": userId?.id,
            "post_id": targetId,
          };
        } else if (action == PointAction.postView) {
          body = {
            "user_id": userId?.id,
            "post_id": targetId,
            "view_duration": viewDuration,
          };
        } else {
          body = {
            "user_id": userId?.id ?? 0,
            "post_id": targetId,
            "comment_id": action == PointAction.comment ? commentId : 0,
            "content_type": contentType,
          };
        }

        final pointsResponse = await http.post(
          Uri.parse(uri),
          headers: head ?? {},
          body: jsonEncode(body),
        );

        respPrinter(pointsResponse.statusCode, pointsResponse.body);

        if (pointsResponse.statusCode == 200) {
          final pointsData = jsonDecode(pointsResponse.body);
          if (pointsData['message'].toString().contains("Points earned for")) {
            pointsSymbol = pointsData['data']['points_symbol']?.toString();
            pointsEarned = pointsData['data']['points_earned']?.toDouble();
            pointsSuccess = true;
          }
        }
        else
        {
          onFailure(pointsResponse);
        }
      } catch (e) {
        Logger().e("Error getting points data: $e");
      }

      // Call Bolt API based on action
      if(getBolt)
        {
          try {
            final boltApi = BoltApi();

            if (action == PointAction.like) {
              await boltApi.likeBolt(
                postId: targetId,
                showToast: false,
                onError: (e) {
                  Logger().e("Error in Bolt API: $e");
                },
                onFailure: (s) {
                  Logger().e("Failure in Bolt API: ${s.statusCode}");
                },
                onSuccess: (data) {
                  boltEarned = data['data']['bolt_earned']?.toDouble();
                  boltSuccess = true;
                },
              );
            } else if (action == PointAction.comment) {
              await boltApi.commentBolt(
                postId: targetId,
                commentId: commentId,
                showToast: false,
                onError: (e) {
                  Logger().e("Error in Bolt API: $e");
                },
                onFailure: (s) {
                  onFailure(s);
                  Logger().e("Failure in Bolt API: ${s.statusCode}");
                },
                onSuccess: (data) {
                  boltEarned = data['data']['bolt_earned']?.toDouble();
                  boltSuccess = true;
                },
              );
            } else if (action == PointAction.postView) {
              await boltApi.postViewBolt(
                postId: targetId,
                viewDuration: viewDuration,
                showToast: false,
                onError: (e) {
                  Logger().e("Error in Bolt API: $e");
                },
                onFailure: (s) {
                  Logger().e("Failure in Bolt API: ${s.statusCode}");
                },
                onSuccess: (data) {
                  boltEarned = data['data']['bolt_earned']?.toDouble();
                  boltSuccess = true;
                },
              );
            } else if (action == PointAction.postUpload) {
              await boltApi.postUploadBolt(
                postId: targetId,
                showToast: false,
                onError: (e) {
                  Logger().e("Error in Bolt API: $e");
                },
                onFailure: (s) {
                  Logger().e("Failure in Bolt API: ${s.statusCode}");
                },
                onSuccess: (data) {
                  boltEarned = data['data']['bolt_earned']?.toDouble();
                  boltSuccess = true;
                },
              );
            } else if (action == PointAction.reelUpload) {
              await boltApi.reelUploadBolt(
                reelId: targetId,
                showToast: false,
                onError: (e) {
                  Logger().e("Error in Bolt API: $e");
                },
                onFailure: (s) {
                  Logger().e("Failure in Bolt API: ${s.statusCode}");
                },
                onSuccess: (data) {
                  boltEarned = data['data']['bolt_earned']?.toDouble();
                  boltSuccess = true;
                },
              );
            } else if (action == PointAction.reelWatch) {
              await boltApi.reelWatchBolt(
                reelId: targetId,
                watchDuration: duration > 0 ? duration : 30,
                showToast: false,
                onError: (e) {
                  Logger().e("Error in Bolt API: $e");
                },
                onFailure: (s) {
                  Logger().e("Failure in Bolt API: ${s.statusCode}");
                },
                onSuccess: (data) {
                  boltEarned = data['data']['bolt_earned']?.toDouble();
                  boltSuccess = true;
                },
              );
            }
          } catch (e) {
            Logger().e("Error calling Bolt API: $e");
          }
        }

      // Show combined toast if any points or bolt earned
      if (pointsSuccess || boltSuccess) {
        final List<String> messages = [];
        if (pointsSuccess && pointsEarned != null && pointsEarned > 0) {
          messages.add("Earn ${pointsSymbol ?? ''} $pointsEarned");
        }
        if (boltSuccess && boltEarned != null && boltEarned! > 0) {
          messages.add("Bolt Points $boltEarned");
        }
        if (messages.isNotEmpty) {

          Get.snackbar("Points Earn", messages.join(" | "),snackPosition: SnackPosition.TOP,backgroundColor: greenColor,
          duration: const Duration(milliseconds: 1500),);
        }
      }
    } catch (e) {
      onError("Request failed: $e");
    }
  }

  //
  Future<void> getPointHistory({
    int page = 1,
    required void Function(String) onError,
    required void Function(http.Response) onFailure,
    required void Function(PointsHistoryResponceModel) onSuccess,
  }) async {
    try {
      final head = await DB().getHeaderForRow();
      final user = await DB().getUser();
      final url =
          'https://app.wamims.world/public/social/point/index.php?action=history&user_id=${user?.id}&page=$page&limit=10';

      final response = await http.get(
        Uri.parse(url),
        headers: head ?? {},
      );

      respPrinter(response.statusCode, response.body);

      if (response.statusCode == 200) {
        try {
          onSuccess(
              PointsHistoryResponceModel.fromJson(jsonDecode(response.body)),);
        } catch (e) {
          onError("Response parsing failed: $e");
        }
      } else {
        onFailure(response);
      }
    } catch (e) {
      onError("Request failed: $e");
    }
  }
}

mixin PointAction {
  static const String like = "like";
  static const String comment = "comment";
  static const String share = "share";
  static const String follow = "follow";
  static const String view = "view";
  static const String reelLike = "reel_like";
  static const String reelView = "reels_watch";
  static const String reelUpload = "reel_upload";
  static const String reelWatch = "reels_watch";
  static const String postView = 'post_view';
  static const String postUpload = 'social_points_upload';
  // static const String storyView = "story_view";
  // static const String storyLike = "story_like";
  // static const String save = "save";
  // static const String unsave = "unsave";

  /// ✅ Helper (optional)
  static bool isValid(String action) {
    return [
      like,
      comment,
      share,
      follow,
      view,
      reelLike,
      reelView,
      // storyView,
      // storyLike,
      // save,
      // unsave,
    ].contains(action);
  }
}
