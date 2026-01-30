import 'dart:io';
import '../configs.dart';
import '../utils/app_common.dart';

class AdHelper {
  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return appConfigs.value.bannerAdId.isNotEmpty ? appConfigs.value.bannerAdId : BANNER_AD_ID;
    } else if (Platform.isIOS) {
      return appConfigs.value.iosBannerAdId.isNotEmpty ? appConfigs.value.iosBannerAdId : IOS_BANNER_AD_ID;
    }
    throw UnsupportedError("Unsupported platform");
  }
}
