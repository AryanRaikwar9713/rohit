import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:media_kit/media_kit.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/locale/language_en.dart';
import 'package:streamit_laravel/screens/auth/model/app_configuration_res.dart';
import 'package:streamit_laravel/screens/auth/model/login_response.dart';
import 'package:streamit_laravel/screens/coming_soon/model/coming_soon_response.dart';
import 'package:streamit_laravel/screens/home/model/dashboard_res_model.dart';
import 'package:streamit_laravel/screens/live_tv/model/live_tv_dashboard_response.dart';
import 'package:streamit_laravel/screens/person/model/person_model.dart';
import 'package:streamit_laravel/services/in_app_purhcase_service.dart';
import 'package:streamit_laravel/utils/local_storage.dart';
import 'package:streamit_laravel/video_players/model/video_model.dart';
import 'package:y_player/y_player.dart';
import 'app_lovin_ads/add_helper.dart';
import 'components/admob_app_open_helper.dart';
import 'components/admob_rewarded_ad_helper.dart';
import 'app_theme.dart';
import 'configs.dart';
import 'locale/app_localizations.dart';
import 'locale/languages.dart';
import 'network/auth_apis.dart';
import 'screens/profile/model/profile_detail_resp.dart';
import 'screens/splash_screen.dart';
import 'utils/app_common.dart';
import 'utils/colors.dart';
import 'utils/common_base.dart';
import 'utils/constants.dart';
import 'utils/location_monitor.dart';
import 'utils/local_storage.dart' as local;
import 'utils/push_notification_service.dart';
import 'http_overrides_stub.dart' if (dart.library.io) 'http_overrides_io.dart' as http_overrides;
//aryan
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('${FirebaseMsgConst.notificationDataKey} : ${message.data}');
  log('${FirebaseMsgConst.notificationKey} : ${message.notification}');
  log('${FirebaseMsgConst.notificationTitleKey} : ${message.notification?.title ?? ''}');
  log('${FirebaseMsgConst.notificationBodyKey} : ${message.notification?.body ?? ''}');
  // When server sends only "data" (no "notification"), show local notification so user sees it
  if (message.notification == null) {
    await PushNotificationService.showNotificationFromBackground(message);
  }
}

Rx<BaseLanguage> locale = LanguageEn().obs;

DashboardDetailResponse? cachedDashboardDetailResponse;

LiveChannelDashboardResponse? cachedLiveTvDashboard;

ProfileDetailResponse? cachedProfileDetails;

InAppPurchaseService inAppPurchaseService = InAppPurchaseService();
// RxLists for cached lists
RxList<VideoPlayerModel> cachedMovieList = RxList<VideoPlayerModel>();
RxList<VideoPlayerModel> cachedTvShowList = RxList<VideoPlayerModel>();
RxList<VideoPlayerModel> cachedVideoList = RxList<VideoPlayerModel>();
RxList<ComingSoonModel> cachedComingSoonList = RxList<ComingSoonModel>();
RxList<VideoPlayerModel> cachedContinueWatchList = RxList<VideoPlayerModel>();
RxList<VideoPlayerModel> cachedWatchList = RxList<VideoPlayerModel>();
RxList<VideoPlayerModel> cachedRentedContentList = RxList<VideoPlayerModel>();
RxList<ChannelModel> cachedChannelList = RxList();
RxList<PersonModel> cachedPersonList = RxList();
RxBool isChild = true.obs;

