import 'package:flutter/material.dart';
import 'package:streamit_laravel/screens/api/otherModels/follower_controoelrs.dart';
import 'package:get/get.dart';
import 'package:streamit_laravel/screens/api/otherModels/follower_responce_model.dart';

class DrawerSubFollowers extends StatefulWidget {
  const DrawerSubFollowers({super.key});

  @override
  State<DrawerSubFollowers> createState() => _DrawerSubFollowersState();
}

class _DrawerSubFollowersState extends State<DrawerSubFollowers> {
  late FollowerController _followerController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myInit();
  }

  myInit() {
    _followerController = Get.put(FollowerController());
    _followerController.initData();
  }

  @override
  void dispose() {
    _followerController.cleareData();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        //
        appBar: AppBar(
          bottom: const TabBar(
              indicatorPadding: EdgeInsetsGeometry.symmetric(horizontal: 10),
              tabs: [
                Tab(
                  text: 'Followers',
                ),
                Tab(
                  text: 'Following',
                ),
              ]),
        ),

        //
        body: Obx(
          () {
            if (_followerController.loading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return TabBarView(
              children: [
                _buildFollowers(),
                _buildFollowings(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFollowers() {
    //
    if (_followerController.followersList.isEmpty) {
      return const Center(
        child: Text(
          "No Followers",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    //
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: _followerController.followersList.length,
      itemBuilder: (context, index) {
        final data = _followerController.followersList[index];
        return _buildTile(data);
      },
    );
  }

  Widget _buildFollowings() {
    //
    if (_followerController.followingList.isEmpty) {
      return const Center(
        child: Text(
          "No Followers",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    //
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: _followerController.followingList.length,
      itemBuilder: (context, index) {
        final data = _followerController.followingList[index];
        return _buildTile(data);
      },
    );
  }

  Widget _buildTile(FollwerOrFlollowingUser data) {

    //
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          shape: BoxShape.circle,
        ),
        child: Image.network(data.avatar??"",
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person,color: Colors.white,);
        },),
      ),

      //
      horizontalTitleGap: 8,

      //
      title: Text('${data.firstName} ${data.lastName ?? ""}'),
      titleTextStyle: const TextStyle(color: Colors.white),
      subtitleTextStyle: const TextStyle(color: Colors.white),
      trailing: SizedBox(
        height: 30,
        child: ElevatedButton(
            onPressed: () {
              _followerController.followOrUnfollow(data.id??0);
            },
            child:
                Text((data.isFollowing ?? false) ? 'Connect' : 'Disconnect')),
      ),
    );
  }
}
