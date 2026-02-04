// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/ads/custom_ads/ad_player_controller.dart';
import 'package:streamit_laravel/ads/model/custom_ad_response.dart';
import 'package:streamit_laravel/network/core_api.dart';
import 'package:streamit_laravel/screens/coming_soon/coming_soon_controller.dart';
import 'package:streamit_laravel/screens/coming_soon/coming_soon_screen.dart';
import 'package:streamit_laravel/screens/live_tv/live_tv_controller.dart';
import 'package:streamit_laravel/screens/live_tv/live_tv_screen.dart';
import 'package:streamit_laravel/screens/profile/profile_screen.dart';
import 'package:streamit_laravel/screens/search/search_screen.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_screen.dart';
import 'package:streamit_laravel/video_players/model/vast_ad_response.dart';
import 'package:streamit_laravel/local_db.dart';

import '../../network/auth_apis.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/common_base.dart';
import '../../utils/constants.dart';
import '../../utils/colors.dart';
import '../../utils/local_storage.dart' as storage;
import '../home/home_controller.dart';
import '../home/home_screen.dart';
import '../profile/profile_controller.dart';
import '../profile/profile_login_screen.dart';
import '../search/search_controller.dart';
import '../donation/donation_screen.dart';
import '../donation/donation_login_screen.dart';
import '../social/social_screen.dart';
import '../social/social_login_screen.dart';
import '../reels/reels_screen.dart';
import '../reels/reels_login_screen.dart';
import '../shops_section/shop_screen.dart';
import '../events/events_screen.dart';
// TODO: Keep imports for future use
// ignore: unused_import
import '../video_channel/screens/video_channel_screen.dart';
// ignore: unused_import
import '../video_channel/video_channle_controller.dart';
import 'components/menu.dart';
import '../../location_api.dart';
import 'dart:math' as math;

