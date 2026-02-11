// ignore_for_file: constant_identifier_names

import 'package:country_picker/country_picker.dart';

const APP_NAME = 'Wamims';
const APP_LOVIN_SDK_KEY =
    'q2SgFv2aGqCffJmPw7vLqgKFeiqw7zjY4mMZk5tA0i4g3k23JVmp4uv44zTwNC6L3YMqZQeJHVPFzLjw6NwtTY';
const APP_MINI_LOGO_URL = 'assets/launcher_icons/wammisLogo.png';
// const APP_MINI_LOGO_URL = '$DOMAIN_URL/img/logo/mini_logo.png';
const APP_LOGO_URL = 'assets/launcher_icons/wammisLogo.png';
// const APP_LOGO_URL = '$DOMAIN_URL/img/logo/logo.png';
const DEFAULT_LANGUAGE = 'en';
const DASHBOARD_AUTO_SLIDER_SECOND = 6000;
const CUSTOM_AD_AUTO_SLIDER_SECOND_VIDEO = 30000;
const CUSTOM_AD_AUTO_SLIDER_SECOND_IMAGE = 30000;
const LIVE_AUTO_SLIDER_SECOND = 5;

const API_VERSION = 2;

///DO NOT ADD SLASH HERE
const DOMAIN_URL = "https://app.wamims.world";

const BASE_URL = '$DOMAIN_URL/api/';

const APP_APPSTORE_URL = '';

// Wallet System Configuration
const bool ENABLE_POINT_WALLET_SYSTEM =
    false; // Set to true to enable Point Wallet tab

/// Version 1: false = hide point system completely. Only Bolt (from rewarded ads) shown.
/// Version 2: true = enable point/bolt earnings from social, reels, etc.
const bool ENABLE_POINT_EARNINGS_SYSTEM =
    false; // false for v1: only bolt from ads; true for v2: points+bolt from social/reels

///LOCAL VIDEO TYPE URL
const LOCAL_VIDEO_DOMAIN_URL = '$DOMAIN_URL/storage/streamit-laravel/';

//region STRIPE
const STRIPE_URL = 'https://api.stripe.com/v1/payment_intents';
const STRIPE_merchantIdentifier = "merchant.flutter.stripe.test";
const STRIPE_MERCHANT_COUNTRY_CODE = 'IN';
const STRIPE_CURRENCY_CODE = 'INR';
//endregion

//region RazorPay
const String commonSupportedCurrency = 'INR';
//endregion

//region  PAYSTACK
const String payStackCurrency = "NGN";
//endregion

// PAYPAl
const String payPalSupportedCurrency = 'USD';
//endregion

//ADs - Test IDs (Replace with production IDs when ready)
//Android Test IDs
const INTERSTITIAL_AD_ID = "ca-app-pub-3940256099942544/1033173712";
const BANNER_AD_ID = "ca-app-pub-3940256099942544/6300978111";
const REWARDED_AD_ID =
    "ca-app-pub-3940256099942544/5224354917"; // AdMob Rewarded Test ID
const NATIVE_AD_ID =
    "ca-app-pub-3940256099942544/2247696110"; // AdMob Native Test ID

//IOS Test IDs
const IOS_INTERSTITIAL_AD_ID = "ca-app-pub-3940256099942544/4411468910";
const IOS_BANNER_AD_ID = "ca-app-pub-3940256099942544/2934735716";
const IOS_REWARDED_AD_ID = "ca-app-pub-3940256099942544/1712485313";
const IOS_NATIVE_AD_ID = "ca-app-pub-3940256099942544/3986624511";

//Note: For FIREBASE_SERVER_CLIENT_ID ---> Go to android/app/google-services.json
// - Find press ctrl+F and look for "client_type": 3
// "client_id" in same object has be pasted here

const FIREBASE_SERVER_CLIENT_ID =
    '228110272023-dhnin6t8nvlj5edf7j09uimtu3l2dit7.apps.googleusercontent.com';

//region defaultCountry
Country get defaultCountry => Country(
      phoneCode: '91',
      countryCode: 'IN',
      e164Sc: 91,
      geographic: true,
      level: 1,
      name: 'India',
      example: '23456789',
      displayName: 'India (IN) [+91]',
      displayNameNoCountryCode: 'India (IN)',
      e164Key: '91-IN-0',
      fullExampleWithPlusSign: '+919123456789',
    );
//endregion
