import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/ads/components/custom_ad_slider_widget.dart';
import 'package:streamit_laravel/utils/app_common.dart';

import '../../../../utils/common_base.dart';
import '../../screens/home/components/ad_component.dart';
import '../../screens/home/components/geners/genres_component.dart';
import '../../screens/home/components/language_component/language_component.dart';
import '../../screens/home/components/person_component/person_component.dart';
import '../../screens/home/components/rate/rate_component.dart';
import '../../screens/home/model/dashboard_res_model.dart';
import 'movie_horizontal/movie_component.dart';

class CategoryListComponent extends StatelessWidget {
  final RxList<CategoryListModel> categoryList;
  final bool isSearch;
  final bool isLoading;

  const CategoryListComponent({super.key, required this.categoryList, this.isSearch = false, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categoryList.length,
        itemBuilder: (context, index) {
          final CategoryListModel category = categoryList[index];
          switch (category.sectionType) {
            case DashboardCategoryType.trending:
              return const Offstage();
            case DashboardCategoryType.personalised:
              return HorizontalMovieComponent(
                movieDet: category,
                isSearch: false,
                type: category.sectionType,
                isLoading: isLoading,
              ).visible(category.data.isNotEmpty);
            case DashboardCategoryType.top10:
              return HorizontalMovieComponent(
                movieDet: category,
                isTop10: true,
                isSearch: isSearch,
                type: category.sectionType,
              ).visible(category.data.isNotEmpty);
            case DashboardCategoryType.advertisement:
              return AdComponent();
            case DashboardCategoryType.movie:
            case DashboardCategoryType.tvShow:
            case DashboardCategoryType.horizontalList:
              return HorizontalMovieComponent(
                movieDet: category,
                isSearch: isSearch,
                type: category.sectionType,
                isLoading: isLoading,
              ).visible(category.data.isNotEmpty);
            case DashboardCategoryType.channels:
              return HorizontalMovieComponent(
                movieDet: category,
                isSearch: isSearch,
                isTopChannel: true,
                type: category.sectionType,
                isLoading: isLoading,
              ).visible(category.data.isNotEmpty);
            case DashboardCategoryType.customAd:
              return Obx(
                () => const CustomAdSliderWidget().visible(getDashboardController().customHomePageAds.isNotEmpty),
              );
            case DashboardCategoryType.language:
              return LanguageComponent(
                languageDetails: category,
                isLoading: isLoading,
              ).visible(category.data.isNotEmpty);
            case DashboardCategoryType.personality:
              return PersonComponent(
                personDetails: category,
                isLoading: isLoading,
              ).visible(category.data.isNotEmpty);
            case DashboardCategoryType.genres:
              return GenreComponent(
                genresDetails: category,
                isLoading: isLoading,
              ).visible(category.data.isNotEmpty);
            case DashboardCategoryType.rateApp:
              return RateComponent(
                rateDetails: category,
                isLoading: isLoading,
              );
            default:
              return HorizontalMovieComponent(
                movieDet: category,
                isSearch: isSearch,
                isLoading: isLoading,
                type: category.sectionType,
              ).visible(category.data.isNotEmpty);
          }
        },
      ),
    );
  }
}
