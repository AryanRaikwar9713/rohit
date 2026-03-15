import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:streamit_laravel/ads/ads_helper.dart';
import 'package:streamit_laravel/utils/colors.dart';

/// Native advanced ad – dark theme, clear "Ad" label (policy-compliant).
class AdMobNativeAdWidget extends StatefulWidget {
  const AdMobNativeAdWidget({super.key});

  @override
  State<AdMobNativeAdWidget> createState() => _AdMobNativeAdWidgetState();
}

class _AdMobNativeAdWidgetState extends State<AdMobNativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: AdHelper().nativeAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) setState(() => _isLoaded = false);
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: appScreenBackgroundDark,
        cornerRadius: 12,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: appColorPrimary,
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          size: 16,
          style: NativeTemplateFontStyle.bold,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.grey,
          size: 12,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.grey,
          size: 10,
        ),
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: cardBackgroundBlackDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColorDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 8),
            child: Text(
              'Ad',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 280,
              child: AdWidget(ad: _nativeAd!),
            ),
          ),
        ],
      ),
    );
  }
}
