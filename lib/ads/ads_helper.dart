import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

import '../configs.dart';
import '../utils/app_common.dart';

class AdHelper {
  static bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;
  static bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  String get bannerAdUnitId {
    if (_isAndroid) {
      final id = appConfigs.value.bannerAdId;
      return id.isNotEmpty && id.startsWith('ca-app-pub-') ? id : BANNER_AD_ID;
    } else if (_isIOS) {
      final id = appConfigs.value.iosBannerAdId;
      return id.isNotEmpty && id.startsWith('ca-app-pub-') ? id : IOS_BANNER_AD_ID;
    }
    throw UnsupportedError("Unsupported platform");
  }

  String get interstitialAdUnitId {
    if (_isAndroid) {
      final id = appConfigs.value.interstitialAdId;
      return id.isNotEmpty && id.startsWith('ca-app-pub-') ? id : INTERSTITIAL_AD_ID;
    } else {
      final id = appConfigs.value.iosInterstitialAdId;
      return id.isNotEmpty && id.startsWith('ca-app-pub-') ? id : IOS_INTERSTITIAL_AD_ID;
    }
  }

  String get rewardedAdUnitId {
    if (_isAndroid) {
      final id = appConfigs.value.rewardedAdId;
      return id.isNotEmpty && id.startsWith('ca-app-pub-') ? id : REWARDED_AD_ID;
    } else {
      final id = appConfigs.value.iosRewardedAdId;
      return id.isNotEmpty && id.startsWith('ca-app-pub-') ? id : IOS_REWARDED_AD_ID;
    }
  }

  String get rewardInterstitialAdUnitId {
    if (_isAndroid) {
      final id = appConfigs.value.rewardInterstitialAdId;
      return id.isNotEmpty && id.startsWith('ca-app-pub-') ? id : REWARD_INTERSTITIAL_AD_ID;
    } else {
      final id = appConfigs.value.iosRewardInterstitialAdId;
      return id.isNotEmpty && id.startsWith('ca-app-pub-') ? id : IOS_REWARD_INTERSTITIAL_AD_ID;
    }
  }

  String get nativeAdUnitId {
    if (_isAndroid) {
      final id = appConfigs.value.nativeAdId;
      return id.isNotEmpty && id.startsWith('ca-app-pub-') ? id : NATIVE_AD_ID;
    } else {
      final id = appConfigs.value.iosNativeAdId;
      return id.isNotEmpty && id.startsWith('ca-app-pub-') ? id : IOS_NATIVE_AD_ID;
    }
  }

  String get appOpenAdUnitId {
    if (_isAndroid) return APP_OPEN_AD_ID;
    return IOS_APP_OPEN_AD_ID;
  }
}
