import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/walletSection/bolt/bolt_api.dart';
import 'package:streamit_laravel/screens/walletSection/wallet_api.dart';

import 'reel_comment_response_model.dart';
import 'reel_response_model.dart';
import 'reels_api.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_controller.dart';

class ReelsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<Reel> apiReels = <Reel>[].obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;

  RxInt currentReelId = 0.obs;
  RxBool isPlaying = true.obs;

  // Video controllers for each reel
  final Map<int, Player> videoControllers = {};
  final Map<int, VideoController> videoPlayerControllers = {};

  @override
  void onInit() {
    super.onInit();
    loadReelsFromApi();
  }

  @override
  void onClose() {
    for (var player in videoControllers.values) {
      player.dispose();
    }
    videoPlayerControllers.clear();
    super.onClose();
  }

  // Load reels from real API
  Future<void> loadReelsFromApi(
      {bool refresh = false, bool loadingMore = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        hasMoreData.value = true;
        apiReels.clear();
      }

      if (!hasMoreData.value || isLoading.value) return;

      if (!loadingMore) {
        isLoading.value = true;
      }
      await ReelsApi().getReels(
        currentPage.value,
        onSuccess: (response) {
          if (currentPage.value > 1) {
            apiReels.addAll(response.data?.reels ?? []);
          } else {
            apiReels.assignAll(response.data?.reels ?? []);
          }
          hasMoreData.value = response.data?.pagination?.hasMore ?? false;
          currentPage.value++;
        },
        onFailure: (response) {
          Logger().e('Failed to load reels: ${response.statusCode}');
          Logger().e(jsonDecode(response.body));
        },
        onError: (error) {
          Logger().e('Error loading reels: $error');
          Get.snackbar("Error", error);
        },
      );

      isLoading.value = false;
    } catch (e) {
      print("Error loading reels $e");
      isLoading.value = false;
    }
  }

  Future<void> refreshReels() async {
    await loadReelsFromApi(refresh: true);
  }

  Future<void> loadMoreReels() async {
    await loadReelsFromApi(loadingMore: true);
  }

  // Like reel API integration
  Future<void> toggleLikeReel(int reelId) async {
    try {
      var reelIndex = apiReels.indexWhere(
        (element) => element.id == reelId,
      );

      await ReelsApi().likeReel(
        reelId: reelId,
        onError: (e) {
          Logger().e("Error in Like Api ${e}");
        },
        onFailure: (s) => _handleResponse(s),
        onSuccess: (isLiked, likeCount) {
          // Update apiReels if reel exists there
          if (reelIndex != -1) {
            var reel = apiReels[reelIndex];
            reel.stats?.likesCount = likeCount;
            reel.interactions?.isLiked = isLiked;
            apiReels[reelIndex] = reel;
            apiReels.refresh();
          }

          // Also update VammisProfileController.userReels if reel exists there
          if (Get.isRegistered<VammisProfileController>()) {
            try {
              final profileController = Get.find<VammisProfileController>();
              var userReelIndex = profileController.userReels.indexWhere(
                (element) => element.id == reelId,
              );
              if (userReelIndex != -1) {
                var userReel = profileController.userReels[userReelIndex];
                userReel.stats?.likesCount = likeCount;
                userReel.interactions?.isLiked = isLiked;
                profileController.userReels[userReelIndex] = userReel;
                profileController.userReels.refresh();
              }
            } catch (e) {
              Logger().e("Error updating userReels: $e");
            }
          }

          WalletApi().getPointsAndBolt(
            action: PointAction.like,
            targetId: reelId,
            getBolt: false,
            contentType: "reel",
            onError: (e) {
              Logger().e("Error in Like Api ${e}");
            },
            onFailure: (s) => _handleResponse(s),
          );
        },
      );
    } catch (e) {
      Logger().e("Error in Like Api");
    }
  }

  // Add comment on reel
  Future<void> addCommentOnReel({
    required int reelId,
    required String comment,
  }) async {
    try {
      await ReelsApi().addCommentOnReel(
        reelId: reelId,
        comment: comment,
        onError: (e) {
          Logger().e("Error in Comment Api ${e}");
        },
        onFailure: (s) => _handleResponse(s),
        onSuccess: (comment) async{

          await getReelComments(reelId,refresh: true);

          apiReels.refresh();


          WalletApi().getPointsAndBolt(
            action: PointAction.comment,
            targetId: reelId,
            commentId: comment.id ?? 0,
            getBolt: false,
            contentType: "reel",
            onError: (e) {
              Logger().e("Error in Comment Api ${e}");
            },
            onFailure: (s) => _handleResponse(s),
          );
        },
      );
    } catch (e) {
      Logger().e("Error In posting comment");
    }
  }

  // Get reel comments
  RxBool commentLoading = false.obs;
  RxInt commentPage = 1.obs;
  RxList<ReelComment> comments = <ReelComment>[].obs;
  RxBool hasMoreComment = false.obs;

  Future<void> getReelComments(int reelId,{bool refresh = false}) async {
    try {
      if(!refresh)
        {
          commentLoading.value = true;
        }

      if(refresh){
        commentPage.value = 1;
      }
      await ReelsApi().getReelComments(
        reel_id: reelId,
        page: commentPage.value,
        onError: (e) {
          Logger().e("Error in get Reel Comment Api $e");
        },
        onFailure: (s) => _handleResponse(s),
        onSuccess: (response) {
          Logger().i("Comment Get Done");
          if (commentPage.value == 1) {
            comments.assignAll(response.data?.comments ?? []);
          } else {
            comments.addAll(response.data?.comments ?? []);
          }
          commentPage.value++;
          hasMoreComment.value = response.data?.pagination?.hasNext ?? false;
        },
      );
    } catch (e) {
      Logger().e(e);
    }
    commentLoading.value = false;
  }

  void loadMoreComments(int reelId) {
    if (!hasMoreComment.value || commentLoading.value) return;
    getReelComments(reelId);
  }

  void resetCommentData() {
    commentPage.value = 1;
    comments.clear();
    commentLoading.value = true;
    hasMoreComment.value = false;
  }

  // Video Player Methods (keeping existing functionality)
  void onReelChanged(int reelId) {
    currentReelId(reelId);

    //
    videoControllers.forEach(
      (key, value) {
        if (key == reelId) {
          value.play();
        } else {
          value.pause();
        }
      },
    );

    print("Reel Changed $reelId");
    //
    if (videoControllers.containsKey(reelId)) {
      videoControllers[reelId]?.play();
    } else {
      initializeVideo(reelId);
    }

    int reelIndex = apiReels.indexWhere(
      (element) => element.id == reelId,
    );

    if ((apiReels.length - reelIndex) < 10) {
      if (reelIndex % 10 > 7) {
        loadMoreReels();
      }
    }
  }

  void togglePlayPause() {
    if (videoControllers.containsKey(currentReelId.value)) {
      if (isPlaying.value) {
        videoControllers[currentReelId.value]?.pause();
        isPlaying(false);
      } else {
        videoControllers[currentReelId.value]?.play();
        isPlaying(true);
      }
    }
  }

  Player? getVideoController(int reelId) {
    if (!videoControllers.containsKey(reelId)) {
      final player = Player();
      videoControllers[reelId] = player;
    }
    return videoControllers[reelId];
  }

  VideoController? getVideoPlayerController(int index) {
    if (!videoPlayerControllers.containsKey(index)) {
      final videoController = VideoController(videoControllers[index]!);
      videoPlayerControllers[index] = videoController;
    }
    return videoPlayerControllers[index];
  }

  void initializeVideo(int reelId) {
    try {
      final reel = apiReels.firstWhere(
        (element) => element.id == reelId,
      );
      final player = getVideoController(reelId);

      if (player != null && reel.content?.videoUrl != null) {
        player.open(Media(reel.content?.videoUrl ?? ''));
        player.play();
      }
    } catch (e) {
      print('Error initializing video for index $reelId: $e');
    }
  }

  void disposeVideo(int index) {
    if (videoControllers.containsKey(index)) {
      videoControllers[index]?.dispose();
      videoControllers.remove(index);
    }
    if (videoPlayerControllers.containsKey(index)) {
      // VideoController doesn't have dispose method, it's managed by Player
      videoPlayerControllers.remove(index);
    }
  }

  // Helper Methods
  void shareReel(int index) {
    if (index < apiReels.length) {
      // TODO: Implement share functionality
      toast('Share feature coming soon!');
    }
  }

  void followUser(int userId) {
    print("Follow to $userId");
    try {
      ReelsApi().followUser(
        targetUserId: userId,
        onError: (e) {
          Logger().e("Error on Following user $e");
        },
        onFailure: (s) {
          _handleResponse(s);
        },
        onSuccess: (isFollowing) {
          apiReels.forEach((e) {
            if (e.user?.id == userId) {
              e.user?.isFollowing = isFollowing;
            }
          });
          apiReels.refresh();

          // Also update VammisProfileController.userReels if reels exist there
          if (Get.isRegistered<VammisProfileController>()) {
            try {
              final profileController = Get.find<VammisProfileController>();
              profileController.userReels.forEach((e) {
                if (e.user?.id == userId) {
                  e.user?.isFollowing = isFollowing;
                }
              });
              profileController.userReels.refresh();
            } catch (e) {
              Logger().e("Error updating userReels follow: $e");
            }
          }
        },
      );
    } catch (e) {
      Logger().e("Error on Following user $e");
    }
  }

  void reportReel(int index) {
    if (index < apiReels.length) {
      print('Reporting reel: ${apiReels[index].id}');
    }
  }

  void blockUser(int index) {
    if (index < apiReels.length) {
      // In a real app, this would block the user
      print('Blocking user: ${apiReels[index].user?.fullName}');
    }
  }

  void copyLink(int index) {
    if (index < apiReels.length) {
      print('Copying link for reel: ${apiReels[index].id}');
    }
  }



  _handleResponse(http.Response s) {
    Logger().e(s.statusCode);
    Logger().e(jsonDecode(s.body));
  }
}
