import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_api.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/get_story_responce_model.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/story_responce_model.dart';


class StoryContrller extends GetxController
{

  List<dynamic>  sotryData = [
    {
      "userId": "u1",
      "userName": "Aman",
      "profileImage": "https://randomuser.me/api/portraits/men/32.jpg",
      "stories": [
        {
          "storyId": "s1",
          "type": "image",
          "mediaUrl": "https://picsum.photos/id/1015/600/900",
          "duration": 5,
          "isViewed": false,
          "createdAt": "2025-12-18T10:30:00",
        },
        {
          "storyId": "s2",
          "type": "video",
          "mediaUrl": "https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4",
          "duration": 0,
          "isViewed": false,
          "createdAt": "2025-12-18T10:35:00",
        }
      ],
    },
    {
      "userId": "u2",
      "userName": "Riya",
      "profileImage": "https://randomuser.me/api/portraits/women/45.jpg",
      "stories": [
        {
          "storyId": "s3",
          "type": "image",
          "mediaUrl": "https://picsum.photos/id/1025/600/900",
          "duration": 6,
          "isViewed": true,
          "createdAt": "2025-12-18T09:10:00",
        },
        {
          "storyId": "s4",
          "type": "image",
          "mediaUrl": "https://picsum.photos/id/1035/600/900",
          "duration": 5,
          "isViewed": true,
          "createdAt": "2025-12-18T09:12:00",
        }
      ],
    },
    {
      "userId": "u3",
      "userName": "Rahul",
      "profileImage": "https://randomuser.me/api/portraits/men/76.jpg",
      "stories": [
        {
          "storyId": "s5",
          "type": "video",
          "mediaUrl": "https://sample-videos.com/video321/mp4/720/sample_720p_1mb.mp4",
          "duration": 0,
          "isViewed": false,
          "createdAt": "2025-12-18T08:00:00",
        }
      ],
    }
  ];

  PageController userPageController = PageController();
  PageController storyPageController = PageController();

  RxInt selectedStoryId = 0.obs;
  RxInt selectedUserId = 0.obs;

  RxList<StoryUser> storyList = RxList<StoryUser>([]);
  RxBool isLoading = false.obs;

  RxBool isLastUser = false.obs;
  RxBool isLastStory = false.obs;

  final api = StoryApi();


  void setStoryPageController()
  {
    // selectedUserId.value = storyList[0].userId??'';
    // selectedStoryId.value = storyList[0].stories?[0].storyId??'';
    userPageController = PageController();
    storyPageController = PageController();
  }

  Future<void> loadStory() async
  {
    try
    {
      await  api.getStories(onSuccess: (d){

        storyList.value = d.stories??[];


      }, onError: onError, onFail: (d){
        Logger().e("Feaild To get Sotry ${d.statusCode}");
      },);
    }
    catch(e)
{
  Logger().e('Error in Function $e');
}
    setStoryPageController();
    isLoading.value = false;
  }

  void onUserChage(int userId)
  {
    selectedUserId.value = userId;
    isLastUser.value = userId==(storyList.last.user?.id??0);
    final int userInd = storyList.indexWhere((element) => element.user?.id==selectedUserId.value,);
    isLastStory.value =  storyList[userInd].stories?.length==1;
  }

  void onStoryChange(int storyId,int userId)
  {
    selectedStoryId.value = storyId;
    selectedUserId.value = userId;
    isLastUser.value = storyList.last.user?.id==selectedUserId.value;
    final int userInd = storyList.indexWhere((element) => element.user?.id==selectedUserId.value,);
    isLastStory.value =  storyList[userInd].stories?.last.id==storyId;
    print('selectedUserId $selectedUserId');
    print('selectedStoryId $selectedStoryId');
    print('isLastUser $isLastUser');
    print('isLastStory $isLastStory');
  }

  
  
  void nextStory()
  {
    print('$selectedUserId $selectedStoryId');





    print("${isLastStory.value} ${isLastUser.value}");
    // print('${storyList}');

    if(isLastUser.value&&isLastStory.value)
      {
        Navigator.pop(navigatorKey.currentContext!);
      }
    else if(isLastStory.value)
      {
        isLastStory.value = false;
        userPageController.nextPage(duration: const Duration(milliseconds: 100), curve: Curves.linear);
      }
    else
      {
        storyPageController.nextPage(duration: const Duration(milliseconds: 100), curve: Curves.linear);
      }
  }
  
  
  void prevStory()
  {
    
  }


  void reset()
  {
    selectedStoryId.value = 0;
    selectedUserId.value = 0;
    isLastUser.value = false;
    isLastStory.value = false;
    userPageController.dispose();
    storyPageController.dispose();
    storyList.clear();
    isLoading.value = true;
  }

}