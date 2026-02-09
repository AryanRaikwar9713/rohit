// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/dashboard/dashboard_screen.dart';

import 'package:streamit_laravel/network/auth_apis.dart';
import '../../../configs.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../../utils/extension/get_x_extention.dart';
import '../../../utils/constants.dart';
import '../../../utils/country_picker/country_code.dart';
import '../../../utils/extension/string_extention.dart';
import '../../../utils/firebase_phone_auth/firebase_auth_util.dart';
import '../../../utils/firebase_phone_auth/firebase_excauth_exception_utils.dart';
import '../components/device_list_component.dart';
import '../components/otp_verify_component.dart';
import '../model/error_model.dart';
import '../services/social_logins.dart';
import '../sign_up/signup_screen.dart';

class SignInController extends GetxController {
  final GlobalKey<FormState> signInformKey = GlobalKey();

  RxBool isPhoneAuthLoading = false.obs;
  RxBool isOTPSent = false.obs;
  RxBool isVerifyBtn = false.obs;
  RxBool isBtnEnable = false.obs;
  RxBool isRememberMe = true.obs;
  RxBool isLoading = false.obs;
  RxBool isNormalLogin = false.obs;

  RxString countryCode = "+91".obs;
  RxBool isOTPVerify = false.obs;

  Rx<String> verificationCode = ''.obs;
  Rx<String> verificationId = ''.obs;
  Rx<String> mobileNo = ''.obs;
  Rx<Timer> codeResendTimer = Timer(Duration.zero, () {}).obs;
  Rx<int> codeResendTime = 0.obs;

  set setCodeResendTime(int time) {
    codeResendTime(time);
  }

  TextEditingController phoneCont = TextEditingController();
  TextEditingController countryCodeCont = TextEditingController();
  TextEditingController verifyCont = TextEditingController();

  Rx<Country> selectedCountry = defaultCountry.obs;

  FocusNode phoneFocus = FocusNode();
  FocusNode countryCodeFocus = FocusNode();

  TextEditingController emailCont =
      TextEditingController(text: Constants.DEFAULT_EMAIL);
  TextEditingController passwordCont =
      TextEditingController(text: Constants.DEFAULT_PASS);

  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  /// Stored when 406 (other devices) is shown; used to retry login after device logout without re-verification.
  Map<String, dynamic>? _pendingLoginRequest;
  bool _pendingIsSocialLogin = false;
  bool _pendingIsNormalLogin = false;

  @override
  void onInit() {
    init();
    getBtnEnable();
    super.onInit();
  }

  Future<void> init() async {
    if (await isIqonicProduct) {
      phoneCont.text = Constants.demoNumber;
      getBtnEnable();
    }
  }

  void getBtnEnable() {
    if (phoneCont.text.isNotEmpty && phoneCont.text.isNotEmpty) {
      isBtnEnable(true);
    } else {
      isBtnEnable(false);
    }
  }

  void getVerifyBtnEnable() {
    if (verifyCont.text.isNotEmpty && verifyCont.text.length == 6) {
      hideKeyBoardWithoutContext();
      isVerifyBtn(true);
    } else {
      isVerifyBtn(false);
    }
  }

