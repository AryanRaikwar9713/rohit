import 'package:flutter/material.dart';
import 'package:streamit_laravel/screens/home/home_controller.dart';
import 'package:get/get.dart';
import 'package:streamit_laravel/screens/home/home_screen.dart';

class CustomLikeButton extends StatelessWidget {
  final bool isLiked;
  final int? likeCount;
  final Future<void> Function()? onLike;
  const CustomLikeButton(
      {required this.isLiked, this.likeCount, this.onLike, super.key,});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onLike,
          child: SizedBox(
            // padding: EdgeInsets.all(5),
            height: 30,
            width: 30,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: isLiked
                  ? Image.asset(
                      'assets/icons/like_bulbe.png',
                      color: Colors.yellow,
                    )
                  : const Icon(Icons.lightbulb_outline),
            ),
          ),
        ),
        if (likeCount != null)
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: [
                  Colors.yellow.shade400,  // Yellow
                  Colors.orange.shade500,  // Orange
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: Text(
              ' $likeCount',
              style: const TextStyle(
                color: Colors.white, // IMPORTANT: White रखें
              ),
            ),
          ),
      ],
    );
  }
}

class CustomStreamButton extends StatelessWidget {
  const CustomStreamButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate directly to HomeScreen
        final HomeController controller = (Get.isRegistered<HomeController>())
            ? Get.find()
            : Get.put(HomeController());

        Get.to(() => HomeScreen(homeScreenController: controller));
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Image.asset(
          "assets/launcher_icons/streamLogo.png",
          width: 20,
          height: 20,
          color: Colors.white,
        ),
      ),
    );
  }
}
