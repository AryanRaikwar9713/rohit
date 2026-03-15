import 'package:cached_network_image/cached_network_image.dart';
import 'package:streamit_laravel/utils/image_cache_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/ads/components/admob_banner_widget.dart';
import 'package:streamit_laravel/components/admob_native_ad_widget.dart';
import 'package:streamit_laravel/screens/messaging/message_inbox_screen.dart';
import 'package:streamit_laravel/screens/notificationSection/notification_screen.dart';
import 'package:streamit_laravel/utils/app_common.dart';
import 'package:streamit_laravel/screens/social/comment_responce_model.dart';
import 'package:streamit_laravel/screens/social/social_post_card.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/social/social_search_screen.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/story_controller.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_screen.dart' show openVammisProfile;
import 'package:streamit_laravel/screens/reels/reels_screen.dart';
import 'package:streamit_laravel/screens/reels/reels_api.dart';
import 'package:streamit_laravel/screens/reels/reel_response_model.dart';
import 'package:streamit_laravel/configs.dart';
import 'package:streamit_laravel/screens/walletSection/wallet_api.dart';
import 'package:streamit_laravel/screens/walletSection/wallet_tab_manage.dart';
import 'package:streamit_laravel/utils/constants.dart';
import 'package:streamit_laravel/components/home_stories_row.dart';
import '../../utils/colors.dart';
import 'social_controller.dart';
import 'create_post_screen.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen>
    with WidgetsBindingObserver {
  final ScrollController _controller = ScrollController();
  final GlobalKey<_TopReelsSectionState> _reelsSectionKey = GlobalKey<_TopReelsSectionState>();
  late SocialController controller;
  late StoryContrller storyController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = (Get.isRegistered<SocialController>())
        ? Get.find<SocialController>()
        : Get.put(SocialController());
    _controller.addListener(_scrollListener);

    storyController = (Get.isRegistered<StoryContrller>())
        ? Get.find<StoryContrller>()
        : Get.put(StoryContrller());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && isLoggedIn.value) {
        final ctrl = Get.isRegistered<WamimsNotificationController>()
            ? Get.find<WamimsNotificationController>()
            : Get.put(WamimsNotificationController(), permanent: true);
        ctrl.refreshUnreadCount();
      }
    });
    // Defer story load so first frame paints faster (reduces jank/crash on weak devices)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) storyController.loadStory();
    });
  }

  void _scrollListener() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final atBottom = position.pixels >= position.maxScrollExtent - 50;
    if (atBottom &&
        controller.hasMoreData.value &&
        !controller.isLoading.value) {
      controller.loadMorePosts();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed &&
          Get.isRegistered<SocialController>()) {
        Get.find<SocialController>().refreshData();
      }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SocialController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: appBackgroundColorDark,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(88),
            child: Container(
              decoration: const BoxDecoration(
                color: appBackgroundColorDark,
              ),
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 12),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    // Title only (drawer/menu removed per request)
                    Text(
                      'WAMIMS',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Spacer(),
                    // Messages (compact, responsive)
                    Builder(
                      builder: (ctx) {
                        final iconSize = MediaQuery.sizeOf(ctx).width < 360 ? 20.0 : 22.0;
                        return IconButton(
                          onPressed: () {
                            doIfLogin(onLoggedIn: () {
                              Get.to(() => const MessageInboxScreen());
                            },);
                          },
                          icon: Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                            size: iconSize,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          tooltip: 'Messages',
                        );
                      },
                    ),
                    2.width,
                    // Notification with real unread count badge
                    Builder(
                      builder: (ctx) {
                        final notifCtrl = Get.isRegistered<WamimsNotificationController>()
                            ? Get.find<WamimsNotificationController>()
                            : Get.put(WamimsNotificationController(), permanent: true);
                        return Obx(() {
                          final count = notifCtrl.unreadCount.value;
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Get.to(const WamimsNotificationScreen())?.then((_) {
                                    notifCtrl.refreshUnreadCount();
                                  });
                                },
                                icon: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              if (count > 0)
                                Positioned(
                                  right: 8,
                                  top: 10,
                                  child: Container(
                                    constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.yellow.shade400,
                                          Colors.orange.shade500,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: appScreenBackgroundDark, width: 1.5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        count > 99 ? '99+' : '$count',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        });
                      },
                    ),
                    4.width,
                    // Wallet Icon - Watch Ads & Earn Bolts
                    IconButton(
                      onPressed: () {
                        Get.to(() => const WalletTabManage());
                      },
                      icon: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 26,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Wallet - Watch Ads & Earn Bolts',
                    ),
                    4.width,
                    // Search icon
                    IconButton(
                      onPressed: () {
                        Get.to(() => const SocialSearchScreen());
                      },
                      icon: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 90),
            child: ElevatedButton(
              onPressed: () async {
                Get.to(const CreatePostScreen());
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(56, 56),
                maximumSize: const Size(56, 56),
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
                backgroundColor: Colors.transparent, // IMPORTANT
                foregroundColor: Colors.white,
                shadowColor: Colors.orange,
                elevation: 8,
              ),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFD700), // Gold
                      Color(0xFFFFA500), // Orange
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
             
                ),
                child: const Icon(Icons.add, size: 28),
              ),
            ),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              color: Colors.white,
              onRefresh: () async {
                // Refresh stories, reels and posts so latest content shows first (like Instagram)
                await Future.wait([
                  controller.refreshData(),
                  storyController.loadStory(),
                  _reelsSectionKey.currentState?.refresh() ?? Future.value(),
                ]);
              },
              child: SingleChildScrollView(
                controller: _controller,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [

                    // if (kDebugMode)
                    //   Obx(() {
                    //     return Column(
                    //       children: [
                    //         Text(
                    //           "${controller.currentPage.value}",
                    //           style: TextStyle(color: Colors.white),
                    //         ),
                    //         Text(
                    //           "${controller.hasMoreData.value}",
                    //           style: TextStyle(color: Colors.white),
                    //         ),
                    //         Text(
                    //           "${controller.posts.length}",
                    //           style: TextStyle(color: Colors.white),
                    //         ),
                    //       ],
                    //     );
                    //   }),

                    const HomeStoriesRow(),

                    _TopReelsSection(key: _reelsSectionKey),

                    // Social Feed
                    Obx(() {
                      if (controller.isLoading.value &&
                          controller.posts.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: appColorPrimary,
                          ),
                        );
                      }

                      if (controller.posts.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                size: 64,
                                color: Colors.grey[600],
                              ),
                              16.height,
                              Text(
                                'No posts yet',
                                style: boldTextStyle(
                                    size: 18, color: Colors.grey[600],),
                              ),
                              8.height,
                              Text(
                                'Be the first to share something!',
                                style: secondaryTextStyle(
                                    size: 14, color: Colors.grey[500],),
                              ),
                              24.height,
                              // Debug buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      log('=== Manual Refresh Triggered ===');
                                      controller.refreshData();
                                    },
                                    child: Text('Refresh',
                                        style:
                                            boldTextStyle(color: Colors.white),),
                                  ),
                                  16.width,
                                  ElevatedButton(
                                    onPressed: () {
                                      log('=== Testing API with User ID 1 ===');
                                      controller.testApiWithDifferentUser();
                                    },
                                    child: Text('Test API',
                                        style:
                                            boldTextStyle(color: Colors.white),),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }

                      // Build a list of items (posts and ads)
                      final List<Widget> items = [];
                      for (int i = 0; i < controller.posts.length; i++) {
                        items.add(SocialPostCard(
                          post: controller.posts[i],
                          key: ValueKey(controller.posts[i].postId),
                          onLike: () async {
                            await controller.toggleLike(
                                int.parse(controller.posts[i].postId ?? '0'),);
                          },
                          onFollowTap: () async {
                            controller.followUser(int.parse(
                                controller.posts[i].user?.userId ?? '0',),);
                          },
                          onComment: () async {
                            controller.getPostComment(
                                int.parse(controller.posts[i].postId ?? '0'),);
                            await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => _CommentBottomSheet(
                                postId: int.parse(
                                    controller.posts[i].postId ?? '0',),
                              ),
                            );
                            controller.resateCommentData();
                          },
                          onImageTap: () async {
                            await showDialog(
                              context: context,
                              builder: (context) => Blur(
                                blur: 7,
                                child: Dialog(
                                  backgroundColor: Colors.transparent,
                                  insetPadding: EdgeInsets.zero,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: resolveImageUrl(controller.posts[i].imageUrl ?? ''),
                                          cacheManager: ExtendedTimeoutCacheManager(),
                                          fit: BoxFit.contain,
                                          width: double.infinity,
                                          height: double.infinity,
                                          placeholder: (_, __) => Container(color: Colors.grey[900], child: const Center(child: CircularProgressIndicator())),
                                          errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey, size: 48),
                                        ),
                                        Positioned(
                                          top: MediaQuery.of(context).padding.top + 8,
                                          right: 12,
                                          child: IconButton(
                                            icon: const Icon(Icons.close, color: Colors.white, size: 28),
                                            onPressed: () => Navigator.of(context).pop(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );

                            if (ENABLE_POINT_EARNINGS_SYSTEM) {
                              WalletApi().getPointsAndBolt(
                                  action: PointAction.postView,
                                  getBolt: false,
                                  targetId: int.parse(
                                      controller.posts[i].postId ?? '0',),
                                  contentType: "post",
                                  onError: onError,
                                  onFailure: (d) {},);
                            }
                          },
                          onSare: () async {
                            Clipboard.setData(const ClipboardData(
                                text: Constants.DUMMY_SHARE_LINK,),);
                            toast("Url Copied");
                          },
                        ),);

                        // Add AdMob Native Ad after every 4 posts (matches social post UI)
                        if ((i + 1) % 4 == 0) {
                          items.add(const AdMobNativeAdWidget());
                        }

                        // Add AppLovin banner ad after every 5 posts
                        if ((i + 1) % 5 == 0) {
                          items.add(_buildAppLovinBannerAd());
                        }

                        // Add custom ad after every 3 posts (but not if we just added other ads)
                        if ((i + 1) % 3 == 0 && (i + 1) % 4 != 0 && (i + 1) % 5 != 0) {
                          final adIndex = ((i + 1) ~/ 3) - 1;
                          if (adIndex < controller.ads.length) {
                            items.add(_buildAdCard(controller.ads[adIndex]));
                          }
                        }
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: items.length,
                        itemBuilder: (context, index) => RepaintBoundary(
                          child: items[index],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }



  Widget _buildAdCard(SocialAd ad) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appColorPrimary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ad Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: appColorPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: [
                          Colors.yellow.shade400,  // Yellow
                          Colors.orange.shade400,  // Orange
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: Text(
                      'SPONSORED',
                      style: boldTextStyle(size: 11, color: Colors.white), // IMPORTANT: White रखें
                    ),
                  ),
                ),
                8.width,
                const Spacer(),
                const Icon(
                  Icons.info_outline,
                  color: Colors.grey,
                  size: 18,
                ),
              ],
            ),
          ),

          // Ad Image
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(ad.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Ad Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ad.title,
                  style: boldTextStyle(size: 16, color: Colors.white),
                ),
                4.height,
                Text(
                  ad.description,
                  style: secondaryTextStyle(size: 14, color: Colors.grey),
                ),
                12.height,
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.yellow.shade400,  // Yellow
                        Colors.orange.shade400,  // Orange
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      ad.actionText,
                      style: boldTextStyle(size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppLovinBannerAd() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appColorPrimary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Ad Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: appColorPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'AD',
                    style: boldTextStyle(size: 10, color: appColorPrimary),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          // AdMob Banner (more reliable when AppLovin ms.applvn.com is blocked)
          const AdMobBannerWidget(),
        ],
      ),
    );
  }
}

