import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/app_logo_widget.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/dashboard/dashboard_controller.dart';
// TODO: Keep imports for future release - Shop feature
// ignore: unused_import
import 'package:streamit_laravel/screens/shops_section/shop_controller.dart';
// ignore: unused_import
import 'package:streamit_laravel/screens/shops_section/shop_profile_screen.dart';
// ignore: unused_import
import 'package:streamit_laravel/screens/shops_section/shop_registration_screen.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_controller.dart';
import 'package:streamit_laravel/screens/video_channel/screens/create_channel_screen.dart';
import 'package:streamit_laravel/screens/video_channel/screens/video_channel_screen.dart';
import 'package:streamit_laravel/screens/video_channel/video_channle_controller.dart';
import 'package:streamit_laravel/screens/z%20drawer_sub_screen/drawer_sub_followers.dart';
import 'package:streamit_laravel/screens/z%20drawer_sub_screen/drawer_sub_project_screen.dart';
import 'package:streamit_laravel/screens/z%20drawer_sub_screen/drawer_sub_reels.dart';
import 'package:streamit_laravel/screens/z%20drawer_sub_screen/drawer_sub_social.dart';
import 'package:streamit_laravel/screens/z%20drawer_sub_screen/notice_board_screen.dart';

class DashBoardDrawer extends StatefulWidget {
  const DashBoardDrawer({super.key});

  @override
  State<DashBoardDrawer> createState() => _DashBoardDrawerState();
}

class _DashBoardDrawerState extends State<DashBoardDrawer> {
  late DashboardController dashboardController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dashboardController = Get.find<DashboardController>();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        clipBehavior: Clip.hardEdge,
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  // stops: [.1,.9],

                  begin: AlignmentGeometry.topCenter,
                  end: AlignmentGeometry.bottomCenter,
                  colors: [
                Colors.grey.shade900,
                Colors.blueGrey.shade900,
              ])),
          child: Column(
            children: [
              50.height, const AppMinLogoWidget(),

              20.height,

              //Clip
              _buildTileItem(
                  icon: Image.asset(
                    'assets/launcher_icons/streamLogo.png',
                    width: 30,
                    color: Colors.white,
                  ),
                  title: "Clips",
                  onTap: () async {
                    final VideoChannelController c =
                        Get.put(VideoChannelController());
                    showDialog(
                        context: context,
                        builder: (context) => WillPopScope(
                            onWillPop: () async {
                              return false;
                            },
                            child: const Center(
                              child: CircularProgressIndicator(),
                            )),
                        barrierDismissible: false);
                    await c.getChannel();
                    Navigator.pop(context);

                    // Check if channel exists - if yes show profile, if no show create screen
                    if (c.hasChannel.value) {
                      Get.to(VideoChannelScreen());
                    } else {
                      Get.to(CreateVideoChannelScreen());
                    }
                  }),

              //Reels
              _buildTileItem(
                  icon: const Icon(
                    FontAwesomeIcons.video,
                    color: Colors.white,
                  ),
                  title: "Reels",
                  onTap: () {
                    Get.to(const DrawerSubReels());
                  }),

              //Reels
              _buildTileItem(
                  icon: const Icon(
                    FontAwesomeIcons.images,
                    color: Colors.white,
                  ),
                  title: "Posts",
                  onTap: () {
                    Get.to(const DrawerSubSocial());
                  }),

              _buildTileItem(
                  icon: const Icon(
                    Icons.event,
                    color: Colors.white,
                  ),
                  title: "Impact",
                  onTap: () async {
                    var controller = Get.put(VammisProfileController());
                    var user = await DB().getUser();
                    controller.loadUserProfile(user?.id ?? 0);
                    Get.to(const DrawerSubProjectScreen());
                    // Get.to(const );
                  }),

              // TODO: Shop - Hidden for current version, will be released in future
              // Keep all logic intact, just hide from drawer
              // if (dashboardController.isShopEnabled.value) ...[
              //   //
              //   _buildTileItem(
              //       icon: const Icon(
              //         Icons.shopping_bag,
              //         color: Colors.white,
              //       ),
              //       title: "Shop",
              //       onTap: () async {
              //         var shopController = Get.put(ShopController());
              //         await shopController.loadShopProfile();
              //         if (shopController.hasShop.value) {
              //           Get.to(() => const ShopProfileScreen());
              //         } else {
              //           Get.to(() => const ShopRegistrationScreen());
              //         }
              //       }),

              //   //
              // ],

              //
              _buildTileItem(
                  icon: const Icon(
                    Icons.people_rounded,
                    color: Colors.white,
                  ),
                  title: "My Followers",
                  onTap: () {
                    Get.to(const DrawerSubFollowers());
                  }),

              //
              _buildTileItem(
                  icon: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                  ),
                  title: "Notice Board",
                  onTap: () {
                    Get.to(const NoticeBoardScreen());
                  }),

              //
              _buildTileItem(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  title: "LogOut",
                  onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }

  _buildTileItem({
    required String title,
    Widget? icon,
    required Function()? onTap,
  }) {
    return ListTile(
      leading: icon,
      title: Text(title),
      titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 2.5),
      onTap: onTap,
    );
  }
}
