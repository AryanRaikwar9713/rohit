import 'dart:async'; // Added for microtask

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/widgets/video_controls_theme_data_injector.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/main.dart';
import 'package:streamit_laravel/utils/app_common.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/video_players/component/ad_widgets.dart';
import 'package:streamit_laravel/video_players/component/overlay_ad_widget.dart';
import 'package:streamit_laravel/video_players/model/video_model.dart';
import 'package:streamit_laravel/video_players/video_player_controller.dart';
import 'package:streamit_laravel/video_players/y_player_material.dart';
import 'package:y_player/y_player.dart';

/// A customizable YouTube video player widget.
///
/// This widget provides a flexible way to embed and control YouTube videos
/// in a Flutter application, with options for customization and event handling.
class YPlayerWidget extends StatefulWidget {
  /// The URL of the YouTube video to play.
  final String youtubeUrl;

  /// The aspect ratio of the video player. If null, defaults to 16:9.
  final double? aspectRatio;

  /// Whether the video should start playing automatically when loaded.
  final bool autoPlay;

  /// The primary color for the player's UI elements.
  final Color? color;

  /// A widget to display while the video is not yet loaded.
  final Widget? placeholder;

  /// A widget to display while the video is loading.
  final Widget? loadingWidget;

  /// A widget to display if there's an error loading the video.
  final Widget? errorWidget;

  /// A callback that is triggered when the player's state changes.
  final YPlayerStateCallback? onStateChanged;

  /// A callback that is triggered when the video's playback progress changes.
  final YPlayerProgressCallback? onProgressChanged;

  /// A callback that is triggered when the player controller is ready.
  final Function(YPlayerController controller)? onControllerReady;

  /// A callback that is triggered when the player enters full screen mode.
  final Function()? onEnterFullScreen;

  /// A callback that is triggered when the player exits full screen mode.
  final Function()? onExitFullScreen;

  /// The margin around the seek bar.
  final EdgeInsets? seekBarMargin;

  /// The margin around the seek bar in fullscreen mode.
  final EdgeInsets? fullscreenSeekBarMargin;

  /// The margin around the bottom button bar.
  final EdgeInsets? bottomButtonBarMargin;

  /// The margin around the bottom button bar in fullscreen mode.
  final EdgeInsets? fullscreenBottomButtonBarMargin;

  /// Whether to choose the best quality automatically.
  final bool chooseBestQuality;
  final bool isTrailer;

  final VoidCallback? skipTap;
  final VoidCallback? nextEpisode;
  final bool showNextEpisodeButton;

  final String thumbnailImage;

  final SubtitleModel? subTiltle;
  final VideoPlayersController videoPlayerController;

  final String watchedTime;

  final bool hideControls;

  /// Constructs a YPlayer widget.
  ///
  /// The [youtubeUrl] parameter is required and should be a valid YouTube video URL.
  const YPlayerWidget({
    super.key,
    required this.youtubeUrl,
    this.showNextEpisodeButton = false,
    this.aspectRatio,
    this.autoPlay = true,
    this.placeholder,
    required this.isTrailer,
    this.loadingWidget,
    this.errorWidget,
    this.skipTap,
    this.onStateChanged,
    this.onProgressChanged,
    this.onControllerReady,
    this.color,
    this.onEnterFullScreen,
    this.onExitFullScreen,
    this.seekBarMargin,
    this.fullscreenSeekBarMargin,
    this.bottomButtonBarMargin,
    this.fullscreenBottomButtonBarMargin,
    this.chooseBestQuality = true,
    this.nextEpisode,
    this.thumbnailImage = '',
    this.subTiltle,
    required this.videoPlayerController,
    required this.watchedTime,
    this.hideControls = false,
  });

  @override
  YPlayerWidgetState createState() => YPlayerWidgetState();
}

/// The state for the YPlayer widget.
///
/// This class manages the lifecycle of the video player and handles
/// initialization, playback control, and UI updates.
class YPlayerWidgetState extends State<YPlayerWidget> with SingleTickerProviderStateMixin {
  /// The controller for managing the YouTube player.
  late YPlayerController _controller;

  /// The controller for the video display.
  late VideoController _videoController;

  /// Flag to indicate whether the controller is fully initialized and ready.
  bool _isControllerReady = false;
  late ValueChanged<double> onSpeedChanged;
  double currentSpeed = 1.0;
  bool showNextButton = false;
  // Cache built widgets to avoid unnecessary rebuilds
  Widget? cachedLoadingWidget;
  Widget? cachedErrorWidget;
  Widget? cachedPlaceholder;
  bool languageSelected = false;

