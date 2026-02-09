import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/auth/sign_in/sign_in_screen.dart';
import 'package:streamit_laravel/generated/assets.dart';

import '../../components/app_scaffold.dart';
import '../../components/cached_image_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import '../dashboard/dashboard_screen.dart';
import '../home/home_controller.dart';

class ReelsLoginScreen extends StatelessWidget {
  const ReelsLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      scaffoldBackgroundColor: appScreenBackgroundDark,
      hasLeadingWidget: false,
      body: Column(
        children: [
          (Get.height * 0.16).toInt().height,
          CachedImageWidget(
            url: Assets.imagesIcLogin,
            height: Get.height * 0.15,
          ),
          40.height,
          Text(
            'Login to Watch Reels',
            style:
                boldTextStyle(size: 20, color: white, weight: FontWeight.w600),
          ),
          6.height,
          Text(
            'Discover amazing short videos and create your own reels',
            style: primaryTextStyle(size: 14, color: darkGrayTextColor),
          ),
          16.height,
          AppButton(
            width: Get.width * 0.6,
            text: locale.value.logIn,
            color: appColorPrimary,
            textStyle: appButtonTextStyleWhite,
            shapeBorder: RoundedRectangleBorder(borderRadius: radius(6)),
            onTap: () {
              Get.to(() => SignInScreen(), arguments: true)?.then((value) {
                if (value == true) {
                  Get.offAll(() => DashboardScreen(
                      dashboardController: getDashboardController(),),);
                }
              });
              Get.lazyPut(() => HomeController());
            },
          ),
          10.height,
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Need help? ",
                  style: primaryTextStyle(size: 14, color: darkGrayTextColor),
                ),
                TextSpan(
                  text: "Contact Support",
                  style: commonW600SecondaryTextStyle(
                      size: 14, color: appColorPrimary,),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
