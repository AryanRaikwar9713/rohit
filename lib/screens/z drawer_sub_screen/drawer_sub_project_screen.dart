import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_controller.dart';
import 'package:streamit_laravel/utils/mohit/campain_project_card.dart';


class DrawerSubProjectScreen extends StatefulWidget {
  const DrawerSubProjectScreen({super.key});

  @override
  State<DrawerSubProjectScreen> createState() => _DrawerSubProjectScreenState();
}

class _DrawerSubProjectScreenState extends State<DrawerSubProjectScreen> {

  late VammisProfileController controller;
  late int userId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myInit();
  }

  Future<void> myInit() async
  {
    controller = Get.put(VammisProfileController());
    final user = await DB().getUser();
    userId = user?.id??0;
    controller.loadUserProjects(userId);
  }

  void addScrollListner()
  {
    _scrollController.addListener((){
      if(_scrollController.position.pixels==_scrollController.position.maxScrollExtent)
        {
          controller.loadMoreProjects();
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      //
      appBar: AppBar(
        title: const Text("Projects"),
      ),

      //
      body: Obx(() {

        if(controller.isLoadingProjects.value)
        {
          return const Center(child: CircularProgressIndicator());
        }
        if(controller.userProjects.isEmpty)
        {
          return const Center(child: Text("No Projects",style: TextStyle(color: Colors.white,fontSize: 18),));
        }
        return ListView.builder(
          itemCount: controller.userProjects.length,
          itemBuilder: (context, index) {
            final p = controller.userProjects[index];
            return CampaignProjectCard(project: p);
          },
        );
      },),
    );
  }
}