  @override
  void initState() {
    super.initState();
    _controller = YPlayerController(
      onStateChanged: widget.onStateChanged,
      onProgressChanged: widget.onProgressChanged,
    );
    _videoController = VideoController(_controller.player);

    // Use microtask to avoid blocking UI thread
    Future.microtask(_initializePlayer);

    // Cache widgets
    cachedLoadingWidget = widget.loadingWidget ?? const CircularProgressIndicator.adaptive();
    cachedErrorWidget = widget.errorWidget ?? const Text('Error loading video', style: TextStyle(color: appColorPrimary));
    cachedPlaceholder = widget.placeholder ?? const SizedBox.shrink();
  }

  /// Initializes the video player with the provided YouTube URL and settings.
  Future<void> _initializePlayer() async {
    try {
      // Attempt to initialize the player with the given YouTube URL and settings
      await _controller.initialize(
        widget.youtubeUrl,
        autoPlay: widget.autoPlay,
        aspectRatio: widget.aspectRatio,
        chooseBestQuality: widget.chooseBestQuality,
      );

      if (mounted) {
        // If the widget is still in the tree, update the state
        setState(() {
          _isControllerReady = true;
        });

        // Notify that the controller is ready, if a callback was provided
        if (widget.onControllerReady != null) {
          widget.onControllerReady!(_controller);
          if (widget.watchedTime.isNotEmpty) {
            // If a watched time is provided, seek to that position
            _controller.player.seek(_parseWatchedTime(widget.watchedTime));
          }
        }
      }
    } catch (e) {
      // Log any errors that occur during initialization
      debugPrint('YPlayer: Error initializing player: $e');
      if (mounted) {
        // If there's an error, set the controller as not ready
        setState(() {
          _isControllerReady = false;
        });
      }
    }
  }

  Duration _parseWatchedTime(String watchedTime) {
    final parts = watchedTime.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final seconds = int.parse(parts[2]);
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  Future<void> _handleEnterFullscreen() async {
    if (widget.onEnterFullScreen != null) {
      widget.onEnterFullScreen!();
    } else {
      yPlayerDefaultEnterFullscreen();
    }
  }

  Future<void> _handleExitFullscreen() async {
    isPipModeOn(false);
    if (widget.onExitFullScreen != null) {
      widget.onExitFullScreen!();
    } else {
      yPlayerDefaultExitFullscreen();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the player dimensions based on the available width and aspect ratio
        final aspectRatio = widget.aspectRatio ?? 16 / 9;
        final playerWidth = constraints.maxWidth;
        final playerHeight = playerWidth / aspectRatio;
        // Use ValueListenableBuilder to only rebuild when controller status changes
        return ValueListenableBuilder<YPlayerStatus>(
          valueListenable: _controller.statusNotifier,
          builder: (context, status, _) {
            return Container(
              width: playerWidth,
              height: playerHeight,
              color: Colors.transparent,
              child: _buildPlayerContent(
                playerWidth,
                playerHeight,
                status,
                widget.showNextEpisodeButton,
              ),
            );
          },
        );
      },
    );
  }

  /// Builds the main content of the player based on its current state.
  Widget _buildPlayerContent(double width, double height, YPlayerStatus status, bool showNextEpisodeButton) {
    if (_isControllerReady && _controller.isInitialized) {
      // Always set speed since controller does not expose currentSpeed
      _controller.speed(currentSpeed);

      // If the controller is ready and initialized, show the video player
      return MaterialVideoControlsTheme(
        normal: MaterialVideoControlsThemeData(
          seekBarBufferColor: Colors.grey,
          seekOnDoubleTap: true,
          seekBarPositionColor: widget.color ?? const Color(0xFFFF0000),
          seekBarThumbColor: widget.color ?? const Color(0xFFFF0000),
          seekBarMargin: widget.seekBarMargin ?? EdgeInsets.zero,
          bottomButtonBarMargin: widget.bottomButtonBarMargin ?? const EdgeInsets.only(left: 16, right: 8),
          brightnessGesture: true,
          volumeGesture: true,
          bottomButtonBar: [
            const MaterialPositionIndicator(),
            const Spacer(),
            CustomMaterialFullscreenButton(videoPlayersController: widget.videoPlayerController),
          ],
        ),
        fullscreen: MaterialVideoControlsThemeData(
          volumeGesture: true,
          seekOnDoubleTap: true,
          seekBarMargin: widget.fullscreenSeekBarMargin ?? EdgeInsets.zero,
          bottomButtonBarMargin: widget.fullscreenBottomButtonBarMargin ?? const EdgeInsets.only(left: 16, right: 8, bottom: 16),
          seekBarBufferColor: Colors.grey,
          seekBarPositionColor: widget.color ?? const Color(0xFFFF0000),
          seekBarThumbColor: widget.color ?? const Color(0xFFFF0000),
          bottomButtonBar: [
            const YMaterialPositionIndicator(),
            const Spacer(),
            const MaterialFullscreenButton(),
          ],
        ),
        child: Video(
          controller: _videoController,
          controls: widget.hideControls ? null : MaterialVideoControls,
          width: width,
          height: height,
          filterQuality: FilterQuality.high,
          onEnterFullscreen: _handleEnterFullscreen,
          onExitFullscreen: _handleExitFullscreen,
          aspectRatio: 16 / 9,
          subtitleViewConfiguration: SubtitleViewConfiguration(style: primaryTextStyle()),
        ),
      );
    } else if (status == YPlayerStatus.loading) {
      // If the video is still loading, show a loading indicator
      return Center(child: cachedLoadingWidget);
    } else if (status == YPlayerStatus.error) {
      // If there was an error, show the error widget
      return Center(child: cachedErrorWidget);
    } else {
      // For any other state, show the placeholder or an empty container
      return cachedPlaceholder!;
    }
  }
}

