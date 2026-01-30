import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/ads/custom_ads/ad_player.dart';
import 'package:streamit_laravel/components/cached_image_widget.dart';
import 'package:streamit_laravel/configs.dart';
import 'package:streamit_laravel/generated/assets.dart';
import 'package:streamit_laravel/utils/app_common.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/ads/model/custom_ad_response.dart';

class CustomAdComponent extends StatefulWidget {
  final List<CustomAd> ads;
  const CustomAdComponent({super.key, required this.ads});

  @override
  State<CustomAdComponent> createState() => _CustomAdComponentState();
}

class _CustomAdComponentState extends State<CustomAdComponent> {
  PageController adPageController = PageController();
  final RxInt _currentPage = 0.obs;

  void startAuroSlider() {
    Timer.periodic(const Duration(milliseconds: CUSTOM_AD_AUTO_SLIDER_SECOND_IMAGE), (Timer timer) {
      if (_currentPage < widget.ads.length - 1) {
        _currentPage.value++;
      } else {
        _currentPage.value = 0;
      }
      if (adPageController.hasClients) adPageController.animateToPage(_currentPage.value, duration: const Duration(seconds: 2), curve: Curves.easeOutQuart);
    });
    adPageController.addListener(() {
      _currentPage.value = adPageController.page!.toInt();
    });
  }

  @override
  void initState() {
    super.initState();
    startAuroSlider();
  }

  @override
  void dispose() {
    adPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      height: Get.height * 0.15,
      width: Get.width,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
            ),
            child: PageView.builder(
              controller: adPageController,
              itemCount: widget.ads.length,
              itemBuilder: (context, index) {
                final ad = widget.ads[index];
                final isVideo = ad.type == 'video';
                final mediaUrl = ad.media ?? '';
                final redirectUrl = ad.redirectUrl ?? '';
                return InkWell(
                  onTap: () {
                    if (redirectUrl.isNotEmpty) launchUrlCustomURL(redirectUrl);
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: isVideo
                      ? AdPlayer(videoUrl: prepareAdVideoUrl(mediaUrl), height: Get.height * 0.15)
                      : CachedNetworkImage(
                          imageUrl: mediaUrl,
                          fit: BoxFit.fill,
                          errorWidget: (context, url, error) {
                            return Container(
                              height: Get.height * 0.15,
                              width: Get.width,
                              decoration: BoxDecoration(
                                color: secondaryTextColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const CachedImageWidget(
                                url: Assets.iconsIcError,
                                fit: BoxFit.contain,
                              ).paddingAll(24),
                            );
                          },
                        ),
                );
              },
            ),
          ),
          if (widget.ads.length.validate() > 1)
            DotIndicator(
              pageController: adPageController,
              pages: widget.ads,
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
        ],
      ),
    );
  }

  String prepareAdVideoUrl(String videoUrl) {
    if (!videoUrl.contains('https')) {
      return DOMAIN_URL + videoUrl;
    }
    return videoUrl;
  }
}
