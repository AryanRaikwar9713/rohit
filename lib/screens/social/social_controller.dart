import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:streamit_laravel/screens/social/comment_responce_model.dart';

import 'package:streamit_laravel/screens/social/social_api.dart';
import 'package:streamit_laravel/screens/social/social_post_responce_Model.dart';
import 'package:streamit_laravel/screens/walletSection/bolt/bolt_api.dart';
import 'package:streamit_laravel/screens/walletSection/wallet_api.dart';

import '../../network/core_api.dart';
import 'package:http/http.dart' as http;

class SocialController extends GetxController {
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxList<SocialPost> posts = <SocialPost>[].obs;
  final RxList<SocialAd> ads = <SocialAd>[].obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;

  // Post upload states
  final RxBool isUploadingPost = false.obs;
  final RxBool onCreatePostScreen = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh data when controller is ready
    log('=== SocialController Ready - Refreshing Data ===');
    refreshData();

    // Test with user ID 1 to see if there are any posts
    testApiWithDifferentUser();
  }

  void _initializeData() {
    loadPosts(navigatorKey.currentContext!);
    _loadAds();
  }

  Future<void> refreshData() async {
    await loadPosts(navigatorKey.currentContext!, refresh: true);
    _loadAds();
  }

  // Test method to check if API works with different user ID
  Future<void> testApiWithDifferentUser() async {
    try {
      log('=== Testing API with User ID 1 (same as main call) ===');
      final CoreServiceApis coreApi = CoreServiceApis();
      final response = await coreApi.getSocialPosts(
        perPage: 10,
        userId: 1,
        onError: (s) {},
        onFailure: (s) {},
        onSuccess: (s) {},
        // Test with user ID 1
      );

      if (response['success'] == true) {
        if (response['data'] is Map) {
          final Map<String, dynamic> dataMap = response['data'];
          final List<dynamic> postsData = dataMap['posts'] ?? [];
          log('Found ${postsData.length} posts for user ID 1 (new structure)');
          log('Pagination: ${dataMap['pagination']}');
          for (int i = 0; i < postsData.length; i++) {
            log('Post $i: ${postsData[i]}');
          }
        } else if (response['data'] is List) {
          final List<dynamic> postsData = response['data'];
          log('Found ${postsData.length} posts for user ID 1 (old structure)');
          for (int i = 0; i < postsData.length; i++) {
            log('Post $i: ${postsData[i]}');
          }
        }
      }
    } catch (e) {
      log('Test API error: $e');
    }
  }

  Future<void> loadPosts(BuildContext context, {bool refresh = false}) async {
    print("loading Post");
    try {
      if (refresh) {
        currentPage.value = 1;
        hasMoreData.value = true;
        posts.clear();
      }

      if (!hasMoreData.value) return;

      isLoading.value = true;

      // Load real data from API
      final response =
          await SocialApi().getSocialPost(currentPage.value, onSuccess: (d) {
        if (currentPage.value > 1) {
          posts.value.addAll(d.data?.posts ?? []);
          posts.refresh();
        } else {
          posts.value = d.data?.posts ?? [];
          posts.refresh();
        }
        hasMoreData.value = d.data?.pagination?.hasNextPage ?? false;
        currentPage.value++;
      }, onFailure: (s) {
        hasMoreData.value = false;
      }, onError: (e) {
        Get.snackbar("Error", e);
        hasMoreData.value = false;
      },);

      isLoading.value = false;
    } catch (e) {
      print("Error $e");
      isLoading.value = false;
      hasMoreData.value = false;
    }
  }

  Future<void> loadMorePosts() async {
    if (!hasMoreData.value || isLoading.value) return;
    await loadPosts(navigatorKey.currentContext!);
  }

  void _loadAds() {
    ads.value = [
      SocialAd(
        id: 1,
        title: 'Premium Subscription',
        description: 'Get unlimited access to all features',
        imageUrl:
            'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400&h=200&fit=crop',
        actionText: 'Subscribe Now',
        actionUrl: 'https://example.com/subscribe',
      ),
      SocialAd(
        id: 2,
        title: 'New Movie Release',
        description: 'Check out the latest blockbuster',
        imageUrl:
            'https://images.unsplash.com/photo-1489599800075-2a4b3b3b3b3b?w=400&h=200&fit=crop',
        actionText: 'Watch Now',
        actionUrl: 'https://example.com/movie',
      ),
    ];
    ads.refresh();
  }

  // Post interaction methods
  Future<void> toggleLike(int postId) async {
    try {
      final SocialPost p = posts.value
          .where((element) => element.postId == postId.toString())
          .first;

      await SocialApi().likePost(
        postId: postId,
        onError: (e) {
          Logger().e("Error in Like Api $e");
        },
        onFailure: (s) => _handleResponce(s),
        onSuccess: (isLiked, likeCount) {
          final postIndex = posts.value.indexWhere(
            (element) => element.postId == postId.toString(),
          );

          final post = posts.value[postIndex];

          post.engagement?.likesCount = likeCount;
          post.engagement?.isLiked = isLiked;
          posts.value[postIndex] = post;
          posts.refresh();
          if (isLiked) {
            WalletApi().getPointsAndBolt(
              action: PointAction.like,
              getBolt: false,
              targetId: postId,
              contentType: "post",
              onError: (e) {
                Logger().e("Error in Like Api $e");
              },
              onFailure: (s) => _handleResponce(s),
            );
          }
        },
      );
    } catch (e) {
      Logger().e("Error in Like Api");
    }
  }

  Future<void> commentOnPost(int postId, String comment) async {
    try {
      await SocialApi().addCommentOnPost(
        postId: postId,
        comment: comment,
        onError: (e) {
          Logger().e("Error in Comment Api $e");
        },
        onFailure: (s) => _handleResponce(s),
        onSuccess: (c) {
          comments.add(c);
          comments.refresh();

          final int postInt = posts.indexWhere(
            (element) => element.postId == postId.toString(),
          );

          final post = posts.value[postInt];

          post.engagement?.commentsCount =
              (post.engagement?.commentsCount ?? 0) + 1;

          posts.value[postInt] = post;
          posts.refresh();

          WalletApi().getPointsAndBolt(
            action: PointAction.comment,
            targetId: postId,
            getBolt: false,
            commentId: int.parse(c.commentId ?? '0'),
            contentType: "post",
            onError: (e) {
              Logger().e("Error in Comment Api $e");
            },
            onFailure: (s) => _handleResponce(s),
          );
        },
      );
    } catch (e) {
      Logger().e("Error In posting on Commnet");
    }
  }

  void sharePost(int postId) {
    // TODO: Implement share functionality
    toast('Share feature coming soon!');
  }

  void donateToPost(int postId) {
    // TODO: Implement donation functionality
    toast('Donation feature coming soon!');
  }

  void toggleBookmark(int postId) {}

  // Create post method
  Future<void> createPost({
    required String caption,
    String? imagePath,
    String? title,
    List<String>? hashtags,
    bool showDonateButton = false,
  }) async {
    try {
      isUploadingPost.value = true;

      await SocialApi().createPost(
        title: title ?? '',
        caption: caption,
        mediaUrl: imagePath,
        hashtags: hashtags ?? [],
        showDonateButton: showDonateButton,
        // onProgress: (d){
        //   Logger().i("Progress $d");
        // },
        onError: (e) {
          isUploadingPost.value = false;
          Logger().e("Error in create Post Api $e");
        },
        onFailure: (s) {
          isUploadingPost.value = false;
          _handleResponce(s);
        },
        onSuccess: (s) async {
          isUploadingPost.value = false;
          Get.snackbar("Success", "Post Created Successfully",
              backgroundColor: Colors.green,);
          print("post created done callin point APi");
          WalletApi().getPointsAndBolt(
              action: PointAction.postUpload,
              getBolt: false,
              targetId: s,
              contentType: "post",
              onError: (d) {
                Logger().e("asdfj0");
              },
              onFailure: (d) {
                Logger().e("Error in Point Api $d");
              },);
          print("post created done callin point APi");
          await refreshData();
          // Only pop if user is still on the create post screen
          if (onCreatePostScreen.value) {
            Navigator.pop(navigatorKey.currentContext!);
          }
        },
      );
    } catch (e) {
      isUploadingPost.value = false;
      Logger().e("Can'Not create Post $e");
    } finally {
      isLoading.value = false;
      log('=== createPost completed ===');
    }
  }

  RxBool commentLoading = false.obs;
  RxInt commentPage = 1.obs;
  RxList<SocialPostComment> comments = <SocialPostComment>[].obs;
  RxBool hasMoreComment = false.obs;

  //Get All Comment
  Future<void> getPostComment(int postId) async {
    try {
      await SocialApi().getPostComment(
        post_id: postId,
        page: commentPage.value,
        onError: (e) {
          Logger().e("Error in get Post Comment Api $e");
        },
        onFailure: (s) => _handleResponce(s),
        onSuccess: (s) {
          Logger().i("Comment Get Doen");
          if (commentPage.value == 1) {
            comments.value = s.data?.comments ?? [];
            comments.refresh();
          } else {
            comments.value.addAll(s.data?.comments ?? []);
            comments.refresh();
          }
          commentPage.value++;
          hasMoreComment.value = s.data?.pagination?.hasNextPage ?? false;
        },
      );
    } catch (e) {
      Logger().e(e);
    }
    commentLoading.value = false;
  }

  void loadMoreComment(int postId) {
    if (!hasMoreComment.value || commentLoading.value) return;
    getPostComment(postId);
  }

  void resateCommentData() {
    commentPage.value = 1;
    comments.clear();
    comments.refresh();
    commentLoading.value = true;
    hasMoreComment.value = false;
  }

  void followUser(int userId) {
    try {
      SocialApi().followUser(
        targetUserId: userId,
        onError: (e) {
          Logger().e("Error on Following user $e");
        },
        onFailure: (s) {
          _handleResponce(s);
        },
        onSuccess: (isFollowing) {
          for (final e in posts) {
            if (e.user?.userId == userId.toString()) {
              e.user?.isFollowed = isFollowing;
            }
          }
          posts.refresh();
        },
      );
    } catch (e) {
      Logger().e('Error On Following User $e');
    }
  }

  // Fallback method for creating posts locally when API is not available

  void _handleResponce(http.Response s) {
    Logger().e(s.statusCode);
    Logger().e(jsonDecode(s.body));
  }

  void _handleError(String e) {
    Logger().e(e);
  }
}

// Social Ad Model
class SocialAd {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String actionText;
  final String actionUrl;

  SocialAd({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.actionText,
    required this.actionUrl,
  });
}
