import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import '../../utils/constants.dart';
import 'eighteen_plus_controller.dart';

/// Apna gradient - 18+ Restricted (yellow-orange)
const LinearGradient _eighteenPlusGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class EighteenPlusCard extends StatelessWidget {
  EighteenPlusCard({super.key});

  final EighteenPlusController eighteenPlusCont = Get.put(EighteenPlusController());

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1a1510),
            appScreenBackgroundDark,
          ],
        ),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFFF9800).withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: AnimatedScrollView(
        crossAxisAlignment: CrossAxisAlignment.center,
        padding: const EdgeInsets.only(left: 28, right: 28, top: 28, bottom: 28),
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _eighteenPlusGradient,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          24.height,
          ShaderMask(
            shaderCallback: (bounds) => _eighteenPlusGradient.createShader(bounds),
            child: Text(
              locale.value.contentRestrictedAccess,
              textAlign: TextAlign.center,
              style: commonW500PrimaryTextStyle(size: 20, color: Colors.white),
            ),
          ),
          8.height,
          Text(
            locale.value.areYou18Above,
            textAlign: TextAlign.center,
            style: secondaryTextStyle(size: 16),
          ),
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              checkBox(),
              12.width,
              Text(
                locale.value.displayAClearProminentWarning,
                style: primaryTextStyle(
                  size: 12,
                  color: darkGrayTextColor,
                ),
              ).expand(),
            ],
          ).onTap(
            () {
              eighteenPlusCont.is18Plus.value = !eighteenPlusCont.is18Plus.value;
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          28.height,
          Obx(
            () => Row(
              spacing: 14,
              children: [
                // No - outline style
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFF9800).withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await setValue(SharedPreferenceConst.IS_FIRST_TIME_18, true);
                        await setValue(SharedPreferenceConst.IS_18_PLUS, false);
                        is18Plus(false);
                        Get.back(result: false);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        child: Text(
                          locale.value.no,
                          style: primaryTextStyle(size: 16, color: white),
                        ),
                      ),
                    ),
                  ),
                ).expand(),
                // Yes - gradient when confirmed
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: eighteenPlusCont.is18Plus.isTrue
                        ? _eighteenPlusGradient
                        : null,
                    color: eighteenPlusCont.is18Plus.isTrue
                        ? null
                        : lightBtnColor,
                    boxShadow: eighteenPlusCont.is18Plus.isTrue
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF9800).withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        if (eighteenPlusCont.is18Plus.isTrue) {
                          await setValue(SharedPreferenceConst.IS_FIRST_TIME_18, true);
                          await setValue(SharedPreferenceConst.IS_18_PLUS, true);
                          is18Plus(true);
                          Get.back(result: true);
                        } else {
                          toast(locale.value.pleaseConfirmContent);
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        child: Text(
                          locale.value.yes,
                          style: appButtonTextStyleWhite.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ).expand(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget checkBox() {
    return Obx(
      () => InkWell(
        onTap: () {
          eighteenPlusCont.is18Plus.value = !eighteenPlusCont.is18Plus.value;
        },
        child: Container(
          height: 20,
          width: 20,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: eighteenPlusCont.is18Plus.isTrue
                ? _eighteenPlusGradient
                : null,
            color: eighteenPlusCont.is18Plus.isTrue
                ? null
                : white,
            border: Border.all(
              color: eighteenPlusCont.is18Plus.isTrue
                  ? Colors.transparent
                  : const Color(0xFFFF9800).withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          child: eighteenPlusCont.is18Plus.isTrue
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : null,
        ),
      ),
    );
  }
}