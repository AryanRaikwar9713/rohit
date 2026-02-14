import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:streamit_laravel/configs.dart';

class AdMobRewardedAdHelper {
  static RewardedAd? _rewardedAd;

  static bool get isRewardedAdReady => _rewardedAd != null;

  static void initialize() {
    loadRewardedAd();
  }

  static void loadRewardedAd() {
    final adUnitId = Platform.isIOS ? IOS_REWARDED_AD_ID : REWARDED_AD_ID;
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
        },
      ),
    );
  }

  static Future<bool> showRewardedAd({
    required Future<void> Function() onRewardReceived,
  }) async {
    if (_rewardedAd == null) return false;
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewardReceived();
      },
    );
    return true;
  }
}
