import 'dart:convert';
import 'package:get/get.dart';
import 'package:html/dom.dart';
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/donation/model/get_project_list_responce_model.dart';
import 'package:streamit_laravel/screens/reels/reel_response_model.dart';
import 'package:streamit_laravel/screens/social/comment_responce_model.dart';
import 'package:streamit_laravel/screens/social/social_api.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_api.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/models/vammis_profile_model.dart';
import 'package:streamit_laravel/screens/social/social_post_responce_Model.dart';
import 'package:streamit_laravel/screens/walletSection/wallet_api.dart';

class VammisProfileController extends GetxController {
  // Profile Data
  Rx<VammisProfileResponceModel?> profileResponse =
      Rx<VammisProfileResponceModel?>(null);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxBool ifSelfProfile = false.obs;

  // Posts & Reels & Projects
  RxList<SocialPost> userPosts = <SocialPost>[].obs;
  RxList<Reel> userReels = <Reel>[].obs;
  RxList<Project> userProjects = <Project>[].obs;
  RxInt currentTab = 0.obs; // 0 = Posts, 1 = Reels, 2 = Projects

  // Pagination
  RxInt postsPage = 1.obs;
  RxInt reelsPage = 1.obs;
  RxInt projectsPage = 1.obs;
  RxBool hasMorePosts = true.obs;
  RxBool hasMoreReels = true.obs;
  RxBool hasMoreProjects = true.obs;
  RxBool isLoadingPosts = false.obs;
  RxBool isLoadingReels = false.obs;
  RxBool isLoadingProjects = false.obs;

  int? currentUserId;



