// ignore_for_file: avoid_types_as_parameter_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/common_base.dart';

import '../../main.dart';
import 'choose_option_screen.dart';
import 'walk_through_cotroller.dart';

/// Apna gradient - Walk through (yellow-orange)
const LinearGradient _walkThroughGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class WalkThroughScreen extends StatelessWidget {
  final WalkThroughController walkThroughCont = Get.put(WalkThroughController());

  WalkThroughScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              appScreenBackgroundDark,
              appScreenBackgroundDark.withValues(alpha: 0.98),
              const Color(0xFF1a1510),
            ],
          ),
        ),
        child: SafeArea(
          child: Obx(
            () => Column(
              children: [
                8.height,
                if (walkThroughCont.currentPosition.value == walkThroughCont.pages.length)
                  const Offstage()
                else
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () {
                        Get.offAll(() => const ChooseOptionScreen(), duration: const Duration(milliseconds: 500), curve: Curves.linearToEaseOut);
                      },
                      child: ShaderMask(
                        shaderCallback: (b) => _walkThroughGradient.createShader(b),
                        child: Text(
                          locale.value.lblSkip,
                          style: primaryTextStyle(color: Colors.white, size: 16, weight: FontWeight.w600),
                        ),
                      ),
                    ).paddingOnly(top: 8, right: 12),
                  ),
                8.height,
                Expanded(
                  child: PageView.builder(
                    itemCount: walkThroughCont.pages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final WalkThroughModelClass page = walkThroughCont.pages[index];
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  page.image.validate(),
                                  height: double.infinity,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          20.height,
                          ShaderMask(
                            shaderCallback: (b) => _walkThroughGradient.createShader(b),
                            child: Text(
                              page.title.toString(),
                              textAlign: TextAlign.center,
                              style: commonW500PrimaryTextStyle(size: 22, color: Colors.white),
                            ),
                          ),
                          8.height,
                          Text(
                            page.subTitle.toString(),
                            textAlign: TextAlign.center,
                            style: secondaryTextStyle(size: 14),
                          ).paddingSymmetric(horizontal: 16),
                        ],
                      );
                    },
                    controller: walkThroughCont.pageController.value,
                    onPageChanged: (num) {
                      walkThroughCont.currentPosition.value = num + 1;
                    },
                  ),
                ),
                16.height,
                DotIndicator(
                  pageController: walkThroughCont.pageController.value,
                  pages: walkThroughCont.pages,
                  indicatorColor: const Color(0xFFFF9800),
                  unselectedIndicatorColor: white.withValues(alpha: 0.4),
                  currentBoxShape: BoxShape.circle,
                  boxShape: BoxShape.circle,
                  dotSize: 6,
                  currentDotSize: 8,
                ),
                20.height,
                Container(
                  decoration: BoxDecoration(
                    gradient: _walkThroughGradient,
                    borderRadius: BorderRadius.circular(defaultAppButtonRadius / 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF9800).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        if (walkThroughCont.currentPosition.value == 3) {
                          Get.offAll(() => const ChooseOptionScreen(), duration: const Duration(milliseconds: 500), curve: Curves.linearToEaseOut);
                        } else {
                          walkThroughCont.pageController.value.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.linearToEaseOut);
                        }
                      },
                      borderRadius: BorderRadius.circular(defaultAppButtonRadius / 2),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        width: Get.width * 0.5,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        child: Text(
                          walkThroughCont.currentPosition.value == 3 ? locale.value.lblGetStarted : locale.value.lblNext,
                          style: appButtonTextStyleWhite.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
                24.height,
              ],
            ),
          ),
        ).paddingAll(12),
      ),
    );
  }
}