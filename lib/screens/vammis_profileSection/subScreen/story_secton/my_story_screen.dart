import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/my_story_controller.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/my_story_responce_model.dart';

class MyStoryScreen extends StatefulWidget {
  final String? storyId;
  final MyStoryController controller;
  const MyStoryScreen(
      {required this.controller, required this.storyId, super.key,});

  @override
  State<MyStoryScreen> createState() => _MyStoryScreenState();
}

class _MyStoryScreenState extends State<MyStoryScreen> {
  PageController? pageController;

  VideoPlayerController? videoPlayerController;
  Duration storyDuration = const Duration(seconds: 5);
  Timer? videoPositionTimer;
  Timer? imageTimer;

  int currentStoryIndex = 0;
  bool isPaused = false;
  bool _isNavigating = false;
  bool _isVideoLoading = false;
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializePageController();
  }

  void _initializePageController() {
    if (pageController != null) return;

    if (widget.controller.activeStories.isEmpty) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && pageController == null) {
          _initializePageController();
        }
      });
      return;
    }

    int initialIndex = 0;
    if (widget.storyId != null) {
      try {
        final storyId = int.parse(widget.storyId!);
        initialIndex = widget.controller.activeStories.indexWhere(
          (element) => element.id == storyId,
        );
        if (initialIndex == -1) initialIndex = 0;
      } catch (e) {
        initialIndex = 0;
      }
    }

    currentStoryIndex = initialIndex;
    pageController = PageController(initialPage: initialIndex);
    _loadStory(initialIndex);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadStory(int index) async {
    if (index < 0 || index >= widget.controller.activeStories.length) return;

    final story = widget.controller.activeStories[index];

    // Dispose previous video controller and timers
    videoPlayerController?.dispose();
    videoPositionTimer?.cancel();
    imageTimer?.cancel();
    videoPlayerController = null;
    _isVideoLoading = false;
    _isVideoPlaying = false;

    if (story.mediaType == 'video' && story.mediaUrl != null) {
      _isVideoLoading = true;
      setState(() {});

      try {
        videoPlayerController = VideoPlayerController.network(
          story.mediaUrl!,
        );

        // Listen to video player state changes
        videoPlayerController!.addListener(_videoPlayerListener);

        await videoPlayerController!.initialize();
        storyDuration = videoPlayerController!.value.duration;

        // Check if video is buffering
        if (videoPlayerController!.value.isBuffering) {
          _isVideoLoading = true;
        } else {
          _isVideoLoading = false;
        }

        // Start playing video
        await videoPlayerController!.play();

        // Wait a bit to check if video actually started playing
        await Future.delayed(const Duration(milliseconds: 300));

        if (videoPlayerController!.value.isPlaying &&
            !videoPlayerController!.value.isBuffering) {
          _isVideoLoading = false;
          _isVideoPlaying = true;
        } else {
          _isVideoLoading = true;
          _isVideoPlaying = false;
        }

        _startVideoPositionListener();
      } catch (e) {
        print('Error loading video: $e');
        storyDuration = const Duration(seconds: 5);
        _isVideoLoading = false;
        _isVideoPlaying = false;
      }
    }
    else {
      // For images, use default 5 seconds
      storyDuration = const Duration(seconds: 5);
      _isVideoLoading = false;
      _isVideoPlaying = false;

      // Start timer for image auto-advance
      imageTimer?.cancel();
      if (!isPaused) {
        imageTimer = Timer(storyDuration, () {
          if (mounted &&
              currentStoryIndex == index &&
              !isPaused &&
              widget.controller.activeStories[index].mediaType == 'image') {
            _goToNextStory();
          }
        });
      }
    }

    setState(() {});
  }

  void _videoPlayerListener() {
    if (videoPlayerController != null &&
        videoPlayerController!.value.isInitialized) {
      final isPlaying = videoPlayerController!.value.isPlaying;
      final wasLoading = _isVideoLoading;

      // Check if video is still loading (buffering)
      final isBuffering = videoPlayerController!.value.isBuffering;

      if (wasLoading && !isBuffering && isPlaying) {
        // Video finished loading and started playing
        _isVideoLoading = false;
        _isVideoPlaying = true;
        if (mounted) {
          setState(() {});
        }
      } else if (isPlaying != _isVideoPlaying) {
        _isVideoPlaying = isPlaying;
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  void _startVideoPositionListener() {
    videoPositionTimer?.cancel();
    if (videoPlayerController != null) {
      videoPositionTimer =
          Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (videoPlayerController != null &&
            videoPlayerController!.value.isInitialized &&
            !isPaused) {
          final position = videoPlayerController!.value.position;
          final duration = videoPlayerController!.value.duration;

          // Check if video is complete (with small buffer to avoid timing issues)
          if (duration.inMilliseconds > 0 &&
              position.inMilliseconds >= duration.inMilliseconds - 100) {
            timer.cancel();
            _goToNextStory();
          }
        }
      });
    }
  }

  void _goToNextStory() {
    if (_isNavigating) return; // Prevent multiple calls
    _isNavigating = true;

    imageTimer?.cancel();
    videoPositionTimer?.cancel();

    // Remove video listener before disposing
    videoPlayerController?.removeListener(_videoPlayerListener);

    if (currentStoryIndex < widget.controller.activeStories.length - 1) {
      final nextIndex = currentStoryIndex + 1;
      pageController
          ?.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      )
          .then((_) {
        if (mounted) {
          _isNavigating = false;
        }
      });
    } else {
      _isNavigating = false;
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  void _goToPreviousStory() {
    if (_isNavigating) return;
    _isNavigating = true;

    // Cancel all timers before navigating
    imageTimer?.cancel();
    videoPositionTimer?.cancel();

    // Remove video listener before disposing
    videoPlayerController?.removeListener(_videoPlayerListener);

    isPaused = false;
    _isVideoLoading = false;
    _isVideoPlaying = false;

    if (currentStoryIndex > 0) {
      pageController
          ?.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      )
          .then((_) {
        if (mounted) {
          _isNavigating = false;
        }
      });
    } else {
      _isNavigating = false;
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
      if (videoPlayerController != null &&
          videoPlayerController!.value.isInitialized) {
        if (isPaused) {
          videoPlayerController!.pause();
        } else {
          videoPlayerController!.play();
        }
      }
      // Pause/resume image timer
      if (isPaused) {
        imageTimer?.cancel();
      } else {
        final story = widget.controller.activeStories[currentStoryIndex];
        if (story.mediaType == 'image') {
          final remainingTime = storyDuration;
          imageTimer?.cancel();
          imageTimer = Timer(remainingTime, () {
            if (mounted && !isPaused) {
              _goToNextStory();
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    videoPlayerController?.removeListener(_videoPlayerListener);
    videoPlayerController?.dispose();
    videoPositionTimer?.cancel();
    imageTimer?.cancel();
    pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() {
          if (widget.controller.isLoading.value ||
              widget.controller.activeStories.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          // Initialize page controller if not already initialized
          if (pageController == null &&
              widget.controller.activeStories.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && pageController == null) {
                _initializePageController();
              }
            });
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (pageController == null) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return Column(
            children: [
              // Progress bars at the top
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    for (int i = 0;
                        i < widget.controller.activeStories.length;
                        i++)
                      Expanded(
                        key: ValueKey(
                            'progress_${widget.controller.activeStories[i].id}_$currentStoryIndex',),
                        child: Padding(
                          padding: EdgeInsets.only(
                            right:
                                i < widget.controller.activeStories.length - 1
                                    ? 4.0
                                    : 0,
                          ),
                          child: _StoryProgressBar(
                            key: ValueKey(
                                'bar_${widget.controller.activeStories[i].id}_${i == currentStoryIndex}',),
                            isActive: i == currentStoryIndex,
                            isCompleted: i < currentStoryIndex,
                            duration: i == currentStoryIndex
                                ? storyDuration
                                : (widget.controller.activeStories[i]
                                            .mediaType ==
                                        'video'
                                    ? const Duration(
                                        seconds:
                                            5,) // Will be updated when loaded
                                    : const Duration(seconds: 5)),
                            onComplete: _goToNextStory,
                            isPaused: (isPaused || _isVideoLoading) &&
                                i == currentStoryIndex,
                            videoController: i == currentStoryIndex
                                ? videoPlayerController
                                : null,
                            isVideoLoading: i == currentStoryIndex && _isVideoLoading,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Story content
              Expanded(
                child: GestureDetector(
                  onTapDown: (details) {
                    print("jkahkjds");
                    final screenWidth = MediaQuery.of(context).size.width;
                    if (details.localPosition.dx < screenWidth / 2) {
                      _goToPreviousStory();
                    } else {
                      _goToNextStory();
                    }
                  },
                  onLongPressStart: (_) => _togglePause(),
                  onLongPressEnd: (_) => _togglePause(),
                  child: PageView.builder(
                    controller: pageController,
                    onPageChanged: (index) {
                      if (currentStoryIndex != index) {
                        _isNavigating = false; // Reset navigation flag
                        isPaused = false; // Reset pause state on story change
                        _isVideoLoading = false;
                        _isVideoPlaying = false;

                        // Remove previous video listener
                        videoPlayerController
                            ?.removeListener(_videoPlayerListener);

                        currentStoryIndex = index;
                        _loadStory(index);
                        setState(() {});
                      }
                    },
                    itemCount: widget.controller.activeStories.length,
                    itemBuilder: (context, index) {
                      final story = widget.controller.activeStories[index];
                      return _StoryViewWidget(
                        story: story,
                        videoController: index == currentStoryIndex
                            ? videoPlayerController
                            : null,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _StoryViewWidget extends StatelessWidget {
  final ActiveStory story;
  final VideoPlayerController? videoController;

  const _StoryViewWidget({
    required this.story,
    this.videoController,
  });

  @override
  Widget build(BuildContext context) {
    if (story.mediaType == 'image') {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: story.mediaUrl != null
            ? Image.network(
                story.mediaUrl!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 50,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
              )
            : const Center(
                child: Icon(Icons.image, color: Colors.white, size: 50),
              ),
      );
    } else if (story.mediaType == 'video') {
      if (videoController != null && videoController!.value.isInitialized) {
        return SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: videoController!.value.size.width,
              height: videoController!.value.size.height,
              child: VideoPlayer(videoController!),
            ),
          ),
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }
    } else {
      return const Center(
        child: Text(
          'Unsupported media type',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }
}

class _StoryProgressBar extends StatefulWidget {
  final bool isActive;
  final bool isCompleted;
  final Duration duration;
  final VoidCallback onComplete;
  final bool isPaused;
  final VideoPlayerController? videoController;
  final bool isVideoLoading;

  const _StoryProgressBar({
    super.key,
    required this.isActive,
    required this.isCompleted,
    required this.duration,
    required this.onComplete,
    this.isPaused = false,
    this.videoController,
    this.isVideoLoading = false,
  });

  @override
  State<_StoryProgressBar> createState() => _StoryProgressBarState();
}

class _StoryProgressBarState extends State<_StoryProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    if (widget.isCompleted) {
      _animationController.value = 1.0;
    } else if (widget.isActive && !widget.isPaused && !widget.isVideoLoading) {
      // Small delay to ensure widget is fully built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            widget.isActive &&
            !widget.isPaused &&
            !widget.isVideoLoading) {
          _startAnimation();
        }
      });
    }
  }

  @override
  void didUpdateWidget(_StoryProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update duration if changed
    if (widget.duration != oldWidget.duration) {
      _animationController.duration = widget.duration;
    }


    if (widget.isVideoLoading && !oldWidget.isVideoLoading) {
      _animationController.stop();
      _timer?.cancel();
    } else if (!widget.isVideoLoading &&
        oldWidget.isVideoLoading &&
        widget.isActive) {
      _animationController.reset();
      _startAnimation();
    }


    if (widget.isActive && !oldWidget.isActive) {
      _animationController.reset();
      _timer?.cancel();
      if (!widget.isVideoLoading) {
        _startAnimation();
      }
    } else if (!widget.isActive && oldWidget.isActive) {
      // Story became inactive - stop animation
      _animationController.stop();
      _timer?.cancel();
    }

    // Handle pause state changes
    if (widget.isPaused && !oldWidget.isPaused) {
      _animationController.stop();
      _timer?.cancel();
    } else if (!widget.isPaused &&
        oldWidget.isPaused &&
        widget.isActive &&
        !widget.isVideoLoading) {
      // Resume animation
      _startAnimation();
    }

    // Handle completion state
    if (widget.isCompleted && !oldWidget.isCompleted) {
      _animationController.value = 1.0;
      _timer?.cancel();
    } else if (!widget.isCompleted && oldWidget.isCompleted) {
      // Story is no longer completed - reset
      _animationController.reset();
    }

    // If video controller changed, restart animation (if not loading)
    if (widget.videoController != oldWidget.videoController &&
        widget.isActive &&
        !widget.isVideoLoading) {
      _timer?.cancel();
      _animationController.reset();
      _startAnimation();
    }
  }

  void _startAnimation() {
    // Don't start if video is loading
    if (!widget.isActive ||
        widget.isPaused ||
        widget.isCompleted ||
        widget.isVideoLoading) {
      return;
    }

    _timer?.cancel();
    _animationController.reset();

    if (widget.videoController != null &&
        widget.videoController!.value.isInitialized) {
      // For video, track video position
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        // Don't update if video is loading or paused
        if (widget.isVideoLoading || widget.isPaused) {
          return;
        }

        if (widget.videoController != null &&
            widget.videoController!.value.isInitialized &&
            widget.isActive &&
            !widget.isPaused &&
            !widget.isCompleted) {
          final position = widget.videoController!.value.position;
          final duration = widget.videoController!.value.duration;

          if (duration.inMilliseconds > 0) {
            final progress = position.inMilliseconds / duration.inMilliseconds;
            setState(() {
              _animationController.value = progress.clamp(0.0, 1.0);
            });

            if (progress >= 0.99) {
              timer.cancel();
              if (widget.isActive && mounted) {
                widget.onComplete();
              }
            }
          }
        } else {
          timer.cancel();
        }
      });
    } else {
      // For images, use timer-based animation
      _animationController.duration = widget.duration;
      _animationController.forward().then((_) {
        if (widget.isActive && mounted && !widget.isCompleted) {
          widget.onComplete();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
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
