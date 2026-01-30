// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/network/auth_apis.dart';

import '../../../utils/common_base.dart';

class ForgotPasswordController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isBtnEnable = false.obs;
  RxBool isVerifyBtn = false.obs;
  RxBool isResetLinSent = false.obs;
  final GlobalKey<FormState> forgotPassFormKey = GlobalKey();

  TextEditingController emailCont = TextEditingController();
  TextEditingController verifyCont = TextEditingController();

  //Timer Counter
  late Timer timer;
  RxInt start = 60.obs;



  @override
  void onClose() {
    emailCont.clear();
    super.onClose();
  }

  Future<void> saveForm() async {
    if (isLoading.isTrue) return;

    isLoading(true);
    hideKeyBoardWithoutContext();
    Map<String, dynamic> req = {
      'email': emailCont.text.trim(),
    };

    await AuthServiceApis().forgotPasswordApi(request: req).then((value) async {
      isLoading(false);
      emailCont.clear();
      isBtnEnable(false);
      isResetLinSent(true);
      successSnackBar(value.message);
    }).catchError((e) {
      isLoading(false);
      toast(e.toString(), print: true);
    });
  }

  void getBtnEnable() {
    if (emailCont.text.isNotEmpty) {
      isBtnEnable(true);
    } else {
      isBtnEnable(false);
    }
  }
}