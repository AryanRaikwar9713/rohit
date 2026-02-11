import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs_lite.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/donation/model/get_project_list_responce_model.dart';
import 'package:streamit_laravel/screens/donation/project_detail_screen.dart';
import 'package:streamit_laravel/screens/profile/profile_controller.dart';
import 'package:streamit_laravel/screens/reels/reel_response_model.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/social_account/s_media_account_contrller.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/social_account/socila_media_account_model.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/create_story_screen.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/my_story_controller.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/my_story_responce_model.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/my_story_screen.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/user_post_view_screen.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/user_reel_screen.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_controller.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/models/vammis_profile_model.dart'
    as vammis_model;
import 'package:streamit_laravel/screens/vammis_profileSection/edit_vammis_profile_screen.dart';
import 'package:streamit_laravel/screens/wamims_setting_screen/setting_screen.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/mohit/campain_project_card.dart';
import 'package:streamit_laravel/utils/mohit/custom_like_button.dart';
import 'package:streamit_laravel/utils/mohit/vammis_profile_avtar.dart';

/// Apna gradient - yellow-orange (Impact/Events jaisa)
const LinearGradient _profileGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class VammisProfileScreen extends StatefulWidget {
  final int userId;
  final bool isOwnProfile;
  final popButton;

  const VammisProfileScreen({
    required this.userId,
    required this.isOwnProfile,
    required this.popButton,
    super.key,
  });

  @override
  State<VammisProfileScreen> createState() => _VammisProfileScreenState();
}

class _VammisProfileScreenState extends State<VammisProfileScreen> {
  final VammisProfileController controller = Get.put(VammisProfileController());
  final ScrollController scrollController = ScrollController();
  final SocialMediaController socialMediaController = Get.put(SocialMediaController());
  MyStoryController? myStoryController;

