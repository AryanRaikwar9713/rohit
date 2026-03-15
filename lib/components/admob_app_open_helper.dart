import 'dart:io' if (dart.library.io) '../utils/platform_stub.dart' as io;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:streamit_laravel/configs.dart';

/// App Open ad – show when app returns from background only (policy: no cold-start, cooldown).
class AdMobAppOpenHelper {
  static AppOpenAd? _ad;
  static bool _isLoaded = false;
  static DateTime? _lastShownAt;
  static bool _hasBeenInBackground = false;
  static const _cooldownMinutes = 240; // 4 hours – policy-friendly

  static String get _adUnitId =>
      io.Platform.isAndroid ? APP_OPEN_AD_ID : IOS_APP_OPEN_AD_ID;

  static bool get isAppOpenAdReady => _ad != null && _isLoaded;

  static void load() {
    AppOpenAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoaded = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _ad = null;
              _isLoaded = false;
              load();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _ad = null;
              _isLoaded = false;
              load();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _ad = null;
          _isLoaded = false;
        },
      ),
    );
  }

  static void onAppPaused() => _hasBeenInBackground = true;

  /// Call when app is resumed. Only after user has left app (policy: no cold-start).
  static void maybeShowOnResume() {
    if (!_hasBeenInBackground || !_isLoaded || _ad == null) return;
    if (_lastShownAt != null) {
      final diff = DateTime.now().difference(_lastShownAt!);
      if (diff.inMinutes < _cooldownMinutes) return;
    }
    _lastShownAt = DateTime.now();
    _ad!.show();
  }
}
