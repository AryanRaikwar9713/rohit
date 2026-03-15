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

  /// Viewers per story (my stories only). Filled once backend adds API.
  final RxMap<int, List<StoryViewer>> viewersByStory =
      <int, List<StoryViewer>>{}.obs;

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
       activeStories.assignAll(d.activeStories ?? []);
       }, onError: (e){
      Logger().e(e);
    }, onFail: (e){
      toast(jsonDecode(e.body)['message']);
    },);

     isLoading.value = false;
  }

  Future<void> loadViewersForStory(int? storyId) async {
    if (storyId == null || storyId <= 0) return;
    try {
      await StoryApi().getStoryViewers(
        storyId: storyId,
        onSuccess: (viewers) {
          viewersByStory[storyId] = viewers;
          viewersByStory.refresh();
        },
        onError: (e) => Logger().w('Story viewers API error: $e'),
        onFail: (resp) =>
            Logger().w('Story viewers API failed: ${resp.statusCode}'),
      );
    } catch (e) {
      Logger().e('Error loading story viewers: $e');
    }
  }

  List<StoryViewer> getViewersForStory(int? storyId) {
    if (storyId == null) return const [];
    return viewersByStory[storyId] ?? const [];
  }

  void reset()
  {
    isLoading.value = false;
    activeStories.clear();
  }

}

class StoryViewer {
  final int id;
  final String username;
  final String name;
  final String avatar;
  final DateTime? viewedAt;

  StoryViewer({
    required this.id,
    required this.username,
    required this.name,
    required this.avatar,
    this.viewedAt,
  });

  factory StoryViewer.fromJson(Map<String, dynamic> json) => StoryViewer(
        id: json['id'] ?? 0,
        username: json['username'] ?? '',
        name: json['name'] ?? '',
        avatar: json['avatar'] ?? '',
        viewedAt: json['viewed_at'] != null
            ? DateTime.tryParse(json['viewed_at'])
            : null,
      );

}