class CustomMaterialFullscreenButton extends StatelessWidget {
  /// Icon for [MaterialFullscreenButton].
  final Widget? icon;

  /// Overriden icon size for [MaterialFullscreenButton].
  final double? iconSize;

  /// Overriden icon color for [MaterialFullscreenButton].
  final Color? iconColor;

  final VideoPlayersController videoPlayersController;

  const CustomMaterialFullscreenButton({
    super.key,
    this.icon,
    this.iconSize,
    this.iconColor,
    required this.videoPlayersController,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => toggleFullscreen(context, videoPlayersController),
      icon: icon ?? (isFullscreen(context) ? const Icon(Icons.fullscreen_exit) : const Icon(Icons.fullscreen)),
      iconSize: iconSize ?? _theme(context).buttonBarButtonSize,
      color: iconColor ?? _theme(context).buttonBarButtonColor,
    );
  }
}

MaterialVideoControlsThemeData _theme(BuildContext context) => FullscreenInheritedWidget.maybeOf(context) == null
    ? MaterialVideoControlsTheme.maybeOf(context)?.normal ?? kDefaultMaterialVideoControlsThemeData
    : MaterialVideoControlsTheme.maybeOf(context)?.fullscreen ?? kDefaultMaterialVideoControlsThemeDataFullscreen;

Future<void> toggleFullscreen(BuildContext context, VideoPlayersController videoPlayersController) {
  if (isFullscreen(context)) {
    return _exitFullscreen(context);
  } else {
    return _yPlayerDefaultEnterFullscreen(context, videoPlayersController);
  }
}

Future<void> _exitFullscreen(BuildContext context) {
  return lock.synchronized(() async {
    if (isFullscreen(context)) {
      if (context.mounted) {
        await Navigator.of(context).maybePop();
        // It is known that this [context] will have a [FullscreenInheritedWidget] above it.
        if (context.mounted) {
          FullscreenInheritedWidget.of(context).parent.refreshView();
        }
      }
      // [exitNativeFullscreen] is moved to [WillPopScope] in [FullscreenInheritedWidget].
      // This is because [exitNativeFullscreen] needs to be called when the user presses the back button.
    }
  });
}

Widget _overlayView(VideoPlayersController videoPlayersController) {
  return Obx(() {
    final overlayAd = videoPlayersController.currentOverlayAd.value;
    if (overlayAd == null) {
      return const SizedBox.shrink();
    }
    return Positioned(
      bottom: isPipModeOn.value ? 2 : 40,
      child: OverlayAdWidget(
        overlayAd: overlayAd,
        isFullScreen: MediaQuery.of(Get.context!).orientation == Orientation.landscape,
        onClose: () {
          videoPlayersController.currentOverlayAd.value = null;
          videoPlayersController.overlayAdTimer?.cancel();
        },
      ),
    );
  });
}

