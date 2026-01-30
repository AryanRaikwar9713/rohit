import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/video/video_details/components/video_details_component.dart';
import 'package:streamit_laravel/screens/video/video_details_controller.dart';
import 'package:streamit_laravel/screens/video/video_details_shimmer_screen.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/constants.dart';

import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/common_base.dart';
import '../../utils/empty_error_state_widget.dart';
import '../../video_players/video_player.dart';

class VideoDetailsScreen extends StatelessWidget {
  final bool isContinueWatch;

  VideoDetailsScreen({super.key, this.isContinueWatch = false});

  final VideoDetailsController movieDetCont = Get.put(VideoDetailsController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      isLoading: movieDetCont.isLoading,
      scaffoldBackgroundColor: black,
      topBarBgColor: Colors.transparent,
      body: RefreshIndicator(
        color: appColorPrimary,
        onRefresh: () async {
          return movieDetCont.getMovieDetail();
        },
        child: Obx(
          () => AnimatedScrollView(
            refreshIndicatorColor: appColorPrimary,
            physics: isPipModeOn.value ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 30),
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: VideoPlayersComponent(
                  isTrailer: false,
                  isPipMode: isPipModeOn.value,
                  showWatchNow: isMoviePaid(requiredPlanLevel: movieDetCont.movieData.value.requiredPlanLevel) ||
                      (!movieDetCont.movieData.value.isPurchased &&
                          (movieDetCont.movieData.value.access == MovieAccess.payPerView || movieDetCont.movieData.value.movieAccess == MovieAccess.payPerView)),
                  onWatchNow: () {
                    playMovie(
                      continueWatchDuration: movieDetCont.movieData.value.watchedTime,
                      newURL: movieDetCont.movieData.value.videoUrlInput,
                      urlType: movieDetCont.movieData.value.videoUploadType,
                      videoType: movieDetCont.movieData.value.type,
                      isWatchVideo: true,
                    );
                  },
                  videoModel: getVideoPlayerResp(movieDetCont.movieData.value.toJson()),
                ),
              ),
              if (!isPipModeOn.value)
                SnapHelperWidget(
                  future: movieDetCont.getMovieDetailsFuture.value,
                  loadingWidget: movieDetCont.isLoading.isFalse ? const VideoDetailsShimmerScreen() : const Offstage(),
                  errorBuilder: (error) {
                    return NoDataWidget(
                      titleTextStyle: secondaryTextStyle(color: white),
                      subTitleTextStyle: primaryTextStyle(color: white),
                      title: error,
                      retryText: locale.value.reload,
                      imageWidget: const ErrorStateWidget(),
                      onRetry: () {
                        movieDetCont.getMovieDetail();
                      },
                    ).visible(movieDetCont.isLoading.isFalse);
                  },
                  onSuccess: (res) {
                    return VideoDetailsComponent(
                      videoDetail: movieDetCont.movieDetailsResp.value,
                      movieDetailCont: movieDetCont,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}