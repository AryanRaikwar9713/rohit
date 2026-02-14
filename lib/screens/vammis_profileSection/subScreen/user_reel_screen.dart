import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:streamit_laravel/screens/reels/components/reel_item_widget.dart';
import 'package:streamit_laravel/screens/reels/reel_response_model.dart';
import 'package:streamit_laravel/screens/reels/reels_controller.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_controller.dart';



class UserReelScreen extends StatefulWidget {
  final int reelId;
  /// When opened from [VammisProfileScreen], pass the same tag so the correct controller is found.
  final String? profileTag;

  const UserReelScreen({required this.reelId, super.key, this.profileTag});

  @override
  State<UserReelScreen> createState() => _UserReelScreenState();
}

class _UserReelScreenState extends State<UserReelScreen> {

  late final VammisProfileController profileController;
  late PageController pageController;
  int curIndex = 0;
  late ReelsController videoController;

  @override
  void initState() {
    super.initState();
    profileController = widget.profileTag != null
        ? Get.find<VammisProfileController>(tag: widget.profileTag)
        : (Get.isRegistered<VammisProfileController>()
            ? Get.find<VammisProfileController>()
            : Get.put(VammisProfileController()));
    curIndex = profileController.userReels.indexWhere((element) => element.id == widget.reelId);
    if (curIndex < 0) curIndex = 0;
    pageController = PageController(initialPage: curIndex);
    videoController = (Get.isRegistered<ReelsController>())
        ? Get.find<ReelsController>()
        : Get.put(ReelsController());
    _getAndController();
  }

  void _getAndController()
  {

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx( () =>
         PageView(
           scrollDirection: Axis.vertical,
           onPageChanged: (d){

             videoController.videoControllers.forEach(
               (key, value) => value.pause(),
             );

             videoController.videoControllers[profileController.userReels[d].id]?.play();

             if((profileController.userReels.length-d)<10&&(d%10)==2)
               {
                 profileController.loadMoreReel();
               }
           },
           controller: pageController,
           children: [
             for(final Reel r in profileController.userReels)
               ReelItemWidget(reel: r, controller: videoController),
           ],
        ),
      ),
    );
  }
}
