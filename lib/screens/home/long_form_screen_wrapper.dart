import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:streamit_laravel/screens/home/home_controller.dart';
import 'package:streamit_laravel/screens/home/home_screen.dart';
import 'package:streamit_laravel/utils/app_common.dart';

/// Wraps Long form (Home) screen. Always shows content (Coming soon overlay removed).
class LongFormScreenWrapper extends StatelessWidget {
  const LongFormScreenWrapper({
    super.key,
    required this.homeScreenController,
  });

  final HomeController homeScreenController;

  @override
  Widget build(BuildContext context) {
    return HomeScreen(homeScreenController: homeScreenController);
  }
}
