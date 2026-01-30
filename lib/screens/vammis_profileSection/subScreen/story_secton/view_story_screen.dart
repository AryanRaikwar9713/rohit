import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/get_story_responce_model.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/story_controller.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/story_responce_model.dart';
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
              return Center(child: CircularProgressIndicator(),);
            }

          return  PageView(
            controller: storyContrller.userPageController,
            onPageChanged: (index){
              storyContrller.onUserChage(storyContrller.storyList[index].user?.id??0);
            },
            children: [
              for(StoryUser model in storyContrller.storyList)
                _buildUsers(model,storyContrller)
            ],
          );

        }),
      ),
    );
  }



  _buildUsers(StoryUser model,StoryContrller controller)
  {
    return Column(
      children: [
        10.height,
        ListTile(
          leading: WamimsProfileAvtar(image: model.user?.avatar??'', story: true, radious: 30,),
          title: Text("${model.user?.username??'No Name'}",style: TextStyle(color: Colors.white,fontFamily: GoogleFonts.poppins().fontFamily),),
        ),
        Expanded(
          child: PageView(
            controller: controller.storyPageController,
            onPageChanged: (index){
              controller.onStoryChange(model.stories?[index].id??0,model.user?.id ??0);
            },
            children: [
              for(StoryStory story in model.stories??[])
                _buildStory(story,controller)
            ],
          ),
        )
      ],
    );
  }


  _buildStory(StoryStory s,StoryContrller controller)
  {

    return Container(
      alignment: Alignment.center,
      child: Stack(
        children: [

          (s.mediaType=='video')?
          Center(child: Text(s.mediaUrl??'',style: TextStyle(color: Colors.white),),)
              :Center(child: Image.network(s.mediaUrl??'',
          errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported_outlined,color: Colors.white,size: 40,),)),

          //
          InkWell(
            onTap: (){
              print("ajsdf");
            },
            child: Container(

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
          )

        ],
      ),
    );
  }


}