  /// Load User Profile
  Future<void> loadUserProfile(int userId) async {
    currentUserId = userId;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await VammisProfileApi().getUserProfile(
        userId: userId,
        onSuccess: (response) async {
          isLoading.value = false;
          profileResponse.value = response;
          final curruntUser = await DB().getUser();
          ifSelfProfile.value = userId == (curruntUser?.id ?? 0);
          // Load posts, reels and projects after profile loads
          loadUserPosts(userId);
          loadUserReels(userId);
          loadUserProjects(userId);
        },
        onError: (error) {
          isLoading.value = false;
          errorMessage.value = error;
          Logger().e('Error loading profile: $error');
          toast(error);
        },
        onFailure: (response) {
          isLoading.value = false;
          try {
            final errorData = jsonDecode(response.body);
            errorMessage.value =
                errorData['message'] ?? 'Failed to load profile';
            toast(errorMessage.value);
          } catch (e) {
            errorMessage.value = 'Failed to load profile';
            toast(errorMessage.value);
          }
        },
      );
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Something went wrong: $e';
      Logger().e('Exception loading profile: $e');
      toast(errorMessage.value);
    }
  }

  /// Load User Posts
  Future<void> loadUserPosts(int userId, {bool refresh = false}) async {
    print("lkakjfd");
    currentUserId = userId;
    if (refresh) {
      postsPage.value = 1;
      hasMorePosts.value = true;
      userPosts.clear();
    }

    if (!hasMorePosts.value || isLoadingPosts.value) { return; }

    if(refresh)
    {
      isLoadingPosts.value = true;
    }

    try {
      await VammisProfileApi().getUserPost(
        userId: userId,
        page: postsPage.value,
        onSuccess: (data) {
          isLoadingPosts.value = false;

          isLoadingMore.value = false;
          final newPosts = data.data?.posts ?? [];
          if (refresh) {
            userPosts.value = newPosts;
          } else {
            userPosts.addAll(newPosts);
          }
          userPosts.refresh();
          hasMorePosts.value = data.data?.pagination?.hasNextPage ?? false;
        },
        onError: (error) {
          isLoadingPosts.value = false;
          Logger().e('Error loading posts: $error');
        },
        onFailure: (response) {
          isLoadingPosts.value = false;
          Logger().e('Failed to load posts: ${response.statusCode}');
        },
      );
    } catch (e) {
      isLoadingPosts.value = false;
      Logger().e('Exception loading posts: $e');
    }
  }

  RxBool isLoadingMore = false.obs;


  Future<void> loadMorePost() async {
    print("load More Posr");
    if (hasMorePosts.value && !isLoadingMore.value) {
      postsPage.value++;
      isLoadingMore.value = true;
      await loadUserPosts(currentUserId!);
      isLoadingMore.value = false;
    }
  }

  /// Load User Reels
  Future<void> loadUserReels(int userId, {bool refresh = false}) async {
    currentUserId = userId;
    if (refresh) {
      reelsPage.value = 1;
      hasMoreReels.value = true;
      userReels.clear();
    }

    if (!hasMoreReels.value || isLoadingReels.value) { return; }

    isLoadingReels.value = true;

    try {
      await VammisProfileApi().getUserReels(
        userId: userId,
        page: reelsPage.value,
        onSuccess: (data) {
          Logger().i(data);
          isLoadingReels.value = false;
          if (reelsPage.value == 1) {
            userReels.value = data.data?.reels ?? [];
          } else {
            userReels.addAll(data.data?.reels ?? []);
          }

          userReels.refresh();
          hasMoreReels.value = data.data?.pagination?.hasMore ?? false;
        },
        onError: (error) {
          isLoadingReels.value = false;
          Logger().e('Error loading reels: $error');
        },
        onFailure: (response) {
          isLoadingReels.value = false;
          Logger().e('Failed to load reels: ${response.statusCode}');
        },
      );
    } catch (e) {
      isLoadingReels.value = false;
      Logger().e('Exception loading reels: $e');
    }
  }

  Future<void> loadMoreReel() async {
    print("lading More Post");
    if (hasMoreReels.value && !isLoadingMore.value) {
      reelsPage.value++;
      isLoadingMore.value = true;
      print("Calling load reels");
      await loadUserReels(currentUserId!);
      isLoadingMore.value = false;
    }
  }

  /// Load User Projects
  Future<void> loadUserProjects(int userId, {bool refresh = false}) async {
    currentUserId = userId;
    if (refresh) {
      projectsPage.value = 1;
      hasMoreProjects.value = true;
      userProjects.clear();
    }

    if (!hasMoreProjects.value || isLoadingProjects.value) { return; }

    isLoadingProjects.value = true;

    try {
      await VammisProfileApi().getUserProjects(
        userId: userId,
        page: projectsPage.value,
        onSuccess: (data) {
          isLoadingProjects.value = false;

          final newProjects = data.data?.projects ?? [];
          if (refresh) {
            userProjects.value = newProjects;
          } else {
            userProjects.addAll(newProjects);
          }
          userProjects.refresh();
          hasMoreProjects.value = data.data?.pagination?.hasNextPage ?? false;
        },
        onError: (error) {
          isLoadingProjects.value = false;
          Logger().e('Error loading projects: $error');
        },
        onFailure: (response) {
          isLoadingProjects.value = false;
          Logger().e('Failed to load projects: ${response.statusCode}');
        },
      );
    } catch (e) {
      isLoadingProjects.value = false;
      Logger().e('Exception loading projects: $e');
    }
  }

  Future<void> loadMoreProjects() async {
    if (hasMoreProjects.value && !isLoadingMore.value) {
      projectsPage.value++;
      isLoadingMore.value = true;
      await loadUserProjects(currentUserId!);
      isLoadingMore.value = false;
    }
  }

  /// Follow/Unfollow User
  Future<void> toggleFollow() async {
    if (profileResponse.value?.data == null) { return; }

    final currentFollowStatus =
        profileResponse.value!.data!.isFollowing ?? false;
    final userId = profileResponse.value!.data!.user?.id;

    if (userId == null) { return; }

    // Optimistic update
    profileResponse.value!.data!.isFollowing = !currentFollowStatus;
    if (currentFollowStatus) {
      profileResponse.value!.data!.user!.followersCount =
          (profileResponse.value!.data!.user!.followersCount ?? 1) - 1;
      if (profileResponse.value!.data!.stats != null) {
        profileResponse.value!.data!.stats!.followers =
            (profileResponse.value!.data!.stats!.followers ?? 1) - 1;
      }
    } else {
      profileResponse.value!.data!.user!.followersCount =
          (profileResponse.value!.data!.user!.followersCount ?? 0) + 1;
      if (profileResponse.value!.data!.stats != null) {
        profileResponse.value!.data!.stats!.followers =
            (profileResponse.value!.data!.stats!.followers ?? 0) + 1;
      }
    }
    profileResponse.refresh();

    try {
      await VammisProfileApi().followUser(
        targetUserId: userId,
        onSuccess: (isFollowing) {
          profileResponse.value!.data!.isFollowing = isFollowing;
          profileResponse.refresh();
        },
        onError: (error) {
          // Revert on error
          profileResponse.value!.data!.isFollowing = currentFollowStatus;
          if (currentFollowStatus) {
            profileResponse.value!.data!.user!.followersCount =
                (profileResponse.value!.data!.user!.followersCount ?? 0) + 1;
            if (profileResponse.value!.data!.stats != null) {
              profileResponse.value!.data!.stats!.followers =
                  (profileResponse.value!.data!.stats!.followers ?? 0) + 1;
            }
          } else {
            profileResponse.value!.data!.user!.followersCount =
                (profileResponse.value!.data!.user!.followersCount ?? 1) - 1;
            if (profileResponse.value!.data!.stats != null) {
              profileResponse.value!.data!.stats!.followers =
                  (profileResponse.value!.data!.stats!.followers ?? 1) - 1;
            }
          }
          profileResponse.refresh();
          toast(error);
        },
        onFailure: (response) {
          // Revert on failure
          profileResponse.value!.data!.isFollowing = currentFollowStatus;
          if (currentFollowStatus) {
            profileResponse.value!.data!.user!.followersCount =
                (profileResponse.value!.data!.user!.followersCount ?? 0) + 1;
            if (profileResponse.value!.data!.stats != null) {
              profileResponse.value!.data!.stats!.followers =
                  (profileResponse.value!.data!.stats!.followers ?? 0) + 1;
            }
          } else {
            profileResponse.value!.data!.user!.followersCount =
                (profileResponse.value!.data!.user!.followersCount ?? 1) - 1;
            if (profileResponse.value!.data!.stats != null) {
              profileResponse.value!.data!.stats!.followers =
                  (profileResponse.value!.data!.stats!.followers ?? 1) - 1;
            }
          }
          profileResponse.refresh();
          toast('${jsonDecode(response.body)['error']}');
        },
      );
    } catch (e) {
      // Revert on exception
      profileResponse.value!.data!.isFollowing = currentFollowStatus;
      profileResponse.refresh();
      Logger().e('Exception toggling follow: $e');
    }
  }

  /// Refresh Profile
  Future<void> refreshProfile() async {
    if (currentUserId != null) {
      await loadUserProfile(currentUserId!);
    }
  }

  Future<void> likePost(int postId) async {
    try {
      await SocialApi().likePost(
        postId: postId,
        onError: onError,
        onFailure: (d) {},
        onSuccess: (isLiked, likeCount) => {
          userPosts.value.forEach(
            (element) {
              if (element.postId == postId) {
                element.engagement?.isLiked = isLiked;
                element.engagement?.likesCount = likeCount;
              }
              userPosts.refresh();
            },
          ),
        },
      );
    } catch (e) {
      Logger().e("Error on Like Post $e");
    }
  }

  RxInt commentPage = 1.obs;
  RxBool hasMoreComment = true.obs;
  RxBool commentLoading = true.obs;
  RxList<SocialPostComment> comments = <SocialPostComment>[].obs;

  Future<void> getPostComment(int postId) async {
    try {
      await SocialApi().getPostComment(
        post_id: postId,
        page: commentPage.value,
        onError: (e) {
          Logger().e("Error in get Post Comment Api $e");
        },
        onFailure: (s) {},
        onSuccess: (s) {
          Logger().i("Comment Get Doen");
          if (commentPage.value == 1) {
            comments.value.clear();
          }
          comments.value.addAll(s.data?.comments ?? []);
          comments.refresh();
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

  //
  Future<void> commentOnPost(int postId, String comment) async {
    try {
      await SocialApi().addCommentOnPost(
        postId: postId,
        comment: comment,
        onError: (e) {
          Logger().e("Error in Comment Api $e");
        },
        onFailure: (s) {},
        onSuccess: (c) {
          comments.add(c);
          comments.refresh();

          final int postInt = userPosts.indexWhere(
            (element) => element.postId == postId.toString(),
          );

          final post = userPosts.value[postInt];

          post.engagement?.commentsCount =
              (post.engagement?.commentsCount ?? 0) + 1;

          userPosts.value[postInt] = post;
          userPosts.refresh();

          WalletApi().getPointsAndBolt(
            action: PointAction.comment,
            getBolt: false,
            targetId: postId,
            commentId: int.parse(c.commentId ?? '0'),
            contentType: "post",
            onError: (e) {
              Logger().e("Error in Comment Api $e");
            },
            onFailure: (s) {},
          );
        },
      );
    } catch (e) {
      Logger().e("Error In posting on Commnet");
    }
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
        onFailure: (s) {},
        onSuccess: (isFollowing) {
          for (final e in userPosts) {
            if (e.user?.userId == userId.toString()) {
              e.user?.isFollowed = isFollowing;
            }
          }

          userPosts.refresh();
        },
      );
    } catch (e) {
      Logger().e('Error On Following User $e');
    }
  }


  Future<void> logOut() async
  {

  }
}
