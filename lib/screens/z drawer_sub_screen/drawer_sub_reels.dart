import 'package:flutter/material.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/reels/upload_reel_screen.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/user_reel_screen.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_controller.dart';
import 'package:get/get.dart';

class DrawerSubReels extends StatefulWidget {
  const DrawerSubReels({super.key});

  @override
  State<DrawerSubReels> createState() => _DrawerSubReelsState();
}

class _DrawerSubReelsState extends State<DrawerSubReels> {

  late VammisProfileController profileController;
  late int userId;
  ScrollController _scrollController = ScrollController();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myInit();
  }


  myInit() async
  {
    profileController = Get.put(VammisProfileController());
    var user  = await DB().getUser();
    userId = user?.id??0;
    profileController.loadUserReels(userId,refresh: true,);
    addScrollListener();
  }

  void addScrollListener()
  {
    _scrollController.addListener(() {
      if(_scrollController.position.pixels==_scrollController.position.maxScrollExtent)
        {
          profileController.loadMoreReel();
        }

    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      //
      appBar: AppBar(
        title: Text("Reel"),
        actions: [
          IconButton(onPressed: (){
            Get.to(const UploadReelScreen());
          }, icon: const Icon(Icons.add))
        ],
      ),

      body: Obx((){

        //
        if(profileController.isLoadingReels.value)
          {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

        //
        else if(profileController.userReels.isEmpty)
          {
            return Center(child: ElevatedButton(onPressed: (){
              Get.to(const UploadReelScreen());
            }, child: const Text("Upload Reel")),);
          }


        //
        return RefreshIndicator(
          onRefresh: ()async{
            await profileController.loadUserReels(userId,refresh: true);
          },
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsetsGeometry.symmetric(vertical: 20,horizontal: 5),
            gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,
            mainAxisExtent: MediaQuery.of(context).size.height*.4,
            mainAxisSpacing: 5,crossAxisSpacing: 5),
            itemCount: profileController.userReels.length,
            // itemCount: 9,
            itemBuilder: (context, index) {
               var reel = profileController.userReels[index];
              return GestureDetector(
                onTap: (){
                  Get.to(UserReelScreen(reelId: reel.id??0));
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  // color: Colors.red,
                    child: Image.network(reel.content?.thumbnailUrl??'',fit: BoxFit.cover,)),
              );
            },
          ),
        );

      }),
    );
  }
}
