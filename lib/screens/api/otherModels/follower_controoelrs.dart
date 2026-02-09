import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:streamit_laravel/screens/api/followers_PI.dart';
import 'package:streamit_laravel/screens/api/otherModels/follower_responce_model.dart';
import 'package:streamit_laravel/screens/social/social_api.dart';


class FollowerController extends GetxController
{



  RxList<FollwerOrFlollowingUser> followersList = RxList<FollwerOrFlollowingUser>([]);
  RxList<FollwerOrFlollowingUser> followingList = RxList<FollwerOrFlollowingUser>([]);

  RxList<int> selectedUsers = RxList<int>([]);

  RxBool hasMoreFollowing = false.obs;
  RxBool hasMoreFollowers = false.obs;

  RxInt followingPage = 1.obs;
  RxInt followersPage = 1.obs;

  final api = FollowersApi();

  RxBool loading = true.obs;

  Future<void> initData() async
  {
    await getFollowers();
    await getFollowings();
    loading.value = false;
  }


  void followOrUnfollow(int userId)
  {
    SocialApi().followUser(
        targetUserId: userId, onError: (e){}, onFailure: (d){}, onSuccess: (d){
          _updateFolloser(userId, d);
    },);
  }

  Future<void> _updateFolloser(int userId,bool isFollowing) async
  {
    for (final element in followingList) {
      if(element.id==userId)
        {
          element.isFollowing = isFollowing;
        }
    }


    for (final element in followersList) {
      if(element.id==userId)
      {
        element.isFollowing = isFollowing;
      }
    }

    followersList.refresh();
    followingList.refresh();
  }




  Future<void> getFollowers() async
  {
   try
   {
    await  api.getFollowersApi(onError: (d){
      Logger().e("Error in api $d");
    }, onSuccess: (d){

      if(followersPage.value==1)
        {
          followersList.value = d.data?.followers??[];
        }
      else
        {
          followersList.addAll(d.data?.followers??[]);
        }
      hasMoreFollowers.value = d.meta?.pagination?.hasNextPage??false;
    }, onFail: (d){
      Logger().e('failed to get folowes \n${d.statusCode}\n${d.body}');

    },);
   }
   catch(e)
    {
      Logger().e("Error in function");
    }
  }

  Future<void> getMoreFollowers() async
  {
    followersPage.value++;
     await getFollowers();
  }

  Future<void> refrashFollowers() async
  {
    followersPage.value ==1;
     await getFollowers();
  }

  Future<void> getFollowings() async
  {
    try
        {
          await api.getFollowingsApi(onError: (e){
            Logger().e("Errro in APi $e");
          }, onSuccess: (d){
            if(followingPage.value==1)
              {
                followingList.value = d.data?.following??[];
              }
            else
              {
                followingList.addAll(d.data?.following??[]);
              }
            hasMoreFollowing.value = d.meta?.pagination?.hasNextPage??false;
          }, onFail: (e){
            Logger().e("Faild To get\n${e.statusCode} \n${e.body}");
          },);
        }
        catch (e)
    {
      Logger().e("Error in Function $e");
    }
  }

  Future<void> getMoreFollowings() async
  {
    followingPage.value++;
     await getFollowings();
  }

  Future<void> refrashFollowings() async
  {
    followingPage.value ==1;
     await getFollowings();
  }


  void selectUser(int userid)
  {
    print("User $userid");
    if(selectedUsers.contains(userid))
      {
        print("user id select removing");
        selectedUsers.removeWhere((element) => element==userid,);
      }
    else
      {
        print("user id select adding");
        selectedUsers.add(userid);
      }
    selectedUsers.refresh();
  }






  void cleareData()
  {
    followersList.clear();
    followingList.clear();
    hasMoreFollowing.value = false;
    hasMoreFollowers.value = false;
    followingPage.value = 1;
    followersPage.value = 1;
    loading.value = true;
    selectedUsers.clear();
  }

}