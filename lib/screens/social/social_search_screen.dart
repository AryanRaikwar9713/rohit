import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/admob_native_ad_widget.dart';
import 'package:streamit_laravel/configs.dart';
import 'package:streamit_laravel/screens/reels/reel_response_model.dart';
import 'package:streamit_laravel/screens/reels/reels_api.dart';
import 'package:streamit_laravel/screens/social/social_post_responce_Model.dart';
import 'package:streamit_laravel/screens/social/social_api.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_screen.dart' show openVammisProfile, VammisProfileScreen;
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_api.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/get_story_responce_model.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/story_controller.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/view_story_screen.dart';
import 'package:streamit_laravel/utils/mohit/vammis_profile_avtar.dart';
import 'package:streamit_laravel/screens/wammis_search/searchApi.dart';
import 'package:streamit_laravel/screens/wammis_search/search_result_responce_model.dart';
import 'package:streamit_laravel/screens/donation/project_detail_screen.dart';
import 'package:streamit_laravel/screens/reels/reels_screen.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/utils/colors.dart';

class SocialSearchScreen extends StatefulWidget {
  const SocialSearchScreen({super.key});

  @override
  State<SocialSearchScreen> createState() => _SocialSearchScreenState();
}

class _SocialSearchScreenState extends State<SocialSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchApi _searchApi = SearchApi();
  final ReelsApi _reelsApi = ReelsApi();
  final SocialApi _socialApi = SocialApi();
  final StoryApi _storyApi = StoryApi();

  bool _isLoading = false;
  bool _isLoadingRecommended = false;
  SearchResultReponceModel? _searchResults;
  List<Reel> _topReels = [];
  List<SocialPost> _trendingPosts = [];
  SearchResultReponceModel? _suggestedUsers;
  List<StoryUser> _storyUsers = [];
  final Set<int> _followingUserIds = {}; // suggested users follow state

  @override
  void initState() {
    super.initState();
    _loadStories();
    _loadRecommended();
  }

  Future<void> _loadStories() async {
    _storyApi.getStories(
      onSuccess: (d) {
        if (mounted) setState(() => _storyUsers = d.stories ?? []);
      },
      onError: (_) {},
      onFail: (_) {},
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecommended() async {
    if (_isLoadingRecommended) return;
    setState(() => _isLoadingRecommended = true);

    _loadStories();

    await Future.wait([
      _reelsApi.getReels(1, onSuccess: (r) {
        if (mounted) setState(() => _topReels = r.data?.reels ?? []);
      }, onFailure: (_) {}, onError: (_) {},),
      _socialApi.getSocialPost(1, onSuccess: (r) {
        if (mounted) setState(() => _trendingPosts = r.data?.posts ?? []);
      }, onFailure: (_) {}, onError: (_) {},),
    ]);
    _searchApi.searchApi('a', limit: 12, onSuccess: (r) async {
      if (mounted && r.data?.results != null) {
        final users = r.data!.results!.where((e) => e.contentType == 'user').toList();
        if (users.isNotEmpty) setState(() => _suggestedUsers = SearchResultReponceModel(success: true, data: SearchData(results: users)));
      }
    }, onError: (_) async {}, onFailed: (_) async {},);

    if (mounted) setState(() => _isLoadingRecommended = false);
  }

  void _openProfile(int userId, {bool isOwnProfile = false}) {
    if (userId <= 0) return;
    openVammisProfile(userId: userId, isOwnProfile: isOwnProfile, popButton: true);
  }

  void _onFollowUser(int? targetId) {
    if (targetId == null || targetId <= 0) return;
    _socialApi.followUser(
      targetUserId: targetId,
      onSuccess: (value) {
        final isFollowing = value == true || value == 1;
        if (mounted) {
          setState(() {
            if (isFollowing) _followingUserIds.add(targetId);
            else _followingUserIds.remove(targetId);
          });
        }
      },
      onError: (e) => toast(e),
      onFailure: (_) => toast('Failed to update follow'),
    );
  }

  /// User avatar circle: resolves URL and uses CachedNetworkImage so 404 shows placeholder
  Widget _userAvatarCircle({required String url, required double radius}) {
    final resolved = url.isEmpty ? '' : resolveImageUrl(url, pathPrefix: 'storage/avatars/');
    if (resolved.isEmpty) {
      return CircleAvatar(radius: radius, backgroundColor: Colors.grey[800], child: const Icon(Icons.person, color: Colors.grey));
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: resolved,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.grey[800], child: const Icon(Icons.person, color: Colors.grey)),
        errorWidget: (_, __, ___) => Container(color: Colors.grey[800], child: const Icon(Icons.person, color: Colors.grey)),
      ),
    );
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = null);
      return;
    }

    setState(() => _isLoading = true);

    _searchApi.searchApi(
      query.trim(),
      onSuccess: (result) async {
        if (mounted) {
          setState(() {
          _searchResults = result;
          _isLoading = false;
        });
        }
      },
      onError: (error) async {
        if (mounted) {
          setState(() => _isLoading = false);
          toast(error);
        }
      },
      onFailed: (response) async {
        if (mounted) {
          setState(() => _isLoading = false);
          toast("Search failed: ${response.statusCode}");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 400;
    final padding = isNarrow ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: appBackgroundColorDark,
      appBar: AppBar(
        backgroundColor: appBackgroundColorDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 17),
          decoration: InputDecoration(
            hintText: 'Search posts, users, reels...',
            hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 15),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchResults = null);
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {});
            if (value.length >= 2) {
              _performSearch(value);
            } else {
              setState(() => _searchResults = null);
            }
          },
          onSubmitted: _performSearch,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: appColorPrimary))
          : _buildBody(padding, isNarrow),
    );
  }

  Widget _buildBody(double padding, bool isNarrow) {
    final hasQuery = _searchController.text.trim().length >= 2;

    if (hasQuery && _searchResults != null) {
      return _buildSearchResults(padding, isNarrow);
    }

    return RefreshIndicator(
      color: appColorPrimary,
      onRefresh: _loadRecommended,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_storyUsers.isNotEmpty) ...[
              _sectionTitle('Stories', isNarrow, size: 20),
              12.height,
              _buildStoriesStrip(isNarrow),
              20.height,
            ],
            Text(
              'Recommended for you',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: isNarrow ? 20 : 22, fontWeight: FontWeight.w700),
            ),
            14.height,
            if (_isLoadingRecommended)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: appColorPrimary)))
            else ...[
              if (_topReels.isNotEmpty) _sectionTitle('Top reels', isNarrow, size: 18),
              10.height,
              _buildTopReels(isNarrow),
              20.height,
              const AdMobNativeAdWidget(),
              20.height,
              if (_trendingPosts.isNotEmpty) _sectionTitle('Trending posts', isNarrow, size: 18),
              10.height,
              _buildTrendingPosts(padding, isNarrow),
              20.height,
              if (_suggestedUsers?.data?.results != null && _suggestedUsers!.data!.results!.isNotEmpty) _sectionTitle('Suggested users', isNarrow, size: 18),
              10.height,
              if (_suggestedUsers?.data?.results != null) _buildSuggestedUsers(isNarrow),
              28.height,
              _emptySearchHint(isNarrow),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isNarrow, {double? size}) {
    final fontSize = size ?? (isNarrow ? 16 : 18);
    return Text(
      title,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildStoriesStrip(bool isNarrow) {
    return SizedBox(
      height: (isNarrow ? 72 : 88) + 28,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _storyUsers.length > 12 ? 12 : _storyUsers.length,
        itemBuilder: (context, index) {
          final story = _storyUsers[index];
          final avatar = story.user?.avatar ?? '';
          final name = story.user?.username ?? story.user?.name ?? 'User';
          return Padding(
            padding: const EdgeInsets.only(right: 14),
            child: InkWell(
              onTap: () {
                try {
                  if (Get.isRegistered<StoryContrller>()) {
                    Get.find<StoryContrller>().loadStory();
                  } else {
                    Get.put(StoryContrller()).loadStory();
                  }
                  Get.to(() => const ViewStoryScreen());
                } catch (_) {
                  Get.put(StoryContrller());
                  Get.find<StoryContrller>().loadStory();
                  Get.to(() => const ViewStoryScreen());
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WamimsProfileAvtar(image: avatar, story: true, radious: isNarrow ? 32 : 38),
                  8.height,
                  SizedBox(
                    width: isNarrow ? 64 : 76,
                    child: Text(
                      name,
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: isNarrow ? 12 : 13, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptySearchHint(bool isNarrow) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: isNarrow ? 52 : 72, color: Colors.grey[600]),
          16.height,
          Text(
            'Search for posts, users, reels, and projects',
            style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: isNarrow ? 15 : 17),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopReels(bool isNarrow) {
    final itemSize = isNarrow ? 108.0 : 128.0;
    return SizedBox(
      height: itemSize + 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _topReels.length > 10 ? 10 : _topReels.length,
        itemBuilder: (context, index) {
          final reel = _topReels[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                try {
                  Get.to(() => const ReelsScreen());
                } catch (_) {}
              },
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CachedNetworkImage(
                      imageUrl: resolveImageUrl(reel.content?.thumbnailUrl ?? ''),
                      width: itemSize,
                      height: itemSize,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.grey[800], child: const Icon(Icons.video_library, color: Colors.grey)),
                      errorWidget: (_, __, ___) => Container(color: Colors.grey[800], child: const Icon(Icons.video_library, color: Colors.grey)),
                    ),
                  ),
                  8.height,
                  SizedBox(
                    width: itemSize,
                    child: Text(
                      reel.content?.caption ?? 'Reel',
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: isNarrow ? 12 : 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingPosts(double padding, bool isNarrow) {
    final list = _trendingPosts.length > 6 ? _trendingPosts.take(6) : _trendingPosts;
    return Column(
      children: list.map((post) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _PostTile(
            post: post,
            isNarrow: isNarrow,
            onTap: () async {
              final u = await DB().getUser();
              final userId = post.user?.userId != null ? int.tryParse(post.user!.userId.toString()) : null;
              if (userId != null && userId > 0) _openProfile(userId, isOwnProfile: u?.id == userId);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSuggestedUsers(bool isNarrow) {
    final users = _suggestedUsers!.data!.results!.take(10).toList();
    return Column(
      children: users.map((r) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _SuggestedUserTile(
          result: r,
          isNarrow: isNarrow,
          isFollowing: _followingUserIds.contains(r.contentId),
          onFollow: () async {
            final id = r.contentId ?? 0;
            if (id <= 0) return;
            _socialApi.followUser(
              targetUserId: id,
              onSuccess: (value) {
                final isFollowing = value == true || value == 1;
                if (mounted) {
                  setState(() {
                  if (isFollowing) {
                    _followingUserIds.add(id);
                  } else {
                    _followingUserIds.remove(id);
                  }
                });
                }
              },
              onError: (e) => toast(e),
              onFailure: (_) => toast('Failed to update follow'),
            );
          },
          onTap: () {
            final id = r.contentId ?? 0;
            if (id > 0) _openProfile(id);
          },
        ),
      ),).toList(),
    );
  }

  Widget _buildSearchResults(double padding, bool isNarrow) {
    final results = _searchResults!.data?.results ?? [];
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: isNarrow ? 56 : 72, color: Colors.grey[600]),
            16.height,
            Text('No results for "${_searchController.text.trim()}"', style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 16), textAlign: TextAlign.center),
          ],
        ),
      );
    }

    final posts = results.where((r) => r.contentType == 'post').toList();
    final users = results.where((r) => r.contentType == 'user').toList();
    final reels = results.where((r) => r.contentType == 'reel').toList();
    final projects = results.where((r) => r.contentType == 'project').toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (users.isNotEmpty) ...[_sectionTitle('Users', isNarrow), 8.height, ...users.map((u) => _buildUserItem(u, isNarrow, onFollow: () => _onFollowUser(u.contentId))), 16.height],
          if (posts.isNotEmpty) ...[_sectionTitle('Posts', isNarrow), 8.height, ...posts.map((p) => _buildPostItem(p, isNarrow)), 16.height],
          if (reels.isNotEmpty) ...[_sectionTitle('Reels', isNarrow), 8.height, ...reels.map((r) => _buildReelItem(r, isNarrow)), 16.height],
          if (projects.isNotEmpty) ...[_sectionTitle('Projects', isNarrow), 8.height, ...projects.map((p) => _buildProjectItem(p, isNarrow))],
        ],
      ),
    );
  }

  Widget _buildUserItem(Result user, bool isNarrow, {VoidCallback? onFollow}) {
    final id = user.contentId ?? 0;
    final isFollowing = id > 0 && _followingUserIds.contains(id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (id > 0) _openProfile(id);
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.all(isNarrow ? 12 : 14),
          decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              _userAvatarCircle(
                url: (user.imageUrl ?? user.avatarUrl ?? '').trim(),
                radius: isNarrow ? 26.0 : 30.0,
              ),
              14.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.contentTitle ?? 'User', style: GoogleFonts.poppins(color: Colors.white, fontSize: isNarrow ? 16 : 17, fontWeight: FontWeight.w600)),
                    if (user.extraData?.followersCount != null) 4.height,
                    if (user.extraData?.followersCount != null) Text('${user.extraData!.followersCount} followers', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              if (onFollow != null && id > 0)
                TextButton(
                  onPressed: onFollow,
                  style: TextButton.styleFrom(
                    backgroundColor: isFollowing ? Colors.grey[700] : appColorPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(isFollowing ? 'Following' : 'Follow', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostItem(Result post, bool isNarrow) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.all(isNarrow ? 12 : 14),
        decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(14)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(imageUrl: resolveImageUrl(post.imageUrl), width: 72, height: 72, fit: BoxFit.cover, errorWidget: (_, __, ___) => const Icon(Icons.image)),
              ),
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty) 14.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.contentTitle != null) Text(post.contentTitle!, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (post.contentDescription != null) 6.height,
                  if (post.contentDescription != null) Text(post.contentDescription!, style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReelItem(Result reel, bool isNarrow) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          try { Get.to(() => const ReelsScreen()); } catch (_) {}
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.all(isNarrow ? 12 : 14),
          decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              if (reel.imageUrl != null && reel.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(imageUrl: resolveImageUrl(reel.imageUrl), width: 72, height: 72, fit: BoxFit.cover, errorWidget: (_, __, ___) => const Icon(Icons.video_library)),
                ),
              if (reel.imageUrl != null && reel.imageUrl!.isNotEmpty) 14.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [const Icon(Icons.play_circle_outline, color: appColorPrimary, size: 20), 6.width, Text('Reel', style: GoogleFonts.poppins(color: appColorPrimary, fontSize: 14, fontWeight: FontWeight.w600))]),
                    6.height,
                    Text(reel.contentTitle ?? 'Reel', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectItem(Result project, bool isNarrow) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          final id = project.contentId ?? 0;
          if (id > 0) {
            try { Get.to(() => ProjectDetailScreen(id: id)); } catch (_) {}
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.all(isNarrow ? 12 : 14),
          decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(14)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (project.imageUrl != null && project.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(imageUrl: resolveImageUrl(project.imageUrl), width: 72, height: 72, fit: BoxFit.cover, errorWidget: (_, __, ___) => const Icon(Icons.folder)),
                ),
              if (project.imageUrl != null && project.imageUrl!.isNotEmpty) 14.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.contentTitle ?? 'Project', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (project.extraData?.fundingPercentage != null) 6.height,
                    if (project.extraData?.fundingPercentage != null) Text('${project.extraData!.fundingPercentage}% funded', style: GoogleFonts.poppins(color: appColorPrimary, fontSize: 14)),
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

class _PostTile extends StatelessWidget {
  final SocialPost post;
  final VoidCallback onTap;
  final bool isNarrow;

  const _PostTile({required this.post, required this.onTap, this.isNarrow = false});

  @override
  Widget build(BuildContext context) {
    final imageSize = isNarrow ? 96.0 : 110.0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.all(isNarrow ? 12 : 14),
        decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(14)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: resolveImageUrl(post.imageUrl),
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey[800], height: imageSize, width: imageSize, child: const Icon(Icons.image, color: Colors.grey)),
                  errorWidget: (_, __, ___) => Container(color: Colors.grey[800], height: imageSize, width: imageSize, child: const Icon(Icons.image, color: Colors.grey)),
                ),
              ),
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty) 14.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    post.title ?? post.caption ?? 'Post',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: isNarrow ? 15 : 16, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (post.caption != null && post.caption!.isNotEmpty) 6.height,
                  if (post.caption != null)
                    Text(
                      post.caption!,
                      style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: isNarrow ? 13 : 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

class _SuggestedUserAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;

  const _SuggestedUserAvatar({required this.imageUrl, required this.radius});

  @override
  Widget build(BuildContext context) {
    final resolved = imageUrl.isEmpty ? '' : resolveImageUrl(imageUrl, pathPrefix: 'storage/avatars/');
    if (resolved.isEmpty) {
      return CircleAvatar(radius: radius, backgroundColor: Colors.grey[800], child: const Icon(Icons.person, color: Colors.grey, size: 28));
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: resolved,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.grey[800], child: const Icon(Icons.person, color: Colors.grey)),
        errorWidget: (_, __, ___) => Container(color: Colors.grey[800], child: const Icon(Icons.person, color: Colors.grey)),
      ),
    );
  }
}

class _SuggestedUserTile extends StatelessWidget {
  final Result result;
  final bool isNarrow;
  final bool isFollowing;
  final VoidCallback onFollow;
  final VoidCallback onTap;

  const _SuggestedUserTile({
    required this.result,
    required this.isNarrow,
    required this.isFollowing,
    required this.onFollow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isNarrow ? 12 : 14, vertical: 12),
      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(30),
            child: _SuggestedUserAvatar(
                imageUrl: (result.imageUrl ?? result.avatarUrl ?? '').trim(),
                radius: isNarrow ? 26 : 28,
              ),
          ),
          14.width,
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    result.contentTitle ?? 'User',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: isNarrow ? 15 : 16, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (result.extraData?.followersCount != null) 4.height,
                  if (result.extraData?.followersCount != null)
                    Text(
                      '${result.extraData!.followersCount} followers',
                      style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                    ),
                ],
              ),
            ),
          ),
          Material(
            color: isFollowing ? Colors.grey.shade700 : appColorPrimary,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: onFollow,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  isFollowing ? 'Connected' : 'Follow',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
