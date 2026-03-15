import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_api.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_secton/get_story_responce_model.dart';

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

  /// User IDs whose stories have been viewed (for yellow vs 50% ring)
  final RxList<int> viewedStoryUserIds = <int>[].obs;

  /// Local like state for stories (per-story, optimistic until backend confirms).
  final RxSet<int> likedStoryIds = <int>{}.obs;

  RxBool isLastUser = false.obs;
  RxBool isLastStory = false.obs;

  final api = StoryApi();

  void markStoryUserViewed(int userId) {
    if (userId <= 0) return;
    if (!viewedStoryUserIds.contains(userId)) {
      viewedStoryUserIds.add(userId);
      viewedStoryUserIds.refresh();
      _sortStoryListUnviewedFirst();
    }
  }

  /// Unviewed first, viewed last; within each group, latest story first.
  void _sortStoryListUnviewedFirst() {
    final list = storyList.toList();
    if (list.isEmpty) return;
    list.sort((a, b) {
      final aViewed = viewedStoryUserIds.contains(a.user?.id ?? 0);
      final bViewed = viewedStoryUserIds.contains(b.user?.id ?? 0);
      if (aViewed != bViewed) return aViewed ? 1 : -1;
      final aLatest = a.stories?.map((s) => s.createdAt ?? DateTime(0)).fold<DateTime>(DateTime(0), (p, t) => t.isAfter(p) ? t : p) ?? DateTime(0);
      final bLatest = b.stories?.map((s) => s.createdAt ?? DateTime(0)).fold<DateTime>(DateTime(0), (p, t) => t.isAfter(p) ? t : p) ?? DateTime(0);
      return bLatest.compareTo(aLatest);
    });
    storyList.assignAll(list);
  }

  bool hasViewedStory(int? userId) => userId != null && viewedStoryUserIds.contains(userId);

  bool isStoryLiked(int? storyId) =>
      storyId != null && likedStoryIds.contains(storyId);


  int initialUserPageIndex = 0;

  void setStoryPageController({int? initialPage}) {
    if (initialPage != null) initialUserPageIndex = initialPage;
    try {
      userPageController.dispose();
    } catch (_) {}
    try {
      storyPageController.dispose();
    } catch (_) {}
    userPageController = PageController(initialPage: initialUserPageIndex);
    storyPageController = PageController();
  }

  Future<void> loadStory() async
  {
    try
    {
      await  api.getStories(onSuccess: (d){
        final list = d.stories ?? [];
        // Latest first: sort each user's stories by createdAt desc, then users by their latest story
        for (final user in list) {
          final stories = user.stories;
          if (stories != null && stories.isNotEmpty) {
            stories.sort((a, b) {
              final at = a.createdAt ?? DateTime(0);
              final bt = b.createdAt ?? DateTime(0);
              return bt.compareTo(at);
            });
          }
        }
        list.sort((a, b) {
          final aLatest = a.stories?.map((s) => s.createdAt ?? DateTime(0)).fold<DateTime>(DateTime(0), (p, t) => t.isAfter(p) ? t : p) ?? DateTime(0);
          final bLatest = b.stories?.map((s) => s.createdAt ?? DateTime(0)).fold<DateTime>(DateTime(0), (p, t) => t.isAfter(p) ? t : p) ?? DateTime(0);
          return bLatest.compareTo(aLatest);
        });
        storyList.assignAll(list);
        _sortStoryListUnviewedFirst();
        final firstStoryId = list.isNotEmpty ? list.first.stories?.firstOrNull?.id ?? 0 : 0;
        if (firstStoryId > 0) {
          api.recordStoryView(
            storyId: firstStoryId,
            onError: (e) => Logger().w('Record story view error: $e'),
            onFail: (r) => Logger().w('Record story view failed: ${r.statusCode}'),
          );
        }
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

  /// Toggle like on a story (used for double‑tap like). Works locally even if
  /// backend API is not ready yet.
  void toggleLikeOnStory(int? storyId) {
    if (storyId == null || storyId <= 0) return;
    final alreadyLiked = likedStoryIds.contains(storyId);
    if (alreadyLiked) {
      likedStoryIds.remove(storyId);
    } else {
      likedStoryIds.add(storyId);
    }
    likedStoryIds.refresh();

    // Fire‑and‑forget API call – safe even if endpoint not live yet.
    api.likeStory(
      storyId: storyId,
      isLike: !alreadyLiked,
      onError: (e) => Logger().w('Story like API error: $e'),
      onFail: (resp) =>
          Logger().w('Story like API failed: ${resp.statusCode}'),
    );
  }

  void onUserChage(int userId)
  {
    markStoryUserViewed(selectedUserId.value);
    selectedUserId.value = userId;
    isLastUser.value = userId==(storyList.last.user?.id??0);
    final int userInd = storyList.indexWhere((element) => element.user?.id==selectedUserId.value,);
    isLastStory.value =  storyList[userInd].stories?.length==1;
  }

  void onStoryChange(int storyId, int userId) {
    selectedStoryId.value = storyId;
    selectedUserId.value = userId;
    if (storyId > 0) {
      api.recordStoryView(
        storyId: storyId,
        onError: (e) => Logger().w('Record story view error: $e'),
        onFail: (r) => Logger().w('Record story view failed: ${r.statusCode}'),
      );
    }
    isLastUser.value = storyList.last.user?.id==selectedUserId.value;
    final int userInd = storyList.indexWhere((element) => element.user?.id==selectedUserId.value,);
    isLastStory.value =  storyList[userInd].stories?.last.id==storyId;
    if (kDebugMode) {
      print('selectedUserId $selectedUserId');
      print('selectedStoryId $selectedStoryId');
      print('isLastUser $isLastUser');
      print('isLastStory $isLastStory');
    }
  }

  
  
  void nextStory()
  {
    if (kDebugMode) print('$selectedUserId $selectedStoryId');





    if (kDebugMode) print("${isLastStory.value} ${isLastUser.value}");
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