  final Map<String,String> mediaIcons = {
    'youtube':'assets/icons/social_media/youtube.png',
    'instagram':'assets/icons/social_media/instagram.png',
    'facebook':'assets/icons/social_media/facebook.png',
    'twitter':'assets/icons/social_media/twitter.png',
    'linkedin':'assets/icons/social_media/linkedin.png',
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollController.addListener(_scrollListener);
    socialMediaController.getSocialAccount();
    if(widget.isOwnProfile)
      {
        myStoryController = Get.put(MyStoryController());
      }

  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (controller.currentTab.value == 0) {
        controller.loadMorePost();
      } else if (controller.currentTab.value == 1) {
        controller.loadMoreReel();
      } else if (controller.currentTab.value == 2) {
        controller.loadMoreProjects();
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Get.delete<VammisProfileController>();
    if(widget.isOwnProfile)
      {
        Get.delete<MyStoryController>();
      }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Load profile on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.profileResponse.value == null ||
          controller.currentUserId != widget.userId) {
        controller.loadUserProfile(widget.userId);
      }
    });

    return Scaffold(

      //
      backgroundColor: appScreenBackgroundDark,

      //
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // leading: SizedBox(),
        leading: (widget.popButton)
            ? IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              )
            : const SizedBox(),
        title: Obx(() {
          final user = controller.profileResponse.value?.data?.user;
          final name = user?.username ??
              (user != null
                  ? '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim()
                  : 'Profile');
          return Text(
            name.isEmpty ? 'Profile' : name,
            style: boldTextStyle(size: 18, color: Colors.white),
          );
        }),
        centerTitle: true,
        actions: [
          const CustomStreamButton(),
          // IconButton(
          //   onPressed: () => controller.refreshProfile(),
          //   icon: const Icon(Icons.more_vert, color: Colors.white),
          // ),
          if (widget.isOwnProfile)
            IconButton(
                onPressed: () {
                  Get.to(() => const SettingScreen());
                },
                icon: const Icon(Icons.settings, color: Colors.white),),

          if (widget.isOwnProfile)
            IconButton(
                onPressed: () {
                  Get.to(() => const CreateStoryScreen());
                },
                icon: const Icon(Icons.add_circle_rounded, color: Colors.white),),
        ],
      ),

      //
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: appColorPrimary),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.withOpacity(0.7),
                ),
                16.height,
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                24.height,
                ElevatedButton(
                  onPressed: () => controller.loadUserProfile(widget.userId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColorPrimary,
                  ),
                  child: const Text('Retry',
                      style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          );
        }

        final profileData = controller.profileResponse.value?.data;
        if (profileData == null) {
          return const Center(
            child: Text(
              'No profile data found',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: ()async{
            await controller.refreshProfile();
            await socialMediaController.getSocialAccount();
          },
          color: appColorPrimary,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(profileData, controller),

                _buildMyStory(),
                
                _budildSocialAccounts(socialMediaController),

                // Tab Bar
                _buildTabBar(controller),

                // Content based on selected tab
                Obx(() => _buildTabContent(controller)),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(
      vammis_model.VammisProfile profile, VammisProfileController controller,) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Picture and Stats Row
          Row(
            children: [
              // Profile Picture
              WamimsProfileAvtar(
                image: profile.user?.avatarUrl ?? '',
                onTap: () {
                  print('${profile.user?.avatarUrl}');
                  print('${profile.user?.avatar}');

                  String? imageUrl;
                  if (profile.user?.avatarUrl != null &&
                      profile.user!.avatarUrl!.isNotEmpty) {
                    imageUrl = profile.user?.avatarUrl ?? '';
                  }

                  if (imageUrl == null &&
                      profile.user?.avatar != null &&
                      profile.user!.avatar!.isNotEmpty) {
                    imageUrl = profile.user?.avatar;
                  }

                  if (imageUrl == null) {
                    return;
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Blur(
                            child: Container(
                              clipBehavior: Clip.hardEdge,
                              margin: const EdgeInsetsGeometry.symmetric(horizontal: 50),
                              decoration:const BoxDecoration(
                                shape: BoxShape.circle,

                              ),
                              child: Hero(
                                  tag: 'profileImage',
                                  child: Image.network(imageUrl ?? ''),),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),

              const SizedBox(width: 20),

              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      '${profile.contentCounts?.posts ?? profile.stats?.posts ?? 0}',
                      'Posts',
                    ),
                    _buildStatItem(
                      '${profile.user?.followersCount ?? profile.stats?.followers ?? 0}',
                      'Followers',
                    ),
                    _buildStatItem(
                      '${profile.user?.followingCount ?? profile.stats?.following ?? 0}',
                      'Following',
                    ),
                  ],
                ),
              ),
            ],
          ),

          16.height,

          // Name and Bio
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.user?.username ??
                    (profile.user != null
                        ? '${profile.user!.firstName ?? ''} ${profile.user!.lastName ?? ''}'
                            .trim()
                        : 'User'),
                style: boldTextStyle(size: 16, color: Colors.white),
              ),
              if (profile.user?.bio != null &&
                  profile.user!.bio!.isNotEmpty) ...[
                8.height,
                Text(
                  profile.user!.bio!,
                  style: primaryTextStyle(size: 14, color: Colors.white70),
                ),
              ],
            ],
          ),

          16.height,

          // Additional Stats (Projects, Donations, Engagement)
          if (profile.contentCounts != null || profile.stats != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (profile.contentCounts?.projects != null ||
                    profile.stats?.projects != null)
                  _buildStatItem(
                    '${profile.contentCounts?.projects ?? profile.stats?.projects ?? 0}',
                    'Projects',
                  ),
                if (profile.isOwnProfile == true) ...[
                  // Show donations given only for own profile
                  if (profile.stats?.donationsGiven != null)
                    _buildStatItem(
                      profile.stats!.donationsGiven!.toStringAsFixed(0),
                      'Donated',
                    ),
                ] else ...[
                  // Show donations received only for other user's profile
                  if (profile.stats?.donationsReceived != null)
                    _buildStatItem(
                      '${profile.stats!.donationsReceived ?? 0}',
                      'Donations',
                    ),
                ],
                if (profile.stats?.totalEngagement != null)
                  _buildStatItem(
                    '${profile.stats!.totalEngagement ?? 0}',
                    'Engagement',
                  ),
              ],
            ),
            16.height,
          ],

          // Personal Information (Only for own profile)
          if (profile.isOwnProfile == true) ...[
            _buildPersonalInfoSection(profile),
            16.height,
          ],

          // Social Links (Show for all profiles if available)
          if (profile.user != null &&
              (profile.user!.facebookLink != null ||
                  profile.user!.instagramLink != null ||
                  profile.user!.twitterLink != null ||
                  profile.user!.dribbbleLink != null)) ...[
            _buildSocialLinksSection(profile.user!),
            16.height,
          ],

          // Popularity Data (Only for own profile)
          if (profile.isOwnProfile == true &&
              profile.popularityData != null) ...[
            _buildPopularitySection(profile.popularityData!),
            16.height,
          ],

          // Recent Activities (Only for own profile)
          if (profile.isOwnProfile == true &&
              profile.recentActivities != null &&
              profile.recentActivities!.isNotEmpty) ...[
            _buildRecentActivitiesSection(profile.recentActivities!),
            16.height,
          ],

          // Action Buttons

          if (widget.isOwnProfile) ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Get.to(() => const EditVammisProfileScreen())?.then((result) {
                    if (result == true) {
                      controller.refreshProfile();
                    }
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: _profileGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _profileGradient.colors.first.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    "Edit Profile",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _buildFollowButton(profile, controller),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      toast('Message feature coming soon');
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade700),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Message',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => _profileGradient.createShader(bounds),
          child: Text(
            count,
            style: boldTextStyle(size: 18, color: Colors.white),
          ),
        ),
        4.height,
        Text(
          label,
          style: secondaryTextStyle(size: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildFollowButton(
      vammis_model.VammisProfile profile, VammisProfileController controller,) {
    final isFollowing = profile.isFollowing ?? false;

    if (widget.isOwnProfile) {
      return OutlinedButton(
        onPressed: () {
          Get.to(() => const EditVammisProfileScreen())?.then((result) {
            if (result == true) {
              controller.refreshProfile();
            }
          });
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade700),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ElevatedButton(
      onPressed: () => controller.toggleFollow(),
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing ? Colors.grey.shade800 : appColorPrimary,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        isFollowing ? 'Connected' : 'Connect',
        style: TextStyle(
          color: isFollowing ? Colors.green : Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTabBar(VammisProfileController controller) {
    return Container(
      color: appScreenBackgroundDark,
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              'Posts',
              0,
              Icons.grid_on,
              controller,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              'Reels',
              1,
              Icons.video_library,
              controller,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              'Projects',
              2,
              Icons.folder,
              controller,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    String label,
    int index,
    IconData icon,
    VammisProfileController controller,
  ) {
    return Obx(() {
      final isSelected = controller.currentTab.value == index;
      return InkWell(
        onTap: () => controller.currentTab.value = index,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? _profileGradient.colors.first
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected)
                ShaderMask(
                  shaderCallback: (b) => _profileGradient.createShader(b),
                  child: Icon(icon, color: Colors.white, size: 20),
                )
              else
                Icon(icon, color: Colors.grey, size: 20),
              const SizedBox(width: 6),
              if (isSelected)
                ShaderMask(
                  shaderCallback: (b) => _profileGradient.createShader(b),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                )
              else
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTabContent(VammisProfileController controller) {
    switch (controller.currentTab.value) {
      case 0:
        return _buildPostsTab(controller);
      case 1:
        return _buildReelsTab(controller);
      case 2:
        return _buildProjectsTab(controller);
      default:
        return _buildPostsTab(controller);
    }
  }

  Widget _buildPostsTab(VammisProfileController controller) {
    if (controller.isLoadingPosts.value && controller.userPosts.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: appColorPrimary),
        ),
      );
    }

    if (controller.userPosts.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_outlined,
                size: 64,
                color: Colors.grey.shade600,
              ),
              16.height,
              Text(
                'No posts yet',
                style: TextStyle(color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        top: 12,
        bottom: 80,
        left: 10,
        right: 10,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: controller.userPosts.length,
      itemBuilder: (context, index) {
        final post = controller.userPosts[index];
        return GestureDetector(
          onTap: () {
            Get.to(const UserPostViewScreen());
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _profileGradient.colors.first.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: post.imageUrl != null && post.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: post.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade800,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: appColorPrimary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade800,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      color: Colors.grey.shade800,
                      child: Text(
                        "${post.caption}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReelsTab(VammisProfileController controller) {
    if (controller.isLoadingReels.value && controller.userReels.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: appColorPrimary),
        ),
      );
    }

    if (controller.userReels.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library_outlined,
                size: 64,
                color: Colors.grey.shade600,
              ),
              16.height,
              Text(
                'No reels yet',
                style: TextStyle(color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        top: 12,
        bottom: 80,
        left: 10,
        right: 10,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: controller.userReels.length,
      itemBuilder: (context, index) {
        final Reel reel = controller.userReels[index];
        final thumbUrl = reel.content?.thumbnailUrl ?? '';

        return GestureDetector(
          onTap: () {
            Get.to(UserReelScreen(reelId: reel.id ?? 0));
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _profileGradient.colors.first.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: thumbUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: thumbUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade800,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: appColorPrimary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade800,
                        child: const Icon(
                          Icons.videocam_off,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade800,
                      child: const Center(
                        child: Icon(Icons.video_library_outlined, color: Colors.grey),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProjectsTab(VammisProfileController controller) {
    if (controller.isLoadingProjects.value && controller.userProjects.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: appColorPrimary),
        ),
      );
    }

    if (controller.userProjects.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_outlined,
                size: 64,
                color: Colors.grey.shade600,
              ),
              16.height,
              Text(
                'No projects yet',
                style: TextStyle(color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        top: 16,
        bottom: 80,
        left: 14,
        right: 14,
      ),
      itemCount: controller.userProjects.length +
          (controller.hasMoreProjects.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == controller.userProjects.length) {
          if (controller.hasMoreProjects.value) {
            controller.loadMoreProjects();
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(color: appColorPrimary),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        final project = controller.userProjects[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _profileGradient.colors.first.withOpacity(0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CampaignProjectCard(project: project),
        );
      },
    );
  }

  // Personal Information Section (Only for own profile)
  Widget _buildPersonalInfoSection(vammis_model.VammisProfile profile) {
    final user = profile.user;
    if (user == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _profileGradient.colors.first.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (b) => _profileGradient.createShader(b),
            child: Text(
              'Personal Information',
              style: boldTextStyle(size: 16, color: Colors.white),
            ),
          ),
          16.height,
          if (user.email != null && user.email!.isNotEmpty) ...[
            _buildInfoRow(Icons.email, 'Email', user.email!),
            12.height,
          ],
          if (user.mobile != null && user.mobile!.isNotEmpty) ...[
            _buildInfoRow(Icons.phone, 'Mobile', user.mobile!),
            12.height,
          ],
          if (user.walletPoints != null) ...[
            _buildInfoRow(
              Icons.account_balance_wallet,
              'Wallet Points',
              '${user.walletPoints}',
            ),
          ],
        ],
      ),
    );
  }

  // Social Links Section
  Widget _buildSocialLinksSection(vammis_model.User user) {
    final List<Widget> links = [];

    if (user.facebookLink != null && user.facebookLink.toString().isNotEmpty) {
      links.add(_buildSocialLink(
          Icons.facebook, 'Facebook', user.facebookLink.toString(),),);
    }
    if (user.instagramLink != null &&
        user.instagramLink.toString().isNotEmpty) {
      links.add(_buildSocialLink(
          Icons.camera_alt, 'Instagram', user.instagramLink.toString(),),);
    }
    if (user.twitterLink != null && user.twitterLink.toString().isNotEmpty) {
      links.add(_buildSocialLink(
          Icons.alternate_email, 'Twitter', user.twitterLink.toString(),),);
    }
    if (user.dribbbleLink != null && user.dribbbleLink.toString().isNotEmpty) {
      links.add(_buildSocialLink(
          Icons.palette, 'Dribbble', user.dribbbleLink.toString(),),);
    }

    if (links.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Social Links',
            style: boldTextStyle(size: 16, color: Colors.white),
          ),
          12.height,
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: links,
          ),
        ],
      ),
    );
  }

  // Popularity Section (Only for own profile)
  Widget _buildPopularitySection(vammis_model.PopularityData popularityData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popularity',
            style: boldTextStyle(size: 16, color: Colors.white),
          ),
          16.height,
          if (popularityData.popularityScore != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Popularity Score',
                  style: primaryTextStyle(size: 14, color: Colors.white70),
                ),
                Text(
                  popularityData.popularityScore!.toStringAsFixed(1),
                  style: boldTextStyle(size: 16, color: appColorPrimary),
                ),
              ],
            ),
            12.height,
          ],
          if (popularityData.popularityTrend != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trend',
                  style: primaryTextStyle(size: 14, color: Colors.white70),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: popularityData.popularityTrend == 'up'
                        ? Colors.green.withOpacity(0.2)
                        : popularityData.popularityTrend == 'down'
                            ? Colors.red.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        popularityData.popularityTrend == 'up'
                            ? Icons.trending_up
                            : popularityData.popularityTrend == 'down'
                                ? Icons.trending_down
                                : Icons.trending_flat,
                        size: 16,
                        color: popularityData.popularityTrend == 'up'
                            ? Colors.green
                            : popularityData.popularityTrend == 'down'
                                ? Colors.red
                                : Colors.grey,
                      ),
                      4.width,
                      Text(
                        popularityData.popularityTrend!.toUpperCase(),
                        style: secondaryTextStyle(
                          size: 12,
                          color: popularityData.popularityTrend == 'up'
                              ? Colors.green
                              : popularityData.popularityTrend == 'down'
                                  ? Colors.red
                                  : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Recent Activities Section (Only for own profile)
  Widget _buildRecentActivitiesSection(
      List<vammis_model.RecentActivity> activities,) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activities',
            style: boldTextStyle(size: 16, color: Colors.white),
          ),
          16.height,
          ...activities.take(5).map((activity) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _getActivityIcon(activity.type),
                      color: appColorPrimary,
                      size: 20,
                    ),
                    12.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (activity.title != null &&
                              activity.title!.isNotEmpty)
                            Text(
                              activity.title!,
                              style: primaryTextStyle(
                                  size: 14, color: Colors.white,),
                            ),
                          if (activity.description != null &&
                              activity.description!.isNotEmpty) ...[
                            4.height,
                            Text(
                              activity.description!,
                              style: secondaryTextStyle(
                                  size: 12, color: Colors.white70,),
                            ),
                          ],
                          if (activity.createdAt != null) ...[
                            4.height,
                            Text(
                              _formatDate(activity.createdAt!),
                              style: secondaryTextStyle(
                                  size: 11, color: Colors.white54,),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),),
        ],
      ),
    );
  }

  // Helper methods
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: appColorPrimary, size: 20),
        12.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: secondaryTextStyle(size: 12, color: Colors.white70),
              ),
              2.height,
              Text(
                value,
                style: primaryTextStyle(size: 14, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLink(IconData icon, String label, String url) {
    return GestureDetector(
      onTap: () {
        // Open URL in browser
        // You can use url_launcher package here
        toast('Opening $label');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[700]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: appColorPrimary, size: 18),
            8.width,
            Text(
              label,
              style: secondaryTextStyle(size: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'post':
        return Icons.post_add;
      case 'reel':
        return Icons.video_library;
      case 'project':
        return Icons.folder;
      case 'donation':
        return Icons.favorite;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _budildSocialAccounts(SocialMediaController c) {
    return Obx(() {
      if(c.account.isEmpty)
        {
          return const SizedBox();
        }
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Other Platforms",style: TextStyle(color: Colors.white,fontSize: 16),),
            10.height,
            Row(
              children: [
                for(final SocialMediaAccount a in c.account)
                  GestureDetector(
                    onTap: (){launchUrl(Uri.parse(a.url??''));},
                    child: Container(
                      margin: const EdgeInsetsGeometry.symmetric(horizontal: 3),
                      padding: const EdgeInsets.all(5),
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white),
                      ),
                      child: Image.asset(mediaIcons[a.platform]??''),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
      
    },);
  }


  Widget _buildMyStory()
  {
    if(myStoryController==null)
      {
        return const SizedBox();
      }
    return Obx((){

      //
      // return ElevatedButton(onPressed: (){
      //   myStoryController?.getMyStory();
      // }, child: Text("test"));

      if(myStoryController?.activeStories.isEmpty??true)
        {
          return ElevatedButton(onPressed: (){
            myStoryController?.getMyStory();
          }, child: const Text("test"),);
          return const SizedBox();
        }
      else
        {
           return  Align(
             alignment: Alignment.centerLeft,
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Padding(
                   padding: const EdgeInsetsGeometry.symmetric(horizontal: 10,vertical: 5),
                     child: Text("Story",style: TextStyle(color: Colors.white,fontSize: 16,fontFamily: GoogleFonts.poppins().fontFamily),),),
                 10.height,
                 SingleChildScrollView(
                   scrollDirection: Axis.horizontal,
                   child: Padding(
                    padding: const EdgeInsetsGeometry.only(left: 5,right: 5,bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                      for(final ActiveStory s in myStoryController?.activeStories??[])
                        GestureDetector(
                          onTap: (){
                            Get.to(MyStoryScreen(storyId: s.id.toString(),controller: myStoryController!));
                          },
                          child: Container(

                            margin: const EdgeInsetsGeometry.symmetric(horizontal: 5),
                            clipBehavior: Clip.hardEdge,
                            height: 50,
                            width: 50,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white),
                            ),
                            child: Container(
                              clipBehavior: Clip.hardEdge,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Image.network(s.mediaUrl??'',fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.videocam),),
                            ),
                          ),
                        ),

                        if(kDebugMode)
                          IconButton(onPressed: (){
                            myStoryController?.getMyStory();
                          }, icon: const Icon(Icons.refresh),),

                    ],),
                             ),
                 ),
               ],
             ),
           );
        }

    });
  }
  
  
}
