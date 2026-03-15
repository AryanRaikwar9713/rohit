import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:streamit_laravel/ads/ads_helper.dart';
import 'package:streamit_laravel/utils/colors.dart';

/// Responsive AdMob banner – respects screen width, clear "Ad" label (policy-compliant).
class AdMobBannerWidget extends StatefulWidget {
  const AdMobBannerWidget({super.key});

  @override
  State<AdMobBannerWidget> createState() => _AdMobBannerWidgetState();
}

class _AdMobBannerWidgetState extends State<AdMobBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  double _height = 50;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBanner());
  }

  Future<void> _loadBanner() async {
    if (!mounted) return;
    final w = MediaQuery.of(context).size.width;
    AdSize size = AdSize.banner;
    if (w > 0) {
      final anchor = await AdSize.getAnchoredAdaptiveBannerAdSize(
        Orientation.portrait,
        w.round(),
      );
      if (anchor != null) size = anchor;
    }
    if (!mounted) return;
    setState(() => _height = size.height.toDouble());

    _bannerAd = BannerAd(
      adUnitId: AdHelper().bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (_, __) {
          if (mounted) setState(() => _isLoaded = false);
        },
      ),
    );
    await _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      constraints: BoxConstraints(minHeight: _height),
      color: appScreenBackgroundDark,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Policy: clear "Ad" label so users know it's an ad
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Ad',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (_isLoaded && _bannerAd != null)
            SizedBox(
              height: _height,
              child: AdWidget(ad: _bannerAd!),
            )
          else
            SizedBox(height: _height, child: const SizedBox.shrink()),
        ],
      ),
    );
  }
}
