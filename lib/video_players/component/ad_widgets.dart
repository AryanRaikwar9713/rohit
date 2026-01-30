import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/utils/app_common.dart';
import 'package:streamit_laravel/video_players/video_player_controller.dart';
import '../../utils/colors.dart';
import '../component/custom_progress_bar.dart';

class AdView extends StatelessWidget {
  final VideoPlayersController controller;
  final String Function(int) skipInText;
  final String advertisementText;
  final String skipLabel;

  const AdView({
    super.key,
    required this.controller,
    required this.skipInText,
    required this.advertisementText,
    required this.skipLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isAdPlaying.value) {
        return const SizedBox.shrink();
      }
      return Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          GestureDetector(
              onTap: () async {
                final ad = controller.preRollAds.isNotEmpty && controller.currentAdIndex.value < controller.preRollAds.length ? controller.preRollAds[controller.currentAdIndex.value] : null;
                final clickUrl = ad?.clickThroughUrl;
                if (clickUrl != null && clickUrl.isNotEmpty) {
                  await launchUrl(Uri.parse(clickUrl));
                }
              },
              child: Video(
                controller: controller.adVideoController,
                controls: (state) => const SizedBox.shrink(),
              )),
          if (controller.isAdPlaying.value && !isPipModeOn.value) ...[
            AdProgressBar(controller: controller),
          ],
          if (controller.isCurrentAdSkippable.value && !isPipModeOn.value) ...[
            Positioned(
              top: 10,
              right: 10,
              child: Obx(
                () => Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: controller.adSkipTimer.value > 0
                      ? Text(
                          skipInText(controller.adSkipTimer.value),
                          style: primaryTextStyle(),
                        )
                      : InkWell(
                          onTap: controller.skipAd,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              skipLabel,
                              style: primaryTextStyle(),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
          if (!isPipModeOn.value)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  advertisementText,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class AdProgressBar extends StatelessWidget {
  final VideoPlayersController controller;

  const AdProgressBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 6,
      child: StreamBuilder<Duration>(
        stream: controller.adPlayer.stream.position,
        builder: (context, snapshot) {
          final adPosition = snapshot.data ?? Duration.zero;
          final adDuration = controller.adPlayer.state.duration;
          return StreamBuilder<bool>(
              stream: controller.adPlayer.stream.playing,
              builder: (context, playingSnapshot) {
                final isPlaying = playingSnapshot.data ?? false;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          isPlaying ? controller.adPlayer.pause() : controller.adPlayer.play();
                        },
                        child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: appColorPrimary, size: 34),
                      ),
                      Expanded(
                        child: CustomProgressBar(
                          position: adPosition,
                          duration: adDuration,
                          adBreaks: const [],
                          isAdPlaying: true,
                        ),
                      ),
                    ],
                  ),
                );
              });
        },
      ),
    );
  }
}