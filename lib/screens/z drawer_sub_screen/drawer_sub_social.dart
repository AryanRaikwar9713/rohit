import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/social/create_post_screen.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_controller.dart';

class DrawerSubSocial extends StatefulWidget {
  const DrawerSubSocial({super.key});

  @override
  State<DrawerSubSocial> createState() => _DrawerSubSocialState();
}

class _DrawerSubSocialState extends State<DrawerSubSocial> {
  late VammisProfileController profileController;
  late int userId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myInit();
  }

  Future<void> myInit() async {
    profileController = Get.put(VammisProfileController());
    final user = await DB().getUser();
    userId = user?.id ?? 0;
    profileController.loadUserPosts(
      userId,
      refresh: true,
    );

    addScrollListener();

  }

  void addScrollListener()
  {
    _scrollController.addListener(() {
      print("ssdfa");
      if(_scrollController.position.pixels==_scrollController.position.maxScrollExtent)
      {
        profileController.loadMorePost();
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //
      appBar: AppBar(
        title: const Text("Posts"),
      ),

      body: Obx(() {

        if (profileController.isLoadingPosts.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (profileController.userPosts.isEmpty) {
          return Center(
            child: ElevatedButton(
                onPressed: () {
                  Get.to(const CreatePostScreen());
                },
                child: const Text("Upload Post"),),
          );
        }
        return RefreshIndicator(
            child: GridView.builder(
              padding: const EdgeInsetsGeometry.symmetric(horizontal: 5),
              controller: _scrollController,
                gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,
                mainAxisSpacing: 5,crossAxisSpacing: 5,
                mainAxisExtent: MediaQuery.of(context).size.height*.25,),
              itemBuilder: (context, index) {
                  final post = profileController.userPosts[index];

                return Container(
                  color: Colors.red,
                );
              },
              itemCount: profileController.userPosts.length,
            ),
            onRefresh: () async {
              profileController.loadUserPosts(userId, refresh: true);
            },);
      }),
    );
  }
}
