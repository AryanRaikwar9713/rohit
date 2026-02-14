import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/get_story_responce_model.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/story_controller.dart';
import 'package:streamit_laravel/utils/mohit/vammis_profile_avtar.dart';
import 'package:get/get.dart';



class ViewStoryScreen extends StatefulWidget {
  const ViewStoryScreen({super.key});

  @override
  State<ViewStoryScreen> createState() => _ViewStoryScreenState();
}

class _ViewStoryScreenState extends State<ViewStoryScreen> {

  late StoryContrller storyContrller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    storyContrller  = Get.put(StoryContrller());
    storyContrller.loadStory();
  }


  @override
  void dispose() {
    // TODO: implement dispose
    storyContrller.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body:Obx((){

          if(storyContrller.isLoading.value)
            {
              return const Center(child: CircularProgressIndicator(),);
            }
          if(storyContrller.storyList.isEmpty)
            {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_stories_outlined, size: 64, color: Colors.grey[400]),
                    16.height,
                    Text('No stories yet', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                  ],
                ),
              );
            }

          return  PageView(
            controller: storyContrller.userPageController,
            onPageChanged: (index){
              storyContrller.onUserChage(storyContrller.storyList[index].user?.id??0);
            },
            children: [
              for(final StoryUser model in storyContrller.storyList)
                _buildUsers(model,storyContrller),
            ],
          );

        }),
      ),
    );
  }



  Column _buildUsers(StoryUser model,StoryContrller controller)
  {
    return Column(
      children: [
        10.height,
        ListTile(
          leading: WamimsProfileAvtar(image: model.user?.avatar??'', story: true, radious: 30,),
          title: Text(model.user?.username??'No Name',style: TextStyle(color: Colors.white,fontFamily: GoogleFonts.poppins().fontFamily),),
        ),
        Expanded(
          child: PageView(
            controller: controller.storyPageController,
            onPageChanged: (index){
              controller.onStoryChange(model.stories?[index].id??0,model.user?.id ??0);
            },
            children: [
              for(final StoryStory story in model.stories??[])
                _buildStory(story,controller),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStoryMedia(StoryStory s) {
    final hasMedia = (s.mediaUrl ?? '').trim().isNotEmpty;
    if (!hasMedia) {
      return Center(child: Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey[600]));
    }
    if (s.mediaType == 'video') {
      return Center(child: Icon(Icons.videocam_outlined, size: 64, color: Colors.grey[400]));
    }
    return Center(
      child: Image.network(
        s.mediaUrl!,
        fit: BoxFit.contain,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : Center(child: CircularProgressIndicator(value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1) : null)),
        errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported_outlined, color: Colors.white54, size: 40),
      ),
    );
  }

  Container _buildStory(StoryStory s,StoryContrller controller)
  {
    return Container(
      color: Colors.grey[900],
      alignment: Alignment.center,
      child: Stack(
        children: [
          _buildStoryMedia(s),

          //
          InkWell(
            onTap: (){
              print("ajsdf");
            },
            child: SizedBox(

              height: double.infinity,
              width:MediaQuery.of(context).size.width*.3,
            ),
          ),

          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: InkWell(
              onTap: (){
                controller.nextStory();
              },
              child: Container(

                width:MediaQuery.of(context).size.width*.3,
              ),
            ),
          ),

        ],
      ),
    );
  }


}