const platform = MethodChannel('flutter.iqonic.streamitlaravel.com.channel');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize MediaKit
  MediaKit.ensureInitialized();
  YPlayerInitializer.ensureInitialized();

  if (!kIsWeb) {
    await AdLovinHelper.initialize();
  }

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  if (!kIsWeb) {
    await Firebase.initializeApp().then((value) {
      PushNotificationService().initFirebaseMessaging().catchError((error) {
        log('Firebase Messaging initialization error: $error');
      });
      if (kReleaseMode) {
        FlutterError.onError =
            FirebaseCrashlytics.instance.recordFlutterFatalError;
      }
    }).catchError(onError);
  }
  await GetStorage.init();
  //
  fontFamilyPrimaryGlobal =
      GoogleFonts.roboto(fontWeight: FontWeight.normal, fontSize: 16)
          .fontFamily;
  textPrimarySizeGlobal = 16;
  fontFamilySecondaryGlobal = GoogleFonts.roboto(
          fontWeight: FontWeight.normal,
          color: secondaryTextColor,
          fontSize: 14,)
      .fontFamily;
  textSecondarySizeGlobal = 14;
  fontFamilyBoldGlobal = GoogleFonts.roboto(
          fontWeight: FontWeight.bold, color: primaryTextColor, fontSize: 16,)
      .fontFamily;
  textPrimaryColorGlobal = primaryTextColor;
  textSecondaryColorGlobal = secondaryTextColor;
  //
  defaultBlurRadius = 0;
  defaultRadius = 12;
  defaultSpreadRadius = 0;
  appButtonBackgroundColorGlobal = appColorPrimary;
  defaultAppButtonRadius = defaultRadius;
  defaultAppButtonElevation = 0;
  defaultAppButtonTextColorGlobal = primaryTextColor;
  passwordLengthGlobal = 8;

  selectedLanguageCode(
      local.getValueFromLocal(SELECTED_LANGUAGE_CODE) ?? DEFAULT_LANGUAGE,);

  await initialize(
      aLocaleLanguageList: languageList(),
      defaultLanguage: selectedLanguageCode.value,);

  final BaseLanguage temp =
      await const AppLocalizations().load(Locale(selectedLanguageCode.value));
  locale = temp.obs;
  locale.value =
      await const AppLocalizations().load(Locale(selectedLanguageCode.value));

  if (getStringAsync(SharedPreferenceConst.CONFIGURATION_RESPONSE).isNotEmpty) {
    final ConfigurationResponse configData = ConfigurationResponse.fromJson(
        jsonDecode(
            getStringAsync(SharedPreferenceConst.CONFIGURATION_RESPONSE),),);
    appConfigs(configData);
  }

  try {
    final getThemeFromLocal =
        local.getValueFromLocal(SettingsLocalConst.THEME_MODE);
    if (getThemeFromLocal is int) {
      toggleThemeMode(themeId: getThemeFromLocal);
    } else {
      toggleThemeMode(themeId: THEME_MODE_LIGHT);
    }
  } catch (e) {
    log('getThemeFromLocal from cache E: $e');
  }

  isLoggedIn(getBoolValueAsync(SharedPreferenceConst.IS_LOGGED_IN) ||
      getStringAsync(SharedPreferenceConst.USER_DATA).isNotEmpty,);

  if (isLoggedIn.value) {
    final userData = getStringAsync(SharedPreferenceConst.USER_DATA);

    if (getStringAsync(SharedPreferenceConst.USER_DATA).isNotEmpty) {
      loginUserData(UserData.fromJson(jsonDecode(userData)));
      // Subscribe to FCM topic user_<id> so push (like/comment/share/message) works when app was killed
      if (!kIsWeb && loginUserData.value.id > 0) {
        PushNotificationService().registerFCMAndTopics();
      }
    } else {
      isLoggedIn(false);
      AuthServiceApis().clearData();
    }
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: appScreenBackgroundDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  if (!kIsWeb) {
    http_overrides.setHttpOverrides();
    await MobileAds.instance.initialize();
    AdMobRewardedAdHelper.initialize();
    AdMobAppOpenHelper.load();
  }
  runApp(const MyApp());
}

class _AppOpenAdLifecycleWrapper extends StatefulWidget {
  final Widget child;

  const _AppOpenAdLifecycleWrapper({required this.child});

  @override
  State<_AppOpenAdLifecycleWrapper> createState() =>
      _AppOpenAdLifecycleWrapperState();
}

class _AppOpenAdLifecycleWrapperState extends State<_AppOpenAdLifecycleWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      AdMobAppOpenHelper.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      AdMobAppOpenHelper.maybeShowOnResume();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      title: APP_NAME,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.noTransition,
      supportedLocales: LanguageDataModel.languageLocales(),
      builder: (context, child) {
        final Widget inner = MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(0.8)),
          child: SafeArea(
            left: false,
            top: false,
            right: false,
            bottom: !kIsWeb && (defaultTargetPlatform != TargetPlatform.iOS),
            child: child!,
          ),
        );
        final Widget content = kIsWeb
            ? LayoutBuilder(
                builder: (context, constraints) {
                  const double maxWidth = 500;
                  if (constraints.maxWidth > maxWidth) {
                    return Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: maxWidth),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: inner,
                      ),
                    );
                  }
                  return inner;
                },
              )
            : inner;
        return _AppOpenAdLifecycleWrapper(
          child: LocationMonitorWidget(child: content),
        );
      },
      localizationsDelegates: const [
        AppLocalizations(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) =>
          Locale(selectedLanguageCode.value),
      fallbackLocale: const Locale(DEFAULT_LANGUAGE),
      locale: Locale(selectedLanguageCode.value),
      theme: AppTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      initialBinding: BindingsBuilder(() {
        setStatusBarColor(transparentColor);
      }),
      onGenerateRoute: (settings) {
        if (settings.name.validate().split('/').last.isDigit()) {
          return MaterialPageRoute(
            builder: (context) {
              return SplashScreen(
                  deepLink: settings.name.validate(), link: true,);
            },
          );
        } else {
          return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
      home: const SplashScreen(),
      // ),
    );
  }
}
