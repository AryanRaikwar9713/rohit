import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_api.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/my_story_responce_model.dart';


class MyStoryController extends GetxController
{

  RxBool isLoading = false.obs;
  RxList<ActiveStory> activeStories = <ActiveStory>[].obs;
  PageController pageController = PageController();

  @override
  void onInit() {
    super.onInit();
    getMyStory();
  }

  Future<void> getMyStory() async
  {
    print("Getting Storyis");
    isLoading.value = true;
     await StoryApi().getOwnStories(onSuccess: (d){
       activeStories.value = d.activeStories!;
       }, onError: (e){
      Logger().e(e);
    }, onFail: (e){
      toast(jsonDecode(e.body)['message']);
    });

     isLoading.value = false;
  }

  void reset()
  {
    isLoading.value = false;
    activeStories.value = [];
  }

}