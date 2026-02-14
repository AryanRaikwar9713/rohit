import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/home/shimmer_home.dart';
import 'package:streamit_laravel/screens/walletSection/wallet_tab_manage.dart';
import 'package:streamit_laravel/utils/app_common.dart';
import 'package:streamit_laravel/utils/colors.dart';

import '../../components/app_scaffold.dart';
import '../../components/category_list/category_list_component.dart';
import '../../components/shimmer_widget.dart';
import '../../main.dart';
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

          // Main Content
          Expanded(
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
                        ],
                      );
                    },
                  ),
                ),
              ],
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


          // App Title only (no logo for v1)
          Text(
            'Wamims',
            style: boldTextStyle(size: 20, color: Colors.white),
          ),

          const Spacer(),

          // Action Icons - Notification, Search, Wallet (MUST BE VISIBLE)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Notification Icon
              IconButton(
                onPressed: () {
                  toast('Notifications');
                },
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 24,
                ),
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
                tooltip: 'Wallet - Watch Ads & Earn Bolts',
              ),

              // Search Icon
              IconButton(
                onPressed: () {
                  Get.toNamed('/search');
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
}
