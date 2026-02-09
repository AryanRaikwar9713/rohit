import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'components/reel_item_widget.dart';
import 'components/reel_video_ad_widget.dart';
import 'reels_controller.dart';
import 'upload_reel_screen.dart';
import 'package:streamit_laravel/screens/walletSection/wallet_tab_manage.dart';

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
    _pageController = PageController();

    // Set system UI overlay style for full screen experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Defer controller delete so that: (1) any open comment bottom sheet can
    // close and stop using the controller, (2) Video platform view and
    // media_kit Player listeners are fully torn down (avoids "[Player] has been disposed").
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }
      SchedulerBinding.instance.addPostFrameCallback((_) {
        // Extra delay so Video/AndroidVideoController widListener stops before we dispose Players
        Future.delayed(const Duration(milliseconds: 350), () {
          if (Get.isRegistered<ReelsController>()) {
            Get.delete<ReelsController>();
          }
        });
      });
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          // Wallet Icon
          IconButton(
            onPressed: () {
              Get.to(() => const WalletTabManage());
            },
            icon: const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 26,
            ),
            tooltip: 'Wallet - Watch Ads & Earn Bolts',
          ),
          IconButton(
            style: const ButtonStyle(
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
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
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

        // Calculate total items (reels + ads every 5 reels)
        const int adInterval = 5; // Show ad after every 5 reels
        final int totalItems = _controller.apiReels.length + 
            (_controller.apiReels.length ~/ adInterval);
        
        return PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          physics: const PageScrollPhysics(),
          itemCount: totalItems,
          onPageChanged: (index) {
            // Calculate actual reel index (accounting for ads)
            final actualReelIndex = _getActualReelIndex(index, adInterval);
            if (actualReelIndex >= 0 && actualReelIndex < _controller.apiReels.length) {
              _controller.onReelChanged(_controller.apiReels[actualReelIndex].id ?? 0);
            }
          },
          itemBuilder: (context, index) {
            // Check if this position should show an ad
            if (_shouldShowAd(index, adInterval)) {
              return RepaintBoundary(
                key: ValueKey('ad_$index'),
                child: const ReelVideoAdWidget(),
              );
            }
            
            // Calculate actual reel index (accounting for ads before this position)
            final actualReelIndex = _getActualReelIndex(index, adInterval);
            if (actualReelIndex < 0 || actualReelIndex >= _controller.apiReels.length) {
              return Container(color: Colors.black);
            }
            
            // Use RepaintBoundary to optimize rebuilds
            return RepaintBoundary(
              key: ValueKey(_controller.apiReels[actualReelIndex].id),
              child: ReelItemWidget(
                key: ValueKey(_controller.apiReels[actualReelIndex].id),
                reel: _controller.apiReels[actualReelIndex],
                controller: _controller,
              ),
            );
          },
        );
      }),
    );
  }
  
  // Check if position should show an ad
  bool _shouldShowAd(int index, int adInterval) {
    // Show ad after every 5 reels (at positions 5, 10, 15, etc.)
    // But skip first position (index 0)
    if (index == 0) return false;
    return (index % (adInterval + 1)) == 0;
  }
  
  // Get actual reel index accounting for ads
  int _getActualReelIndex(int index, int adInterval) {
    // Count how many ads are before this position
    int adsBefore = 0;
    for (int i = 1; i <= index; i++) {
      if (_shouldShowAd(i, adInterval)) {
        adsBefore++;
      }
    }
    // Subtract ads to get actual reel index
    return index - adsBefore;
  }
}
