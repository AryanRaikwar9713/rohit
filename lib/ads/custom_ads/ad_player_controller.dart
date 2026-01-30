import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:streamit_laravel/configs.dart';
import 'package:streamit_laravel/utils/app_common.dart';

import '../../video_players/model/ad_config.dart';

class AdPlayerController extends GetxController {
  Rx<AdConfig?> customAd = Rx<AdConfig?>(null);
  RxInt customAdSkipTimer = 0.obs;
  Timer? customAdSkipTimerController;
  Rx<PageController> adPageController = PageController().obs;
  Rx<Timer> timer = Timer(Duration.zero, () {}).obs;

  final RxInt _currentPage = 0.obs;

  Future<void> getCustomAds() async {
    var homePageAds = getDashboardController().customAds.where((ad) => ad.placement?.toLowerCase() == 'home_page').toList();

    if (homePageAds.isNotEmpty) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      homePageAds = homePageAds.where((ad) {
        // Filter out ads that have not yet started
        if (ad.startDate != null) {
          final adStartDay = DateTime(ad.startDate!.year, ad.startDate!.month, ad.startDate!.day);
          if (adStartDay.isAfter(today)) return false;
        }

        // Filter out ads that have already ended
        if (ad.endDate != null) {
          final adEndDay = DateTime(ad.endDate!.year, ad.endDate!.month, ad.endDate!.day);
          if (adEndDay.isBefore(today)) return false;
        }

        return true;
      }).toList();

      getDashboardController().customHomePageAds.value = homePageAds;

      if (getDashboardController().customHomePageAds.isNotEmpty) {
        startAutoSlider(getDashboardController().customHomePageAds.first.type ?? 'video');
      }
    } else {
      getDashboardController().customHomePageAds.value = homePageAds;
    }
  }

  Future<void> startAutoSlider(String type) async {
    timer.value = Timer.periodic(Duration(milliseconds: type == 'video' ? CUSTOM_AD_AUTO_SLIDER_SECOND_VIDEO : CUSTOM_AD_AUTO_SLIDER_SECOND_IMAGE), (Timer timer) {
      if (_currentPage < getDashboardController().customHomePageAds.length - 1) {
        _currentPage.value++;
      } else {
        _currentPage.value = 0;
      }
      if (adPageController.value.hasClients) adPageController.value.animateToPage(_currentPage.value, duration: const Duration(seconds: 2), curve: Curves.easeOutQuart);
    });
    adPageController.value.addListener(() {
      _currentPage.value = adPageController.value.page!.toInt();
    });
  }

  Future<void> showCustomAd(AdConfig ad) async {
    customAd.value = ad;
    if (ad.type == 'video' && ad.isSkippable) {
      customAdSkipTimer(ad.skipAfterSeconds);
      customAdSkipTimerController?.cancel();
      customAdSkipTimerController = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (customAdSkipTimer.value > 0) {
          customAdSkipTimer.value--;
        } else {
          timer.cancel();
        }
      });
    }
  }

  void closeCustomAd() {
    customAd.value = null;
    customAdSkipTimerController?.cancel();
    Get.back();
  }
}
