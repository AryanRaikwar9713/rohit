import 'package:flutter/material.dart';
import 'package:streamit_laravel/generated/assets.dart';
import '../configs.dart';
import '../utils/constants.dart';

class AppMinLogoWidget extends StatelessWidget {
  final Size? size;

  const AppMinLogoWidget({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      APP_MINI_LOGO_URL,
      height: size?.height ?? Constants.appLogoSize,
      width: size?.width ?? Constants.appLogoSize,
      errorBuilder: (context, url, error) {
        return Image.asset(
          Assets.iconsIcIcon,
          height: size?.height ?? Constants.appLogoSize,
          width: size?.width ?? Constants.appLogoSize,
        );
      },
    );
  }
}

class AppLogoWidget extends StatelessWidget {
  final Size? size;

  const AppLogoWidget({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      APP_LOGO_URL,
      height: size?.height ?? Constants.appLogoSize,
      width: size?.width ?? Constants.appLogoSize,
      errorBuilder: (context, url,er) {
        return Image.asset(
          Assets.assetsAppLogo,
          height: size?.height ?? Constants.appLogoSize,
          width: size?.width ?? Constants.appLogoSize,
        );
      },
    );
  }
}
