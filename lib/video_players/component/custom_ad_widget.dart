import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/ads/custom_ads/ad_player.dart';
import 'package:streamit_laravel/ads/model/custom_ad_response.dart';
import 'package:streamit_laravel/components/cached_image_widget.dart';
import 'package:streamit_laravel/configs.dart';
import 'package:streamit_laravel/main.dart';
import 'package:streamit_laravel/utils/app_common.dart';

class CustomAdWidget extends StatefulWidget {
  final CustomAd adConfig;
  final RxInt? skipTimer;
  final VoidCallback? onSkip;

  const CustomAdWidget({
    super.key,
    required this.adConfig,
    this.skipTimer,
    this.onSkip,
  });

  @override
  State<CustomAdWidget> createState() => _CustomAdWidgetState();
}

class _CustomAdWidgetState extends State<CustomAdWidget> {
  final RxBool _timerStarted = false.obs;

  void startSkipTimer() {
    if (_timerStarted.value) return;
    _timerStarted.value = true;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.skipTimer!.value > 0) {
        widget.skipTimer!.value--;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.adConfig;
    if (ad.type == 'image') {
      return Material(
        color: Colors.black54,
        child: Center(
          child: Stack(
            children: [
              Container(
                height: 400,
                margin: const EdgeInsets.fromLTRB(30, 16, 30, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    if (ad.redirectUrl?.isNotEmpty ?? false) {
                      launchUrlCustomURL(ad.redirectUrl!);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: CachedImageWidget(
                    url: ad.media.validate(),
                    height: 350,
                    fit: BoxFit.cover,
                    radius: 12,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 16,
                child: GestureDetector(
                  onTap: widget.onSkip,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (ad.type == 'video') {
      return Material(
        color: Colors.black54,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (ad.redirectUrl?.isNotEmpty ?? false) {
                  launchUrlCustomURL(ad.redirectUrl!);
                }
              },
              child: AdPlayer(
                videoUrl: prepareAdVideoUrl(ad.media.validate()),
                startSkipTimer: (value) {
                  if (value.value) {
                    startSkipTimer();
                  }
                },
                isFromPlayerAd: true,
              ),
            ),
            // GestureDetector(
            //   onTap: () {
            //     if (ad.redirectUrl?.isNotEmpty ?? false) {
            //       launchUrlCustomURL(ad.redirectUrl!);
            //     }
            //   },
            //   child: Container(color: Colors.transparent),
            // ),
            Obx(() => widget.skipTimer!.value > 0
                ? Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      color: whiteColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text(locale.value.skipIn(widget.skipTimer!.value), style: const TextStyle(color: black, fontWeight: FontWeight.w500)),
                    ),
                  )
                : Positioned(
                    top: 10,
                    right: 10,
                    child: InkWell(
                      onTap: widget.onSkip,
                      child: Container(
                        color: whiteColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Text(locale.value.lblSkip, style: const TextStyle(color: black, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  )),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String prepareAdVideoUrl(String videoUrl) {
    if (!videoUrl.contains('https')) {
      return  DOMAIN_URL + videoUrl;
    }
    return videoUrl;
  }
}