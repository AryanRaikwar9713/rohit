// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/configs.dart';
import 'package:streamit_laravel/screens/profile/model/profile_detail_resp.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/common_base.dart';
import 'package:streamit_laravel/utils/constants.dart';
import 'package:streamit_laravel/utils/country_picker/country_code.dart';
import 'package:streamit_laravel/utils/extension/string_extention.dart';

import '../../../main.dart';
import '../../../network/core_api.dart';
import '../../subscription/model/subscription_plan_model.dart';
import '../profile_controller.dart';

class EditProfileController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isBtnEnable = false.obs;
  final GlobalKey<FormState> editProfileFormKey = GlobalKey();

  TextEditingController emailCont = TextEditingController();
  TextEditingController firstNameCont = TextEditingController();
  TextEditingController lastNameCont = TextEditingController();
  TextEditingController mobileNoCont = TextEditingController();
  TextEditingController dobCont = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode confPasswordFocus = FocusNode();
  FocusNode mobileNoFocus = FocusNode();
  FocusNode dobFocus = FocusNode();
  Rx<ProfileModel> profileDet = ProfileModel(planDetails: SubscriptionPlanModel()).obs;

  RxString selectedGender = GenderTypeConst.MALE.obs;
  RxString profilePic = "".obs;
  Rx<File> imageFile = File("").obs;
  XFile? pickedFile;
  Rx<Country> selectedCountry = defaultCountry.obs;
  RxString countryCode = "+91".obs;

  RxBool isPicLoading = false.obs;
  ProfileController profCont = Get.put(ProfileController());

  @override
  void onInit() {
    if (Get.arguments is ProfileModel) {
      profileDet(Get.arguments);
      firstNameCont.text = profileDet.value.firstName;
      lastNameCont.text = profileDet.value.lastName;
      emailCont.text = profileDet.value.email;
      try {
        mobileNoCont.text = profileDet.value.mobile.extractPhoneCodeAndNumber.$2;
        selectedCountry(CountryParser.parsePhoneCode(profileDet.value.mobile.extractPhoneCodeAndNumber.$1));
        countryCode("+${selectedCountry.value.phoneCode}");
      } catch (e) {
        selectedCountry(Country.from(json: defaultCountry.toJson()));
        mobileNoCont.text = profileDet.value.mobile.trim();
        countryCode("+${selectedCountry.value.phoneCode}");
      }

      dobCont.text = profileDet.value.dateOfBirth;
      profilePic(profileDet.value.profileImage);
      selectedGender.value = profileDet.value.gender;
      isBtnEnable(true);
    }
    super.onInit();
  }

  void setGender(String gender) => selectedGender.value = gender;

  void onBtnEnable() {
    if (firstNameCont.text == profileDet.value.firstName &&
        lastNameCont.text == profileDet.value.lastName &&
        emailCont.text == profileDet.value.email &&
        mobileNoCont.text == profileDet.value.mobile &&
        imageFile.value.path.isEmpty) {
      isBtnEnable(false);
    } else {
      isBtnEnable(true);
    }
  }

  Future<void> changeCountry(BuildContext context) async {
    showCustomCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        margin: const EdgeInsets.only(top: 80),
        bottomSheetHeight: Get.height * 0.86,
        backgroundColor: btnColor,
        padding: const EdgeInsets.only(top: 12, left: 4, right: 4),
        textStyle: secondaryTextStyle(color: white),
        searchTextStyle: primaryTextStyle(color: white),
        inputDecoration: InputDecoration(
          labelStyle: secondaryTextStyle(color: white),
          labelText: locale.value.searchHere,
          prefixIcon: const Icon(Icons.search, color: white),
          border: const OutlineInputBorder(borderSide: BorderSide(color: borderColor)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: white)),
        ),
      ),

      showPhoneCode: true, // optional. Shows phone code before the country name.
      onSelect: (Country country) {
        countryCode("+${country.phoneCode}");
        selectedCountry(country);
        log(country.flagEmoji);
      },
    );
  }

  Future<void> _handleGalleryClick() async {
    isPicLoading(true);
    Get.back();
    pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1800, maxHeight: 1800);
    if (pickedFile != null) {
      imageFile(File(pickedFile!.path));
    }
    onBtnEnable();
    isPicLoading(false);
  }

  Future<void> _handleCameraClick() async {
    isPicLoading(true);
    Get.back();
    pickedFile = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 1800, maxHeight: 1800);
    if (pickedFile != null) {
      imageFile(File(pickedFile!.path));
    }
    onBtnEnable();
    isPicLoading(false);
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: btnColor,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SettingItemWidget(
              title: locale.value.gallery,
              leading: const Icon(Icons.image, color: white),
              titleTextColor: white,
              onTap: () async {
                _handleGalleryClick();
              },
            ),
            SettingItemWidget(
              title: locale.value.camera,
              leading: const Icon(Icons.camera, color: white),
              titleTextColor: white,
              onTap: () {
                _handleCameraClick();
              },
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
          ],
        ).paddingAll(16.0);
      },
    );
  }

  @override
  void onClose() {
    firstNameCont.clear();
    lastNameCont.clear();
    emailCont.clear();
    mobileNoCont.clear();
    dobCont.clear();
    imageFile(File(""));
    super.onClose();
  }

  Future<void> updateProfile() async {
    if (isLoading.value) return;
    isLoading(true);
    final Map<String, dynamic> profileRequest = {
      "id": profileDet.value.id.toString(),
      "first_name": firstNameCont.value.text,
      "last_name": lastNameCont.value.text,
      "mobile": mobileNoCont.text.formatPhoneNumber(countryCode.value),
      "email": emailCont.value.text,
      "date_of_birth": dobCont.value.text,
      "gender": selectedGender.value,
    };

    await CoreServiceApis().updateProfileReq(
      request: profileRequest,
      files: imageFile.value.path.isNotEmpty ? [imageFile.value] : null,
    ).then((value) {
      Get.back(result: true);
      successSnackBar(locale.value.profileUpdatedSuccessfully);
    }).catchError((e) {
      errorSnackBar(error: e);
    }).whenComplete(() => isLoading(false));
  }
}