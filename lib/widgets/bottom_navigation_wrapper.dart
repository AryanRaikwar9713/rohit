import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../screens/dashboard/dashboard_screen.dart';
import '../screens/dashboard/components/menu.dart';
import '../utils/app_common.dart';
import '../utils/colors.dart';
import '../utils/mohit/custom_like_button.dart';

/// Wrapper widget that adds bottom navigation bar to any screen
class BottomNavigationWrapper extends StatelessWidget {
  final Widget child;
  final bool showBottomNav;

  const BottomNavigationWrapper({
    super.key,
    required this.child,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context) {
    final dashboardController = getDashboardController();

    return Scaffold(
      extendBody: true,
      backgroundColor: appScreenBackgroundDark,
      body: child,
      bottomNavigationBar: showBottomNav
          ? Obx(() {
              return Blur(
                blur: 30,
                borderRadius: radius(0),
                child: NavigationBarTheme(
                  data: NavigationBarThemeData(
                    backgroundColor:
                        context.primaryColor.withValues(alpha: 0.02),
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
                      // Clear navigation stack and go to dashboard when bottom nav is clicked
                      await dashboardController.onBottomTabChange(index);
                      Get.offAll(
                        () => DashboardScreen(
                          dashboardController: dashboardController,
                        ),
                      );
                    },
                    destinations: List.generate(
                      dashboardController.bottomNavItems.length,
                      (index) {
                        return _navigationBarItemWidget(
                          dashboardController.bottomNavItems[index],
                          dashboardController.currentIndex.value == index,
                        );
                      },
                    ),
                  ),
                ),
              );
            })
          : null,
    );
  }

  Widget _navigationBarItemWidget(BottomBarItem navBar, bool isCurrentTab) {
    return NavigationDestination(
      selectedIcon: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            Colors.yellow.shade400,  // Yellow
            Colors.orange.shade500,  // Orange
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: navBar.customIcon != null 
            ? const CustomStreamButton()
            : Icon(
                navBar.activeIcon,
                color: Colors.white,
                size: 20,
              ),
      ),
      icon: navBar.customIcon != null
          ? const CustomStreamButton()
          : Icon(
              navBar.icon,
              color: iconColor,
              size: 20,
            ),
      label: navBar.title,
    );
  }
}