  Future<void> isDemoUser({bool verify = false}) async {
    if (Get.isBottomSheetOpen ?? false) return;
    isLoading(true);

    Future.delayed(
      const Duration(seconds: 2),
      () {
        if (verify) {
          isOTPVerify(true);
          isLoading(false);
          phoneSignIn();
        } else {
          if (Get.isBottomSheetOpen ?? false) {
            isLoading(false);
            return;
          }
          isOTPSent(true);
          verificationId('');
          mobileNo(phoneCont.text);
          countryCode(countryCode.value);
          initializeCodeResendTimer;
          isLoading(false);
          Get.bottomSheet(
            isDismissible: false,
            enableDrag: false,
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: OTPVerifyComponent(
                mobileNo: "$countryCode${phoneCont.text}",
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> checkIfDemoUser(
      {bool verify = false, required VoidCallback callBack,}) async {
    if (phoneCont.text.trim() == Constants.demoNumber) {
      verificationCode('123456');
      verifyCont.text = '123456';
      isOTPVerify(true);
      isDemoUser(verify: verify);
    } else {
      callBack.call();
    }
  }

  void resetOTPState() {
    verifyCont.clear();
    isVerifyBtn(false);
    isOTPSent(false);
    isOTPVerify(false);
    verificationCode('');
    verificationId('');
    codeResendTime(0);
    // isLoading(false);

    if (codeResendTimer.value.isActive) {
      codeResendTimer.value.cancel();
    }
  }

  Future<void> onLoginPressed() async {
    // Prevent multiple taps: do not open OTP sheet again if already open or request in progress
    if (isLoading.value) return;
    if (Get.isBottomSheetOpen ?? false) return;

    isLoading(true);
    isOTPSent(false);
    final firebaseAuthUtil = FirebaseAuthUtil();

    try {
      // resetOTPState();
      firebaseAuthUtil.login(
          mobileNumber: "$countryCode${phoneCont.text}",
          onCodeSent: (value) {
            isOTPSent(true);
            verificationId(value);
            mobileNo(phoneCont.text);
            countryCode(countryCode.value);
            initializeCodeResendTimer;
            isLoading(false);
            if (Get.isBottomSheetOpen ?? false) {
              Get.safeBack(); // Close current bottom sheet first
            }
            Future.delayed(const Duration(milliseconds: 200), () {
              // Open OTP sheet only once (in case multiple onCodeSent fired)
              if (Get.isBottomSheetOpen ?? false) return;
              if (phoneCont.text.trim() != Constants.demoNumber) {
                resetOTPState();
              }

              Get.bottomSheet(
                isDismissible: false,
                enableDrag: false,
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: OTPVerifyComponent(
                    mobileNo: "$countryCode${phoneCont.text}",
                  ),
                ),
              );
            });
          },
          /*  onTimeout: () {
            Future.delayed(const Duration(milliseconds: 200), () {
              if (phoneCont.text.trim() != Constants.demoNumber) {
                resetOTPState();
              }

              Get.bottomSheet(
                isDismissible: false,
                isScrollControlled: false,
                enableDrag: false,
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: OTPVerifyComponent(
                    mobileNo: "$countryCode${phoneCont.text}",
                  ),
                ),
              );
            });
          }, */
          onVerificationFailed: (value) {
            isOTPSent(false);
            isPhoneAuthLoading(false);
            isLoading(false);
            errorSnackBar(
                error:
                    FirebaseAuthHandleExceptionsUtils().handleException(value),);
          },);
    } catch (e) {
      isLoading(false);
      isOTPSent(false);
      errorSnackBar(error: e);
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
          prefixIcon: const Icon(
            Icons.search,
            color: white,
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(
              color: borderColor,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: white,
            ),
          ),
        ),
      ),

      showPhoneCode:
          true, // optional. Shows phone code before the country name.
      onSelect: (Country country) {
        countryCode("+${country.phoneCode}");
        selectedCountry(country);
      },
    );
  }

  Future<void> loginAPICall(
      {required Map<String, dynamic> request,
      required bool isSocialLogin,
      bool isNormalLogin = false,}) async {
    _pendingLoginRequest = Map.from(request);
    _pendingIsSocialLogin = isSocialLogin;
    _pendingIsNormalLogin = isNormalLogin;

    await AuthServiceApis()
        .loginUser(request: request, isSocialLogin: isSocialLogin)
        .then((value) async {
      _pendingLoginRequest = null;
      handleLoginResponse(
          isSocialLogin: isSocialLogin, isNormalLogin: isNormalLogin,);
    }).catchError((e) async {
      if (e.toString().startsWith('404') ||
          (e is Map<String, dynamic> &&
              e.containsKey('status_code') &&
              e['status_code'] == 404)) {
        _pendingLoginRequest = null;
        ///open sign up screen but not close previous route
        Get.safeBack();
        isLoading(false);
        Get.to(() => SignUpScreen(), arguments: [true, mobileNo, countryCode]);
      } else {
        isLoading(false);
        if (!isNormalLogin) {
          Get.safeBack();
        }
        errorSnackBar(error: e);
        if (e is Map<String, dynamic> &&
            e.containsKey('status_code') &&
            e['status_code'] == 406 &&
            e.containsKey('response')) {
          final ErrorModel errorData = ErrorModel.fromJson(e['response']);
          Get.bottomSheet(
            isScrollControlled: true,
            enableDrag: false,
            DeviceListComponent(
              loggedInDeviceList: errorData.otherDevice,
              onLogout: (logoutAll, deviceId, deviceName) {
                Get.safeBack();
                Get.safeBack();
                // Loading dialog UPAR dikhne ke liye (client request)
                Get.dialog(
                  Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  barrierDismissible: false,
                );
                if (logoutAll) {
                  logOutAll(
                    errorData.otherDevice.first.userId,
                    onSuccess: _retryPendingLogin,
                  );
                } else {
                  deviceLogOut(
                    device: deviceId,
                    userId: errorData.otherDevice.first.userId,
                    onSuccess: _retryPendingLogin,
                  );
                }
              },
            ),
          );
        }
      }
    });
  }

  void _retryPendingLogin() {
    final request = _pendingLoginRequest;
    if (request == null) return;
    _pendingLoginRequest = null;
    loginAPICall(
      request: request,
      isSocialLogin: _pendingIsSocialLogin,
      isNormalLogin: _pendingIsNormalLogin,
    );
  }

  Future<void> saveForm({bool isNormalLogin = false}) async {
    if (isLoading.isTrue) return;

    hideKeyBoardWithoutContext();
    isLoading(true);
    final Map<String, dynamic> req = {
      'email': emailCont.text.trim(),
      'password': passwordCont.text.trim(),
      'device_id': yourDevice.value.deviceId,
      'device_name': yourDevice.value.deviceName,
      'platform': yourDevice.value.platform,
    };

    await loginAPICall(
        isSocialLogin: false, request: req, isNormalLogin: isNormalLogin,);
  }

  Future<void> phoneSignIn() async {
    if (isLoading.value) return;

    isLoading(true);
    // Format the mobile number properly to avoid double country codes
    final String formattedMobile =
        mobileNo.value.trim().formatPhoneNumber(countryCode.value);
    final Map<String, dynamic> request = {
      UserKeys.username: formattedMobile,
      UserKeys.password: formattedMobile,
      UserKeys.mobile: formattedMobile,
      'device_id': yourDevice.value.deviceId,
      'device_name': yourDevice.value.deviceName,
      'platform': yourDevice.value.platform,
      UserKeys.loginType: LoginTypeConst.LOGIN_TYPE_OTP,
    };

    await loginAPICall(isSocialLogin: true, request: request);
  }

  void get initializeCodeResendTimer {
    codeResendTimer.value.cancel();
    codeResendTime(60);
    codeResendTimer.value = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (codeResendTime > 0) {
        setCodeResendTime = --codeResendTime.value;
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> onVerifyPressed() async {
    final firebaseAuthUtil = FirebaseAuthUtil();
    isLoading(true);
    isVerifyBtn(false);
    try {
      await firebaseAuthUtil.verifyOTPCode(
        verificationId: verificationId.value,
        verificationCode: verifyCont.text,
        onVerificationSuccess: (value) {
          log("Phone Auth Completed");
          isOTPVerify(true);
          isLoading(false);
          phoneSignIn();
        },
        onCodeVerificationFailed: (value) {
          isLoading(false);
          verifyCont.clear();

          Get.safeBack();
          Get.bottomSheet(
            isDismissible: false,
            enableDrag: false,
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: OTPVerifyComponent(
                mobileNo: mobileNo.value,
              ),
            ),
          );
          errorSnackBar(error: value);
        },
      );
    } catch (error) {
      isLoading(false);
      verifyCont.clear();

      Get.safeBack();
      Get.bottomSheet(
        isDismissible: false,
        enableDrag: false,
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: OTPVerifyComponent(
            mobileNo: mobileNo.value,
          ),
        ),
      );
      errorSnackBar(error: error);
    }
  }

  Future<void> reSendOTP() async {
    if (isLoading.value) {
      return;
    }
    final firebaseAuthUtil = FirebaseAuthUtil();
    isLoading(true);
    firebaseAuthUtil.login(
        mobileNumber: "${countryCode.value}${mobileNo.value}",
        onCodeSent: (value) {
          initializeCodeResendTimer;
          isLoading(false);
          verificationId(value);
        },
        /* onTimeout: () {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (phoneCont.text.trim() != Constants.demoNumber) {
              resetOTPState();
            }

            Get.bottomSheet(
              isDismissible: false,
              isScrollControlled: false,
              enableDrag: false,
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: OTPVerifyComponent(
                  mobileNo: "$countryCode${phoneCont.text}",
                ),
              ),
            );
          });
        }, */
        onVerificationFailed: (value) {
          isLoading(false);
          verifyCont.clear();
          errorSnackBar(
              error:
                  FirebaseAuthHandleExceptionsUtils().handleException(value),);
        },);
  }

  Future<void> googleSignIn() async {
    if (isLoading.value) return;
    final List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();

    if (connectivityResult.first == ConnectivityResult.none) {
      toast(locale.value.yourInternetIsNotWorking, print: true);
      return;
    }

    isLoading(true);
    await GoogleSignInAuthService().signInWithGoogle().then((value) async {
      if (value != null) {
        final Map<String, dynamic> request = {
          UserKeys.email: value.email,
          UserKeys.password: value.email,
          UserKeys.firstName: value.firstName,
          UserKeys.lastName: value.lastName,
          UserKeys.mobile: value.mobile,
          UserKeys.fileUrl: value.profileImage,
          'device_id': yourDevice.value.deviceId,
          'device_name': yourDevice.value.deviceName,
          'platform': yourDevice.value.platform,
          UserKeys.loginType: LoginTypeConst.LOGIN_TYPE_GOOGLE,
        };
        log('signInWithGoogle REQUEST: $request');

        await loginAPICall(request: request, isSocialLogin: true);
      }
    }).catchError((e) {
      isLoading(false);
      log("Error is $e");
      toast(e.toString(), print: true);
    }).whenComplete(() => isLoading(false));
  }

  Future<void> appleSignIn() async {
    final List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();

    if (connectivityResult.first == ConnectivityResult.none) {
      toast(locale.value.yourInternetIsNotWorking, print: true);
      return;
    }
    isLoading(true);
    await GoogleSignInAuthService().signInWithApple().then((value) async {
      final Map<String, dynamic> request = {
        UserKeys.email: value.email,
        UserKeys.password: value.email,
        UserKeys.firstName: value.firstName,
        UserKeys.lastName: value.lastName,
        UserKeys.mobile: value.mobile,
        UserKeys.fileUrl: value.profileImage,
        'device_id': yourDevice.value.deviceId,
        'device_name': yourDevice.value.deviceName,
        'platform': yourDevice.value.platform,
        UserKeys.loginType: LoginTypeConst.LOGIN_TYPE_APPLE,
      };
      log('signInWithGoogle REQUEST: $request');

      /// Social Login Api
      await loginAPICall(request: request, isSocialLogin: true);
    }).catchError((e) {
      isLoading(false);
      toast(e.toString(), print: true);
    });
  }

  void handleLoginResponse(
      {String? password,
      bool isSocialLogin = false,
      bool isNormalLogin = false,}) {
    try {
      setValue(SharedPreferenceConst.USER_PASSWORD,
          isSocialLogin ? "" : passwordCont.text.trim(),);
      setValue(SharedPreferenceConst.IS_LOGGED_IN, true);
      setValue(SharedPreferenceConst.IS_REMEMBER_ME, isRememberMe.value);

      // Navigate directly to home screen for all registered users
      Get.offAll(
        () => DashboardScreen(dashboardController: getDashboardController()),
        binding: BindingsBuilder(() {
          getDashboardController().onBottomTabChange(0);

          // Get ads
          getDashboardController().getActiveVastAds();
          getDashboardController().getActiveCustomAds().then((value) {
            getDashboardController().adPlayerController.getCustomAds();
          });
        }),
      );

      isLoading(false);
    } catch (e) {
      log("Error  ==> $e");
    }
  }

  Future<void> deviceLogOut({
    required String device,
    required int userId,
    VoidCallback? onSuccess,
  }) async {
    removeKey(SharedPreferenceConst.IS_PROFILE_ID);
    isLoading(true);
    await AuthServiceApis()
        .deviceLogoutApiWithoutAuth(deviceId: device, userId: userId)
        .then((value) {
      successSnackBar(value.message);
      if (Get.isBottomSheetOpen ?? false) Get.safeBack();
      onSuccess?.call();
    }).catchError((e) {
      errorSnackBar(error: e);
      if (Get.isBottomSheetOpen ?? false) Get.safeBack();
    }).whenComplete(() {
      isLoading(false);
      if (Get.isDialogOpen ?? false) Get.safeBack();
    });
  }

  Future<void> logOutAll(int userId, {VoidCallback? onSuccess}) async {
    if (isLoading.value) return;
    isLoading(true);
    await AuthServiceApis()
        .logOutAllAPIWithoutAuth(userId: userId)
        .then((value) async {
      successSnackBar(value.message);
      if (Get.isBottomSheetOpen ?? false) Get.safeBack();
      onSuccess?.call();
    }).catchError((e) {
      errorSnackBar(error: e);
    }).whenComplete(() {
      isLoading(false);
      if (Get.isDialogOpen ?? false) Get.safeBack();
    });
  }
}
