import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/app_common.dart';
import 'loader_widget.dart';

class Body extends StatelessWidget {
  final Widget child;
  final RxBool isLoading;
  final Color? loaderColor;

  const Body({super.key, required this.isLoading, required this.child, this.loaderColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      height: Get.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          Obx(() => LoaderWidget(loaderColor: loaderColor).center().visible(isLoading.value || adsLoader.value)),
        ],
      ),
    );
  }
}
