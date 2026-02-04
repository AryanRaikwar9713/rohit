import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/crate_impact_profile_screen.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/impact_profile_controller.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/impact_profile_screen.dart';
import 'package:streamit_laravel/screens/dashboard/dashboard_controller.dart';
import 'package:streamit_laravel/screens/reels/upload_reel_screen.dart';
// TODO: Keep imports for future release - Shop feature
// ignore: unused_import
import 'package:streamit_laravel/screens/shops_section/shop_controller.dart';
// ignore: unused_import
import 'package:streamit_laravel/screens/shops_section/shop_profile_screen.dart';
// ignore: unused_import
import 'package:streamit_laravel/screens/shops_section/shop_registration_screen.dart';
// ignore: unused_import
import 'package:streamit_laravel/screens/shops_section/shop_screen.dart';
import 'package:streamit_laravel/screens/social/create_post_screen.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/edit_vammis_profile_screen.dart';
import 'package:get/get.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/user_post_view_screen.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/user_reel_screen.dart';
import 'package:streamit_laravel/screens/walletSection/wallet_tab_manage.dart';
import 'package:streamit_laravel/screens/wamims_setting_screen/add_social_media.dart';
import 'package:streamit_laravel/utils/colors.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late DashboardController dashboardController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    dashboardController = (Get.isRegistered<DashboardController>())
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //
      appBar: AppBar(
        titleTextStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18,),
        title: const Text("Settings"),
      ),

      //
      body: ListView(
        children: [
          //
          _buildTile(
            title: "Edit Profile",
            icon: const Icon(Icons.person_2_outlined),
            onTap: () {
              Get.to(() => const EditVammisProfileScreen());
            },
          ),

          //
          // TODO: Shop Dashboard - Hidden for current version, will be released in future
          // Keep all logic intact, just hide from settings
          // Obx(() {
          //   if (dashboardController.isShopEnabled.value) {
          //     return _buildTile(
          //         title: "Shop Dashboard",
          //         icon: Image.asset('assets/icons/settign/store.png',width: 20,color: Colors.white,),
          //         onTap: () {
          //           var shopController = (Get.isRegistered<ShopController>())
          //               ? Get.find<ShopController>()
          //               : Get.put(ShopController());
          //           if (shopController.hasShop.value) {
          //             Get.to(() => ShopProfileScreen());
          //           } else {
          //             Get.to(() => ShopRegistrationScreen());
          //           }
          //         });
          //   } else {
          //     return SizedBox();
          //   }
          // }),

          //
          _buildTile(
              title: "Campaign DashBoard",
              icon: Image.asset("assets/icons/settign/campain.png",width: 20,color: Colors.white,),
              onTap: () async {
                final impactController =
                    Get.isRegistered<ImpactProfileController>()
                        ? Get.find<ImpactProfileController>()
                        : Get.put(ImpactProfileController());

                // Show loading
                Get.dialog(
                  const Center(
                    child: CircularProgressIndicator(
                      color: appColorPrimary,
                    ),
                  ),
                  barrierDismissible: false,
                );

                // Check account
                await impactController.checkImpactAccount();

                // Close loading
                Get.back();

                // Navigate based on account status
                if (impactController.profileResponse.value?.data?.hasAccount ==
                    true) {
                  Get.to(() => const ImpactProfileScreen());
                } else {
                  Get.to(() => const CrateImpactProfileScreen());
                }
              },),

          //
          _buildTile(
            title: 'My Post',
            icon: const Icon(Icons.image),
            onTap: () {
              Get.to(() => const UserPostViewScreen());
            },
          ),

          //
          _buildTile(
            title: 'My Reel',
            icon: Image.asset('assets/icons/settign/reel.png',height: 25,color: Colors.white,),
            onTap: () {
              Get.to(() => const UserReelScreen(reelId: 0));
            },
          ),

          _buildTile(
            title: 'My Campaign',
            icon: const Icon(Icons.event_outlined),
            onTap: () {
              // Get.to(() => const UserCampaignScreen());
            },
          ),

          _buildTile(
            title: 'Wallet',
            icon: Image.asset(
              'assets/icons/social_media/wallet.png',
              color: Colors.white,
              width: 20,
            ),
            onTap: () {
              Get.to(const WalletTabManage());
            },
          ),

          // TODO: Event Participant - Hidden for current version, will be released in future
          // Keep all logic intact, just hide from settings
          // Obx(() {
          //   if (dashboardController.isShopEnabled.value) {
          //     return _buildTile(
          //         title: "Event Participant",
          //         icon: Image.asset('assets/icons/settign/participation.png',width: 25,color: Colors.white,),
          //         subtitle: 'View all the events you have participated in',
          //         onTap: () {});
          //   } else {
          //     return SizedBox();
          //   }
          // }),

          _buildTile(
              title: "Social Media",
              icon: Image.asset('assets/icons/settign/social-media.png',color: Colors.white,height: 25,),
              onTap: () {
                Get.to(const AddSocialMedia());
              },),

          _buildTile(
              title: "Block Accounts",
              icon: Image.asset('assets/icons/settign/block-user.png',color: Colors.white,height: 25,),
              onTap: () {
                toast("Coming Soon");
              },),

          _buildTile(
              title: "Archive Points",
              icon: const Icon(Icons.point_of_sale),
              onTap: () {
                toast("Coming Soon");
              },),


        ],
      ),
    );
  }

  ListTile _buildTile({
    required String title,
    required Widget icon,
    String? subtitle,
    required Function()? onTap,
  }) {
    return ListTile(
      iconColor: Colors.white,
      leading: icon,
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      subtitleTextStyle: TextStyle(
          color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w400,),
      onTap: onTap,
    );
  }
}
