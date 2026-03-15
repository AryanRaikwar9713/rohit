import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/configs.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/auth/model/login_response.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/models/vammis_profile_model.dart';
import 'package:streamit_laravel/utils/app_common.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/get_story_responce_model.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/story_controller.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/view_story_screen.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/create_story_screen.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/my_story_screen.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/my_story_controller.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_api.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_controller.dart';
import 'package:streamit_laravel/utils/mohit/vammis_profile_avtar.dart';

/// Same avatar resolution as profile page: prefer avatarUrl, then avatar (string or map with url).
String _avatarStringFromProfileUser(User? user) {
  if (user == null) return '';
  final a = user.avatarUrl;
  if (a != null && a.trim().isNotEmpty) return a;
  final b = user.avatar;
  if (b == null) return '';
  if (b is String && b.trim().isNotEmpty) return b;
  // Backend may send avatar as object; try to get url from map without strict typing
  try {
    if (b is Map && (b as Map).isNotEmpty) {
      for (final key in ['url', 'avatar_url', 'avatar']) {
        final v = (b as Map)[key];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
    }
  } catch (_) {}
  final s = b.toString().trim();
  return (s.isNotEmpty && !s.contains('Instance of')) ? s : '';
}

/// Instagram-style stories row: "Your story" + followed users' stories.
/// Use on Home and Social so stories from followed users appear in one place.
class HomeStoriesRow extends StatefulWidget {
  const HomeStoriesRow({super.key});

  @override
  State<HomeStoriesRow> createState() => _HomeStoriesRowState();
}

class _HomeStoriesRowState extends State<HomeStoriesRow> {
  late StoryContrller _storyController;
  UserData? _currentUser;
  /// Avatar for "Your story" — from login user or fallback from vammis profile API.
  String _yourStoryAvatar = '';

  @override
  void initState() {
    super.initState();
    _storyController = Get.isRegistered<StoryContrller>()
        ? Get.find<StoryContrller>()
        : Get.put(StoryContrller());
    _loadCurrentUserAndAvatar();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _storyController.loadStory();
    });
  }

  Future<void> _loadCurrentUserAndAvatar() async {
    final u = await DB().getUser();
    if (!mounted) return;
    setState(() => _currentUser = u);
    final userId = u?.id ?? loginUserData.value.id;

    // 1) Prefer cached profile from VammisProfileController (same source as profile page)
    if (userId > 0 && Get.isRegistered<VammisProfileController>()) {
      final profileCtrl = Get.find<VammisProfileController>();
      if (profileCtrl.currentUserId == userId && profileCtrl.profileResponse.value?.data?.user != null) {
        final cached = _avatarStringFromProfileUser(profileCtrl.profileResponse.value!.data!.user);
        if (cached.isNotEmpty && mounted) {
          setState(() => _yourStoryAvatar = cached);
        }
      }
    }

    // 2) Else use login/DB profile_image if present (until profile API returns)
    final fromGlobal = (loginUserData.value.profileImage ?? '').trim();
    final fromDb = (u?.profileImage ?? '').trim();
    final fromLogin = fromGlobal.isNotEmpty ? fromGlobal : fromDb;
    if (fromLogin.isNotEmpty && _yourStoryAvatar.isEmpty && mounted) {
      setState(() => _yourStoryAvatar = fromLogin);
    }

    if (userId <= 0) return;

    // 3) Always fetch profile API so story circle gets same avatar as profile page
    VammisProfileApi().getUserProfile(
      userId: userId,
      onError: (_) {},
      onFailure: (_) {},
      onSuccess: (VammisProfileResponceModel profile) {
        final avatar = _avatarStringFromProfileUser(profile.data?.user);
        if (avatar.isNotEmpty && mounted) {
          setState(() => _yourStoryAvatar = avatar);
        }
      },
    );
  }

  void _showYourStoryOptions(BuildContext context, bool hasOwnStory) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add_circle_outline, color: Colors.white70),
                title: Text('Add story', style: boldTextStyle(size: 16, color: Colors.white)),
                subtitle: Text('Upload a new story', style: secondaryTextStyle(size: 12, color: Colors.grey)),
                onTap: () {
                  Get.back();
                  Get.to(() => const CreateStoryScreen());
                },
              ),
              ListTile(
                leading: Icon(hasOwnStory ? Icons.auto_stories : Icons.auto_stories_outlined, color: Colors.white70),
                title: Text('View my story', style: boldTextStyle(size: 16, color: Colors.white)),
                subtitle: Text(
                  hasOwnStory ? 'See your active story' : "You haven't added a story yet",
                  style: secondaryTextStyle(size: 12, color: Colors.grey),
                ),
                onTap: () async {
                  Get.back();
                  // Always fetch my stories from API — don't rely on get_stories including own story
                  final c = Get.isRegistered<MyStoryController>()
                      ? Get.find<MyStoryController>()
                      : Get.put(MyStoryController());
                  await c.getMyStory();
                  if (!context.mounted) return;
                  if (c.activeStories.isNotEmpty) {
                    Get.to(MyStoryScreen(
                      controller: c,
                      storyId: c.activeStories.first.id.toString(),
                    ),);
                  } else {
                    Get.to(() => const CreateStoryScreen());
                  }
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasOwnStory = _storyController.storyList.any((s) => s.isOwnStory == true);

      return Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 14),
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.grey.shade900),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Obx(() {
                    // Same avatar source as profile page: prefer profile API/cached, then login/DB
                    final pic = _yourStoryAvatar.isNotEmpty
                        ? _yourStoryAvatar
                        : ((loginUserData.value.profileImage ?? '').trim().isNotEmpty
                            ? loginUserData.value.profileImage!
                            : (_currentUser?.profileImage ?? ''));
                    final name = ((_currentUser?.fullName ?? loginUserData.value.fullName ?? '').trim().isNotEmpty)
                        ? (_currentUser?.fullName ?? loginUserData.value.fullName ?? 'Your story')
                        : 'Your story';
                    return _YourStoryCircle(
                      avatar: pic,
                      displayName: name,
                      onTap: () => _showYourStoryOptions(context, hasOwnStory),
                    );
                  }),
                ),
                for (int i = 0; i < _storyController.storyList.length; i++)
                  if (_storyController.storyList[i].isOwnStory != true) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _StoryCircleItem(
                        story: _storyController.storyList[i],
                        seen: _storyController.hasViewedStory(_storyController.storyList[i].user?.id),
                        onTap: () {
                          _storyController.setStoryPageController(initialPage: i);
                          Get.to(() => const ViewStoryScreen());
                        },
                      ),
                    ),
                  ],
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _YourStoryCircle extends StatelessWidget {
  final String avatar;
  final String displayName;
  final VoidCallback onTap;

  const _YourStoryCircle({
    required this.avatar,
    required this.displayName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          WamimsProfileAvtar(
            image: avatar,
            story: false,
            radious: 36,
            onTap: onTap,
          ),
          6.height,
          SizedBox(
            width: 72,
            child: Text(
              displayName,
              style: secondaryTextStyle(size: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryCircleItem extends StatelessWidget {
  final StoryUser story;
  final bool seen;
  final VoidCallback onTap;

  const _StoryCircleItem({
    required this.story,
    required this.seen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          WamimsProfileAvtar(
            image: story.user?.avatar?.toString() ?? '',
            story: true,
            storySeen: seen,
            radious: 36,
            onTap: onTap,
          ),
          6.height,
          SizedBox(
            width: 72,
            child: Text(
              story.user?.username ?? 'Unknown',
              style: secondaryTextStyle(size: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
