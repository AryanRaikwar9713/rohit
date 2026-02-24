import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/configs.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/auth/model/login_response.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/models/vammis_profile_model.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/get_story_responce_model.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/story_controller.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/view_story_screen.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/create_story_screen.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/my_story_screen.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/my_story_controller.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_api.dart';
import 'package:streamit_laravel/utils/mohit/vammis_profile_avtar.dart';

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
    final fromLogin = (u?.profileImage ?? '').trim();
    if (fromLogin.isNotEmpty) {
      setState(() => _yourStoryAvatar = fromLogin);
      return;
    }
    final userId = u?.id ?? -1;
    if (userId <= 0) return;
    VammisProfileApi().getUserProfile(
      userId: userId,
      onError: (_) {},
      onFailure: (_) {},
      onSuccess: (VammisProfileResponceModel profile) {
        final avatar = profile.data?.user?.avatarUrl ?? profile.data?.user?.avatar?.toString();
        if (avatar != null && avatar.trim().isNotEmpty && mounted) {
          setState(() => _yourStoryAvatar = avatar.trim());
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
                  child: _YourStoryCircle(
                    avatar: _yourStoryAvatar.isNotEmpty ? _yourStoryAvatar : (_currentUser?.profileImage ?? ''),
                    displayName: ((_currentUser?.fullName ?? '').trim().isNotEmpty)
                        ? _currentUser!.fullName
                        : 'Your story',
                    onTap: () => _showYourStoryOptions(context, hasOwnStory),
                  ),
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
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade600, width: 2),
            ),
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: Colors.grey.shade800,
              backgroundImage: avatar.trim().isEmpty
                  ? null
                  : NetworkImage(resolveImageUrl(avatar, pathPrefix: 'storage/avatars/')),
              child: avatar.trim().isEmpty
                  ? const Icon(Icons.person, color: Colors.white54, size: 32)
                  : null,
            ),
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
