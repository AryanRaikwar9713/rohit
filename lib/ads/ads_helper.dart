import 'dart:io';
import '../configs.dart';
import '../utils/app_common.dart';

class AdHelper {
  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      final id = appConfigs.value.bannerAdId;
      return id.isNotEmpty && id.startsWith('ca-app-pub-') ? id : BANNER_AD_ID;
    } else if (Platform.isIOS) {
      final id = appConfigs.value.iosBannerAdId;
      return id.isNotEmpty && id.startsWith('ca-app-pub-') ? id : IOS_BANNER_AD_ID;
    }
    throw UnsupportedError("Unsupported platform");
  }
}
