import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/loader_widget.dart';
import 'package:streamit_laravel/screens/auth/sign_in/sign_in_controller.dart';
import 'package:streamit_laravel/utils/colors.dart';

import '../../../main.dart';
import '../../../utils/common_base.dart';

/// Apna gradient - OTP (yellow-orange)
const LinearGradient _otpGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class OTPVerifyComponent extends StatelessWidget {
  final String mobileNo;

  OTPVerifyComponent({super.key, required this.mobileNo});

  final SignInController verificationCont = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: boxDecorationDefault(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(top: BorderSide(color: _otpGradient.colors.first.withOpacity(0.5), width: 2)),
        color: appScreenBackgroundDark,
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                20.height,
                ShaderMask(
                  shaderCallback: (b) => _otpGradient.createShader(b),
                  child: Text(
                    locale.value.oTPVerification,
                    style: commonW500PrimaryTextStyle(size: 20, color: Colors.white),
                  ),
                ),
                8.height,
                Text(
                  locale.value.checkYourSmsInboxAndEnterTheCodeYouGet,
                  style: secondaryTextStyle(),
                ),
                20.height,
                AppTextField(
                  textFieldType: TextFieldType.USERNAME,
                  controller: verificationCont.verifyCont,
                  isValidationRequired: true,
                  errorThisFieldRequired: 'Enter OTP',
                  textStyle: primaryTextStyle(letterSpacing: 6),
                  maxLength: 6,
                  decoration: inputDecoration(context).copyWith(counterText: ''),
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    if (value.length == 6) {
                      verificationCont.getVerifyBtnEnable();
                      verificationCont.isOTPVerify(true);
                    } else {
                      verificationCont.isOTPVerify(false);
                      verificationCont.isVerifyBtn(false);
                    }
                  },
                  onFieldSubmitted: (p0) {
                    verificationCont.verifyCont.text = p0;

                    verificationCont.getVerifyBtnEnable();
                    if (verificationCont.isVerifyBtn.isTrue && verificationCont.codeResendTime.value != 0) {
                      verificationCont.checkIfDemoUser(
                        verify: true,
                        callBack: () {
                          verificationCont.onVerifyPressed();
                        },
                      );
                    }
                  },
                ),
                Obx(() => verificationCont.codeResendTime.value != 0 ? 20.height : 0.height),
                Obx(
                  () => Text(
                    verificationCont.codeResendTime.value == 0 ? "" : verificationCont.codeResendTime.value.toString(),
                    style: commonW500PrimaryTextStyle(size: 18),
                  ),
                ),
                10.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      locale.value.didntGetTheOTP,
                      style: commonW500SecondaryTextStyle(),
                    ),
                    Obx(
                      () => InkWell(
                        onTap: verificationCont.verificationCode.value.length == 6 || verificationCont.codeResendTime > 0
                            ? null
                            : () {
                                verificationCont.verifyCont.text = "";
                                verificationCont.reSendOTP();
                              },
                        child: Text(
                          locale.value.resendOTP.prefixText(value: ' '),
                          style: commonW500SecondaryTextStyle(
                            color: verificationCont.codeResendTime.value == 0 ? _otpGradient.colors.first : darkGrayTextColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                20.height,
                Obx(
                  () {
                    final isEnabled = verificationCont.isOTPVerify.isTrue ||
                        (verificationCont.isVerifyBtn.isTrue && verificationCont.codeResendTime.value != 0);
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (verificationCont.isLoading.isTrue) {
                            verificationCont.isVerifyBtn(false);
                            return;
                          }
                          if (verificationCont.isOTPVerify.isTrue) {
                            verificationCont.phoneSignIn();
                          } else {
                            if (verificationCont.isVerifyBtn.isTrue && verificationCont.codeResendTime.value != 0) {
                              verificationCont.checkIfDemoUser(
                                verify: true,
                                callBack: () {
                                  verificationCont.isVerifyBtn(false);
                                  verificationCont.onVerifyPressed();
                                },
                              );
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: isEnabled ? _otpGradient : null,
                            color: isEnabled ? null : lightBtnColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isEnabled
                                ? [
                                    BoxShadow(
                                      color: _otpGradient.colors.first.withOpacity(0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            locale.value.verify,
                            textAlign: TextAlign.center,
                            style: boldTextStyle(
                              size: 16,
                              color: isEnabled ? Colors.black : darkGrayTextColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                20.height,
              ],
            ),
          ),
          Obx(
            () => verificationCont.isLoading.isTrue ? const Positioned(left: 0, right: 0, top: 0, bottom: 0, child: LoaderWidget()) : const Offstage(),
          ),
        ],
      ),
    );
  }
}
