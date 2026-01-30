import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:streamit_laravel/utils/app_common.dart';
import '../model/overlay_ad.dart';
import '../../generated/assets.dart';
import '../../components/cached_image_widget.dart';
import '../../utils/colors.dart';

class OverlayAdWidget extends StatelessWidget {
  final OverlayAd overlayAd;
  final VoidCallback? onClose;
  final bool isFullScreen;

  const OverlayAdWidget({super.key, required this.overlayAd, this.onClose, this.isFullScreen = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (overlayAd.clickThroughUrl != null && overlayAd.clickThroughUrl!.isNotEmpty) {
              launchUrl(Uri.parse(overlayAd.clickThroughUrl!));
            }
          },
          child: CachedNetworkImage(
            imageUrl: overlayAd.imageUrl,
            width: isFullScreen ? 500 : 300,
            height: isFullScreen
                ? 80
                : isPipModeOn.value
                    ? 10
                    : 60,
            fit: BoxFit.contain,
            placeholder: (context, url) => Container(
              width: isFullScreen ? 500 : 300,
              height: isFullScreen
                  ? 80
                  : isPipModeOn.value
                      ? 10
                      : 60,
              decoration: const BoxDecoration(color: secondaryTextColor),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: CachedImageWidget(
                  url: Assets.iconsIcError,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: isFullScreen ? 500 : 300,
              height: isFullScreen
                  ? 80
                  : isPipModeOn.value
                      ? 10
                      : 60,
              decoration: BoxDecoration(
                color: secondaryTextColor,
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CachedImageWidget(
                  url: Assets.iconsIcError,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        if (onClose != null)
          Positioned(
            top: 0,
            right: isFullScreen ? 6 : 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 18),
              onPressed: onClose,
            ),
          ),
      ],
    );
  }
}