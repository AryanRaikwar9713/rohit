import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
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
    const Duration maxWait = Duration(seconds: 20);
    final DateTime start = DateTime.now();

    void proceed() {
      if (widget.link == true) {
        splashController.handleDeepLinking(deepLink: widget.deepLink);
      } else {
        splashController.init(showLoader: true);
      }
    }

    while (mounted) {
      if (DateTime.now().difference(start) > maxWait) {
        setState(() => _locationPermissionChecked = true);
        proceed();
        return;
      }
      final LocationApi locationApi = LocationApi();
      final bool hasPermission =
          await locationApi.checkMandatoryLocationPermission(context);

      if (hasPermission) {
        setState(() => _locationPermissionChecked = true);
        proceed();
        return;
      }
      setState(() => _locationPermissionChecked = true);
      await Future.delayed(const Duration(seconds: 2));
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
            Image.asset(
              'assets/splash_image.jpeg',
              height: 160,
              width: 160,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.image_not_supported_outlined,
                size: 80,
                color: Colors.grey[600],
              ),
            ),
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
