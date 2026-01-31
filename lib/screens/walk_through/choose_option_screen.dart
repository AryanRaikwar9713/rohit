// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/main.dart';
import 'package:streamit_laravel/utils/common_base.dart';
import 'package:streamit_laravel/generated/assets.dart';

import '../../components/cached_image_widget.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../auth/sign_in/sign_in_screen.dart';
import '../dashboard/dashboard_screen.dart';

/// Apna gradient - Choose option (yellow-orange)
const LinearGradient _chooseOptionGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class ChooseOptionScreen extends StatelessWidget {
  const ChooseOptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              appScreenBackgroundDark.withValues(alpha: 0.3),
              appScreenBackgroundDark,
            ],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            CachedImageWidget(
              url: Assets.imagesIcChooseOptionBg,
              height: Get.height * 0.7,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: kToolbarHeight - 8,
              left: 4,
              child: backButton(padding: EdgeInsets.zero),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF1a1510),
                      appScreenBackgroundDark,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9800).withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (b) => _chooseOptionGradient.createShader(b),
                      child: Text(
                        locale.value.optionTitle,
                        textAlign: TextAlign.center,
                        style: boldTextStyle(size: 22, color: Colors.white),
                      ),
                    ).paddingSymmetric(horizontal: 16),
                    12.height,
                    Text(
                      locale.value.optionDesp.toString(),
                      textAlign: TextAlign.center,
                      style: secondaryTextStyle(size: 14),
                    ).paddingSymmetric(horizontal: 16),
                    24.height,
                    Row(
                      children: [
                        // Explore - outline with gradient border
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(defaultAppButtonRadius / 2),
                            border: Border.all(
                              color: const Color(0xFFFF9800).withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Get.offAll(
                                  () => DashboardScreen(dashboardController: getDashboardController()),
                                  binding: BindingsBuilder(
                                    () {
                                      getDashboardController().onBottomTabChange(0);
                                    },
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(defaultAppButtonRadius / 2),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                alignment: Alignment.center,
                                child: Text(
                                  locale.value.explore,
                                  style: primaryTextStyle(size: 16, color: white.withValues(alpha: 0.9)),
                                ),
                              ),
                            ),
                          ),
                        ).expand(),
                        16.width,
                        // Sign In - gradient button
                        Container(
                          decoration: BoxDecoration(
                            gradient: _chooseOptionGradient,
                            borderRadius: BorderRadius.circular(defaultAppButtonRadius / 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF9800).withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Get.to(() => SignInScreen(), arguments: true);
                              },
                              borderRadius: BorderRadius.circular(defaultAppButtonRadius / 2),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                alignment: Alignment.center,
                                child: Text(
                                  locale.value.signIn,
                                  style: appButtonTextStyleWhite.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        ).expand(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
