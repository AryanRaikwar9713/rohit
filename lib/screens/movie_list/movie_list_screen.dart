// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/dashboard/components/floating_widget.dart';
import 'package:streamit_laravel/screens/movie_list/movie_list_controller.dart';
import 'package:streamit_laravel/screens/movie_list/shimmer_movie_list/shimmer_movie_list.dart';
import 'package:streamit_laravel/screens/slider/banner_widget.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/constants.dart';

import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/animatedscroll_view_widget.dart';
import '../../utils/empty_error_state_widget.dart';
import '../movie_details/movie_details_screen.dart';

class MovieListScreen extends StatelessWidget {
  final String? title;

  MovieListScreen({super.key, this.title});

  MovieListController movieListCont = Get.put(MovieListController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      hasLeadingWidget: false,
      hideAppBar: true,
      scaffoldBackgroundColor: black,
      floatingActionButton: FloatingWidget(label: locale.value.movies),
      body: AnimatedScrollView(
        padding: const EdgeInsets.only(bottom: 60),
        refreshIndicatorColor: appColorPrimary,
        onNextPage: movieListCont.onNextPage,
        onSwipeRefresh: () async {
          movieListCont.page(1);
          movieListCont.sliderController.getBanner(type: BannerType.movie);
          return movieListCont.getMovieDetails();
        },
        children: [
          BannerWidget(sliderController: movieListCont.sliderController),
          Obx(
            () => SnapHelperWidget(
              future: movieListCont.getOriginalMovieListFuture.value,
              loadingWidget: const ShimmerMovieList(),
              errorBuilder: (error) {
                return SizedBox(
                  width: Get.width,
                  height: Get.height * 0.8,
                  child: NoDataWidget(
                    titleTextStyle: secondaryTextStyle(color: white),
                    subTitleTextStyle: primaryTextStyle(color: white),
                    title: error,
                    retryText: locale.value.reload,
                    imageWidget: const ErrorStateWidget(),
                    onRetry: () async {},
                  ).center(),
                );
              },
              onSuccess: (res) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title ?? locale.value.movies, style: primaryTextStyle()).paddingDirectional(start: 16),
                    10.height,
                    if (movieListCont.originalMovieList.isEmpty && !movieListCont.isLoading.value)
                      NoDataWidget(
                        titleTextStyle: boldTextStyle(color: white),
                        subTitleTextStyle: primaryTextStyle(color: white),
                        title: locale.value.noDataFound,
                        retryText: "",
                        imageWidget: const EmptyStateWidget(),
                      ).paddingSymmetric(horizontal: 16)
                    else
                      CustomAnimatedScrollView(
                        paddingLeft: Get.width * 0.04,
                        paddingRight: Get.width * 0.04,
                        paddingBottom: Get.height * 0.10,
                        spacing: Get.width * 0.03,
                        runSpacing: Get.height * 0.02,
                        posterHeight: 150,
                        posterWidth: Get.width * 0.286,
                        isHorizontalList: false,
                        isLoading: movieListCont.isLoading.value,
                        isLastPage: movieListCont.isLastPage.value,
                        itemList: movieListCont.originalMovieList,
                        onTap: (posterDet) {
                          Get.to(() => MovieDetailsScreen(), arguments: posterDet);
                        },
                        isMovieList: true,
                      )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}