import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'components/reel_item_widget.dart';
import 'reels_controller.dart';
import 'upload_reel_screen.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  late PageController _pageController;
  late ReelsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(ReelsController());
    _pageController = PageController(initialPage: 0);

    // Set system UI overlay style for full screen experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Delete controller immediately — by the time we're disposed, children
    // (ReelItemWidgets) are already disposed, so no Obx/listeners remain.
    // Delaying to next frame caused crash when switching to Profile tab.
    if (Get.isRegistered<ReelsController>()) {
      Get.delete<ReelsController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.transparent), // IMPORTANT
              padding: WidgetStatePropertyAll(EdgeInsets.all(12)),
            ),
            onPressed: () {
              Get.to(() => const UploadReelScreen());
            },
            icon: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.yellow.shade400,  // Yellow
                    Colors.orange.shade400,  // Orange
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
          SizedBox(
            width: 15,
          )
        ],
      ),
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Obx(() {
        if (_controller.isLoading.value) {
          return Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          );
        }

        if (_controller.apiReels.isEmpty) {
          return Container(
            color: Colors.black,
            child: const Center(
              child: Text(
                'No reels available',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          physics: PageScrollPhysics(),
          itemCount: _controller.apiReels.length,
          onPageChanged: (index) {
            _controller.onReelChanged(_controller.apiReels[index].id ?? 0);
          },
          itemBuilder: (context, index) {
            return ReelItemWidget(
              key: ValueKey(_controller.apiReels[index].id),
              reel: _controller.apiReels[index],
              controller: _controller,
            );
          },
        );
      }),
    );
  }
}