class _CommentBottomSheet extends StatefulWidget {
  final int postId;
  const _CommentBottomSheet({required this.postId});

  @override
  State<_CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<_CommentBottomSheet> {
  final _commentController = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        final controller = (Get.isRegistered<SocialController>())
            ? Get.find<SocialController>()
            : Get.put(SocialController());
        controller.loadMoreComment(widget.postId);
      }
    });

    // Auto focus text field to open keyboard when bottom sheet appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Small delay to ensure bottom sheet is fully rendered
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = (Get.isRegistered<SocialController>())
        ? Get.find<SocialController>()
        : Get.put(SocialController());

    return Obx(() {
      return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: appScreenBackgroundDark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      "Comments",
                      style: boldTextStyle(size: 18, color: Colors.white),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Divider(color: Colors.grey[700]),

              // Comments List
              if (controller.commentLoading.value)
                const Expanded(
                    child: Center(
                  child: CircularProgressIndicator(),
                ),)
              else
                Expanded(
                  child: controller.comments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "No Comments",
                                style: secondaryTextStyle(
                                    size: 14, color: Colors.grey,),
                              ),
                              if (kDebugMode) ...[
                                Obx(
                                  () => Text(
                                    controller.comments.length.toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                Obx(
                                  () => Text(
                                    controller.currentPage.toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                          itemCount: controller.comments.length,
                          itemBuilder: (context, index) {
                            final SocialPostComment comment =
                                controller.comments[index];

                            // return Text("${c.toJson()}",style: TextStyle(color: Colors.white),);

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8,),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Profile image — tap to open user profile
                                  GestureDetector(
                                    onTap: () {
                                      final raw = comment.user?.userId;
                                      final int? userId = raw is int ? (raw! as int) : int.tryParse(raw?.toString() ?? '');
                                      if (userId != null && userId > 0) {
                                        DB().getUser().then((u) {
                                          openVammisProfile(userId: userId, isOwnProfile: u?.id == userId);
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: false
                                              ? Colors.blue
                                              : Colors.transparent,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              comment.user?.profileImage ?? '',
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                            color: Colors.grey[800],
                                            child: const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            color: Colors.grey[800],
                                            child: const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Comment content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Username and time — tap name to open profile
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                final raw = comment.user?.userId;
                                                final int? userId = raw is int ? (raw! as int) : int.tryParse(raw?.toString() ?? '');
                                                if (userId != null && userId > 0) {
                                                  DB().getUser().then((u) {
                                                    openVammisProfile(userId: userId, isOwnProfile: u?.id == userId);
                                                  });
                                                }
                                              },
                                              child: Text(
                                                '${comment.user?.firstName} ${comment.user?.lastName}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            if (false) ...[
                                              const SizedBox(width: 4),
                                              const Icon(
                                                Icons.verified,
                                                color: Colors.blue,
                                                size: 14,
                                              ),
                                            ],
                                            const SizedBox(width: 8),
                                            Text(
                                              '${(comment.createdAt?.hour ?? 0).toString().padLeft(2, '0')} : ${(comment.createdAt?.minute ?? 0).toString().padLeft(2, '0')} ${(comment.createdAt?.hour ?? 0) < 12 ? 'AM' : 'PM'}',
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),

                                        // Comment text
                                        Text(
                                          comment.comment ?? '',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            height: 1.3,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),

                                  // More options
                                  // GestureDetector(
                                  //   onTap: () {
                                  //     // _showCommentOptions(comment);
                                  //   },
                                  //   child: Icon(
                                  //     Icons.more_vert,
                                  //     color: Colors.grey[400],
                                  //     size: 16,
                                  //   ),
                                  // ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

              // Bottom TextField with keyboard padding
              Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: _commentController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade800,
                    border: InputBorder.none,
                    hintText: "Add a comment...",
                    hintStyle: secondaryTextStyle(size: 14, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: appColorPrimary),
                      onPressed: () async {
                        if (_commentController.text.isEmpty) return;
                        final controller = (Get.isRegistered<SocialController>())
                            ? Get.find<SocialController>()
                            : Get.put(SocialController());
                        await controller.commentOnPost(
                            widget.postId, _commentController.text.trim(),);
                        _commentController.clear();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Top reels section: horizontal list, 5 per load, tap opens ReelsScreen.
class _TopReelsSection extends StatefulWidget {
  const _TopReelsSection({super.key});

  @override
  State<_TopReelsSection> createState() => _TopReelsSectionState();
}

class _TopReelsSectionState extends State<_TopReelsSection> {
  final List<Reel> _reels = [];
  int _page = 0;
  bool _loading = false;
  bool _hasMore = true;
  static const int _pageSize = 5;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  /// Call from parent RefreshIndicator to reload reels (latest first).
  Future<void> refresh() async {
    if (!mounted) return;
    setState(() {
      _reels.clear();
      _page = 0;
      _hasMore = true;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    final nextPage = _page + 1;
    await ReelsApi().getReels(
      nextPage,
      onSuccess: (res) {
        final list = res.data?.reels ?? [];
        // Latest first (like Instagram)
        list.sort((a, b) {
          final at = a.stats?.createdAt ?? DateTime(0);
          final bt = b.stats?.createdAt ?? DateTime(0);
          return bt.compareTo(at);
        });
        final toAdd = list.take(_pageSize).toList();
        if (mounted) {
          setState(() {
            _reels.addAll(toAdd);
            _reels.sort((a, b) {
              final at = a.stats?.createdAt ?? DateTime(0);
              final bt = b.stats?.createdAt ?? DateTime(0);
              return bt.compareTo(at);
            });
            _page = nextPage;
            _hasMore = (res.data?.pagination?.hasMore ?? false) && list.length >= _pageSize;
            _loading = false;
          });
        } else {
          _loading = false;
        }
      },
      onFailure: (_) {
        if (mounted) setState(() => _loading = false);
      },
      onError: (_) {
        if (mounted) setState(() => _loading = false);
      },
    );
    if (mounted && _loading) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_reels.isEmpty && !_loading) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Reels',
              style: boldTextStyle(size: 16, color: Colors.white),
            ),
          ),
          SizedBox(
            height: 168,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _reels.length + (_hasMore && !_loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _reels.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Center(
                      child: TextButton(
                        onPressed: _loading ? null : _loadMore,
                        child: Text(
                          _loading ? '...' : 'More',
                          style: secondaryTextStyle(color: appColorPrimary),
                        ),
                      ),
                    ),
                  );
                }
                final reel = _reels[index];
                final thumb = reel.content?.thumbnailUrl ?? '';
                final url = thumb.trim().isEmpty
                    ? ''
                    : (thumb.startsWith('http') ? thumb : 'https://wamims.international/$thumb');
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      final reelId = reel.id;
                      Get.to(() => ReelsScreen(initialReelId: reelId));
                    },
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade900,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: url.isEmpty
                                ? const Center(
                                    child: Icon(Icons.videocam_outlined,
                                        color: Colors.white54, size: 36,),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: url,
                                    cacheManager: ExtendedTimeoutCacheManager(),
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => const Center(child: CircularProgressIndicator(color: Colors.white54)),
                                    errorWidget: (_, __, ___) => const Center(
                                        child: Icon(Icons.videocam_outlined,
                                            color: Colors.white54, size: 36,),),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/icons/like_bulbe.png',
                                  width: 12,
                                  height: 12,
                                  color: Colors.yellow.shade400,
                                ),
                                3.width,
                                Text(
                                  '${reel.stats?.likesCount ?? 0}',
                                  style: secondaryTextStyle(size: 11, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

