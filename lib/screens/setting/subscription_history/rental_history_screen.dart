import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/setting/subscription_history/rental_history_controller.dart';
import 'package:streamit_laravel/screens/subscription/components/rented_history_card.dart';

import '../../../components/app_scaffold.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/empty_error_state_widget.dart';
import '../../subscription/shimmer_subscription_list.dart';

class RentalHistoryScreen extends StatelessWidget {
  RentalHistoryScreen({
    super.key,
  });

  final RentalHistoryController controller = Get.put(RentalHistoryController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      scaffoldBackgroundColor: appScreenBackgroundDark,
      topBarBgColor: transparentColor,
      isLoading: controller.isLoading,
      appBartitleText: locale.value.rentalHistory,
      body: Obx(() {
        return AnimatedScrollView(
          padding: const EdgeInsets.only(bottom: 120, top: 8),
          listAnimationType: commonListAnimationType,
          refreshIndicatorColor: appColorPrimary,
          physics: const AlwaysScrollableScrollPhysics(),
          onNextPage: () {
            if (!controller.isLastPage.value) {
              controller.page++;
              controller.getRentalListHistoryList();
            }
          },
          onSwipeRefresh: () {
            controller.page(1);
            return controller.getRentalHistoryFuture();
          },
          children: [
            SnapHelperWidget(
              future: controller.getRentalHistoryFuture.value,
              loadingWidget: controller.isLoading.value ? const ShimmerSubscriptionList() : const ShimmerSubscriptionList(),
              errorBuilder: (error) {
                return NoDataWidget(
                  titleTextStyle: secondaryTextStyle(color: white),
                  subTitleTextStyle: primaryTextStyle(color: white),
                  title: error,
                  retryText: locale.value.reload,
                  imageWidget: const ErrorStateWidget(),
                  onRetry: () {
                    controller.getRentalListHistoryList();
                  },
                );
              },
              onSuccess: (res) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.rentalHistoryList.isEmpty && controller.isLoading.isFalse)
                      SizedBox(
                        height: Get.height * 0.6,
                        width: Get.width,
                        child: NoDataWidget(
                          titleTextStyle: boldTextStyle(color: white),
                          subTitleTextStyle: primaryTextStyle(color: white),
                          title: locale.value.noRentalHistoryFound,
                          imageWidget: const EmptyStateWidget(),
                          retryText: locale.value.reload,
                          onRetry: () {
                            controller.getRentalListHistoryList();
                          },
                        ).paddingSymmetric(horizontal: 16).center(),
                      )
                    else
                      AnimatedWrap(
                        listAnimationType: commonListAnimationType,
                        itemBuilder: (context, index) {
                          return RentedHistoryCard(rentalHistory: controller.rentalHistoryList[index]);
                        },
                        runSpacing: 16,
                        spacing: 16,
                        itemCount: controller.rentalHistoryList.length,
                      ),
                  ],
                ).paddingSymmetric(horizontal: 16);
              },
            ),
          ],
        );
      }),
    );
  }
}