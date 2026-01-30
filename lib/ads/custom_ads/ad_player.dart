import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/video_players/y_player_widget.dart';
import 'package:streamit_laravel/video_players/video_player_controller.dart';
import 'package:streamit_laravel/video_players/model/video_model.dart';
import 'package:streamit_laravel/screens/live_tv/live_tv_details/model/live_tv_details_response.dart';
import 'package:streamit_laravel/utils/extension/string_extention.dart';
import 'package:y_player/y_player.dart';

import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/colors.dart';

class AdPlayer extends StatefulWidget {
  final String videoUrl;
  final double? height;
  final bool isFromPlayerAd;
  final ValueChanged<RxBool>? startSkipTimer;

  const AdPlayer({
    super.key,
    required this.videoUrl,
    this.height,
    this.isFromPlayerAd = false,
    this.startSkipTimer,
  });

  @override
  State<AdPlayer> createState() => _AdPlayerState();
}

class _AdPlayerState extends State<AdPlayer> {
  late final Player _player;
  late final VideoController _controller;

  final RxBool hasError = false.obs;
  final RxBool isPlaying = true.obs;
  final RxBool isBuffering = false.obs;
  final RxBool isMuted = true.obs;

  late final VideoPlayersController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayersController(
      videoModel: VideoPlayerModel().obs,
      liveShowModel: LiveShowModel(),
      isTrailer: false.obs,
      onWatchNextEpisode: null,
    );

    if (!widget.videoUrl.isYoutubeLink) {
      _player = Player(
        configuration: PlayerConfiguration(
          muted: widget.isFromPlayerAd ? false : isMuted.value,
        ),
      );

      _controller = VideoController(_player);

      if (widget.videoUrl.isNotEmpty) {
        _player.open(Media(widget.videoUrl)).catchError((e) {
          hasError.value = true;
        });
      } else {
        hasError.value = true;
      }
      _player.stream.buffering.listen((buffering) {
        isBuffering.value = buffering;
        if (!buffering) {
          if (widget.isFromPlayerAd) {
            widget.startSkipTimer?.call(true.obs);
          }
        }
      });
      _player.stream.playing.listen((playing) {
        if (playing) {
          isPlaying.value = true;
        } else {
          isPlaying.value = false;
        }
      });
    }
  }

  @override
  void dispose() {
    if (!widget.videoUrl.isYoutubeLink) {
      _player.dispose();
    }
    super.dispose();
  }

  void _toggleMute() {
    if (widget.videoUrl.isYoutubeLink) {
      isMuted.value = !isMuted.value;
      controller.youtubePlayerController.value.player.setVolume(isMuted.value ? 0 : 100);
    } else {
      isMuted.value = !isMuted.value;
      _player.setVolume(isMuted.value ? 0 : 100);
    }
  }

  // void _togglePlay() {
  //   if (widget.videoUrl.isYoutubeLink) {
  //     isPlaying.value = !isPlaying.value;
  //     if (isPlaying.value) {
  //       controller.youtubePlayerController.value.play();
  //     } else {
  //       controller.youtubePlayerController.value.pause();
  //     }
  //   } else {
  //     isPlaying.value = !isPlaying.value;
  //     if (isPlaying.value) {
  //       _player.play();
  //     } else {
  //       _player.pause();
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (widget.videoUrl.isYoutubeLink) {
      return Obx(() {
        if (hasError.value) return errorWidget();
        return Stack(
          children: [
            YPlayerWidget(
              youtubeUrl: widget.videoUrl,
              isTrailer: false,
              videoPlayerController: controller,
              watchedTime: '',
              loadingWidget: LoaderWidget(loaderColor: appColorPrimary.withAlpha(100)),
              onStateChanged: (status) {
                if (status == YPlayerStatus.paused) {
                  isPlaying.value = false;
                } else if (status == YPlayerStatus.playing) {
                  isPlaying.value = true;
                }
              },
              onControllerReady: (yController) {
                controller.initializeYoutubePlayer(yController);
                if (!widget.isFromPlayerAd) {
                  yController.player.setVolume(0);
                } else {
                  widget.startSkipTimer?.call(true.obs);
                }
              },
              hideControls: true,
            ),

            // Positioned(
            //   bottom: 14,
            //   left: 8,
            //   child: InkWell(
            //     onTap: _togglePlay,
            //     child: Container(
            //       height: 24,
            //       width: 24,
            //       decoration: BoxDecoration(color: appColorSecondary.withValues(alpha: 0.5), shape: BoxShape.circle),
            //       child: isPlaying.value
            //           ? Icon(
            //               Icons.pause,
            //               size: 18,
            //               color: white,
            //             )
            //           : Icon(
            //               Icons.play_arrow,
            //               size: 18,
            //               color: white,
            //             ),
            //     ),
            //   ),
            // ),
            if (!widget.isFromPlayerAd) ...[
              Positioned(
                bottom: 14,
                right: 8,
                child: InkWell(
                  onTap: _toggleMute,
                  child: Container(
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(color: appColorSecondary.withValues(alpha: 0.5), shape: BoxShape.circle),
                    child: isMuted.value
                        ? const Icon(
                            Icons.volume_off,
                            size: 18,
                            color: white,
                          )
                        : const Icon(
                            Icons.volume_up,
                            size: 18,
                            color: white,
                          ),
                  ),
                ),
              ),
            ],
          ],
        );
      });
    } else {
      return Theme(
        data: ThemeData(
          brightness: Brightness.dark,
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: appScreenBackgroundDark,
          ),
          primaryColor: Colors.white,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            bodySmall: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: Obx(() {
            if (hasError.value) return errorWidget();

            return SizedBox(
              height: widget.height ?? 200,
              width: Get.width,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Video(controller: _controller, controls: (state) => const SizedBox.shrink()),
                  if (!widget.isFromPlayerAd) ...[
                    Positioned(
                      bottom: 14,
                      right: 8,
                      child: InkWell(
                        onTap: _toggleMute,
                        child: Container(
                          height: 24,
                          width: 24,
                          decoration: BoxDecoration(color: appColorSecondary.withValues(alpha: 0.5), shape: BoxShape.circle),
                          child: isMuted.value
                              ? const Icon(
                                  Icons.volume_off,
                                  size: 18,
                                  color: white,
                                )
                              : const Icon(
                                  Icons.volume_up,
                                  size: 18,
                                  color: white,
                                ),
                        ),
                      ),
                    ),
                  ],
                  Obx(
                    () => isBuffering.value ? LoaderWidget(loaderColor: appColorPrimary.withAlpha(100)) : const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          }),
        ),
      );
    }
  }

  Widget errorWidget() {
    return Container(
      height: 200,
      width: Get.width,
      decoration: boxDecorationDefault(color: appScreenBackgroundDark),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 34, color: white),
          10.height,
          Text(
            locale.value.videoNotFound,
            style: boldTextStyle(size: 16, color: white),
          ),
        ],
      ),
    );
  }
}
