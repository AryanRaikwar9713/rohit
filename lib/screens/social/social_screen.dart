import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/app_lovin_ads/add_helper.dart';
import 'package:streamit_laravel/screens/dash_boad_drawer.dart';
import 'package:streamit_laravel/screens/notificationSection/notification_screen.dart';
import 'package:streamit_laravel/screens/social/comment_responce_model.dart';
import 'package:streamit_laravel/screens/social/social_post_card.dart';
import 'package:streamit_laravel/screens/social/social_search_screen.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/get_story_responce_model.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/story_controller.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/view_story_screen.dart';
import 'package:streamit_laravel/screens/walletSection/wallet_api.dart';
import 'package:streamit_laravel/utils/constants.dart';
import 'package:streamit_laravel/utils/mohit/vammis_profile_avtar.dart';
import '../../utils/colors.dart';
import '../search/search_screen.dart';
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
    storyController.loadStory();
  }

  _scrollListener() {
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
    if (state == AppLifecycleState.resumed) {
      log('=== App Resumed - Refreshing Social Posts ===');
      // Get the controller from GetX if it exists
      if (Get.isRegistered<SocialController>()) {
        final controller = Get.find<SocialController>();
        controller.refreshData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SocialController>(
      builder: (controller) {
        return Scaffold(
          drawer: const DashBoardDrawer(),
          backgroundColor: appBackgroundColorDark,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(88),
            child: Container(
              decoration: const BoxDecoration(
                color: appBackgroundColorDark,
              ),
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 12),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    // Left logo footprint + text
                    Row(
                      children: [
                        // Footprints icon (two footprints) - using custom icon
                        // Icon(
                        //   Icons.pets_rounded,
                        //   color: Colors.white,
                        //   size: 24,
                        // ),
                        8.width,
                        Text(
                          'WAMIMS',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Megaphone icon (campaign icon)
                    // IconButton(
                    //   onPressed: () {},
                    //   icon: const Icon(
                    //     Icons.campaign,
                    //     color: Colors.white,
                    //     size: 24,
                    //   ),
                    //   padding: EdgeInsets.zero,
                    //   constraints: const BoxConstraints(),
                    // ),
                    4.width,
                    // Notification with badge
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            Get.to(WamimsNotificationScreen());
                          },
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Positioned(
                          right: 8,
                          top: 10,
                          child: Container(
                            width: 17,
                            height: 17,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.yellow.shade400,  // Yellow
                                  Colors.orange.shade500,  // Orange
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: appScreenBackgroundDark, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                '1',
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
                Get.to(CreatePostScreen());
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(56, 56),
                maximumSize: Size(56, 56),
                padding: EdgeInsets.zero,
                shape: CircleBorder(),
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
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFD700), // Gold
                      Color(0xFFFFA500), // Orange
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
             
                ),
                child: Icon(Icons.add, size: 28),
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              controller: _controller,
              child: RefreshIndicator(
                //
                onRefresh: () async {
                  controller.refreshData();
                },
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

                    _UserSotuyWWigdet(),

                    // Social Feed
                    Obx(() {
                      print('=== Social Screen Rebuild ===');
                      print('Is Loading: ${controller.isLoading.value}');
                      print('Posts Count: ${controller.posts.length}');
                      print(
                          'Posts: ${controller.posts.map((p) => '${p.postId}: ${p.caption}').toList()}');

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
                                    size: 18, color: Colors.grey[600]),
                              ),
                              8.height,
                              Text(
                                'Be the first to share something!',
                                style: secondaryTextStyle(
                                    size: 14, color: Colors.grey[500]),
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
                                            boldTextStyle(color: Colors.white)),
                                  ),
                                  16.width,
                                  ElevatedButton(
                                    onPressed: () {
                                      log('=== Testing API with User ID 1 ===');
                                      controller.testApiWithDifferentUser();
                                    },
                                    child: Text('Test API',
                                        style:
                                            boldTextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }

                      // Build a list of items (posts and ads)
                      List<Widget> items = [];
                      for (int i = 0; i < controller.posts.length; i++) {
                        items.add(SocialPostCard(
                          post: controller.posts[i],
                          key: ValueKey(controller.posts[i].postId),
                          onLike: () async {
                            await controller.toggleLike(
                                int.parse(controller.posts[i].postId ?? '0'));
                          },
                          onFollowTap: () async {
                            await controller.followUser(int.parse(
                                controller.posts[i].user?.userId ?? '0'));
                          },
                          onComment: () async {
                            controller.getPostComment(
                                int.parse(controller.posts[i].postId ?? '0'));
                            await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => _CommentBottomSheet(
                                postId: int.parse(
                                    controller.posts[i].postId ?? '0'),
                              ),
                            );
                            controller.resateCommentData();
                          },
                          onImageTap: () async {
                            await showDialog(
                              context: context,
                              builder: (context) => Blur(
                                blur: 7,
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  color: Colors.transparent,
                                  elevation: 0,
                                  shape: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    borderSide: BorderSide.none,
                                    gapPadding: 0,
                                  ),
                                  child: Image.network(
                                    controller.posts[i].imageUrl ?? '',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );

                            WalletApi().getPointsAndBolt(
                                action: PointAction.postView,
                                getBolt: false,
                                targetId: int.parse(
                                    controller.posts[i].postId ?? '0'),
                                contentType: "post",
                                viewDuration: 20,
                                onError: onError,
                                onFailure: (d) {});
                          },
                          onSare: () async {
                            Clipboard.setData(ClipboardData(
                                text: Constants.DUMMY_SHARE_LINK));
                            toast("Url Copied");
                          },
                        ));

                        // Add AppLovin banner ad after every 5 posts
                        if ((i + 1) % 5 == 0) {
                          items.add(_buildAppLovinBannerAd());
                        }

                        // Add custom ad after every 3 posts (but not if we just added AppLovin ad)
                        if ((i + 1) % 3 == 0 && (i + 1) % 5 != 0) {
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
                        itemBuilder: (context, index) => items[index],
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
        border: Border.all(color: appColorPrimary.withOpacity(0.3), width: 1),
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
        border: Border.all(color: appColorPrimary.withOpacity(0.3), width: 1),
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
          // AppLovin Banner Ad
          AdLovinHelper.bannerWidget(),
        ],
      ),
    );
  }
}

class _CommentBottomSheet extends StatefulWidget {
  final int postId;
  _CommentBottomSheet({required this.postId});

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
      Future.delayed(Duration(milliseconds: 300), () {
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
                margin: EdgeInsets.symmetric(vertical: 12),
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
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Divider(color: Colors.grey[700]),

              // Comments List
              if (controller.commentLoading.value)
                Expanded(
                    child: Center(
                  child: CircularProgressIndicator(),
                ))
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
                                    size: 14, color: Colors.grey),
                              ),
                              if (kDebugMode) ...[
                                Obx(
                                  () => Text(
                                    controller.comments.length.toString(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                Obx(
                                  () => Text(
                                    controller.currentPage.toString(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                          itemCount: controller.comments.length,
                          itemBuilder: (context, index) {
                            SocialPostComment comment =
                                controller.comments[index];

                            // return Text("${c.toJson()}",style: TextStyle(color: Colors.white),);

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Profile image
                                  GestureDetector(
                                    onTap: () {
                                      // Navigate to user profile
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
                                        // Username and time
                                        Row(
                                          children: [
                                            Text(
                                              '${comment.user?.firstName} ${comment.user?.lastName}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
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
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: TextField(
                  style: TextStyle(color: Colors.white),
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
                        var controller = (Get.isRegistered<SocialController>())
                            ? Get.find<SocialController>()
                            : Get.put(SocialController());
                        await controller.commentOnPost(
                            widget.postId, _commentController.text.trim());
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


class _UserSotuyWWigdet extends StatefulWidget {
  const _UserSotuyWWigdet({super.key});

  @override
  State<_UserSotuyWWigdet> createState() => _UserSotuyWWigdetState();
}

class _UserSotuyWWigdetState extends State<_UserSotuyWWigdet> {


  late StoryContrller _storyContrller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _storyContrller = (!Get.isRegistered<StoryContrller>())?Get.put(StoryContrller()):Get.find<StoryContrller>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if(_storyContrller.storyList.isEmpty)
        {
          return SizedBox();
        }
      
      return Container(
        margin: EdgeInsetsGeometry.only(
          top: 10,
          bottom: 5,
        ),
        // height: 70,
        padding: EdgeInsetsGeometry.symmetric(vertical: 3),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 5),
            child: Row(children: [
              for(StoryUser story in _storyContrller.storyList)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: WamimsProfileAvtar(image: story.user?.avatar??'',story: true,radious: 30,onTap: (){
                    Get.to(()=>ViewStoryScreen());
                  },),
                )

            ],),
          ),
        ),
      );
    },);
  }
}

