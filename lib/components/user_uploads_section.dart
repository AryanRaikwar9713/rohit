import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/video_channel/long_video_api.dart';
import 'package:streamit_laravel/screens/video_channel/modals/long_video_model.dart';
import 'package:streamit_laravel/screens/video_channel/screens/long_video_player_screen.dart';
import 'package:streamit_laravel/utils/colors.dart';

/// Section on Long (Home) page showing user-uploaded videos. Pagination via list_public (page, limit).
class UserUploadsSection extends StatefulWidget {
  const UserUploadsSection({super.key});

  @override
  State<UserUploadsSection> createState() => _UserUploadsSectionState();
}

class _UserUploadsSectionState extends State<UserUploadsSection> {
  final LongVideoApi _api = LongVideoApi();
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 10;
  List<LongVideoItem> _videos = [];
  int _page = 1;
  bool _hasMore = true;
  bool _loading = true;
  bool _loadingMore = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadFirst();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore || _loading) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) _loadMore();
  }

  Future<void> _loadFirst() async {
    setState(() {
      _loading = true;
      _error = '';
      _page = 1;
      _videos = [];
      _hasMore = true;
    });
    try {
      final result = await _api.listPublicLongVideos(page: 1, limit: _pageSize);
      if (mounted) {
        setState(() {
          _videos = result.videos;
          _hasMore = result.hasMore;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _videos = [];
          _loading = false;
          _hasMore = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _loadingMore) return;
    setState(() => _loadingMore = true);
    final nextPage = _page + 1;
    try {
      final result = await _api.listPublicLongVideos(page: nextPage, limit: _pageSize);
      if (mounted) {
        setState(() {
          _videos = [..._videos, ...result.videos];
          _page = nextPage;
          _hasMore = result.hasMore;
          _loadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasMore = false;
          _loadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        20.height,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('User uploads', style: boldTextStyle(size: 18, color: Colors.white)),
              const Spacer(),
              if (_videos.isNotEmpty)
                Text('${_videos.length} videos', style: secondaryTextStyle(size: 12, color: Colors.white54)),
            ],
          ),
        ),
        12.height,
        if (_loading && _videos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54))),
          )
        else if (_error.isNotEmpty && _videos.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Text(_error, style: secondaryTextStyle(size: 12, color: Colors.white54), maxLines: 2, overflow: TextOverflow.ellipsis),
          )
        else if (_videos.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Text('No uploads yet. Uploaded videos will appear here.', style: secondaryTextStyle(size: 13, color: Colors.white54)),
          )
        else
          SizedBox(
            height: 180,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _videos.length + (_hasMore && _loadingMore ? 1 : 0) + (_hasMore && !_loadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _videos.length) {
                  if (_loadingMore) {
                    return const SizedBox(
                      width: 80,
                      child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54))),
                    );
                  }
                  return _LoadMoreCard(onTap: _loadMore);
                }
                final v = _videos[index];
                return _VideoCard(
                  item: v,
                  onTap: () {
                    if (v.videoUrl != null && v.videoUrl!.isNotEmpty) {
                      Get.to(() => LongVideoPlayerScreen(item: v));
                    } else {
                      toast('Video not available');
                    }
                  },
                );
              },
            ),
          ),
        20.height,
      ],
    );
  }
}

class _LoadMoreCard extends StatelessWidget {
  final VoidCallback onTap;

  const _LoadMoreCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Colors.white54, size: 32),
            8.height,
            Text('Load more', style: secondaryTextStyle(size: 12, color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final LongVideoItem item;
  final VoidCallback onTap;

  const _VideoCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty
                        ? Image.network(
                            item.thumbnailUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: primaryTextStyle(size: 13, color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  6.height,
                  Row(
                    children: [
                      Icon(Icons.thumb_up_outlined, size: 14, color: Colors.white54),
                      4.width,
                      Text('${item.likeCount} Like', style: secondaryTextStyle(size: 11, color: Colors.white54)),
                      12.width,
                      Icon(Icons.chat_bubble_outline, size: 14, color: Colors.white54),
                      4.width,
                      Text('${item.commentCount} Comment', style: secondaryTextStyle(size: 11, color: Colors.white54)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.white12,
      child: const Icon(Icons.videocam, color: Colors.white38, size: 48),
    );
  }
}
