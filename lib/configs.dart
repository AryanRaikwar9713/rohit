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
const DOMAIN_URL = "https://wamims.international";

const BASE_URL = '$DOMAIN_URL/api/';

/// Messaging system (1:1 chat) – backend at /social/message/
const MESSAGE_BASE_URL = 'https://wamims.international/social/message';

/// Resolves image/avatar URL: use as-is if already absolute, else prepend [DOMAIN_URL]
/// with optional [pathPrefix] (e.g. '/storage/avatars/'). Prevents double base URL.
String resolveImageUrl(String? url, {String pathPrefix = ''}) {
  if (url == null || url.trim().isEmpty) return '';
  final u = url.trim();
  if (u.startsWith('http://') || u.startsWith('https://')) return u;
  final prefix = pathPrefix.startsWith('/') ? pathPrefix : '/$pathPrefix';
  final path = u.startsWith('/') ? u : '$prefix$u';
  return '$DOMAIN_URL$path';
}

const APP_APPSTORE_URL = '';

// Wallet System Configuration (v1: bolt from ads only; point wallet = next version)
const bool ENABLE_POINT_WALLET_SYSTEM = false;

/// false = bolt only when user watches ads (Watch & Earn). No bolt for like/comment/post/reel.
/// true = enable bolt/points from social like, comment, post view, reel watch, etc. (next version)
const bool ENABLE_POINT_EARNINGS_SYSTEM = false;

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

// ---------------------------------------------------------------------------
// AdMob & AppLovin – REAL PRODUCTION IDs (no test IDs)
// Account under review: Until approved, fill may be low or zero. No code change needed.
// As soon as account is approved, ads will automatically start showing (no app update).
// ---------------------------------------------------------------------------

// AdMob – Production IDs (policy-compliant placement only)
const String ADMOB_APP_ID_ANDROID = "ca-app-pub-1073907455931977~7164377673";
const String ADMOB_APP_ID_IOS = "ca-app-pub-1073907455931977~7164377673";

// Android
const INTERSTITIAL_AD_ID = "ca-app-pub-1073907455931977/5439699633";
const BANNER_AD_ID = "ca-app-pub-1073907455931977/9661327318";
const REWARDED_AD_ID = "ca-app-pub-1073907455931977/1256912048";
const REWARD_INTERSTITIAL_AD_ID = "ca-app-pub-1073907455931977/4521010843";
const NATIVE_AD_ID = "ca-app-pub-1073907455931977/9501874788";
const APP_OPEN_AD_ID = "ca-app-pub-1073907455931977/7442358082";

// iOS (same unit IDs unless you create iOS-specific in AdMob)
const IOS_INTERSTITIAL_AD_ID = "ca-app-pub-1073907455931977/5439699633";
const IOS_BANNER_AD_ID = "ca-app-pub-1073907455931977/9661327318";
const IOS_REWARDED_AD_ID = "ca-app-pub-1073907455931977/1256912048";
const IOS_REWARD_INTERSTITIAL_AD_ID = "ca-app-pub-1073907455931977/4521010843";
const IOS_NATIVE_AD_ID = "ca-app-pub-1073907455931977/9501874788";
const IOS_APP_OPEN_AD_ID = "ca-app-pub-1073907455931977/7442358082";

//Note: For FIREBASE_SERVER_CLIENT_ID ---> Go to android/app/google-services.json
// - Find press ctrl+F and look for "client_type": 3
// "client_id" in same object has be pasted here

const FIREBASE_SERVER_CLIENT_ID =
    '228110272023-dhnin6t8nvlj5edf7j09uimtu3l2dit7.apps.googleusercontent.com';

/// iOS Google Sign-In client ID (from GoogleService-Info.plist - maarket-points)
const FIREBASE_IOS_CLIENT_ID =
    '228110272023-d4cmai99ein70d8ttl50ppvbmfgbjl25.apps.googleusercontent.com';

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
