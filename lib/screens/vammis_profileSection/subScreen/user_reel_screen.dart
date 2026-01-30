import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:streamit_laravel/screens/reels/components/reel_item_widget.dart';
import 'package:streamit_laravel/screens/reels/reel_response_model.dart';
import 'package:streamit_laravel/screens/reels/reels_controller.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_controller.dart';



class UserReelScreen extends StatefulWidget {
  final int reelId;
  const UserReelScreen({required this.reelId,super.key});

  @override
  State<UserReelScreen> createState() => _UserReelScreenState();
}

class _UserReelScreenState extends State<UserReelScreen> {

  VammisProfileController profileController = Get.find<VammisProfileController>();
  late PageController pageController;
  int curIndex = 0;
  late ReelsController videoController;





  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   curIndex  =  profileController.userReels.value.indexWhere((element) => element.id==widget.reelId,);
   pageController = PageController(initialPage: curIndex);
    videoController = (Get.isRegistered<ReelsController>())?
       Get.find<ReelsController>():Get.put(ReelsController());
   _getAndController();
  }

  _getAndController()
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
             for(Reel r in profileController.userReels)
               ReelItemWidget(reel: r, controller: videoController)
           ],
        ),
      ),
    );
  }
}
