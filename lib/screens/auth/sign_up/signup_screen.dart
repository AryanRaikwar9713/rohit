import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/app_logo_widget.dart';
import 'package:streamit_laravel/components/app_scaffold.dart';
import 'package:streamit_laravel/generated/assets.dart';
import 'package:streamit_laravel/main.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/constants.dart';
import 'package:streamit_laravel/utils/extension/date_time_extention.dart';
import 'package:streamit_laravel/utils/extension/string_extention.dart';

import '../../../utils/common_base.dart';
import '../../../utils/country_picker/country_list.dart';
import '../../../utils/country_picker/country_utils.dart';
import 'sign_up_controller.dart';

/// Apna gradient - Sign up (yellow-orange)
const LinearGradient _signUpGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class SignUpScreen extends StatelessWidget {
  final SignUpController signUpController = Get.put(SignUpController());

  SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      scaffoldBackgroundColor: appScreenBackgroundDark,
      isLoading: signUpController.isLoading,
      topBarBgColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              appScreenBackgroundDark,
              appScreenBackgroundDark,
              const Color(0xFF0f0d0a),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Form(
            key: signUpController.signUpFormKey,
            child: Column(
              children: [
                const AppLogoWidget(
                  size: Size(160, 160),
                ).center(),
                12.height,
                ShaderMask(
                  shaderCallback: (b) => _signUpGradient.createShader(b),
                  child: Text(
                    locale.value.createYourAccount,
                    style: boldTextStyle(size: 22, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                8.height,
                Text(
                  locale.value.completeProfileSubtitle,
                  style: secondaryTextStyle(size: 14),
                  textAlign: TextAlign.center,
                ).paddingSymmetric(horizontal: 16),
                28.height,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Row(
                      children: [
                        InkWell(
                          onTap: () {
                            signUpController.changeCountry(context);
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
                                Text(signUpController.selectedCountry.value.flagEmoji, style: primaryTextStyle(size: 20)),
                                6.width,
                                Text(signUpController.countryCode.value, style: primaryTextStyle()),
                                6.width,
                                const Icon(Icons.arrow_drop_down, color: iconColor),
                              ],
                            ),
                          ),
                        ),
                        16.width,
                        AppTextField(
                          textStyle: primaryTextStyle(),
                          controller: signUpController.mobileCont,
                          textFieldType: TextFieldType.PHONE,
                          cursorColor: white,
                          nextFocus: signUpController.firstNameFocus,
                          maxLength: getValidPhoneNumberLength(CountryModel.fromJson(signUpController.selectedCountry.value.toJson())),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (mobileCont) {
                            if (mobileCont!.isEmpty) {
                              return locale.value.phnRequiredText;
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
                            ).paddingAll(14),
                          ),
                          onChanged: (value) {
                            signUpController.onBtnEnable();
                          },
                        ).expand(flex: 3),
                      ],
                    ),
                  ),
                  16.height,
                  AppTextField(
                    textStyle: primaryTextStyle(),
                    controller: signUpController.firstNameCont,
                    focus: signUpController.firstNameFocus,
                    nextFocus: signUpController.lastNameFocus,
                    textFieldType: TextFieldType.NAME,
                    cursorColor: white,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return locale.value.firstNameIsRequiredField;
                      }
                      return null;
                    },
                    decoration: inputDecoration(
                      context,
                      contentPadding: const EdgeInsets.only(top: 15),
                      hintText: locale.value.firstName,
                      prefixIcon: Image.asset(
                        Assets.iconsIcDefaultUser,
                        color: iconColor,
                        height: 12,
                        width: 12,
                      ).paddingAll(14),
                    ),
                    onChanged: (value) {
                      signUpController.onBtnEnable();
                    },
                  ),
                  16.height,
                  AppTextField(
                    textStyle: primaryTextStyle(),
                    controller: signUpController.lastNameCont,
                    focus: signUpController.lastNameFocus,
                    nextFocus: signUpController.emailFocus,
                    textFieldType: TextFieldType.NAME,
                    cursorColor: white,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return locale.value.lastNameIsRequiredField;
                      }
                      return null;
                    },
                    decoration: inputDecoration(
                      context,
                      contentPadding: const EdgeInsets.only(top: 15),
                      hintText: locale.value.lastName,
                      prefixIcon: Image.asset(
                        Assets.iconsIcDefaultUser,
                        color: iconColor,
                        height: 12,
                        width: 12,
                      ).paddingAll(14),
                    ),
                    onChanged: (value) {
                      signUpController.onBtnEnable();
                    },
                  ),
                  16.height,
                  AppTextField(
                    textStyle: primaryTextStyle(),
                    controller: signUpController.dobCont,
                    focus: signUpController.dobFocus,
                    textFieldType: TextFieldType.OTHER,
                    readOnly: true,
                    onTap: () async {
                      final DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: signUpController.dobCont.text.isNotEmpty ? DateTime.parse(signUpController.dobCont.text) : null,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        confirmText: locale.value.ok,
                        cancelText: locale.value.cancel,
                        helpText: locale.value.dateOfBirth,
                        locale: Locale(selectedLanguageDataModel?.languageCode ?? getStringAsync(SELECTED_LANGUAGE_CODE)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(surface: cardColor, surfaceTint: cardColor, primary: appColorPrimary, onPrimary: primaryTextColor),
                              hintColor: secondaryTextColor,
                              inputDecorationTheme: const InputDecorationTheme(
                                isDense: true,
                                contentPadding: EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
                                hintStyle: TextStyle(fontSize: 16, color: Colors.white),
                                fillColor: appColorPrimary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (selectedDate != null) {
                        signUpController.dobCont.text = selectedDate.formatDateYYYYmmdd();
                      } else {
                        log("Date is not selected");
                      }
                    },
                    decoration: inputDecoration(
                      context,
                      contentPadding: const EdgeInsets.only(top: 14),
                      hintText: locale.value.dateOfBirth,
                      prefixIcon: Image.asset(
                        Assets.iconsIcBirthdate,
                        color: iconColor,
                        height: 12,
                        width: 12,
                      ).paddingAll(17),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return locale.value.birthdayIsRequired;
                      }
                      return null;
                    },
                  ),
                  16.height,
                  InputDecorator(
                    decoration: inputDecoration(
                      context,
                      hintText: locale.value.gender,
                      prefixIcon: commonLeadingWid(imgPath: Assets.iconsIcGender, color: secondaryTextColor).paddingAll(14),
                    ),
                    textAlign: TextAlign.start,
                    child: Obx(
                      () => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RadioListTile(
                            dense: true,
                            controlAffinity: ListTileControlAffinity.trailing,
                            radioScaleFactor: 0.8,
                            title: Text(
                              locale.value.male,
                              style: primaryTextStyle(size: 14),
                              softWrap: false,
                            ),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            contentPadding: EdgeInsets.zero,
                            value: GenderTypeConst.MALE,
                            groupValue: signUpController.selectedGender.value,
                            onChanged: (value) {
                              signUpController.setGender(value.validate());
                            },
                          ).flexible(),
                          RadioListTile(
                            dense: true,
                            radioScaleFactor: 0.8,
                            controlAffinity: ListTileControlAffinity.trailing,
                            title: Text(
                              locale.value.female,
                              style: primaryTextStyle(size: 14),
                              softWrap: false,
                            ),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            contentPadding: EdgeInsets.zero,
                            value: GenderTypeConst.FEMALE,
                            groupValue: signUpController.selectedGender.value,
                            onChanged: (value) {
                              signUpController.setGender(value.validate());
                            },
                          ).flexible(),
                          RadioListTile(
                            dense: true,
                            controlAffinity: ListTileControlAffinity.trailing,
                            radioScaleFactor: 0.8,
                            title: Text(
                              locale.value.other,
                              style: primaryTextStyle(size: 14),
                              softWrap: false,
                            ),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            contentPadding: EdgeInsets.zero,
                            value: GenderTypeConst.OTHER,
                            groupValue: signUpController.selectedGender.value,
                            onChanged: (value) {
                              signUpController.setGender(value.validate());
                            },
                          ).flexible(),
                        ],
                      ),
                    ),
                  ),
                  16.height,
                  AppTextField(
                    textStyle: primaryTextStyle(),
                    controller: signUpController.emailCont,
                    focus: signUpController.emailFocus,
                    nextFocus: signUpController.passwordFocus,
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
                      contentPadding: const EdgeInsets.only(top: 15),
                      hintText: locale.value.email,
                      prefixIcon: commonLeadingWid(imgPath: Assets.iconsIcEmail, color: iconColor, size: 10).paddingAll(14),
                    ),
                    onChanged: (value) {
                      signUpController.onBtnEnable();
                    },
                  ),
                  16.height,
                  AppTextField(
                    textStyle: primaryTextStyle(color: white),
                    controller: signUpController.passwordCont,
                    focus: signUpController.passwordFocus,
                    nextFocus: signUpController.confPasswordFocus,
                    obscureText: true,
                    textFieldType: TextFieldType.PASSWORD,
                    cursorColor: white,
                    errorThisFieldRequired: locale.value.passwordIsRequiredField,
                    decoration: inputDecoration(
                      context,
                      hintText: locale.value.password,
                      contentPadding: const EdgeInsets.only(top: 14),
                      prefixIcon: commonLeadingWid(imgPath: Assets.iconsIcLockKey, color: iconColor).paddingAll(16),
                    ),
                    suffixPasswordVisibleWidget: commonLeadingWid(
                      imgPath: Assets.iconsIcEye,
                      color: iconColor,
                    ).paddingAll(16),
                    suffixPasswordInvisibleWidget: commonLeadingWid(
                      imgPath: Assets.iconsIcEyeSlash,
                      color: iconColor,
                    ).paddingAll(16),
                    onChanged: (value) {
                      signUpController.onBtnEnable();
                    },
                  ),
                  16.height,
                  AppTextField(
                    textStyle: primaryTextStyle(color: white),
                    controller: signUpController.confPasswordCont,
                    focus: signUpController.confPasswordFocus,
                    nextFocus: signUpController.dobFocus,
                    obscureText: true,
                    textFieldType: TextFieldType.PASSWORD,
                    cursorColor: white,
                    decoration: inputDecoration(
                      context,
                      hintText: locale.value.confirmPassword,
                      contentPadding: const EdgeInsets.only(top: 14),
                      prefixIcon: commonLeadingWid(imgPath: Assets.iconsIcLockKey, color: iconColor).paddingAll(16),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return locale.value.passwordIsRequiredField;
                      return signUpController.passwordCont.text == value ? null : locale.value.yourConfirmPasswordDoesnT;
                    },
                    suffixPasswordVisibleWidget: commonLeadingWid(
                      imgPath: Assets.iconsIcEye,
                      color: iconColor,
                    ).paddingAll(16),
                    suffixPasswordInvisibleWidget: commonLeadingWid(
                      imgPath: Assets.iconsIcEyeSlash,
                      color: iconColor,
                    ).paddingAll(16),
                    onChanged: (value) {
                      signUpController.onBtnEnable();
                    },
                  ),
                  40.height,
                  Container(
                    decoration: BoxDecoration(
                      gradient: _signUpGradient,
                      borderRadius: BorderRadius.circular(defaultAppButtonRadius / 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9800).withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (signUpController.signUpFormKey.currentState!.validate()) {
                            hideKeyboard(context);
                            signUpController.saveForm();
                          }
                        },
                        borderRadius: BorderRadius.circular(defaultAppButtonRadius / 2),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          alignment: Alignment.center,
                          child: Text(
                            locale.value.signUp,
                            style: appButtonTextStyleWhite.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ).paddingSymmetric(horizontal: 24),
        ),
        ),
      ),
    );
  }
}