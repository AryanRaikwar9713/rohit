import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/ads/custom_ads/ad_player.dart';
import 'package:streamit_laravel/components/cached_image_widget.dart';
import 'package:streamit_laravel/configs.dart';
import 'package:streamit_laravel/utils/app_common.dart';
import 'package:streamit_laravel/utils/colors.dart';

class CustomAdSliderWidget extends StatefulWidget {
  const CustomAdSliderWidget({super.key});

  @override
  State<CustomAdSliderWidget> createState() => _CustomAdSliderWidgetState();
}

class _CustomAdSliderWidgetState extends State<CustomAdSliderWidget> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (getDashboardController().customHomePageAds.isEmpty) {
        return const SizedBox.shrink();
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: Get.height * 0.2,
        width: Get.width,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              controller: getDashboardController().adPlayerController.adPageController.value,
              itemCount: getDashboardController().customHomePageAds.length,
              itemBuilder: (context, index) {
                final ad = getDashboardController().customHomePageAds[index];
                Widget adWidget;

                if (ad.type == 'image') {
                  adWidget = CachedImageWidget(
                    url: ad.media.validate(),
                    width: Get.width,
                    fit: BoxFit.fill,
                    radius: 6,
                  );
                } else if (ad.type == 'video') {
                  adWidget = AdPlayer(videoUrl: prepareAdVideoUrl(ad.media.validate()), height: Get.height * 0.2);
                } else {
                  adWidget = const SizedBox.shrink();
                }

                return GestureDetector(
                  onTap: () {
                    if (ad.redirectUrl.validate().isNotEmpty) {
                      launchUrlCustomURL(ad.redirectUrl.validate());
                    }
                  },
                  child: adWidget,
                );
              },
            ),
            if (getDashboardController().customHomePageAds.length.validate() > 1)
              Positioned(
                bottom: 10,
                child: DotIndicator(
                  pageController: getDashboardController().adPlayerController.adPageController.value,
                  pages: getDashboardController().customHomePageAds,
                  indicatorColor: white,
                  unselectedIndicatorColor: darkGrayColor,
                  currentBoxShape: BoxShape.rectangle,
                  boxShape: BoxShape.rectangle,
                  borderRadius: radius(3),
                  currentBorderRadius: radius(3),
                  currentDotSize: 6,
                  currentDotWidth: 6,
                  dotSize: 6,
                ),
              ),
          ],
        ),
      );
    });
  }

  String prepareAdVideoUrl(String videoUrl) {
    if (!videoUrl.contains('https')) {
      return DOMAIN_URL + videoUrl;
    }
    return videoUrl;
  }
}
