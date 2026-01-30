import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pod_player/pod_player.dart';
import 'package:streamit_laravel/ads/model/custom_ad_response.dart';
import 'package:streamit_laravel/components/cached_image_widget.dart';
import 'package:streamit_laravel/components/device_not_supported_widget.dart';
import 'package:streamit_laravel/generated/assets.dart';
import 'package:streamit_laravel/utils/app_common.dart';
import 'package:streamit_laravel/video_players/component/ad_widgets.dart';
import 'package:streamit_laravel/video_players/component/custom_ad_widget.dart';
import 'package:streamit_laravel/video_players/component/custom_overlay.dart';
import 'package:streamit_laravel/video_players/component/overlay_ad_widget.dart';
import 'package:streamit_laravel/video_players/component/rent_details_component.dart';
import 'package:streamit_laravel/video_players/video_description_widget.dart';
import 'package:streamit_laravel/video_players/video_settings_dialog.dart';
import 'package:streamit_laravel/video_players/y_player_widget.dart';

import '../components/loader_widget.dart';
import '../main.dart';
import '../screens/live_tv/live_tv_details/model/live_tv_details_response.dart';
import '../utils/colors.dart';
import '../utils/common_base.dart';
import '../utils/constants.dart';
import 'embedded_video/embedded_video_player.dart';
import 'model/video_model.dart';
import 'video_player_controller.dart';

// ignore: must_be_immutable
class VideoPlayersComponent extends StatelessWidget {
  final VideoPlayerModel videoModel;
  final LiveShowModel? liveShowModel;
  final bool isTrailer;
  final bool isPipMode;
  final bool hasNextEpisode;
  final bool isFromDownloads;
  final bool isLoading;
  final bool isComingSoonScreen;

  final VoidCallback? onWatchNow;

  final bool showWatchNow;

  final VoidCallback? onWatchNextEpisode;

  VideoPlayersComponent({
    super.key,
    required this.videoModel,
    this.liveShowModel,
    this.isTrailer = true,
    this.isPipMode = false,
    this.hasNextEpisode = false,
    this.isFromDownloads = false,
    this.isLoading = false,
    this.onWatchNow,
    this.showWatchNow = false,
    this.isComingSoonScreen = false,
    this.onWatchNextEpisode,
  });

  late VideoPlayersController controller = Get.put(
    VideoPlayersController(
      isTrailer: isTrailer.obs,
      videoModel: videoModel.obs,
      liveShowModel: liveShowModel ?? LiveShowModel(),
      onWatchNextEpisode: onWatchNextEpisode,
      isFromDownloads: isFromDownloads.obs,
    ),
    tag: videoModel.id.toString(),
  );

  bool get isLive => liveShowModel != null;

  bool get isVideoTypeYoutube => controller.videoUploadType.value.toLowerCase() == PlayerTypes.youtube.toLowerCase();

  bool get isVideoTypeOther =>
      (controller.videoUploadType.value.toLowerCase() == PlayerTypes.hls.toLowerCase() ||
          controller.videoUploadType.value.toLowerCase() == PlayerTypes.local.toLowerCase() ||
          controller.videoUploadType.value.toLowerCase() == PlayerTypes.url.toLowerCase() ||
          controller.videoUploadType.value.toLowerCase() == PlayerTypes.file.toLowerCase()) &&
      !isLive;

  bool get isVimeo => controller.videoUploadType.toLowerCase() == PlayerTypes.vimeo.toLowerCase();

  bool get isWebView =>
      isVimeo || (isLive ? liveShowModel?.streamType.toLowerCase() == PlayerTypes.embedded.toLowerCase() : (controller.videoUploadType.value.toLowerCase() == PlayerTypes.embedded.toLowerCase()));

