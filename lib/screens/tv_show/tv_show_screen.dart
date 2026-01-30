import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/app_scaffold.dart';
import 'package:streamit_laravel/screens/tv_show/components/tv_show_details_component.dart';
import 'package:streamit_laravel/screens/tv_show/tv_show_controller.dart';
import 'package:streamit_laravel/screens/tv_show/tv_show_shimmer_screen.dart';
import 'package:streamit_laravel/utils/app_common.dart';
import 'package:streamit_laravel/utils/constants.dart';

import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import '../../utils/empty_error_state_widget.dart';
import '../../video_players/video_player.dart';

class TvShowScreen extends StatelessWidget {
  final bool isFromContinueWatch;

  TvShowScreen({super.key, this.isFromContinueWatch = false});

  final TvShowController tvShowController = Get.put(TvShowController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      isLoading: tvShowController.isLoading,
      topBarBgColor: Colors.transparent,
      scaffoldBackgroundColor: appScreenBackgroundDark,
      body: RefreshIndicator(
        color: appColorPrimary,
        onRefresh: () {
          if (!tvShowController.isTrailer.value) {
            return tvShowController.getEpisodeDetail();
          } else {
            return tvShowController.getTvShowDetail();
          }
        },
        child: Obx(
          () {
            return AnimatedScrollView(
              controller: tvShowController.scrollController,
              refreshIndicatorColor: appColorPrimary,
              physics: isPipModeOn.value ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 30),
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: VideoPlayersComponent(
                    key: ValueKey(tvShowController.selectedEpisode.value.id),
                    isTrailer: tvShowController.isTrailer.value && !isFromContinueWatch,
                    isPipMode: isPipModeOn.value,
                    videoModel: getVideoPlayerResp(tvShowController.showData.value.toJson()),
                    showWatchNow: tvShowController.isTrailer.isTrue ||
                        isMoviePaid(requiredPlanLevel: tvShowController.selectedEpisode.value.requiredPlanLevel) ||
                        (!tvShowController.showData.value.isPurchased &&
                            (tvShowController.showData.value.access == MovieAccess.payPerView || tvShowController.showData.value.movieAccess == MovieAccess.payPerView)),
                    hasNextEpisode: tvShowController.currentEpisodeIndex.value < tvShowController.episodeList.length - 1,
                    onWatchNow: () {
                      tvShowController.isTrailer(false);
                      tvShowController.currentEpisodeIndex.value++;
                      tvShowController.playNextEpisode(tvShowController.episodeList[tvShowController.currentEpisodeIndex.value]);
                    },
                    onWatchNextEpisode: () {
                      if (tvShowController.currentEpisodeIndex.value < tvShowController.episodeList.length - 1) {
                        tvShowController.currentEpisodeIndex.value++;
                        tvShowController.playNextEpisode(tvShowController.episodeList[tvShowController.currentEpisodeIndex.value]);
                      }
                    },
                  ),
                ),
                if (!isPipModeOn.value)
                  SnapHelperWidget(
                    future: tvShowController.getTvShowDetailsFuture.value,
                    loadingWidget: tvShowController.isLoading.isFalse ? const TvShowShimmerScreen() : const Offstage(),
                    errorBuilder: (error) {
                      return NoDataWidget(
                        titleTextStyle: secondaryTextStyle(color: white),
                        subTitleTextStyle: primaryTextStyle(color: white),
                        title: error,
                        retryText: locale.value.reload,
                        imageWidget: const ErrorStateWidget(),
                        onRetry: () {
                          tvShowController.getTvShowDetail(showLoader: true);
                        },
                      ).visible(tvShowController.isLoading.value);
                    },
                    onSuccess: (data) {
                      return TvShowDetailsComponent();
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}