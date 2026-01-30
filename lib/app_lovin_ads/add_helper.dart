import 'package:flutter/material.dart';
import 'package:applovin_max/applovin_max.dart';
import 'package:streamit_laravel/configs.dart';

class AdLovinHelper {

  static const String interstitialAdUnitId = "b6f3cfc7e7eab13e";
  static const String rewardedAdUnitId = "8b362c81e5a1b7d1";
  static const String bannerAdUnitId = "8b1a5c1b32845bcb";

  static bool isInterstitialReady = false;
  static bool isRewardedReady = false;

  static Future<void> initialize() async {
    print("🚀 Initializing AppLovin MAX...");
    print("SDK Key: $APP_LOVIN_SDK_KEY");
    print("Banner Ad Unit ID: $bannerAdUnitId");
    print("Interstitial Ad Unit ID: $interstitialAdUnitId");
    print("Rewarded Ad Unit ID: $rewardedAdUnitId");

    try {
      // Enable test mode for debugging - empty array enables test mode for all devices
      AppLovinMAX.setTestDeviceAdvertisingIds([]);
      print("✅ Test Mode Enabled for All Devices");

      await AppLovinMAX.initialize(APP_LOVIN_SDK_KEY);
      print("✅ AppLovin MAX Initialized Successfully");

      // Wait a bit for SDK to fully initialize
      await Future.delayed(Duration(milliseconds: 500));

      _initializeInterstitialAds();
      _initializeRewardedAds();

      loadInterstitial();
      loadRewarded();
    } catch (e) {
      print("❌ AppLovin MAX Initialization Failed: $e");
      print("Error Stack: ${StackTrace.current}");
    }
  }

  static void _initializeInterstitialAds() {
    AppLovinMAX.setInterstitialListener(
      InterstitialListener(
        onAdLoadedCallback: (MaxAd ad) {
          print("Interstitial LOADED");
          isInterstitialReady = true;
        },
        onAdLoadFailedCallback: (String adUnitId, MaxError error) {
          print("Interstitial FAILED: ${error.message}");
          isInterstitialReady = false;
          // Retry after 3 seconds
          Future.delayed(Duration(seconds: 3), loadInterstitial);
        },
        onAdHiddenCallback: (MaxAd ad) {
          print("Interstitial CLOSED");
          isInterstitialReady = false;
          loadInterstitial();
        },
        onAdDisplayedCallback: (MaxAd ad) {
          print("Interstitial Displayed");
        },
        onAdDisplayFailedCallback: (MaxAd ad, MaxError error) {
          print("Interstitial Display Failed: ${error.message}");
        },
        onAdClickedCallback: (MaxAd ad) {
          print("Interstitial Clicked");
        },
      ),
    );
  }

  static void loadInterstitial() {
    AppLovinMAX.loadInterstitial(interstitialAdUnitId);
  }

  static void showInterstitial() {
    if (isInterstitialReady) {
      AppLovinMAX.showInterstitial(interstitialAdUnitId);
    } else {
      print("Interstitial Not Ready Yet");
      loadInterstitial();
    }
  }

  static void _initializeRewardedAds() {
    AppLovinMAX.setRewardedAdListener(
      RewardedAdListener(
        onAdLoadedCallback: (MaxAd ad) {
          print("Rewarded LOADED");
          isRewardedReady = true;
        },
        onAdLoadFailedCallback: (String adUnitId, MaxError error) {
          print("Rewarded FAILED: ${error.message}");
          isRewardedReady = false;
          // Retry after 3 seconds
          Future.delayed(Duration(seconds: 3), loadRewarded);
        },
        onAdReceivedRewardCallback: (MaxAd ad, MaxReward reward) {},
        onAdHiddenCallback: (MaxAd ad) {
          print("Rewarded CLOSED");
          isRewardedReady = false;
          loadRewarded();
        },
        onAdDisplayedCallback: (MaxAd ad) {},
        onAdDisplayFailedCallback: (MaxAd ad, MaxError error) {},
        onAdClickedCallback: (MaxAd ad) {},
      ),
    );
  }

  static void loadRewarded() {
    AppLovinMAX.loadRewardedAd(rewardedAdUnitId);
  }

  static void showRewarded() {
    if (isRewardedReady) {
      AppLovinMAX.showRewardedAd(rewardedAdUnitId);
    } else {
      print("Rewarded Not Ready Yet");
      loadRewarded();
    }
  }

  static Widget bannerWidget() {
    return SizedBox(
      width: double.infinity, // Full width for banner
      height: 50, // Standard banner height
      child: MaxAdView(
        adUnitId: bannerAdUnitId,
        adFormat: AdFormat.banner,
        listener: AdViewAdListener(
          onAdLoadedCallback: (MaxAd ad) {
            print("✅ AppLovin Banner Loaded Successfully");
            print("Banner Ad Unit ID: $bannerAdUnitId");
            print("Banner Ad Network: ${ad.networkName}");
            print("Banner Ad Creative ID: ${ad.creativeId}");
          },
          onAdLoadFailedCallback: (String adUnitId, MaxError error) {
            print("❌ AppLovin Banner Failed to Load");
            print("Ad Unit ID: $adUnitId");
            print("Error Code: ${error.code}");
            print("Error Message: ${error.message}");
            print("Error Waterfall: ${error.waterfall}");
            // Retry loading after a delay
            Future.delayed(Duration(seconds: 5), () {
              print("🔄 Retrying Banner Ad Load...");
            });
          },
          onAdClickedCallback: (MaxAd ad) {
            print("✅ Banner Ad Clicked");
          },
          onAdExpandedCallback: (MaxAd ad) {
            print("Banner Ad Expanded");
          },
          onAdCollapsedCallback: (MaxAd ad) {
            print("Banner Ad Collapsed");
          },
        ),
      ),
    );
  }
}