  String getVideoURLLink() {
    String url = "";
    if (isLive) {
      url = controller.liveShowModel.posterImage;
    } else {
      if (videoModel.thumbnailImage.isNotEmpty) {
        url = videoModel.thumbnailImage;
      } else if (videoModel.posterImage.isNotEmpty) {
        url = videoModel.posterImage;
      } else {}
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        // Calculate skip and watch now button visibility
        final bool skipBtnVisible = (isComingSoonScreen ? showWatchNow : isTrailer && !controller.playNextVideo.value);
        final bool watchNowBtnVisible = (isComingSoonScreen ? showWatchNow : isTrailer || showWatchNow || (videoModel.isPurchased == false || videoModel.isPurchased == true)) == true && isTrailer;
        if (!watchNowBtnVisible && !skipBtnVisible && _customAd() != null && !controller.hasShownCustomAd.value) {
          controller.hasShownCustomAd.value = true;
          Future.delayed(
            const Duration(milliseconds: 100),
            () {
              showCustomAd(onlyPop: true);
            },
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: isPipModeOn.value ? 110 : 220,
              width: Get.width,
              child: Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  if (isLoggedIn.value) ...[
                    if (!isSupportedDevice.value) ...[
                      DeviceNotSupportedComponent(title: videoModel.name),
                    ] else ...<Widget>[
                      if (controller.isBuffering.isTrue)
                        SizedBox(
                          height: isPipModeOn.value ? 110 : 220,
                          width: Get.width,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (getVideoURLLink().isNotEmpty)
                                CachedImageWidget(
                                  url: getVideoURLLink(),
                                  fit: BoxFit.cover,
                                  width: Get.width,
                                  height: Get.height,
                                )
                              else
                                Container(
                                  height: isPipModeOn.value ? 110 : 200,
                                  width: Get.width,
                                  decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius(0)),
                                ),
                              Container(
                                height: 45,
                                width: 45,
                                decoration: boxDecorationDefault(
                                  shape: BoxShape.circle,
                                  color: btnColor,
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (!controller.isTrailer.value && isMoviePaid(requiredPlanLevel: videoModel.requiredPlanLevel))
                        GestureDetector(
                          onTap: () {
                            onSubscriptionLoginCheck(
                              callBack: () {},
                              videoAccess: videoModel.movieAccess,
                              planId: videoModel.planId,
                              planLevel: videoModel.requiredPlanLevel,
                              isPurchased: videoModel.isPurchased,
                            );
                          },
                          child: SizedBox(
                            height: isPipModeOn.value ? 110 : 220,
                            width: Get.width,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (getVideoURLLink().isNotEmpty)
                                  Image.network(
                                    getVideoURLLink(),
                                    height: isPipModeOn.value ? 110 : 200,
                                    width: Get.width,
                                    fit: BoxFit.cover,
                                  )
                                else
                                  Container(
                                    height: isPipModeOn.value ? 110 : 200,
                                    width: Get.width,
                                    decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius(0)),
                                  ),
                                Container(
                                  height: 45,
                                  width: 45,
                                  decoration: boxDecorationDefault(
                                    shape: BoxShape.circle,
                                    color: btnColor,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (videoModel.movieAccess == MovieAccess.payPerView && videoModel.isPurchased == false && !controller.isTrailer.value)
                        GestureDetector(
                          onTap: () {
                            AlertDialog(
                              title: Text(locale.value.rentDetails, style: boldTextStyle(size: 18)),
                              content: Text(
                                locale.value.rentedesc(videoModel.availableFor, videoModel.duration),
                                style: secondaryTextStyle(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: Text(locale.value.close, style: boldTextStyle(color: appColorPrimary)),
                                ),
                              ],
                            );
                          },
                          child: SizedBox(
                            height: isPipModeOn.value ? 110 : 220,
                            width: Get.width,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (getVideoURLLink().isNotEmpty)
                                  Image.network(
                                    getVideoURLLink(),
                                    height: isPipModeOn.value ? 110 : 200,
                                    width: Get.width,
                                    fit: BoxFit.cover,
                                  )
                                else
                                  Container(
                                    height: isPipModeOn.value ? 110 : 200,
                                    width: Get.width,
                                    decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius(0)),
                                  ),
                                Container(
                                  height: 45,
                                  width: 45,
                                  decoration: boxDecorationDefault(
                                    shape: BoxShape.circle,
                                    color: btnColor,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (isWebView || isVideoTypeYoutube || isVideoTypeOther || (isLive && liveShowModel!.serverUrl.isNotEmpty))
                        buildVideoWidget(context)
                      else
                        Container(
                          height: isPipModeOn.value ? 110 : 200,
                          width: Get.width,
                          decoration: boxDecorationDefault(
                            color: appScreenBackgroundDark,
                          ),
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
                        ),
                      Positioned(
                        bottom: isVideoTypeOther ? 32 : 16,
                        right: isVideoTypeOther ? 52 : 50,
                        child: GestureDetector(
                          onTap: () async {
                            controller.isBuffering(true);
                            await controller.pause();
                            if (_customAd() != null) {
                              controller.hasShownCustomAd.value = true;
                              showCustomAd();
                            } else {
                              Future.delayed(
                                const Duration(seconds: 1),
                                () {
                                  controller.isBuffering(false);
                                  onSubscriptionLoginCheck(
                                    callBack: () {
                                      onWatchNow?.call();
                                    },
                                    planId: videoModel.planId,
                                    videoAccess: videoModel.planId <= 0 && videoModel.requiredPlanLevel <= 0 ? MovieAccess.freeAccess : MovieAccess.paidAccess,
                                    planLevel: videoModel.requiredPlanLevel,
                                  );
                                },
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: white),
                              color: Colors.transparent,
                            ),
                            child: Text(
                              locale.value.skip,
                              style: secondaryTextStyle(color: white),
                            ),
                          ),
                        ),
                      ).visible(isComingSoonScreen ? showWatchNow : isTrailer && !controller.playNextVideo.value && controller.isVideoPlaying.value),
                      Positioned(
                        bottom: 16,
                        right: 48,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 1),
                          opacity: controller.playNextVideo.value.getIntBool().toDouble(),
                          child: GestureDetector(
                            onTap: () async {
                              controller.playNextVideo(false);
                              controller.isBuffering(true);
                              if (!controller.isTrailer.value) {
                                await controller.saveToContinueWatchVideo();
                              }
                              await controller.pause();
                              Future.delayed(const Duration(seconds: 1), () {
                                controller.isBuffering(false);
                                onWatchNextEpisode?.call();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: white),
                                color: Colors.transparent,
                              ),
                              child: Text(
                                locale.value.nextEpisode,
                                style: secondaryTextStyle(color: white),
                              ),
                            ),
                          ),
                        ),
                      ).visible(hasNextEpisode && !isTrailer && controller.playNextVideo.value && controller.isVideoPlaying.value),
                    ],
                  ] else
                    GestureDetector(
                      onTap: () {
                        doIfLogin(
                          onLoggedIn: () {},
                        );
                      },
                      child: SizedBox(
                        height: isPipModeOn.value ? 110 : 220,
                        width: Get.width,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (getVideoURLLink().isNotEmpty)
                              Image.network(
                                getVideoURLLink(),
                                height: isPipModeOn.value ? 110 : 200,
                                width: Get.width,
                                fit: BoxFit.cover,
                              )
                            else
                              Container(
                                height: isPipModeOn.value ? 110 : 200,
                                width: Get.width,
                                decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius(0)),
                              ),
                            Container(
                              height: 45,
                              width: 45,
                              decoration: boxDecorationDefault(
                                shape: BoxShape.circle,
                                color: btnColor,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Obx(
                    () => const Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: LoaderWidget(),
                    ).visible(controller.isBuffering.value),
                  ),
                  // if (isPipMode)
                  //   Positioned(
                  //     top: 10,
                  //     left: 0,
                  //     child: IconButton(
                  //       onPressed: () {
                  //         isPipModeOn(false);
                  //         setOrientationPortrait();
                  //       },
                  //       icon: Icon(
                  //         Icons.arrow_back_ios_new_outlined,
                  //         color: Colors.white,
                  //         size: 20,
                  //       ),
                  //     ),
                  //   ),
                  Positioned(
                    top: 10,
                    left: 24,
                    child: Row(
                      spacing: 4,
                      children: [
                        Obx(
                          () {
                            if ((controller.isTrailer.value && isTrailer) && !isLive) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: boxDecorationDefault(
                                  borderRadius: BorderRadius.circular(4),
                                  color: btnColor,
                                ),
                                child: Text(
                                  locale.value.trailer,
                                  style: secondaryTextStyle(color: white),
                                ),
                              );
                            } else {
                              return const Offstage();
                            }
                          },
                        ),
                        if (videoModel.movieAccess == MovieAccess.payPerView)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: boxDecorationDefault(
                              borderRadius: BorderRadius.circular(4),
                              color: rentedColor,
                            ),
                            child: Row(
                              spacing: 4,
                              children: [
                                const CachedImageWidget(
                                  url: Assets.iconsIcRent,
                                  height: 14,
                                  width: 14,
                                  color: Colors.white,
                                ),
                                Text(
                                  videoModel.isPurchased ? locale.value.rented : locale.value.rent,
                                  style: secondaryTextStyle(color: white),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (videoModel.movieAccess == MovieAccess.payPerView && videoModel.isPurchased == false)
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: Get.width,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: boxDecorationDefault(
                          borderRadius: BorderRadius.circular(4),
                          color: btnColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              locale.value.rentedesc(videoModel.availableFor, videoModel.accessDuration.toString()),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              textAlign: TextAlign.start,
                              style: secondaryTextStyle(color: white),
                            ).flexible(),
                            IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  backgroundColor: Colors.black,
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  builder: (context) {
                                    return Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: RentalDetailsComponent(
                                        liveShowModel: liveShowModel,
                                        videoModel: videoModel,
                                        isComingSoonScreen: isComingSoonScreen,
                                        onWatchNow: () async {
                                          await controller.pause();
                                          onWatchNow?.call();
                                        },
                                        isLive: false,
                                        isTrailer: isTrailer,
                                        showWatchNow: isComingSoonScreen ? showWatchNow : isTrailer || showWatchNow,
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.info_outline,
                                size: 16,
                                color: appColorPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    top: 10,
                    right: 16,
                    child: IgnorePointer(
                      ignoring: !isLoggedIn.value,
                      child: Container(
                        height: 26,
                        width: 26,
                        decoration: boxDecorationDefault(
                          shape: BoxShape.circle,
                          color: btnColor,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            Get.bottomSheet(
                              isScrollControlled: true,
                              enableDrag: false,
                              BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: boxDecorationDefault(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(32),
                                      topRight: Radius.circular(32),
                                    ),
                                    border: Border(top: BorderSide(color: borderColor.withValues(alpha: 0.8))),
                                    color: appScreenBackgroundDark,
                                  ),
                                  child: VideoSettingsDialog(videoPlayerController: controller),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.settings,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ).visible(!isLive && !controller.isTrailer.value && !controller.isBuffering.value && controller.isVideoPlaying.value),
                  if (!controller.isTrailer.value) _overlayView(context),
                  _adView(),
                ],
              ),
            ),
            if (!isPipMode)
              VideoDescriptionWidget(
                videoDescription: isLive ? VideoPlayerModel.fromJson(liveShowModel!.toJson()) : videoModel,
                onWatchNow: () async {
                  controller.isBuffering(true);
                  await controller.pause();

                  if (_customAd() != null) {
                    controller.hasShownCustomAd.value = true;
                    showCustomAd();
                  } else {
                    Future.delayed(
                      const Duration(seconds: 1),
                      () {
                        controller.isBuffering(false);
                        onSubscriptionLoginCheck(
                          callBack: () {
                            onWatchNow?.call();
                          },
                          planId: videoModel.planId,
                          videoAccess: videoModel.planId <= 0 && videoModel.requiredPlanLevel <= 0 ? MovieAccess.freeAccess : MovieAccess.paidAccess,
                          planLevel: videoModel.requiredPlanLevel,
                        );
                      },
                    );
                  }
                },
                isDescription: true,
                isTrailer: isTrailer,
                isContentRating: true,
                videoPlayersController: controller,
                showWatchNow: showWatchNow,
              ),
          ],
        );
      },
    );
  }

  Widget _overlayView(BuildContext context) {
    return Obx(() {
      final overlayAd = controller.currentOverlayAd.value;
      if (overlayAd == null) return const SizedBox.shrink();
      return Positioned(
        bottom: isPipModeOn.value ? 2 : 40,
        child: OverlayAdWidget(
          isFullScreen: MediaQuery.of(Get.context!).orientation == Orientation.landscape,
          overlayAd: overlayAd,
          onClose: () {
            controller.currentOverlayAd.value = null;
            controller.overlayAdTimer?.cancel();
          },
        ),
      );
    });
  }

  CustomAd? _customAd() {
    if (getDashboardController().customAds.isNotEmpty) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final List<CustomAd> playerAds = getDashboardController().customAds.where((ad) {
        if (ad.placement?.toLowerCase() != 'player') return false;
        if (ad.targetContentType.validate().isEmpty) return false;

        String videoType = videoModel.type.toLowerCase();
        if (videoType == 'tv_show') videoType = 'tvshow';

        if (ad.targetContentType!.toLowerCase() != videoType) return false;

        if (ad.targetCategories.validate().isNotEmpty) {
          try {
            final List<dynamic> targetCategories = jsonDecode(ad.targetCategories!);
            if (targetCategories.isNotEmpty) {
              final bool categoryMatch = targetCategories.contains(videoModel.id);
              if (!categoryMatch) return false;
            }
          } catch (e) {
            log('Error decoding target_categories: $e');
            return false;
          }
        }

        // Check start date (ad should not start in future)
        if (ad.startDate != null) {
          final adStartDay = DateTime(ad.startDate!.year, ad.startDate!.month, ad.startDate!.day);
          if (adStartDay.isAfter(today)) return false;
        }

        // Check end date (ad should not have ended before today)
        if (ad.endDate != null) {
          final adEndDay = DateTime(ad.endDate!.year, ad.endDate!.month, ad.endDate!.day);
          if (adEndDay.isBefore(today)) return false;
        }

        return true;
      }).toList();

      if (playerAds.isNotEmpty) {
        return (playerAds..shuffle()).first;
      }
    }
    return null;
  }

  Widget buildVideoWidget(BuildContext ctx) {
    return Obx(
      () {
        return Stack(
          children: [
            if (controller.videoUrlInput.value.isEmpty)
              Container(
                height: isPipModeOn.value ? 110 : 200,
                width: Get.width,
                decoration: boxDecorationDefault(
                  color: appScreenBackgroundDark,
                ),
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
              )
            else if (isWebView)
              WebViewContentWidget(
                webViewController: controller.webViewController.value,
                onVideoProgress: (position, duration) {
                  final remaining = duration - position;
                  final threshold = duration.inSeconds * 0.20;
                  controller.playNextVideo(remaining.inSeconds <= threshold);
                },
              )
            else if (isVideoTypeYoutube)
              Obx(
                () => Directionality(
                  textDirection: isRTL.value ? TextDirection.rtl : TextDirection.ltr,
                  child: YPlayerWidget(
                    key: ValueKey(controller.videoUrlInput.value),
                    // key: controller.yPlayerWidgetKey,
                    watchedTime: controller.videoModel.value.watchedTime,
                    aspectRatio: 16 / 9,
                    youtubeUrl: controller.videoUrlInput.value,
                    onControllerReady: (yController) {
                      controller.initializeYoutubePlayer(yController);
                    },
                    showNextEpisodeButton: hasNextEpisode,
                    loadingWidget: const LoaderWidget(),
                    fullscreenSeekBarMargin: const EdgeInsets.only(bottom: 10),
                    errorWidget: _buildErrorContainer(),
                    subTiltle: controller.selectedSubtitleModel.value,
                    onStateChanged: (status) {},
                    // bottomButtonBarMargin: EdgeInsets.only(left: 16, right: 16, bottom: 32),
                    // fullscreenBottomButtonBarMargin: EdgeInsets.only(left: 16, right: 16, bottom: 64),
                    // seekBarMargin: EdgeInsets.only(left: 16, right: 16, bottom: 32),
                    onProgressChanged: (position, duration) {
                      final remaining = duration - position;
                      final threshold = duration.inSeconds * 0.20;
                      controller.playNextVideo(remaining.inSeconds <= threshold);
                      controller.isVideoPlaying(position.inSeconds > 0);

                      final subtitle = controller.availableSubtitleList.firstWhereOrNull((s) => s.start <= position && s.end >= position);
                      if (subtitle != null && subtitle.data != controller.currentSubtitle.value) {
                        controller.currentSubtitle(subtitle.data);
                      } else if (subtitle == null && controller.currentSubtitle.value.isNotEmpty) {
                        controller.currentSubtitle('');
                      }
                    },
                    nextEpisode: () {
                      Future.delayed(const Duration(milliseconds: 400), () {
                        onWatchNextEpisode?.call();
                      });
                    },
                    isTrailer: isTrailer,
                    videoPlayerController: controller,
                  ),
                ),
              )
            else if (isVideoTypeOther)
              _buildOtherVideoPlayer(ctx)
            else if (isLive && liveShowModel!.serverUrl.isNotEmpty)
              _buildLiveStreamPlayer()
            else
              _buildFallbackThumbnail(),
            Positioned(
              left: 32,
              right: 32,
              bottom: 28,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  controller.currentSubtitle.value,
                  textAlign: TextAlign.center,
                  style: primaryTextStyle(
                    color: Colors.white,
                    backgroundColor: Colors.black87,
                    size: 16,
                  ),
                ),
              ),
            ).visible(controller.currentSubtitle.value.isNotEmpty),
            const Align(
              child: LoaderWidget(),
            ).visible(controller.isSubtitleBuffering.value),
          ],
        );
      },
    );
  }

  Widget _buildOtherVideoPlayer(BuildContext ctx) {
    return Theme(
      data: _buildDarkTheme(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: Obx(() {
          return PodVideoPlayer(
            key: controller.uniqueKey,
            alwaysShowProgressBar: false,
            podProgressBarConfig: _progressBarConfig(),
            controller: controller.podPlayerController.value,
            overlayBuilder: (options) => _buildOverlay(ctx),
            videoThumbnail: _getThumbnailImage(),
            onVideoError: _buildErrorContainer,
            onLoading: (_) => LoaderWidget(loaderColor: appColorPrimary.withValues(alpha: 0.4)),
          );
        }),
      ),
    );
  }

  Widget _buildOverlay(BuildContext ctx) {
    return Obx(() {
      final podController = controller.podPlayerController.value;
      final videoValue = podController.videoPlayerValue;
      final position = videoValue?.position ?? Duration.zero;
      final duration = videoValue?.duration ?? const Duration(seconds: 1);

      // Comprehensive ad break management
      final List<Duration> allAdBreaks = controller.getAllAdBreaks();

      // Check if ads are currently playing
      if (controller.isAdPlaying.value && MediaQuery.of(Get.context!).orientation == Orientation.landscape) {
        // Return ad view when ads are playing
        return _adView();
      }

      return CustomPodPlayerControlOverlay(
        position: position,
        duration: duration,
        adBreaks: allAdBreaks,
        isPlaying: podController.isVideoPlaying,
        overlayAd: MediaQuery.of(Get.context!).orientation == Orientation.landscape ? _overlayView(Get.context!) : null,
        onFullscreenToggle: () {
          podController.isFullScreen ? podController.disableFullScreen(ctx) : podController.enableFullScreen();
        },
        onPlayPause: () {
          podController.isVideoPlaying ? podController.pause() : podController.play();
        },
        onSeek: (d) {
          podController.videoSeekTo(d);
        },
        onReplay10: () {
          podController.videoSeekTo(Duration(seconds: position.inSeconds - 10));
        },
        onForward10: () {
          podController.videoSeekTo(Duration(seconds: position.inSeconds + 10));
        },
      );
    });
  }

  Widget _buildLiveStreamPlayer() {
    return Theme(
      data: _buildDarkTheme(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: Obx(
          () => Directionality(
            textDirection: isRTL.value ? TextDirection.rtl : TextDirection.ltr,
            child: PodVideoPlayer(
              key: controller.uniqueKey,
              alwaysShowProgressBar: false,
              onToggleFullScreen: (isFullScreen) async => controller.isPipEnable(isFullScreen),
              podProgressBarConfig: _progressBarConfig(),
              controller: controller.podPlayerController.value,
              videoThumbnail: _getThumbnailImage(),
              onVideoError: _buildErrorContainer,
              onLoading: (_) => LoaderWidget(loaderColor: appColorPrimary.withValues(alpha: 0.4)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackThumbnail() {
    return SizedBox(
      height: isPipModeOn.value ? 110 : 220,
      width: Get.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (getVideoURLLink().isNotEmpty)
            Image.network(
              getVideoURLLink(),
              height: isPipModeOn.value ? 110 : 200,
              width: Get.width,
              fit: BoxFit.cover,
            )
          else
            Container(
              height: isPipModeOn.value ? 110 : 200,
              width: Get.width,
              decoration: boxDecorationDefault(color: canvasColor),
            ),
          if (controller.videoUrlInput.isNotEmpty)
            Container(
              height: 45,
              width: 45,
              decoration: boxDecorationDefault(shape: BoxShape.circle, color: btnColor),
              child: const Icon(Icons.play_arrow, size: 24),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorContainer() {
    return Container(
      height: isPipModeOn.value ? 110 : 200,
      width: Get.width,
      decoration: boxDecorationDefault(color: appScreenBackgroundDark),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 34, color: white),
          10.height,
          Text(locale.value.videoNotFound, style: boldTextStyle(size: 16, color: white)),
        ],
      ),
    );
  }

  DecorationImage? _getThumbnailImage() {
    final url = getVideoURLLink();
    if (url.isNotEmpty && !url.contains("/data/user")) {
      return DecorationImage(
        image: NetworkImage(url),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.4), BlendMode.darken),
      );
    } else if (url.contains("/data/user") && File(url).existsSync()) {
      return DecorationImage(
        image: FileImage(File(url)),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.4), BlendMode.darken),
      );
    }
    return null;
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: appScreenBackgroundDark),
      primaryColor: Colors.white,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  PodProgressBarConfig _progressBarConfig() {
    return const PodProgressBarConfig(
      circleHandlerColor: appColorPrimary,
      backgroundColor: borderColorDark,
      playingBarColor: appColorPrimary,
      bufferedBarColor: appColorSecondary,
      circleHandlerRadius: 6,
      height: 2.6,
      padding: EdgeInsets.only(bottom: 16, left: 8, right: 8),
    );
  }

  Widget _adView() {
    return AdView(
      controller: controller,
      skipInText: (seconds) => locale.value.skipIn(seconds),
      advertisementText: locale.value.advertisement,
      skipLabel: locale.value.skip,
    );
  }

  void showCustomAd({bool onlyPop = false}) {
    void handleAdCompletion() {
      if (onlyPop) return;

      Future.delayed(const Duration(seconds: 1), () {
        controller.isBuffering(false);

        final isFreeAccess = videoModel.planId <= 0 && videoModel.requiredPlanLevel <= 0;
        final accessType = isFreeAccess ? MovieAccess.freeAccess : MovieAccess.paidAccess;

        onSubscriptionLoginCheck(
          callBack: () => onWatchNow?.call(),
          planId: videoModel.planId,
          videoAccess: accessType,
          planLevel: videoModel.requiredPlanLevel,
        );
      });
    }

    showDialog(
      context: Get.context!,
      builder: (_) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            handleAdCompletion();
          }
        },
        child: CustomAdWidget(
          adConfig: _customAd()!,
          skipTimer: 10.obs,
          onSkip: () {
            Get.back();
            handleAdCompletion();
          },
        ),
      ),
    );
  }
}