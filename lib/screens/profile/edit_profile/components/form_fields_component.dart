import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:streamit_laravel/utils/constants.dart';
import 'package:streamit_laravel/utils/extension/date_time_extention.dart';
import 'package:streamit_laravel/utils/extension/string_extention.dart';
import 'package:streamit_laravel/generated/assets.dart';
import '../../../../main.dart';
import '../../../../utils/app_common.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/common_base.dart';
import '../edit_profile_controller.dart';
import 'package:nb_utils/nb_utils.dart';

class EditFormFieldComponent extends StatelessWidget {
  EditFormFieldComponent({super.key});

  final EditProfileController profileCont = Get.put(EditProfileController());

  @override
  Widget build(BuildContext context) {
    return Form(
      key: profileCont.editProfileFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          24.height,
          AppTextField(
            textStyle: primaryTextStyle(color: white),
            controller: profileCont.firstNameCont,
            focus: profileCont.firstNameFocus,
            nextFocus: profileCont.lastNameFocus,
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
              contentPadding: const EdgeInsets.only(top: 14),
              hintText: locale.value.firstName,
              prefixIcon: Image.asset(
                Assets.iconsIcDefaultUser,
                color: iconColor,
                height: 12,
                width: 12,
              ).paddingAll(16),
            ),
            onChanged: (value) {
              profileCont.onBtnEnable();
            },
          ),
          16.height,
          AppTextField(
            textStyle: primaryTextStyle(color: white),
            controller: profileCont.lastNameCont,
            focus: profileCont.lastNameFocus,
            nextFocus: profileCont.emailFocus,
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
              contentPadding: const EdgeInsets.only(top: 14),
              hintText: locale.value.lastName,
              prefixIcon: Image.asset(
                Assets.iconsIcDefaultUser,
                color: iconColor,
                height: 12,
                width: 12,
              ).paddingAll(16),
            ),
            onChanged: (value) {
              profileCont.onBtnEnable();
            },
          ),
          16.height,
          AppTextField(
            textStyle: primaryTextStyle(color: white),
            controller: profileCont.dobCont,
            focus: profileCont.dobFocus,
            // nextFocus: profileCont.isPhoneAuth.isTrue ? null : profileCont.mobileFocus,
            textFieldType: TextFieldType.OTHER,
            readOnly: true,
            onTap: () async {
              final DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: profileCont.dobCont.text.isNotEmpty
                    ? DateTime.parse(profileCont.dobCont.text)
                    : null,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                confirmText: locale.value.ok,
                cancelText: locale.value.cancel,
                helpText: locale.value.dateOfBirth,
                locale: Locale(selectedLanguageDataModel?.languageCode ??
                    getStringAsync(SELECTED_LANGUAGE_CODE),),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                          surface: cardColor,
                          surfaceTint: cardColor,
                          primary: appColorPrimary,
                          onPrimary: primaryTextColor,),
                      hintColor: secondaryTextColor,
                      inputDecorationTheme: const InputDecorationTheme(
                        isDense: true,
                        contentPadding: EdgeInsets.only(
                            left: 10, right: 10, top: 2, bottom: 2,),
                        hintStyle: TextStyle(fontSize: 16, color: Colors.white),
                        fillColor: appColorPrimary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (selectedDate != null) {
                profileCont.dobCont.text = selectedDate.formatDateYYYYmmdd();
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
          ),
          16.height,
          InputDecorator(
            decoration: inputDecoration(
              context,
              hintText: locale.value.gender,
              prefixIcon: commonLeadingWid(
                      imgPath: Assets.iconsIcGender, color: secondaryTextColor,)
                  .paddingAll(14),
            ),
            textAlign: TextAlign.start,
            child: Obx(
              () => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile(
                    dense: true,
                    controlAffinity: ListTileControlAffinity.trailing,
                    title: Text(
                      locale.value.male,
                      style: primaryTextStyle(size: 14),
                      softWrap: false,
                      overflow: TextOverflow.visible,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    contentPadding: EdgeInsets.zero,
                    value: GenderTypeConst.MALE,
                    radioScaleFactor: 0.8,
                    groupValue: profileCont.selectedGender.value,
                    onChanged: (value) {
                      profileCont.setGender(value.validate());
                    },
                  ).flexible(),
                  RadioListTile(
                    dense: true,
                    controlAffinity: ListTileControlAffinity.trailing,
                    title: Text(
                      locale.value.female,
                      style: primaryTextStyle(size: 14),
                      softWrap: false,
                      overflow: TextOverflow.visible,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    contentPadding: EdgeInsets.zero,
                    value: GenderTypeConst.FEMALE,
                    radioScaleFactor: 0.8,
                    groupValue: profileCont.selectedGender.value,
                    onChanged: (value) {
                      profileCont.setGender(value.validate());
                    },
                  ).flexible(),
                  RadioListTile(
                    dense: true,
                    controlAffinity: ListTileControlAffinity.trailing,
                    title: Text(
                      locale.value.other,
                      style: primaryTextStyle(size: 14),
                      softWrap: false,
                      overflow: TextOverflow.visible,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    contentPadding: EdgeInsets.zero,
                    value: GenderTypeConst.OTHER,
                    radioScaleFactor: 0.9,
                    groupValue: profileCont.selectedGender.value,
                    onChanged: (value) {
                      profileCont.setGender(value.validate());
                    },
                  ).flexible(),
                ],
              ),
            ),
          ),
          16.height,
          AppTextField(
            textStyle: primaryTextStyle(color: white),
            controller: profileCont.emailCont,
            focus: profileCont.emailFocus,
            nextFocus: profileCont.mobileNoFocus,
            textFieldType: TextFieldType.EMAIL_ENHANCED,
            enabled:
                loginUserData.value.loginType == LoginTypeConst.LOGIN_TYPE_OTP,
            cursorColor: white,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '';
              } else if (!value.isValidEmail()) {
                return locale.value.pleaseEnterValidEmailAddress;
              }
              return null;
            },
            decoration: inputDecoration(
              context,
              contentPadding: const EdgeInsets.only(top: 14),
              hintText: locale.value.email,
              prefixIcon: Image.asset(
                Assets.iconsIcEmail,
                color: iconColor,
                height: 12,
                width: 12,
              ).paddingAll(15),
            ),
            onChanged: (value) {
              profileCont.onBtnEnable();
            },
          ),
          16.height,
          Obx(
            () => Row(
              children: [
                InkWell(
                  onTap: () {
                    profileCont.changeCountry(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: boxDecorationDefault(
                      borderRadius: BorderRadiusDirectional.zero,
                      border: Border(
                          bottom: BorderSide(
                              color: borderColor.withValues(alpha: 0.6),),),
                      color: appScreenBackgroundDark,
                    ),
                    child: Row(
                      children: [
                        Text(profileCont.selectedCountry.value.flagEmoji,
                            style: primaryTextStyle(size: 20),),
                        16.width,
                        Text(
                          profileCont.countryCode.value,
                          style: primaryTextStyle(color: white),
                        ),
                        6.width,
                        const Icon(Icons.arrow_drop_down, color: iconColor),
                      ],
                    ),
                  ),
                ),
                16.width,
                AppTextField(
                  textStyle: primaryTextStyle(size: 12, color: white),
                  controller: profileCont.mobileNoCont,
                  focus: profileCont.mobileNoFocus,
                  textFieldType: TextFieldType.NUMBER,
                  cursorColor: white,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return locale.value.mobileNumberIsRequiredField;
                    }
                    return null;
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: inputDecoration(
                    context,
                    contentPadding: const EdgeInsets.only(top: 14),
                    hintText: locale.value.mobileNumber,
                    prefixIcon: Image.asset(
                      Assets.iconsIcPhone,
                      color: iconColor,
                      height: 12,
                      width: 12,
                    ).paddingAll(15),
                  ),
                  onChanged: (value) {
                    profileCont.onBtnEnable();
                  },
                ).flexible(),
              ],
            ).paddingOnly(left: 16, right: 16),
          ),
          /*   16.height,
          AppTextField(
            textStyle: primaryTextStyle(size: 12, color: white),
            controller: profileCont.mobileNoCont,
            focus: profileCont.mobileNoFocus,
            textFieldType: TextFieldType.NUMBER,
            cursorColor: white,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return locale.value.mobileNumberIsRequiredField;
              }
              return null;
            },
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: inputDecoration(
              context,
              contentPadding: const EdgeInsets.only(top: 14),
              hintText: locale.value.mobileNumber,
              prefixIcon: Image.asset(
                Assets.iconsIcPhone,
                color: iconColor,
                height: 12,
                width: 12,
              ).paddingAll(15),
            ),
            onChanged: (value) {
              profileCont.onBtnEnable();
            },
          ),*/
          40.height,
          Obx(
            () => AppButton(
              width: double.infinity,
              text: locale.value.savechanges,
              color: profileCont.isBtnEnable.isTrue
                  ? appColorPrimary
                  : cardDarkColor,
              textStyle: appButtonTextStyleWhite,
              shapeBorder: RoundedRectangleBorder(
                  borderRadius: radius(defaultAppButtonRadius / 2),),
              onTap: () {
                if (profileCont.editProfileFormKey.currentState!.validate()) {
                  profileCont.updateProfile();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
