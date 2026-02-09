import 'dart:async';
import 'package:flutter/material.dart';
import 'package:applovin_max/applovin_max.dart';
import 'package:streamit_laravel/configs.dart';

class AdLovinHelper {

  // AppLovin MAX Ad Unit IDs
  // Note: AppLovin doesn't provide universal test IDs like AdMob
  // These IDs must exist in your AppLovin dashboard
  // When test mode is enabled (setTestDeviceAdvertisingIds([])), ANY valid ad unit ID will show test ads
  // For testing, create ad units in AppLovin dashboard and use those IDs here
  // Current IDs - Update these with your actual AppLovin dashboard ad unit IDs
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
      // This ensures test ads are shown for all devices during development
      AppLovinMAX.setTestDeviceAdvertisingIds([]);
      print("✅ Test Mode Enabled for All Devices");
      print("📱 Test ads will be shown for all devices");
      print("🧪 TEST MODE: AppLovin will show test ads automatically");
      print("⚠️ IMPORTANT: Ad unit IDs must exist in your AppLovin dashboard");
      print("   Even in test mode, ad unit IDs must be valid");

      // Initialize with timeout
      await AppLovinMAX.initialize(APP_LOVIN_SDK_KEY).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print("⚠️ AppLovin initialization timeout - continuing anyway");
          return null;
        },
      );
      print("✅ AppLovin MAX Initialized Successfully");
      print("🔑 SDK Key: ${APP_LOVIN_SDK_KEY.substring(0, 20)}...");
      print("🧪 TEST MODE ACTIVE - All ads will be test ads");

      // Wait a bit for SDK to fully initialize
      await Future.delayed(const Duration(milliseconds: 3000));

      _initializeInterstitialAds();
      _initializeRewardedAds();

      // Immediately start loading ads
      print("🔄 Starting to load ads...");
      loadInterstitial();
      loadRewarded();
      
      // Keep retrying if ads don't load
      _startAutoRetryAds();
    } catch (e) {
      print("❌ AppLovin MAX Initialization Failed: $e");
      print("⚠️ Note: If you see network errors, ensure:");
      print("   1. Ad unit IDs exist in your AppLovin dashboard");
      print("   2. SDK key is correct");
      print("   3. Internet connection is available");
      print("   4. App is properly configured in AppLovin dashboard");
      // Continue anyway - ads will retry automatically
    }
  }

  static void _initializeInterstitialAds() {
    AppLovinMAX.setInterstitialListener(
      InterstitialListener(
        onAdLoadedCallback: (MaxAd ad) {
          print("✅ Interstitial LOADED");
          print("   🧪 TEST MODE: This is a test ad");
          isInterstitialReady = true;
        },
        onAdLoadFailedCallback: (String adUnitId, MaxError error) {
          print("Interstitial FAILED: ${error.message}");
          isInterstitialReady = false;
          
          // Check if it's a network error by message
          final isNetworkError = error.message.toLowerCase().contains('network') || 
                                 error.message.toLowerCase().contains('unable to resolve');
          
          if (!isNetworkError) {
            // Retry after 10 seconds for non-network errors
            Future.delayed(const Duration(seconds: 10), loadInterstitial);
          } else {
            print("⚠️ Network error detected. Will retry via auto-retry mechanism.");
          }
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
    print("📥 Loading Interstitial Ad...");
    print("   Ad Unit ID: $interstitialAdUnitId");
    try {
      AppLovinMAX.loadInterstitial(interstitialAdUnitId);
    } catch (e) {
      print("❌ Error loading interstitial ad: $e");
      // Retry after 3 seconds
      Future.delayed(const Duration(seconds: 3), loadInterstitial);
    }
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
          print("✅ Rewarded Ad LOADED Successfully!");
          print("   Ad Unit ID: $rewardedAdUnitId");
          print("   Network: ${ad.networkName}");
          print("   Creative ID: ${ad.creativeId}");
          print("   🧪 TEST MODE: This is a test ad");
          isRewardedReady = true;
        },
        onAdLoadFailedCallback: (String adUnitId, MaxError error) {
          print("❌ Rewarded Ad FAILED to Load");
          print("   Ad Unit ID: $adUnitId");
          print("   Error Code: ${error.code}");
          print("   Error Message: ${error.message}");
          print("   Waterfall: ${error.waterfall}");
          isRewardedReady = false;
          
          // Check if it's a network error by message
          final isNetworkError = error.message.toLowerCase().contains('network') || 
                                 error.message.toLowerCase().contains('unable to resolve');
          
          if (!isNetworkError) {
            // Retry after 10 seconds for non-network errors
            Future.delayed(const Duration(seconds: 10), () {
              print("🔄 Retrying Rewarded Ad Load...");
              loadRewarded();
            });
          } else {
            // For network errors, wait longer (30 seconds) - handled by auto-retry
            print("⚠️ Network error detected. Will retry via auto-retry mechanism.");
          }
        },
        onAdReceivedRewardCallback: (MaxAd ad, MaxReward reward) {
          print("🎉 REWARD RECEIVED!");
          print("   Reward Label: ${reward.label}");
          print("   Reward Amount: ${reward.amount}");
          print("   Ad Network: ${ad.networkName}");
          // Call reward callback if set
          if (_onRewardReceived != null) {
            print("   Calling reward callback...");
            _onRewardReceived!();
          } else {
            print("   ⚠️ No reward callback set!");
          }
        },
        onAdHiddenCallback: (MaxAd ad) {
          print("Rewarded CLOSED");
          isRewardedReady = false;
          loadRewarded();
        },
        onAdDisplayedCallback: (MaxAd ad) {
          print("Rewarded Displayed");
        },
        onAdDisplayFailedCallback: (MaxAd ad, MaxError error) {
          print("Rewarded Display Failed: ${error.message}");
        },
        onAdClickedCallback: (MaxAd ad) {
          print("Rewarded Clicked");
        },
      ),
    );
  }

  // Callback for when reward is received
  static VoidCallback? _onRewardReceived;

  // Set callback for reward received
  static void setRewardCallback(VoidCallback? callback) {
    _onRewardReceived = callback;
  }

  static void loadRewarded() {
    print("📥 Loading Rewarded Ad...");
    print("   Ad Unit ID: $rewardedAdUnitId");
    try {
      AppLovinMAX.loadRewardedAd(rewardedAdUnitId);
    } catch (e) {
      print("❌ Error loading rewarded ad: $e");
      // Retry after 3 seconds
      Future.delayed(const Duration(seconds: 3), loadRewarded);
    }
  }
  
  // Auto-retry mechanism to keep loading ads - Reduced frequency for better performance
  static Timer? _retryTimer;
  static void _startAutoRetryAds() {
    // Cancel existing timer if any
    _retryTimer?.cancel();
    
    // Check every 30 seconds (reduced from 10) if ads are loaded, if not, retry
    _retryTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!isRewardedReady) {
        print("🔄 Rewarded ad still not ready, retrying...");
        loadRewarded();
      }
      if (!isInterstitialReady) {
        print("🔄 Interstitial ad still not ready, retrying...");
        loadInterstitial();
      }
    });
  }

  static void showRewarded() {
    if (isRewardedReady) {
      print("📺 Showing Rewarded Ad...");
      print("   Ad Unit ID: $rewardedAdUnitId");
      try {
        AppLovinMAX.showRewardedAd(rewardedAdUnitId);
      } catch (e) {
        print("❌ Error showing rewarded ad: $e");
        isRewardedReady = false;
        loadRewarded();
      }
    } else {
      print("⏳ Rewarded Ad Not Ready Yet - Loading Now...");
      print("   Current Status: isRewardedReady = $isRewardedReady");
      // Force load immediately
      loadRewarded();
      // Try to show after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (isRewardedReady) {
          print("✅ Ad loaded! Showing now...");
          showRewarded();
        } else {
          print("⏳ Still loading, please wait...");
        }
      });
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
            print("🧪 TEST MODE: This is a test ad");
          },
          onAdLoadFailedCallback: (String adUnitId, MaxError error) {
            print("❌ AppLovin Banner Failed to Load");
            print("Ad Unit ID: $adUnitId");
            print("Error Code: ${error.code}");
            print("Error Message: ${error.message}");
            print("Error Waterfall: ${error.waterfall}");
            // Retry loading after a delay
            Future.delayed(const Duration(seconds: 5), () {
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
