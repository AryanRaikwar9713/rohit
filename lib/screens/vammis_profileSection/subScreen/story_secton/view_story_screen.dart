import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/get_story_responce_model.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/story_controller.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_screen.dart' show openVammisProfile;
import 'package:streamit_laravel/utils/mohit/vammis_profile_avtar.dart';



class ViewStoryScreen extends StatefulWidget {
  const ViewStoryScreen({super.key});

  @override
  State<ViewStoryScreen> createState() => _ViewStoryScreenState();
}

class _ViewStoryScreenState extends State<ViewStoryScreen> {

  late StoryContrller storyContrller;

  @override
  void initState() {
    super.initState();
    storyContrller = Get.isRegistered<StoryContrller>()
        ? Get.find<StoryContrller>()
        : Get.put(StoryContrller());
    if (storyContrller.storyList.isEmpty) {
      storyContrller.loadStory();
    } else {
      storyContrller.setStoryPageController();
    }
  }

  @override
  void dispose() {
    storyContrller.markStoryUserViewed(storyContrller.selectedUserId.value);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body:Obx((){

          if(storyContrller.isLoading.value)
            {
              return const Center(child: CircularProgressIndicator(),);
            }
          if(storyContrller.storyList.isEmpty)
            {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_stories_outlined, size: 64, color: Colors.grey[400]),
                    16.height,
                    Text('No stories yet', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                  ],
                ),
              );
            }

          return  PageView(
            controller: storyContrller.userPageController,
            onPageChanged: (index){
              storyContrller.onUserChage(storyContrller.storyList[index].user?.id??0);
            },
            children: [
              for(final StoryUser model in storyContrller.storyList)
                _buildUsers(model,storyContrller),
            ],
          );

        }),
      ),
    );
  }


  Column _buildUsers(StoryUser model, StoryContrller controller) {
    final userId = model.user?.id ?? 0;
    final stories = model.stories ?? [];
    return Column(
      children: [
        10.height,
        // White progress bars (fill when viewing this user's stories) - like WhatsApp status
        Obx(() {
          if (controller.selectedUserId.value != userId) return const SizedBox.shrink();
          final currentIndex = stories.indexWhere(
            (s) => s.id == controller.selectedStoryId.value,
          );
          final idx = currentIndex < 0 ? 0 : currentIndex;
          if (stories.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                for (int i = 0; i < stories.length; i++)
                  Expanded(
                    key: ValueKey('other_progress_${model.user?.id}_${stories[i].id}_$i'),
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: i < stories.length - 1 ? 4.0 : 0,
                      ),
                      child: _OtherUserStoryProgressBar(
                        key: ValueKey('other_bar_${stories[i].id}_${i == idx}'),
                        isActive: i == idx,
                        isCompleted: i < idx,
                        duration: const Duration(seconds: 7),
                        onComplete: controller.nextStory,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
        ListTile(
          onTap: () async {
            if (userId <= 0) return;
            final u = await DB().getUser();
            openVammisProfile(userId: userId, isOwnProfile: u?.id == userId);
          },
          leading: WamimsProfileAvtar(
            image: model.user?.avatar ?? '',
            story: true,
            radious: 30,
          ),
          title: Text(
            model.user?.username ?? 'No Name',
            style: TextStyle(
              color: Colors.white,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
        ),
        Expanded(
          child: PageView(
            controller: controller.storyPageController,
            onPageChanged: (index) {
              controller.onStoryChange(
                model.stories?[index].id ?? 0,
                model.user?.id ?? 0,
              );
            },
            children: [
              for (final StoryStory story in stories) _buildStory(story, controller),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStoryMedia(StoryStory s) {
    final hasMedia = (s.mediaUrl ?? '').trim().isNotEmpty;
    if (!hasMedia) {
      return Center(child: Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey[600]));
    }
    if (s.mediaType == 'video') {
      return Center(child: Icon(Icons.videocam_outlined, size: 64, color: Colors.grey[400]));
    }
    return Center(
      child: Image.network(
        s.mediaUrl!,
        fit: BoxFit.contain,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : Center(child: CircularProgressIndicator(value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1) : null)),
        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, color: Colors.white54, size: 40),
      ),
    );
  }

  Container _buildStory(StoryStory s, StoryContrller controller) {
    final storyId = s.id ?? 0;
    final size = MediaQuery.of(context).size;
    return Container(
      color: Colors.grey[900],
      alignment: Alignment.center,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Double‑tap anywhere to like this story.
        onDoubleTap: () => controller.toggleLikeOnStory(storyId),
        child: Stack(
          children: [
            _buildStoryMedia(s),

            // Left tap area (reserved for future: previous story).
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: SizedBox(
                height: double.infinity,
                width: size.width * .3,
              ),
            ),

            // Right tap area – go to next story (same as before).
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: InkWell(
                onTap: () {
                  controller.nextStory();
                },
                child: SizedBox(
                  width: size.width * .3,
                ),
              ),
            ),

            // Small heart + like state at bottom‑left (only when liked).
            Positioned(
              left: 16,
              bottom: 24,
              child: Obx(() {
                final liked = controller.isStoryLiked(storyId);
                if (!liked) return const SizedBox.shrink();
                return Row(
                  children: const [
                    Icon(
                      Icons.favorite,
                      color: Colors.redAccent,
                      size: 22,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Liked',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Progress bar for other user's story - white line that fills (like WhatsApp status).
class _OtherUserStoryProgressBar extends StatefulWidget {
  final bool isActive;
  final bool isCompleted;
  final Duration duration;
  final VoidCallback onComplete;

  const _OtherUserStoryProgressBar({
    super.key,
    required this.isActive,
    required this.isCompleted,
    required this.duration,
    required this.onComplete,
  });

  @override
  State<_OtherUserStoryProgressBar> createState() =>
      _OtherUserStoryProgressBarState();
}

class _OtherUserStoryProgressBarState extends State<_OtherUserStoryProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    if (widget.isCompleted) {
      _controller.value = 1.0;
    } else if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.isActive && !widget.isCompleted) {
          _controller.forward().then((_) {
            if (mounted && widget.isActive) widget.onComplete();
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(_OtherUserStoryProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.isCompleted && !oldWidget.isCompleted) {
      _controller.value = 1.0;
    } else if (!widget.isCompleted && oldWidget.isCompleted) {
      _controller.reset();
    }
    if (widget.isActive && !oldWidget.isActive) {
      _controller.reset();
      if (!widget.isCompleted) {
        _controller.forward().then((_) {
          if (mounted && widget.isActive) widget.onComplete();
        });
      }
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double progress = widget.isCompleted
            ? 1.0
            : (widget.isActive ? _animation.value : 0.0);
        return Container(
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      },
    );
  }
}


