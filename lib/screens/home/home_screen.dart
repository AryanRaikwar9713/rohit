import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/home/shimmer_home.dart';
import 'package:streamit_laravel/screens/walletSection/wallet_tab_manage.dart';
import 'package:streamit_laravel/utils/app_common.dart';
import 'package:streamit_laravel/utils/colors.dart';

import '../../components/app_scaffold.dart';
import '../../components/category_list/category_list_component.dart';
import '../../components/home_stories_row.dart';
import '../../components/user_uploads_section.dart';
import '../../components/shimmer_widget.dart';
import '../../main.dart';
import '../legal/contact_us_screen.dart';
import '../messaging/message_inbox_screen.dart';
import '../notificationSection/notification_screen.dart';
import '../social/social_search_screen.dart';
import '../video_channel/screens/create_channel_screen.dart';
import '../video_channel/screens/my_long_videos_screen.dart';
import '../video_channel/video_channle_controller.dart';
import '../../utils/constants.dart';
import '../../utils/empty_error_state_widget.dart';
import 'components/continue_watch_component.dart';
import 'components/slider_widget.dart';
import 'home_controller.dart';

bool _safeBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  return value == true;
}

class HomeScreen extends StatelessWidget {
  final HomeController homeScreenController;

  const HomeScreen({super.key, required this.homeScreenController});

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      hasLeadingWidget: false,
      hideAppBar: true,
      isLoading: homeScreenController.isWatchListLoading,
      scaffoldBackgroundColor: black,
      body: Column(
        children: [
          // Custom App Bar with Coming Soon Icon
          _buildCustomAppBar(),

          // Main Content — pull-down-from-top to refresh
          Expanded(
            child: RefreshIndicator(
              color: appColorPrimary,
              onRefresh: () async {
                await homeScreenController.init(
                    forceSync: true, showLoader: true, forceConfigSync: true,);
              },
              child: AnimatedScrollView(
                refreshIndicatorColor: appColorPrimary,
                padding: const EdgeInsets.only(bottom: 120),
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                onSwipeRefresh: () async {
                  return homeScreenController.init(
                      forceSync: true, showLoader: true, forceConfigSync: true,);
                },
              children: [
                Obx(
                  () => SnapHelperWidget(
                    future: homeScreenController.getDashboardDetailFuture.value,
                    initialData: cachedDashboardDetailResponse,
                    loadingWidget: const ShimmerHome(),
                    errorBuilder: (error) {
                      return SizedBox(
                        width: Get.width,
                        height: Get.height * 0.8,
                        child: NoDataWidget(
                          titleTextStyle: secondaryTextStyle(color: white),
                          subTitleTextStyle: primaryTextStyle(color: white),
                          title: error,
                          retryText: locale.value.reload,
                          imageWidget: const ErrorStateWidget(),
                          onRetry: () async {
                            homeScreenController.init(
                                forceSync: true, showLoader: true,);
                          },
                        ).center(),
                      );
                    },
                    onSuccess: (res) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_safeBool(appConfigs.value.isLogin))
                            const HomeStoriesRow(),
                          SliderComponent(homeScreenCont: homeScreenController)
                              .visible(homeScreenController.dashboardDetail
                                      .value.slider?.isNotEmpty ??
                                  false,),
                          ContinueWatchComponent(
                            continueWatchList: homeScreenController
                                .dashboardDetail.value.continueWatch,
                          ).visible(_safeBool(appConfigs.value.enableContinueWatch) &&
                              _safeBool(appConfigs.value.isLogin) &&
                              (homeScreenController.dashboardDetail.value
                                  .continueWatch.isNotEmpty),),
                          const UserUploadsSection(),
                          CategoryListComponent(
                            categoryList: homeScreenController.sectionList,
                          ),
                          Obx(
                            () => homeScreenController.showCategoryShimmer.value
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      4,
                                      (index) => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          16.height,
                                          const ShimmerWidget(
                                            height: Constants.shimmerTextSize,
                                            width: 180,
                                            radius: 6,
                                          ),
                                          16.height,
                                          HorizontalList(
                                            itemCount: 4,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.start,
                                            wrapAlignment: WrapAlignment.start,
                                            spacing: 18,
                                            runSpacing: 18,
                                            padding: EdgeInsets.zero,
                                            itemBuilder: (context, index) {
                                              return ShimmerWidget(
                                                height: 150,
                                                width: Get.width / 4,
                                                radius: 6,
                                              );
                                            },
                                          ),
                                        ],
                                      ).paddingSymmetric(
                                          vertical: 8, horizontal: 16,),
                                    ),
                                  )
                                : const Offstage(),
                          ),
                          // Footer: real contact data (PayUMoney/gateway compliance)
                          _buildHomeFooter(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [


          // App title
          Text(
            'WAMIMS',
            style: boldTextStyle(size: 20, color: Colors.white),
          ),

          const Spacer(),

          // User upload (videos/movies/series) – same flow as Streamit
          IconButton(
            onPressed: () async {
              doIfLogin(onLoggedIn: () async {
                final VideoChannelController c = Get.put(VideoChannelController());
                final ctx = Get.context;
                if (ctx != null) {
                  showDialog(
                    context: ctx,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator()),
                  );
                }
                await c.getChannel();
                if (ctx != null && Navigator.canPop(ctx)) Navigator.pop(ctx);
                if (c.hasChannel.value) {
                  Get.to(() => const MyLongVideosScreen());
                } else {
                  Get.to(() => const CreateVideoChannelScreen());
                }
              });
            },
            icon: const Icon(Icons.upload_rounded, color: Colors.white, size: 24),
            tooltip: 'Upload videos / movies / series',
          ),

          // Action Icons - Messages, Notification, Wallet, Search
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Messages / Chat list (Instagram/WhatsApp style – recent chats on top)
              IconButton(
                onPressed: () {
                  doIfLogin(onLoggedIn: () {
                    Get.to(() => const MessageInboxScreen());
                  },);
                },
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 24,
                ),
                tooltip: 'Messages',
              ),
              // Notification Icon with real unread count badge
              Builder(
                builder: (ctx) {
                  final notifCtrl = Get.isRegistered<WamimsNotificationController>()
                      ? Get.find<WamimsNotificationController>()
                      : Get.put(WamimsNotificationController(), permanent: true);
                  return Obx(() {
                    final count = notifCtrl.unreadCount.value;
                    return Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            Get.to(() => const WamimsNotificationScreen())?.then((_) {
                              notifCtrl.refreshUnreadCount();
                            });
                          },
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                          tooltip: 'Notifications',
                        ),
                        if (count > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  count > 99 ? '99+' : '$count',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  });
                },
              ),

              // Wallet Icon - Watch Ads & Earn Bolts (RIGHT AFTER NOTIFICATION - MUST BE VISIBLE)
              IconButton(
                onPressed: () {
                  Get.to(() => const WalletTabManage());
                },
                icon: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 28,
                ),
                tooltip: 'Wallet - Watch ads (policy-compliant), earn Bolts, donate',
              ),

              // Search Icon — opens user/post/reel search (no GetX route)
              IconButton(
                onPressed: () {
                  Get.to(() => const SocialSearchScreen());
                },
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Footer on home with real contact (Dillod, MP – gateway compliance). Tap opens Contact Us.
  Widget _buildHomeFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Get.to(() => const ContactUsScreen());
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              const Icon(Icons.support_agent_rounded, color: appColorPrimary, size: 22),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Contact & Support',
                      style: boldTextStyle(size: 13, color: Colors.white),
                    ),
                    2.height,
                    Text(
                      'aryanraikwar09@gmail.com • +91 7987048252',
                      style: secondaryTextStyle(size: 11, color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Dillod, Madhya Pradesh',
                      style: secondaryTextStyle(size: 10, color: Colors.white54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
