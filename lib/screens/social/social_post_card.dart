import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/social/social_post_responce_Model.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_screen.dart';
import 'package:streamit_laravel/configs.dart';
import 'package:streamit_laravel/generated/assets.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/image_cache_manager.dart';

import '../../utils/mohit/vammis_like_botton.dart';

class SocialPostCard extends StatefulWidget {
  final SocialPost post;
  final Future<void> Function()? onLike;
  final Future<void> Function()? onComment;
  final Future<void> Function()? onFollowTap;
  final Future<void> Function()? onImageTap;
  // final Future<void> Function()? onEarn;
  final Future<void> Function()? onSare;
  final bool profilenavigation;

  const SocialPostCard(
      {required this.post,
      this.onImageTap,
      this.onLike,
      this.onComment,
      this.onFollowTap,
      this.onSare,
      this.profilenavigation = true,
      super.key,});

  @override
  State<SocialPostCard> createState() => _SocialPostCardState();
}

class _SocialPostCardState extends State<SocialPostCard> {
  bool isLiking = false;

  bool isLiked = false;
  int likeCount = 0;
  int commentCount = 0;

  bool isDownLoading = false;
  double progress = 0;

  bool readMore = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    isLiked = widget.post.engagement?.isLiked ?? false;
    likeCount = widget.post.engagement?.likesCount ?? 0;
    commentCount = widget.post.engagement?.commentsCount ?? 0;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLiked = widget.post.engagement?.isLiked ?? false;
    likeCount = widget.post.engagement?.likesCount ?? 0;
    commentCount = widget.post.engagement?.commentsCount ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxCardWidth = screenWidth * 0.80;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxCardWidth),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF181818),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () async {
                if (!widget.profilenavigation) return;
                final user = widget.post.user;
                if (user == null) return;
                final rawId = user.userId;
                final int? userId = rawId is int
                    ? rawId! as int
                    : int.tryParse(rawId?.toString() ?? '');
                if (userId == null || userId <= 0) return;
                final u = await DB().getUser();
                openVammisProfile(userId: userId, isOwnProfile: u?.id == userId);
              },
              child: Row(
                children: [
                  // Profile Picture (null-safe for user/profileImage)
                  Builder(
                    builder: (_) {
                      final avatar = widget.post.user?.profileImage?.toString().trim() ?? '';
                      return CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey[850],
                        backgroundImage: avatar.isNotEmpty
                            ? NetworkImage(resolveImageUrl(avatar, pathPrefix: 'storage/avatars/'))
                            : const AssetImage(Assets.iconsIcDefaultUser) as ImageProvider,
                        onBackgroundImageError: (_, __) {},
                      );
                    },
                  ),
                  8.width,

                  // Username and Time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.post.user?.firstName ?? ''} ${widget.post.user?.lastName ?? ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        4.height,
                        Text(
                          _formatTimeAgo(
                              widget.post.createdAt ?? DateTime.now(),),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Three Dots Menu (More Options) - filhal UI me nahi dikhana
                  // 8.width,
                  // Material(
                  //   color: Colors.transparent,
                  //   child: InkWell(
                  //     onTap: () {
                  //       // Show more options menu
                  //     },
                  //     borderRadius: BorderRadius.circular(20),
                  //     child: Padding(
                  //       padding: const EdgeInsets.all(8),
                  //       child: Icon(
                  //         Icons.more_vert,
                  //         color: Colors.grey[400],
                  //         size: 22,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),

          // Post Image: max 80% screen width, fills box (no blank sides), tap for full size
          if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty)
            _PostImageWidget(
              imageUrl: resolveImageUrl(widget.post.imageUrl),
              onTap: widget.onImageTap,
              maxBoxWidth: maxCardWidth,
            ),

          // Caption and Content (Below Image)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Caption with Name
                RichText(
                  maxLines: readMore?null:2,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '${widget.post.user?.firstName ?? ''} ${widget.post.user?.lastName ?? ''} ',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (widget.post.caption != null &&
                          widget.post.caption!.isNotEmpty)
                        TextSpan(
                          text: widget.post.caption,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),

                // Hashtags (lighter grey/blue color)
                if (widget.post.hashtags != null &&
                    widget.post.hashtags!.isNotEmpty) ...[
                  8.height,
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final i in widget.post.hashtags!.split(','))
                        ShaderMask(
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
                            '#${i.trim()}',
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.white, // IMPORTANT: White रखें
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Post Actions Bar (Like, Comment, Share, Donate, Bookmark)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Like Button (Lightbulb Icon)
                GestureDetector(
                  onTap: () async {
                    if (isLiking) return;
                    if (widget.onLike != null) {
                      if (isLiked) {
                        isLiked = false;
                        likeCount--;
                      } else {
                        isLiked = true;
                        likeCount++;
                      }
                      setState(() {
                        isLiking = true;
                      });
                      await widget.onLike!();
                      setState(() {
                        isLiking = false;
                      });
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Like Button
                      WammilsLikeBotton(like: isLiked),

                      const SizedBox(width: 4),

                      // Like Count with YELLOW-ORANGE GRADIENT
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
                        child: Text(
                          likeCount.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white, // IMPORTANT: White रखें
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Comment Button (CupertinoIcons - Instagram-style)
                GestureDetector(
                  onTap: () async {
                    if (widget.onComment != null) {
                      await widget.onComment!();
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.chat_bubble,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        commentCount.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Share Button (CupertinoIcons - Instagram-style)
                GestureDetector(
                  onTap: widget.onSare,
                  child: const Icon(
                    CupertinoIcons.paperplane,
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                const Spacer(),

                // Donate Button – only when post was created with "show donate" toggle ON
                if (widget.post.showDonateButton == true) ...[
                  GestureDetector(
                    onTap: () {
                      // Handle donation
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.yellow.shade400,  // Yellow
                            Colors.orange.shade400,  // Orange
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Colors.black,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Donate 0',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Save/Bookmark Button - filhal UI me nahi dikhana
                // GestureDetector(
                //   onTap: () {
                //     // Handle bookmark
                //   },
                //   child: const Icon(
                //     CupertinoIcons.bookmark,
                //     color: Colors.white,
                //     size: 24,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    ),
    ),
    );
  }
}

/// Post image: max width 80% of screen, fills box (no blank sides), overflow hidden in box. Tap to view full size.
class _PostImageWidget extends StatelessWidget {
  final String imageUrl;
  final Future<void> Function()? onTap;
  final double maxBoxWidth;

  const _PostImageWidget({
    required this.imageUrl,
    this.onTap,
    required this.maxBoxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    // Box width = full card width; height = same as effective width (square) capped at 80% of screen height so it stays in view
    final boxWidth = maxBoxWidth;
    final boxHeight = (boxWidth).clamp(200.0, screenHeight * 0.80);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: boxHeight,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            cacheManager: ExtendedTimeoutCacheManager(),
            fit: BoxFit.cover,
            width: double.infinity,
            height: boxHeight,
            placeholder: (_, __) => Container(
              color: Colors.grey[900],
              height: boxHeight,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(color: appColorPrimary),
            ),
            errorWidget: (_, __, ___) => Container(
              height: boxHeight,
              color: Colors.grey[900],
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
            ),
          ),
        ),
      ),
    );
  }
}

String formateTime(DateTime date) {
  final months = {
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec',
  };

  return '${(date.hour % 12).toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} ${date.hour > 12 ? 'PM' : 'AM'} ${date.day} ${months[date.month]} ${date.year}';
}

String _formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays > 365) {
    final years = (difference.inDays / 365).floor();
    return years == 1 ? '1 year ago' : '$years years ago';
  } else if (difference.inDays > 30) {
    final months = (difference.inDays / 30).floor();
    return months == 1 ? '1 month ago' : '$months months ago';
  } else if (difference.inDays > 0) {
    return difference.inDays == 1
        ? '1 day ago'
        : '${difference.inDays} days ago';
  } else if (difference.inHours > 0) {
    return difference.inHours == 1
        ? '1 hour ago'
        : '${difference.inHours} hours ago';
  } else if (difference.inMinutes > 0) {
    return difference.inMinutes == 1
        ? '1 minute ago'
        : '${difference.inMinutes} minutes ago';
  } else {
    return 'Just now';
  }
}
