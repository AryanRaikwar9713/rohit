import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/app_logo_widget.dart';
import 'package:streamit_laravel/components/app_scaffold.dart';
import 'package:streamit_laravel/configs.dart';
import 'package:streamit_laravel/generated/assets.dart';
import 'package:streamit_laravel/main.dart';
import 'package:streamit_laravel/screens/auth/model/about_page_res.dart';
import 'package:streamit_laravel/utils/app_common.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/constants.dart';
import 'package:streamit_laravel/utils/country_picker/country_list.dart';
import 'package:streamit_laravel/utils/country_picker/country_utils.dart';
import 'package:streamit_laravel/utils/extension/string_extention.dart';

import '../../../utils/common_base.dart';
import '../forgot_password/forgot_password_screen.dart';
import '../sign_in/sign_in_controller.dart';
import '../sign_up/signup_screen.dart';
import 'component/social_auth.dart';

/// Apna gradient - Sign In (yellow-orange)
const LinearGradient _signInGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class SignInScreen extends StatelessWidget {
  // ignore: use_super_parameters
  final bool showBackButton;

  SignInScreen({super.key, this.showBackButton = true});

  final SignInController signInController = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      scaffoldBackgroundColor: appScreenBackgroundDark,
      topBarBgColor: transparentColor,
      isLoading: signInController.isLoading,
      body: SingleChildScrollView(
        child: Form(
          key: signInController.signInformKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const AppLogoWidget(
                size: Size(160, 160),
              ).center(),
              20.height,
              // Text(locale.value.welcomeBackToStreamIt, style: commonW500PrimaryTextStyle(size: 20)),
              ShaderMask(
                shaderCallback: (b) => _signInGradient.createShader(b),
                child: Text(
                  "Welcome Back To $APP_NAME",
                  style: commonW500PrimaryTextStyle(size: 20, color: Colors.white),
                ),
              ),
              8.height,
              Text(locale.value.weHaveEagerlyAwaitedYourReturn, style: secondaryTextStyle()),
              40.height,
              Obx(
                () {
                  if (signInController.isNormalLogin.value) {
                    return formFieldComponent(context);
                  } else {
                    return Column(
                      children: [
                        Obx(
                          () => Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  signInController.changeCountry(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: boxDecorationDefault(
                                    borderRadius: BorderRadiusDirectional.zero,
                                    border: Border(bottom: BorderSide(color: borderColor.withValues(alpha: 0.6))),
                                    color: appScreenBackgroundDark,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(signInController.selectedCountry.value.flagEmoji, style: primaryTextStyle(size: 20)),
                                      6.width,
                                      Text(signInController.countryCode.value, style: primaryTextStyle()),
                                      6.width,
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        color: iconColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              16.width,
                              AppTextField(
                                textStyle: primaryTextStyle(),
                                controller: signInController.phoneCont,
                                textFieldType: TextFieldType.PHONE,
                                cursorColor: white,
                                maxLength: getValidPhoneNumberLength(CountryModel.fromJson(signInController.selectedCountry.value.toJson())),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                validator: (mobileCont) {
                                  if (mobileCont!.isEmpty) {
                                    return locale.value.phnRequiredText;
                                  } else if (!validatePhoneNumberByCountry(signInController.phoneCont.text, CountryModel.fromJson(signInController.selectedCountry.value.toJson()))) {
                                    return locale.value.pleaseEnterAValidMobileNo;
                                  }
                                  return null;
                                },
                                decoration: inputDecoration(
                                  context,
                                  contentPadding: const EdgeInsets.only(top: 14),
                                  hintText: locale.value.mobileNumber,
                                  prefixIcon: Image.asset(
                                    Assets.iconsIcPhone,
                                    color: iconColor,
                                    height: 12,
                                    width: 12,
                                  ).paddingAll(16),
                                ),
                                onChanged: (value) {
                                  signInController.getBtnEnable();
                                },
                                onFieldSubmitted: (value) {
                                  if (signInController.signInformKey.currentState!.validate()) {
                                    hideKeyboard(context);
                                    signInController.isPhoneAuthLoading(true);
                                    signInController.checkIfDemoUser(
                                      callBack: () {
                                        signInController.onLoginPressed();
                                      },
                                    );
                                  }
                                },
                              ).expand(flex: 3),
                            ],
                          ),
                        ),
                        24.height,
                        Obx(
                          () => Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: signInController.isBtnEnable.isTrue
                                  ? () {
                                      if (signInController.signInformKey.currentState!.validate()) {
                                        hideKeyboard(context);
                                        signInController.isPhoneAuthLoading(true);
                                        signInController.checkIfDemoUser(
                                          callBack: () => signInController.onLoginPressed(),
                                        );
                                      }
                                    }
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: Get.width,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: signInController.isBtnEnable.isTrue ? _signInGradient : null,
                                  color: signInController.isBtnEnable.isTrue ? null : lightBtnColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: signInController.isBtnEnable.isTrue
                                      ? [
                                          BoxShadow(
                                            color: _signInGradient.colors.first.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  locale.value.getVerificationCode,
                                  textAlign: TextAlign.center,
                                  style: boldTextStyle(
                                    color: signInController.isBtnEnable.isTrue ? Colors.black : darkGrayTextColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        16.height,
                      ],
                    );
                  }
                },
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: locale.value.dontHaveAnAccount, style: secondaryTextStyle(size: 12)),
                    TextSpan(
                      text: locale.value.signUp.prefixText(value: ' '),
                      style: commonW500SecondaryTextStyle(size: 12, color: _signInGradient.colors.first),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.to(() => SignUpScreen());
                        },
                    ),
                  ],
                ),
              ),
              40.height,
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, _signInGradient.colors.first.withOpacity(0.4)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                  Text(locale.value.or, style: secondaryTextStyle()),
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_signInGradient.colors.first.withOpacity(0.4), Colors.transparent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              28.height,
              Obx(() {
                return SocialIconWidget(
                  icon: signInController.isNormalLogin.value ? Assets.iconsIcPhone : Assets.iconsIcEmail,
                  buttonWidth: Get.width,
                  text: signInController.isNormalLogin.value ? locale.value.loginWithOtp : locale.value.loginWithEmail,
                  onTap: () {
                    signInController.isNormalLogin(!signInController.isNormalLogin.value);
                  },
                );
              }),
              16.height,
              if (appConfigs.value.isEnableSocialLogin) SocialAuthComponent(),
              48.height,
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            final AboutDataModel aboutDataModel = appPageList.firstWhere((element) => element.slug == AppPages.termsAndCondition);
                            if (aboutDataModel.url.validate().isNotEmpty) launchUrlCustomURL(aboutDataModel.url.validate());
                          },
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              Text('${locale.value.bySigningYouAgreeTo} $APP_NAME ', style: commonW500SecondaryTextStyle()),
                              Text('${locale.value.termsConditions} ', style: commonW500SecondaryTextStyle(color: _signInGradient.colors.first)),
                              Text(locale.value.ofAll, style: commonW500SecondaryTextStyle()),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            final AboutDataModel aboutDataModel = appPageList.firstWhere((element) => element.slug == AppPages.privacyPolicy);
                            if (aboutDataModel.url.validate().isNotEmpty) launchUrlCustomURL(aboutDataModel.url.validate());
                          },
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              Text(locale.value.servicesAnd, style: commonW500SecondaryTextStyle()),
                              Text(locale.value.privacyPolicy, style: commonW500SecondaryTextStyle(color: _signInGradient.colors.first)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ).paddingSymmetric(horizontal: 24),
        ),
      ),
    );
  }

  Widget formFieldComponent(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          textStyle: primaryTextStyle(color: white),
          controller: signInController.emailCont,
          focus: signInController.emailFocus,
          nextFocus: signInController.passwordFocus,
          textFieldType: TextFieldType.EMAIL_ENHANCED,
          cursorColor: white,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return locale.value.emailIsARequiredField;
            } else if (!value.isValidEmail()) {
              return locale.value.pleaseEnterValidEmailAddress;
            }
            return null;
          },
          decoration: inputDecoration(
            context,
            hintText: locale.value.email,
            contentPadding: const EdgeInsets.only(top: 14),
            prefixIcon: commonLeadingWid(imgPath: Assets.iconsIcEmail, color: secondaryTextColor, size: 12).paddingAll(16),
          ),
          onChanged: (value) {
            signInController.getBtnEnable();
          },
        ),
        16.height,
        AppTextField(
          textStyle: primaryTextStyle(color: white),
          controller: signInController.passwordCont,
          focus: signInController.passwordFocus,
          obscureText: true,
          textFieldType: TextFieldType.PASSWORD,
          cursorColor: white,
          errorThisFieldRequired: locale.value.passwordIsRequiredField,
          decoration: inputDecoration(
            context,
            hintText: locale.value.password,
            contentPadding: const EdgeInsets.only(top: 14),
            prefixIcon: commonLeadingWid(imgPath: Assets.iconsIcLockKey, color: iconColor, size: 12).paddingAll(16),
          ),
          suffixPasswordVisibleWidget: commonLeadingWid(imgPath: Assets.iconsIcEye, color: iconColor, size: 12).paddingAll(16),
          suffixPasswordInvisibleWidget: commonLeadingWid(imgPath: Assets.iconsIcEyeSlash, color: iconColor, size: 12).paddingAll(16),
          onChanged: (value) {
            signInController.getBtnEnable();
          },
        ),
        24.height,
        Row(
          children: [
            18.width,
            Obx(
              () => InkWell(
                onTap: () {
                  signInController.isRememberMe.value = !signInController.isRememberMe.value;
                },
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: boxDecorationDefault(
                    borderRadius: BorderRadius.circular(4),
                    color: signInController.isRememberMe.isTrue ? _signInGradient.colors.first : appScreenBackgroundDark,
                    border: Border.all(color: _signInGradient.colors.first.withOpacity(0.8)),
                  ),
                  child: Icon(
                    Icons.check,
                    color: signInController.isRememberMe.isTrue ? Colors.white : appScreenBackgroundDark,
                    size: 9,
                  ),
                ),
              ),
            ),
            14.width,
            Text(
              locale.value.rememberMe,
              style: secondaryTextStyle(color: white.withValues(alpha: 0.6), size: 12),
            ).onTap(
              () {
                signInController.isRememberMe.value = !signInController.isRememberMe.value;
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ).expand(),
            InkWell(
              onTap: () {
                Get.to(() => ForgotPassword());
              },
              child: Text(
                locale.value.forgotPassword,
                style: primaryTextStyle(
                  size: 12,
                  color: _signInGradient.colors.first,
                  fontStyle: FontStyle.italic,
                  decorationColor: _signInGradient.colors.first,
                ),
              ),
            ),
          ],
        ),
        30.height,
        Obx(
          () => Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (signInController.signInformKey.currentState!.validate()) {
                  signInController.saveForm(isNormalLogin: true);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: _signInGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _signInGradient.colors.first.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  locale.value.signIn,
                  textAlign: TextAlign.center,
                  style: boldTextStyle(size: 16, color: Colors.black),
                ),
              ),
            ),
          ),
        ),
        16.height,
      ],
    );
  }
}