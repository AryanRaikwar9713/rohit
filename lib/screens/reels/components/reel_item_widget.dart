import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit/media_kit.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/walletSection/bolt/bolt_api.dart';
import 'package:streamit_laravel/screens/walletSection/wallet_api.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_screen.dart';
import 'package:streamit_laravel/utils/mohit/custom_like_button.dart';

import '../reel_response_model.dart';
import '../reels_controller.dart';
import 'reel_comment_bottom_sheet.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_controller.dart';

class ReelItemWidget extends StatefulWidget {
  final Reel reel;
  final ReelsController controller;

  const ReelItemWidget({
    super.key,
    required this.reel,
    required this.controller,
  });

  @override
  State<ReelItemWidget> createState() => _ReelItemWidgetState();
}

class _ReelItemWidgetState extends State<ReelItemWidget>
    with TickerProviderStateMixin {
  VideoController? videoController;
  bool isInitialized = false;
  bool hasError = false;
  late AnimationController _likeAnimationController;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;
  bool _showHeartAnimation = false;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _completedSubscription;

  bool isLike = false;
  int likeCount = 0;
  int commentCount = 0;

  _initData() {
    isLike = widget.reel.interactions?.isLiked ?? false;
    likeCount = widget.reel.stats?.likesCount ?? 0;
    commentCount = widget.reel.stats?.commentsCount ?? 0;
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _initData();
  }

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _initData();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heartScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heartAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  Duration watchTime = Duration.zero;
  Duration prePosition = Duration.zero;

  bool coineGet = false;

  _videoListener(Duration p) {
    if (!mounted) return;
    Duration sub = p - prePosition;
    watchTime = watchTime + sub;
    prePosition = p;
    if (watchTime.inSeconds == 5 && !coineGet) {
      coineGet = true;
      WalletApi().getPointsAndBolt(
          action: PointAction.reelWatch,
          targetId: widget.reel.id ?? 0,
          contentType: 'reel',
          getBolt: false,
          duration: 30,
          onError: (d) {
            Logger().e(d);
          },
          onFailure: (d) {});
    }
  }

  void _initializeVideo() {
    if (!mounted || isInitialized || hasError) return;
    try {
      if (!Get.isRegistered<ReelsController>()) return;
      final player =
          widget.controller.getVideoController(widget.reel.id ?? 0);
      if (player == null || widget.reel.content?.videoUrl == null) return;
      final videoUrl = widget.reel.content!.videoUrl!;
      videoController = VideoController(player);
      player.open(Media(videoUrl));
      player.play();
      if (!mounted) return;
      setState(() {
        isInitialized = true;
      });

      _completedSubscription = player.stream.completed.listen((event) {
        if (!mounted) return;
        try {
          player.seek(Duration.zero);
          player.play();
        } catch (_) {}
      });

      _positionSubscription = player.streams.position.listen((event) {
        _videoListener(event);
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          hasError = true;
          isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _completedSubscription?.cancel();
    _completedSubscription = null;
    videoController = null;
    _likeAnimationController.dispose();
    _heartAnimationController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    if (!Get.isRegistered<ReelsController>()) return;
    var reelId = int.tryParse(widget.reel.id?.toString() ?? '0') ?? 0;
    if (!(widget.reel.interactions?.isLiked ?? false)) {
      widget.controller.toggleLikeReel(reelId);
    }

    setState(() {
      _showHeartAnimation = true;
    });

    _heartAnimationController.forward().then((_) {
      setState(() {
        _showHeartAnimation = false;
      });
      _heartAnimationController.reset();
    });
  }

  // Get current reel from controller to ensure we have the latest data
  Reel? _getCurrentReel() {
    final reelId = widget.reel.id;
    if (reelId == null) return widget.reel;

    // Try to find in apiReels first
    try {
      final controller = widget.controller;
      final reelInApi = controller.apiReels.firstWhere(
        (element) => element.id == reelId,
        orElse: () => widget.reel,
      );
      if (reelInApi.id == reelId) return reelInApi;
    } catch (e) {
      // Ignore
    }

    // Try to find in userReels if VammisProfileController is available
    try {
      if (Get.isRegistered<VammisProfileController>()) {
        final profileController = Get.find<VammisProfileController>();
        final reelInUser = profileController.userReels.firstWhere(
          (element) => element.id == reelId,
          orElse: () => widget.reel,
        );
        if (reelInUser.id == reelId) return reelInUser;
      }
    } catch (e) {
      // Ignore
    }

    // Fallback to widget.reel
    return widget.reel;
  }

  @override
  Widget build(BuildContext context) {
    // Don't build Obx when controller is gone (e.g. after tab switch) — avoids GetX "improper use" error
    if (!Get.isRegistered<ReelsController>()) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
      );
    }
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Stack(
        children: [
          // Video Player
          if (isInitialized && videoController != null)
            Container(
              child: Video(
                controller: videoController!,
                controls: NoVideoControls,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: CachedNetworkImage(
                imageUrl: widget.reel.content?.thumbnailUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.black,
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                ),
              ),
            ),

          // Double tap to like gesture
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (Get.isRegistered<ReelsController>()) {
                  widget.controller.togglePlayPause();
                }
              },
              onDoubleTap: _onDoubleTap,
              child: Container(color: Colors.transparent),
            ),
          ),

          // Heart animation on double tap
          if (_showHeartAnimation)
            Center(
              child: AnimatedBuilder(
                animation: _heartScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _heartScaleAnimation.value,
                    child: Image.asset(
                      "assets/icons/like_bulbe.png",
                      width: 150,
                      color: Colors.yellow,
                    ),
                  );
                },
              ),
            ),

          // Right side action buttons (Instagram style)
          Positioned(
            right: 12,
            bottom: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Like Button
                Obx(() {
                  final currentReel = _getCurrentReel();
                  final isLiked = currentReel?.interactions?.isLiked ?? false;
                  final likeCount = currentReel?.stats?.likesCount ?? 0;

                  return CustomLikeButton(
                    isLiked: isLiked,
                    likeCount: likeCount,
                    onLike: () async {
                      var reelId = widget.reel.id ?? 0;
                      widget.controller.toggleLikeReel(reelId);
                      _likeAnimationController.forward().then((_) {
                        _likeAnimationController.reverse();
                      });
                    },
                  );
                }),
                const SizedBox(height: 20),

                // Comment Button
                Obx(() {
                  final currentReel = _getCurrentReel();
                  final commentCount = currentReel?.stats?.commentsCount ?? 0;
                  return _buildActionButton(
                    icon: CupertinoIcons.chat_bubble,
                    count: commentCount,
                    onTap: () {
                      _showCommentBottomSheet();
                    },
                  );
                }),
                const SizedBox(height: 20),

                // Share Button
                _buildActionButton(
                  icon: CupertinoIcons.arrowshape_turn_up_right_fill,
                  count: 0,
                  onTap: () {
                    // widget.controller.shareReel(0);
                    Clipboard.setData(const ClipboardData(
                        text:
                            "https://play.google.com/store/apps/details?id=com.anytimeott.live"));
                    toast("Url Copied");
                  },
                ),
                // const SizedBox(height: 24),
                const SizedBox(height: 50),

                // More Options
                // GestureDetector(
                //   onTap: () {
                //     _showMoreOptions();
                //   },
                //   child: Padding(
                //     padding:
                //         const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                //     child: const Icon(
                //       Icons.more_vert,
                //       color: Colors.white,
                //       size: 28,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),

          // Bottom content (Instagram style)
          Positioned(
            left: 12,
            right: 80,
            bottom: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Username with follow button
                Row(
                  children: [
                    _buildProfileSection(),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        final userId = widget.reel.user?.id;
                        if (userId == null) return;
                        DB().getUser().then((value) {
                          if (!mounted) return;
                          Get.to(() => VammisProfileScreen(
                              popButton: true,
                              userId: userId,
                              isOwnProfile: value?.id == widget.reel.user?.id));
                        });
                      },
                      child: Text(
                        '@${widget.reel.user?.fullName ?? 'user'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Obx(() {
                      final currentReel = _getCurrentReel();
                      final isFollowing =
                          currentReel?.user?.isFollowing ?? false;
                      return GestureDetector(
                        onTap: () {
                          widget.controller
                              .followUser(widget.reel.user?.id ?? 0);
                        },
                        child: Blur(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.black.withOpacity(0.1),
                          child:  Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isFollowing ? Colors.transparent : Colors.white,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              gradient: isFollowing
                                  ? LinearGradient(
                                colors: [
                                  Colors.yellow.shade400,  // Yellow
                                  Colors.orange.shade500,  // Orange
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                                  : null,
                            ),
                            child: isFollowing
                                ? ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.white.withOpacity(0.9),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              child: Text(
                                'Connected',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            )
                                : Text(
                              'Connect',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 10),
                    const CustomStreamButton()
                  ],
                ),
                const SizedBox(height: 8),

                // Description with hashtags
                RichText(
                  text: TextSpan(
                    children: [
                      // Caption (regular white text)
                      TextSpan(
                        text: widget.reel.content?.caption ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),

                      // Hashtags with GRADIENT
                      if (widget.reel.content?.hashtags != null &&
                          widget.reel.content!.hashtags!.isNotEmpty)
                        WidgetSpan(
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                colors: [
                                  Colors.yellow.shade400,  // Yellow
                                  Colors.orange.shade500,  // Orange
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds);
                            },
                            child: Text(
                              ' ${widget.reel.content!.hashtags!.join(' #')}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white, // IMPORTANT: White रखें
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Music info with dancing icon
                Row(
                  children: [
                      ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: [
                            Colors.yellow.shade400,  // Yellow
                            Colors.orange.shade500,  // Orange
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds);
                      },
                      child: Icon(
                        CupertinoIcons.music_note_2,
                        size: 16,
                        color: Colors.white, // IMPORTANT: White रखें
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Original Sound - ${widget.reel.user?.fullName ?? 'user'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.graphic_eq,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (kDebugMode)
            Obx(
              () {
                final c = (Get.isRegistered<ReelsController>())
                    ? Get.find<ReelsController>()
                    : widget.controller;
                return Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            c.apiReels.length.toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            c.currentReelId.value.toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            final userId = widget.reel.user?.id;
            if (userId == null) return;
            DB().getUser().then((value) {
              if (!mounted) return;
              Get.to(() => VammisProfileScreen(
                  popButton: true,
                  userId: userId,
                  isOwnProfile: value?.id == widget.reel.user?.id));
            });
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: widget.reel.user?.avatar ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    String? imageUrl,
    bool useImage = false,
    required IconData icon,
    required int count,
    required VoidCallback onTap,
    Color? shadowColor,
    bool shadow = false,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _likeAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_likeAnimationController.value * 0.2),
                  child: useImage && imageUrl != null
                      ? Image.asset(
                          imageUrl,
                          width: 28,
                          height: 28,
                          color: color,
                        )
                      : Icon(
                          icon,
                          color: color,
                          size: 28,
                          shadows: [
                            if (shadow)
                              BoxShadow(
                                color: shadowColor ?? Colors.black,
                                // color: Colors.red,
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                          ],
                        ),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              _formatNumber(count),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildOptionItem(Icons.report, 'Report', () {
              widget.controller.reportReel(widget.reel.id ?? 0);
            }),
            _buildOptionItem(Icons.block, 'Block', () {
              widget.controller.blockUser(widget.reel.user?.id ?? 0);
            }),
            _buildOptionItem(Icons.copy, 'Copy Link', () {
              widget.controller.copyLink(0);
            }),
            _buildOptionItem(Icons.share, 'Share to...', () {
              widget.controller.shareReel(0);
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _showCommentBottomSheet() async {
    if (!Get.isRegistered<ReelsController>()) return;
    final controller = Get.find<ReelsController>();
    controller.getReelComments(widget.reel.id ?? 0);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ReelCommentBottomSheet(
        reel: widget.reel,
      ),
    );

    controller.resetCommentData();
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
}