Future<void> _yPlayerDefaultEnterFullscreen(BuildContext context, VideoPlayersController videoPlayersController) {
  final BuildContext ctx = context;
  return lock.synchronized(() async {
    if (!isFullscreen(ctx)) {
      if (ctx.mounted) {
        final stateValue = state(ctx);
        final contextNotifierValue = contextNotifier(ctx);
        final videoViewParametersNotifierValue = videoViewParametersNotifier(ctx);
        final controllerValue = controller(ctx);

        Navigator.of(ctx, rootNavigator: true).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => Material(
              child: Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  VideoControlsThemeDataInjector(
                    // NOTE: Make various *VideoControlsThemeData from the parent context available in the fullscreen context.
                    context: ctx,
                    child: VideoStateInheritedWidget(
                      state: stateValue,
                      contextNotifier: contextNotifierValue,
                      videoViewParametersNotifier: videoViewParametersNotifierValue,
                      disposeNotifiers: false,
                      child: FullscreenInheritedWidget(
                        parent: stateValue,
                        // Another [VideoStateInheritedWidget] inside [FullscreenInheritedWidget] is important to notify about the fullscreen [BuildContext].
                        child: VideoStateInheritedWidget(
                          state: stateValue,
                          contextNotifier: contextNotifierValue,
                          videoViewParametersNotifier: videoViewParametersNotifierValue,
                          disposeNotifiers: false,
                          child: Video(
                            controller: controllerValue,
                            fit: videoViewParametersNotifierValue.value.fit,
                            fill: videoViewParametersNotifierValue.value.fill,
                            alignment: videoViewParametersNotifierValue.value.alignment,
                            aspectRatio: videoViewParametersNotifierValue.value.aspectRatio,
                            filterQuality: videoViewParametersNotifierValue.value.filterQuality,
                            controls: videoViewParametersNotifierValue.value.controls,
                            // Do not acquire or modify existing wakelock in fullscreen mode:
                            wakelock: false,
                            pauseUponEnteringBackgroundMode: stateValue.widget.pauseUponEnteringBackgroundMode,
                            resumeUponEnteringForegroundMode: stateValue.widget.resumeUponEnteringForegroundMode,
                            subtitleViewConfiguration: videoViewParametersNotifierValue.value.subtitleViewConfiguration,
                            onEnterFullscreen: stateValue.widget.onEnterFullscreen,
                            onExitFullscreen: stateValue.widget.onExitFullscreen,
                          ),
                        ),
                      ),
                    ),
                  ),
                  AdView(
                    controller: videoPlayersController,
                    skipInText: (seconds) => locale.value.skipIn(seconds),
                    advertisementText: locale.value.advertisement,
                    skipLabel: locale.value.skip,
                  ),
                  _overlayView(videoPlayersController),
                ],
              ),
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        await onEnterFullscreen(ctx)?.call();
      }
    }
  });
}

class SpeedSliderSheet extends StatefulWidget {
  final double initialSpeed;
  final Color primaryColor;
  final void Function(double) onSpeedChanged;

  const SpeedSliderSheet({
    super.key,
    this.initialSpeed = 1.0,
    required this.onSpeedChanged,
    required this.primaryColor,
  });

  @override
  SpeedSliderSheetState createState() => SpeedSliderSheetState();
}

class SpeedSliderSheetState extends State<SpeedSliderSheet> {
  double _speedValue = 1.0;

  final double _minSpeed = 0.25;
  final double _maxSpeed = 2.0;

  /// Key speeds for labels
  final List<double> _keySpeeds = [0.25, 0.5, 1.0, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _speedValue = widget.initialSpeed;
  }

  void _onChipTapped(double speed) {
    setState(() {
      _speedValue = speed;
    });
    widget.onSpeedChanged(speed);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Playback Speed",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          Text(
            "${_speedValue.toStringAsFixed(1)}x", // Round to 1 decimal place
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Slider(
            value: _speedValue,
            min: _minSpeed,
            max: _maxSpeed,
            activeColor: widget.primaryColor,
            onChanged: (value) {
              final newSpeed = (value * 10).round() / 10;
              setState(() {
                _speedValue = newSpeed;
              });
              widget.onSpeedChanged(newSpeed);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _keySpeeds.map((speed) {
                return GestureDetector(
                  onTap: () => _onChipTapped(speed),
                  child: Chip(
                    label: Text(
                      "${speed}x",
                      style: const TextStyle(fontSize: 12),
                    ),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(40))),
                    backgroundColor: _speedValue == speed ? widget.primaryColor.withValues(alpha: 0.8) : Colors.transparent,
                    labelStyle: TextStyle(
                      color: _speedValue == speed ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class QualitySelectionSheet extends StatelessWidget {
  /// The currently selected quality
  final int selectedQuality;

  /// The primary color of the app
  final Color primaryColor;

  /// List of available quality options
  final List<QualityOption> qualityOptions;

  /// Callback when a quality is selected
  final void Function(int) onQualitySelected;

  const QualitySelectionSheet({
    super.key,
    required this.selectedQuality,
    required this.qualityOptions,
    required this.onQualitySelected,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Video Quality",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: qualityOptions.length,
              itemBuilder: (context, index) {
                final option = qualityOptions[index];
                final isSelected = option.height == selectedQuality;

                return ListTile(
                  title: Text(option.label),
                  trailing: isSelected ? Icon(Icons.check, color: primaryColor) : null,
                  selected: isSelected,
                  selectedColor: primaryColor,
                  onTap: () {
                    Navigator.of(context).pop();
                    onQualitySelected(option.height);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}