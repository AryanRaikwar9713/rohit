import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/social/social_post_responce_Model.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_screen.dart';
import 'package:streamit_laravel/utils/colors.dart';

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
    return Container(
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
                if (!widget.profilenavigation || widget.post.user == null) return;
                // userId API se string ya int aa sakta hai
                final rawId = widget.post.user!.userId;
                final int? userId = rawId is int
                    ? rawId as int
                    : int.tryParse(rawId?.toString() ?? '');
                if (userId == null || userId <= 0) return;
                final u = await DB().getUser();
                Get.to(() => VammisProfileScreen(
                      popButton: true,
                      userId: userId,
                      isOwnProfile: u?.id == userId,
                    ));
              },
              child: Row(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey[850],
                    backgroundImage: widget.post.user?.profileImage != null &&
                            widget.post.user!.profileImage!.isNotEmpty
                        ? NetworkImage(widget.post.user!.profileImage!)
                        : null,
                    child: widget.post.user?.profileImage == null ||
                            widget.post.user!.profileImage!.isEmpty
                        ? Icon(
                            Icons.person,
                            color: Colors.grey[400],
                            size: 20,
                          )
                        : null,
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

          // Post Image: actual size; sirf full-screen type (jo puri screen cover kare) ko 70% cap
          if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty)
            _PostImageWidget(
              imageUrl: widget.post.imageUrl!,
              onTap: widget.onImageTap,
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
    );
  }
}

/// Post image: actual size dikhata hai; sirf jo full-screen type (puri screen cover) ho woh 70% cap
class _PostImageWidget extends StatefulWidget {
  final String imageUrl;
  final Future<void> Function()? onTap;

  const _PostImageWidget({required this.imageUrl, this.onTap});

  @override
  State<_PostImageWidget> createState() => _PostImageWidgetState();
}

class _PostImageWidgetState extends State<_PostImageWidget> {
  int? _imageWidth;
  int? _imageHeight;
  bool _loadFailed = false;
  ImageStream? _imageStream;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();
    _resolveImageDimensions();
  }

  void _resolveImageDimensions() {
    final provider = NetworkImage(widget.imageUrl);
    final stream = provider.resolve(const ImageConfiguration());
    _listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        if (!mounted) return;
        final w = info.image.width;
        final h = info.image.height;
        if (w > 0 && h > 0 && _listener != null) {
          stream.removeListener(_listener!);
          setState(() {
            _imageWidth = w;
            _imageHeight = h;
          });
        }
      },
      onError: (exception, stackTrace) {
        if (!mounted) return;
        if (_listener != null) stream.removeListener(_listener!);
        setState(() => _loadFailed = true);
      },
    );
    _imageStream = stream;
    stream.addListener(_listener!);
  }

  @override
  void dispose() {
    if (_imageStream != null && _listener != null) {
      _imageStream!.removeListener(_listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const appBarHeight = 56.0;
    const bottomNavHeight = 80.0;
    final remainingHeight = screenHeight - appBarHeight - bottomNavHeight - MediaQuery.of(context).padding.top;
    final maxHeightForFullScreen = remainingHeight * 0.70;

    // Dimensions nahi aaye ya load fail: placeholder (chota height, baad mein actual size dikhega)
    if (_loadFailed || (_imageWidth == null && _imageHeight == null)) {
      final placeholderHeight = _loadFailed ? 200.0 : 220.0;
      return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: double.infinity,
          height: placeholderHeight,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _loadFailed
                ? const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                  )
                : const Center(
                    child: CircularProgressIndicator(color: appColorPrimary),
                  ),
          ),
        ),
      );
    }

    // Actual size: full width, height = aspect ratio; sirf full-screen type ko 70% cap
    final w = _imageWidth!.toDouble();
    final h = _imageHeight!.toDouble();
    final heightIfFullWidth = screenWidth * (h / w);
    final displayHeight = heightIfFullWidth > maxHeightForFullScreen
        ? maxHeightForFullScreen
        : heightIfFullWidth;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: double.infinity,
        height: displayHeight,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.contain,
            width: double.infinity,
            height: displayHeight,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[900],
                height: displayHeight,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: appColorPrimary,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: displayHeight,
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                ),
              );
            },
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
