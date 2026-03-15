import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/location_api.dart';
import 'package:streamit_laravel/main.dart';
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

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    const Duration maxWait = Duration(seconds: 8);
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
        proceed();
        return;
      }
      final LocationApi locationApi = LocationApi();
      final bool hasPermission =
          await locationApi.checkMandatoryLocationPermission(context);

      if (hasPermission) {
        proceed();
        return;
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: Get.width,
        height: Get.height,
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/splash_logo.png',
                      fit: BoxFit.contain,
                      width: 200,
                      height: 200,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                    24.height,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Walk a mile in my shoes',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Obx(
              () => splashController.appNotSynced.isTrue
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 48),
                      child: TextButton(
                        onPressed: () {
                          _checkLocationPermission();
                          splashController.init(showLoader: true);
                        },
                        child: Text(locale.value.reload, style: boldTextStyle().copyWith(color: Colors.white)),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
