import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/app_logo_widget.dart';
import 'package:streamit_laravel/location_api.dart';
import 'package:streamit_laravel/main.dart';
import '../components/app_scaffold.dart';
import '../components/loader_widget.dart';
import '../utils/colors.dart';
import 'splash_controller.dart';

class SplashScreen extends StatefulWidget {
  final String deepLink;
  final bool? link;

  const SplashScreen({super.key, this.deepLink = "", this.link});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashScreenController splashController =
      Get.put(SplashScreenController());
  bool _locationPermissionChecked = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    // Keep checking until permission is granted
    while (mounted) {
      final LocationApi locationApi = LocationApi();
      final bool hasPermission =
          await locationApi.checkMandatoryLocationPermission(context);

      if (hasPermission) {
        setState(() {
          _locationPermissionChecked = true;
        });
        // Proceed with app initialization only after permission is granted
        if (widget.link == true) {
          splashController.handleDeepLinking(deepLink: widget.deepLink);
        } else {
          splashController.init(showLoader: true);
        }
        break; // Exit loop when permission is granted
      } else {
        // Permission not granted - wait and check again
        setState(() {
          _locationPermissionChecked = true;
        });
        // Wait before re-checking (give user time to enable location/permission)
        await Future.delayed(const Duration(seconds: 2));
        // Loop will continue and check again
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      hideAppBar: true,
      scaffoldBackgroundColor: appScreenBackgroundDark,
      body: SizedBox(
        height: Get.height,
        width: Get.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogoWidget(size: Size(160, 160)),
            if (!_locationPermissionChecked)
              const LoaderWidget().center()
            else
              Obx(
                () => splashController.isLoading.value
                    ? const LoaderWidget().center()
                    : TextButton(
                        child:
                            Text(locale.value.reload, style: boldTextStyle()),
                        onPressed: () {
                          _checkLocationPermission();
                          splashController.init(showLoader: true);
                        },
                      ).visible(splashController.appNotSynced.isTrue),
              )
          ],
        ),
      ),
    );
  }
}
