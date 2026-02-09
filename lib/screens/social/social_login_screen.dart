import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/app_logo_widget.dart';
import 'package:streamit_laravel/configs.dart';
import 'package:streamit_laravel/screens/auth/sign_in/sign_in_screen.dart';

import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import '../dashboard/dashboard_screen.dart';
import '../home/home_controller.dart';

/// Apna gradient - Auth (yellow-orange)
const LinearGradient _authGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class SocialLoginScreen extends StatelessWidget {
  const SocialLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      scaffoldBackgroundColor: appScreenBackgroundDark,
      hasLeadingWidget: false,
      body: Column(
        children: [
          (Get.height * 0.16).toInt().height,
          // CachedImageWidget(
          //   url: Assets.imagesIcLogin,
          //   height: Get.height * 0.15,
          // ),

          const AppLogoWidget(),
          36.height,
          Text(
            'Login to Join $APP_NAME',
            style: boldTextStyle(size: 22, color: white, weight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          8.height,
          Text(
            'Connect with others, share posts, and be part of our community',
            style: primaryTextStyle(size: 14, color: darkGrayTextColor),
            textAlign: TextAlign.center,
          ),
          24.height,
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Get.to(() => SignInScreen(), arguments: true)?.then((value) {
                  if (value == true) {
                    Get.offAll(() => DashboardScreen(
                        dashboardController: getDashboardController(),),);
                  }
                });
                Get.lazyPut(() => HomeController());
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: Get.width * 0.65,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: _authGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _authGradient.colors.first.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  locale.value.logIn.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: boldTextStyle(size: 16, color: Colors.black),
                ),
              ),
            ),
          ),
          14.height,
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Need help? ",
                  style: primaryTextStyle(size: 14, color: darkGrayTextColor),
                ),
                TextSpan(
                  text: "Contact Support",
                  style: commonW600SecondaryTextStyle(size: 14, color: _authGradient.colors.first),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