class DashboardController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxString userCountry = ''.obs;
  RxBool isShopEnabled = false.obs;
  RxBool isEventsEnabled = false.obs;
  RxList<BottomBarItem> bottomNavItems = <BottomBarItem>[].obs;

  RxList<Widget> screen = <Widget>[].obs;

  RxList<VastAd> vastAds = <VastAd>[].obs;
  final AdPlayerController adPlayerController =
      Get.isRegistered<AdPlayerController>()
          ? Get.find<AdPlayerController>()
          : Get.put(AdPlayerController());
  RxList<CustomAd> customAds = <CustomAd>[].obs;
  RxList<CustomAd> customHomePageAds = <CustomAd>[].obs;
  Worker? _shopEnabledWorker;
  Worker? _eventsEnabledWorker;

  @override
  void onInit() {
    currentIndex(0);
    screen.clear();
    checkUserCountry();
    getAppConfigurations();
    addDataOnBottomNav();
    // Add workers to auto-update bottom nav when shop/events enabled state changes
    _shopEnabledWorker ??=
        ever<bool>(isShopEnabled, (_) => addDataOnBottomNav());
    _eventsEnabledWorker ??=
        ever<bool>(isEventsEnabled, (_) => addDataOnBottomNav());
    onBottomTabChange(0);
    super.onInit();
  }

  @override
  void onClose() {
    _shopEnabledWorker?.dispose();
    _eventsEnabledWorker?.dispose();
    super.onClose();
  }

  /// Check user's country and enable/disable shop section
  Future<void> checkUserCountry() async {
    try {
      final LocationApi locationApi = LocationApi();
      final String? country = await locationApi.getUserCountry();
      if (country != null) {
        userCountry.value = country;
        final String countryLower = country.toLowerCase().trim();

        final bool isIndia = countryLower == 'india' ||
            countryLower == 'in' ||
            countryLower.contains('india');
        // Update values - workers will automatically trigger addDataOnBottomNav
        isShopEnabled.value = isIndia;
        isEventsEnabled.value = isIndia;
        log('Country detected: $country, Shop enabled: ${isShopEnabled.value}, Events enabled: ${isEventsEnabled.value}');
      } else {
        log('Country could not be determined');
        // Update values - workers will automatically trigger addDataOnBottomNav
        isShopEnabled.value = false;
        isEventsEnabled.value = false;
      }
    } catch (e) {
      log('Error checking user country: $e');
      // Update values - workers will automatically trigger addDataOnBottomNav
      isShopEnabled.value = false;
      isEventsEnabled.value = false;
    }
  }

  void addDataOnBottomNav() {
    final int previousIndex = currentIndex.value;

    final List<BottomBarItem> items = [
      BottomBarItem(
          title: 'Social',
          icon: Icons.people_outline,
          activeIcon: Icons.people,
          type: BottomItem.social.name),
      BottomBarItem(
          title: 'Reels',
          icon: Icons.play_circle_outline,
          activeIcon: Icons.play_circle,
          type: BottomItem.reels.name),
      BottomBarItem(
          title: 'Impact',
          icon: Icons.favorite_outline,
          activeIcon: Icons.favorite,
          type: BottomItem.donation.name),
    ];

    // TODO: Shop and Events - Hidden for current version, will be released in future
    // Keep all logic intact, just hide from bottom nav
    // Add Shop only if user is in India
    // if (isShopEnabled.value) {
    //   items.add(
    //     BottomBarItem(
    //         title: 'Shop',
    //         icon: Icons.shopping_bag_outlined,
    //         activeIcon: Icons.shopping_bag,
    //         type: BottomItem.shop.name),
    //   );
    // }

    // Add Events only if user is in India
    // if (isEventsEnabled.value) {
    //   items.add(
    //     BottomBarItem(
    //         title: 'Events',
    //         icon: Icons.event_outlined,
    //         activeIcon: Icons.event,
    //         type: BottomItem.events.name),
    //   );
    // }

    // Clips section is permanently visible (always added)
    items.add(
      BottomBarItem(
        title: 'Clips',
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        type: BottomItem.home.name,
        customIcon: Image.asset(
          'assets/launcher_icons/streamLogo.png',
          width: 22,
          height: 22,
          color: iconColor,
        ),
        customActiveIcon: Image.asset(
          'assets/launcher_icons/streamLogo.png',
          width: 22,
          height: 22,
          color: appColorPrimary,
        ),
      ),
    );

    items.add(
      BottomBarItem(
          title: locale.value.profile,
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          type: BottomItem.profile.name),
    );

    bottomNavItems.value = items;
    bottomNavItems.refresh();

    // Ensure screen list is properly sized to match bottomNavItems
    while (screen.length < items.length) {
      screen.add(const SizedBox());
    }

    final int upperBound = math.max(bottomNavItems.length - 1, 0);
    final int safeIndex = previousIndex.clamp(0, upperBound).toInt();
    if (safeIndex != currentIndex.value) {
      currentIndex(safeIndex);
    }

    // Initialize the current screen if it's not already initialized
    onBottomTabChange(currentIndex.value);
  }

  void addScreenAtPosition(int index, Widget screenWidget) {
    if (screen.length <= index) {
      screen.addAll(
          List.generate(index - screen.length + 1, (_) => const SizedBox()));
    }

    if (screen[index].runtimeType != screenWidget.runtimeType) {
      screen[index] = screenWidget;
    }
  }

  Future<void> onBottomTabChange(int index) async {
    currentIndex(index);
    try {
      if (index < bottomNavItems.length) {
        final BottomBarItem item = bottomNavItems[index];
        final String itemType = item.type;

        switch (itemType) {
          case 'social':
            await handleSocialScreen();
            break;
          case 'reels':
            await handleReelsScreen();
            break;
          case 'donation':
            await handleDonationScreen();
            break;
          case 'home':
            await handleHomeScreen();
            break;
          case 'shop':
            await handleShopScreen();
            break;
          case 'events':
            await handleEventsScreen();
            break;
          case 'profile':
            await handleProfileScreen();
            break;
          default:
            log('Unknown tab type: $itemType');
        }
      }
    } catch (e) {
      log('onBottomTabChange Err: $e');
    }
  }

  T getOrPutController<T>(T Function() createController) {
    return Get.isRegistered<T>() ? Get.find<T>() : Get.put(createController());
  }

  Future<void> handleSocialScreen() async {
    if (getBoolAsync(SharedPreferenceConst.IS_LOGGED_IN)) {
      addScreenAtPosition(0, const SocialScreen());
    } else {
      addScreenAtPosition(0, const SocialLoginScreen());
    }
  }

  Future<void> handleReelsScreen() async {
    // Check login status for reels screen
    if (getBoolAsync(SharedPreferenceConst.IS_LOGGED_IN)) {
      addScreenAtPosition(1, const ReelsScreen());
    } else {
      addScreenAtPosition(1, const ReelsLoginScreen());
    }
  }

  Future<void> handleHomeScreen() async {
    // 'home' type is used for Clips section (permanently visible)
    // Show VideoChannelScreen (video profile screen)
    final int homeIndex =
        bottomNavItems.indexWhere((item) => item.type == BottomItem.home.name);
    if (homeIndex >= 0) {
      // Initialize VideoChannelController
      final HomeController homeScreenController =
          getOrPutController<HomeController>(() => HomeController());
      
      // Always show VideoChannelScreen first to avoid black screen
      addScreenAtPosition(homeIndex, HomeScreen(homeScreenController: homeScreenController));
      
      // Load channel data if not already loaded or loading
      // // Screen will automatically update via Obx when data loads
      // if (!videoChannelController.loading.value &&
      //     videoChannelController.channel.value == null) {
      //   videoChannelController.getChannel();
      // }
    }
  }

  Future<void> handleSearchScreen() async {
    final SearchScreenController searchCont =
        getOrPutController(() => SearchScreenController());
    searchCont.getSearchList();
    addScreenAtPosition(1, SearchScreen(searchCont: searchCont));
  }

  Future<void> handleComingSoonScreen() async {
    final ComingSoonController comingSoonCont =
        getOrPutController(() => ComingSoonController(getComingSoonList: true));
    comingSoonCont.getComingSoonDetails(showLoader: false);
    addScreenAtPosition(2, ComingSoonScreen(comingSoonCont: comingSoonCont));
  }

  Future<void> handleDonationScreen() async {
    if (getBoolAsync(SharedPreferenceConst.IS_LOGGED_IN)) {
      addScreenAtPosition(2, const ImpactDashboardScreen());
    } else {
      addScreenAtPosition(2, const DonationLoginScreen());
    }
  }

  Future<void> handleShopScreen() async {
    final int shopIndex =
        bottomNavItems.indexWhere((item) => item.type == BottomItem.shop.name);
    if (shopIndex >= 0) {
      addScreenAtPosition(shopIndex, const ShopScreen());
    }
  }

  Future<void> handleEventsScreen() async {
    final int eventsIndex = bottomNavItems
        .indexWhere((item) => item.type == BottomItem.events.name);
    if (eventsIndex >= 0) {
      addScreenAtPosition(eventsIndex, const EventsScreen());
    }
  }

  Future<void> handleLiveOrProfileScreen() async {
    if (appConfigs.value.enableLiveTv) {
      final LiveTVController liveTVController =
          getOrPutController(() => LiveTVController());
      liveTVController.getLiveDashboardDetail(showLoader: false);
      addScreenAtPosition(3, LiveTvScreen(liveTVCont: liveTVController));
    } else if (getBoolAsync(SharedPreferenceConst.IS_LOGGED_IN)) {
      final ProfileController profileController =
          getOrPutController(() => ProfileController());
      profileController.getProfileDetail();
      addScreenAtPosition(3, ProfileScreen(profileCont: profileController));
    } else {
      addScreenAtPosition(3, const ProfileLoginScreen());
    }
  }

  Future<void> handleProfileScreen() async {
    if (getBoolAsync(SharedPreferenceConst.IS_LOGGED_IN)) {
      // Get current user ID for self profile
      final user = await DB().getUser();
      final userId = user?.id ?? 0;

      // Calculate profile screen index (always last item in bottom nav)
      final profileIndex = bottomNavItems.length - 1;

      if (userId > 0) {
        addScreenAtPosition(
          profileIndex,
          VammisProfileScreen(
            userId: userId,
            isOwnProfile: true,
            popButton: false,
          ),
        );
      } else {

        addScreenAtPosition(profileIndex, const ProfileLoginScreen());
      }
    } else {
      final profileIndex = bottomNavItems.length - 1;
      addScreenAtPosition(profileIndex, const ProfileLoginScreen());
    }
  }

  Future<void> getAppConfigurations() async {
    if (!getBoolAsync(SharedPreferenceConst.IS_APP_CONFIGURATION_SYNCED_ONCE)) {
      await AuthServiceApis()
          .getAppConfigurations(
              forceSync: !getBoolAsync(
                  SharedPreferenceConst.IS_APP_CONFIGURATION_SYNCED_ONCE,
                  defaultValue: false))
          .then(
        (value) {
          onBottomTabChange(0);
        },
      ).onError((error, stackTrace) {
        toast(error.toString());
      });
    }
  }

  Future<void> getActiveVastAds() async {
    try {
      final VastAdResponse? res = await CoreServiceApis().getVastAds();
      if (res != null) {
        vastAds.value = res.data ?? [];
      }
    } catch (e) {
      log('getActiveVastAds Err: $e');
    }
  }

  Future<void> getActiveCustomAds() async {
    try {
      final CustomAdResponse? res = await CoreServiceApis().getCustomAds();
      if (res != null) {
        customAds.value = res.data ?? [];
      }
    } catch (e) {
      log('getActiveCustomAds Err: $e');
    }
  }

  @override
  void onReady() {
    if (Get.context != null) {
      View.of(Get.context!).platformDispatcher.onPlatformBrightnessChanged =
          () {
        WidgetsBinding.instance.handlePlatformBrightnessChanged();
        try {
          final getThemeFromLocal =
              storage.getValueFromLocal(SettingsLocalConst.THEME_MODE);
          if (getThemeFromLocal is int) {
            toggleThemeMode(themeId: getThemeFromLocal);
          }
        } catch (e) {
          log('getThemeFromLocal from cache E: $e');
        }
      };
      getActiveVastAds();
    }
    super.onReady();
  }

  List<CustomAd> getBannerAdsForCategory({
    String? targetContentType,
    int? categoryId,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return customAds.where((ad) {
      if (ad.placement != 'banner') return false;
      if (ad.status != 1) return false;
      // Check startDate
      if (ad.startDate != null) {
        final adStartDay = DateTime(
            ad.startDate!.year, ad.startDate!.month, ad.startDate!.day);
        if (adStartDay.isAfter(today)) return false;
      }
      if (ad.endDate != null) {
        final adEndDay =
            DateTime(ad.endDate!.year, ad.endDate!.month, ad.endDate!.day);
        if (adEndDay.isBefore(today)) return false;
      }

      // if (ad.startDate != null && now.isBefore(ad.startDate!)) return false;
      // if (ad.endDate != null && now.isAfter(ad.endDate!)) return false;
      if (ad.type != 'image' && ad.type != 'video') return false;
      if (targetContentType != null &&
          ad.targetContentType != targetContentType) return false;
      if (ad.targetCategories != null && ad.targetCategories!.isNotEmpty) {
        try {
          final cats = ad.targetCategories!
              .replaceAll('[', '')
              .replaceAll(']', '')
              .split(',')
              .map((e) => int.tryParse(e.trim()))
              .whereType<int>()
              .toList();
          if (categoryId != null) {
            if (!cats.contains(categoryId)) return false;
          } else {
            return true;
          }
        } catch (_) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}
