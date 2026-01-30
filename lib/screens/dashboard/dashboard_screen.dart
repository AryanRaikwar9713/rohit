import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/colors.dart';
import 'components/menu.dart';
import 'dashboard_controller.dart';
import 'floting_action_bar/floating_action_controller.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key, required this.dashboardController});

  final DashboardController dashboardController;

  final FloatingController floatingController = Get.put(FloatingController());

  @override
  Widget build(BuildContext context) {
    return DoublePressBackWidget(
      child: Scaffold(
        extendBody: true,
        backgroundColor: appScreenBackgroundDark,
        extendBodyBehindAppBar: true,
        // floatingActionButton: Obx(() {
        //   if (dashboardController.currentIndex.value == 1) {
        //     if (!appConfigs.value.enableTvShow &&
        //         !appConfigs.value.enableMovie &&
        //         !appConfigs.value.enableVideo) {
        //       return const Offstage();
        //     } else {
        //       return FloatingButton().paddingBottom(16);
        //     }
        //   } else {
        //     return const Offstage();
        //   }
        // }),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: Obx(
          () {
            final currentIndex = dashboardController.currentIndex.value;
            final screenList = dashboardController.screen;
            
            // Safety check to prevent RangeError
            if (currentIndex >= 0 && currentIndex < screenList.length) {
              return IgnorePointer(
                ignoring: floatingController.isExpanded.value,
                child: screenList[currentIndex],
              );
            } else {
              // Return empty widget if index is out of bounds
              return const SizedBox();
            }
          },
        ),
        bottomNavigationBar: Obx(() {
          return Blur(
            blur: 30,
            borderRadius: radius(0),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: context.primaryColor.withValues(alpha: 0.02),
                indicatorColor: context.primaryColor.withValues(alpha: 0.1),
                labelTextStyle:
                    WidgetStateProperty.all(primaryTextStyle(size: 14)),
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              child: NavigationBar(
                height: 70,
                surfaceTintColor: Colors.transparent,
                selectedIndex: dashboardController.currentIndex.value,
                backgroundColor: Colors.transparent,
                indicatorColor: Colors.transparent,
                animationDuration: GetNumUtils(1000).milliseconds,
                onDestinationSelected: (index) async {
                  hideKeyboard(context);
                  floatingController.isExpanded(false);
                  await dashboardController.onBottomTabChange(index);
                  handleChangeTabIndex(index);
                },
                destinations: List.generate(
                  dashboardController.bottomNavItems.length,
                  (index) {
                    return navigationBarItemWidget(
                      dashboardController.bottomNavItems[index],
                      dashboardController.currentIndex.value == index,
                    );
                  },
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget navigationBarItemWidget(BottomBarItem navBar, bool isCurrentTab) {
    Widget buildIcon(bool selected) {
      if (selected && navBar.customActiveIcon != null) {
        return navBar.customActiveIcon!;
      }
      if (!selected && navBar.customIcon != null) {
        return navBar.customIcon!;
      }
      return Icon(
        selected ? navBar.activeIcon : navBar.icon,
        color: selected ? appColorPrimary : iconColor,
        size: 20,
      );
    }

    return NavigationDestination(
      selectedIcon: buildIcon(true),
      icon: buildIcon(false),
      label: navBar.title,
    );
  }

  Future<void> handleChangeTabIndex(int index) async {
    dashboardController.currentIndex(index);
  }
}
