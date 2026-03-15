import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/common_base.dart';
import 'package:streamit_laravel/utils/constants.dart';
import 'package:streamit_laravel/video_players/model/video_model.dart';
import 'package:streamit_laravel/video_players/video_player.dart';

import '../modals/long_video_model.dart';

/// Full-screen player for user-uploaded long videos (URL playback). Like / Comment bar below.
/// User-uploaded videos are always free to watch; paid content can be controlled from admin via existing subscription module.
class LongVideoPlayerScreen extends StatefulWidget {
  const LongVideoPlayerScreen({super.key, required this.item});

  final LongVideoItem item;

  @override
  State<LongVideoPlayerScreen> createState() => _LongVideoPlayerScreenState();
}

class _LongVideoPlayerScreenState extends State<LongVideoPlayerScreen> {
  late int _likeCount;
  late int _commentCount;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.item.likeCount;
    _commentCount = widget.item.commentCount;
  }

  /// User-uploaded videos: free to watch (no subscription/paywall). Admin can use existing subscription module for paid content elsewhere.
  /// Use HLS when URL is .m3u8 for fast, YouTube-like streaming (small segments load quickly).
  static VideoPlayerModel videoModelFromLongVideo(LongVideoItem item) {
    final url = item.videoUrl ?? '';
    final isHls = url.toLowerCase().contains('.m3u8');
    return VideoPlayerModel(
      id: item.id,
      name: item.title,
      description: item.description ?? '',
      videoUploadType: isHls ? PlayerTypes.hls : PlayerTypes.url,
      videoUrlInput: url,
      thumbnailImage: item.thumbnailUrl ?? '',
      posterImage: item.thumbnailUrl ?? '',
      planId: 0,
      requiredPlanLevel: 0,
      movieAccess: MovieAccess.freeAccess,
      isPurchased: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoModel = videoModelFromLongVideo(widget.item);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: VideoPlayersComponent(
                videoModel: videoModel,
                isTrailer: false,
                showWatchNow: true,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.black87,
              child: Row(
                children: [
                  Text(widget.item.title, style: boldTextStyle(size: 14, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis).expand(),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.grey.shade900),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _liked = !_liked;
                        _likeCount += _liked ? 1 : -1;
                      });
                      toast(_liked ? 'Liked' : 'Unliked');
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_liked ? Icons.thumb_up : Icons.thumb_up_outlined, color: _liked ? appColorPrimary : Colors.white70, size: 22),
                        8.width,
                        Text('$_likeCount', style: secondaryTextStyle(size: 13, color: Colors.white70)),
                        4.width,
                        Text('Like', style: secondaryTextStyle(size: 13, color: Colors.white70)),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      toast('Comments – open when backend adds comment API');
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline, color: Colors.white70, size: 22),
                        8.width,
                        Text('$_commentCount', style: secondaryTextStyle(size: 13, color: Colors.white70)),
                        4.width,
                        Text('Comment', style: secondaryTextStyle(size: 13, color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
