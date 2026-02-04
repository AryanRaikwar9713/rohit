// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:nb_utils/nb_utils.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:streamit_laravel/screens/Impact-dashBoard/crate_impact_profile_screen.dart';
// import 'package:streamit_laravel/screens/Impact-dashBoard/impact_profile_controller.dart';
// import 'package:streamit_laravel/screens/Impact-dashBoard/impact_profile_screen.dart';
// import 'package:streamit_laravel/screens/donation/project_detail_screen.dart';
// import 'package:streamit_laravel/screens/donation_history_section/donation_history_controller.dart';
// import 'package:streamit_laravel/screens/donation_history_section/donation_history_screen.dart';
// import 'package:streamit_laravel/screens/donation_history_section/model/donation_history_history_responce.dart';
// import 'package:streamit_laravel/screens/wammis_search/vammis_search_controller.dart';
// import 'package:streamit_laravel/utils/mohit/campain_project_card.dart';
//
// import '../../utils/colors.dart';
// import 'donation_controller.dart';
//
// class DonationScreen extends StatefulWidget {
//   const DonationScreen({super.key});
//
//   @override
//   State<DonationScreen> createState() => _DonationScreenState();
// }
//
// class _DonationScreenState extends State<DonationScreen> {
//
//
//   int i = 0;
//
//   @override
//   Widget build(BuildContext context) {
//
//
//
//     return GetBuilder<DonationController>(
//       init: DonationController(),
//       builder: (controller) {
//         final DonationHistoryController historyController =
//             Get.isRegistered<DonationHistoryController>()
//                 ? Get.find<DonationHistoryController>()
//                 : Get.put(DonationHistoryController(), permanent: false);
//
//         final VammisSearchController searchController =
//             Get.isRegistered<VammisSearchController>()
//                 ? Get.find<VammisSearchController>()
//                 : Get.put(VammisSearchController(), permanent: false);
//
//         return Scaffold(
//           backgroundColor: Colors.grey.shade900,
//           appBar: AppBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             leading: IconButton(
//               onPressed: () => Get.back(),
//               icon: const Icon(Icons.arrow_back, color: Colors.white),
//             ),
//
//             //
//             bottom: PreferredSize(
//                 preferredSize: const Size.fromHeight(40),
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//
//                   //
//                   child: CupertinoSearchTextField(
//                     controller: searchController.searchController.value,
//                     style: const TextStyle(color: Colors.white),
//                     onChanged: (value) {
//                       if (value.isEmpty) {
//                         searchController.searching.value = false;
//                       }
//                       searchController.getSearch();
//                     },
//                     placeholder: 'Search',
//                     placeholderStyle: const TextStyle(color: Colors.white),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     prefixIcon: const Icon(
//                       Icons.search,
//                       color: Colors.white,
//                     ),
//                   ),
//                 )),
//
//             //
//             title: Text(
//               'Donations',
//               style: boldTextStyle(size: 18, color: Colors.white),
//             ),
//             centerTitle: false,
//             actions: [
//               SizedBox(
//                 height: 30,
//                 child: OutlinedButton(
//                   style: const ButtonStyle(
//                     side: WidgetStatePropertyAll(
//                       BorderSide(
//                         color: appColorPrimary,
//                         width: 1,
//                       ),
//                     ),
//                     shape: WidgetStatePropertyAll(RoundedRectangleBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(5)),
//                     )),
//                     foregroundColor: WidgetStatePropertyAll(appColorPrimary),
//                   ),
//                   onPressed: () async {
//                     toast('Comming Soon');
//                   },
//                   child: const Text(
//                     "Watch & Earn",
//                   ),
//                 ),
//               ),
//               IconButton(
//                 onPressed: () async {
//                   final impactController =
//                       Get.isRegistered<ImpactProfileController>()
//                           ? Get.find<ImpactProfileController>()
//                           : Get.put(ImpactProfileController());
//
//                   // Show loading
//                   Get.dialog(
//                     const Center(
//                       child: CircularProgressIndicator(
//                         color: appColorPrimary,
//                       ),
//                     ),
//                     barrierDismissible: false,
//                   );
//
//                   // Check account
//                   await impactController.checkImpactAccount();
//
//                   // Close loading
//                   Get.back();
//
//                   // Navigate based on account status
//                   if (impactController
//                           .profileResponse.value?.data?.hasAccount ==
//                       true) {
//                     Get.to(() => const ImpactProfileScreen());
//                   } else {
//                     Get.to(() => const CrateImpactProfileScreen());
//                   }
//                 },
//                 icon: const Icon(Icons.person, color: Colors.white),
//               ),
//             ],
//           ),
//           body: SafeArea(
//             child: Stack(
//               children: [
//                 //Screen
//                 Obx(() {
//                   if (controller.loading.value) {
//                     return const Center(
//                       child: CircleAvatar(),
//                     );
//                   }
//
//                   if (controller.projectList.isEmpty) {
//                     return const Center(
//                       child: Text(
//                         'No Data',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w700,
//                             fontSize: 20),
//                       ),
//                     );
//                   }
//
//                   return RefreshIndicator(
//                     onRefresh: () async {
//                       await controller.getProjectlist(refresh: true);
//                       await historyController.loadDonationHistory(
//                           refresh: true);
//                     },
//                     child: ListView.builder(
//                       itemCount: controller.projectList.length +
//                           1, // +1 for recent transactions
//                       itemBuilder: (context, index) {
//                         if (index == 0) {
//                           // Recent Transactions Section
//                           return _buildRecentTransactionsSection(
//                               historyController);
//                         } else {
//                           final projectIndex = index - 1;
//                           final project = controller.projectList[projectIndex];
//                           return CampaignProjectCard(
//                             project: project,
//                           );
//                         }
//                       },
//                     ),
//                   );
//                 }),
//
//                 Obx(() {
//                   return AnimatedSwitcher(
//                     duration: const Duration(milliseconds: 300),
//
//                     //
//                     transitionBuilder: (child, Animation<double> animation) =>
//                         FadeTransition(
//                       opacity: animation,
//                       child: SlideTransition(
//                         position: animation.drive(Tween<Offset>(
//                           begin: const Offset(0, -.1),
//                           end: Offset.zero,
//                         ).chain(CurveTween(curve: Curves.easeInOut))),
//                         child: child,
//                       ),
//                     ),
//                     child: searchController.searching.value
//                         ? searchController.searchView()
//                         : const SizedBox(key: ValueKey('empty')),
//                   );
//                 }),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildHeader(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             IconButton(
//               onPressed: () => Get.back(),
//               icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//             ),
//             Text(
//               'Support Our Mission',
//               style: boldTextStyle(size: 24, color: Colors.white),
//             ).expand(),
//             // Share button
//             IconButton(
//               onPressed: () {
//                 // Add share functionality
//                 toast('Share this campaign');
//               },
//               icon: const Icon(Icons.share, color: Colors.white),
//             ),
//           ],
//         ),
//         16.height,
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 appColorPrimary.withOpacity(0.8),
//                 appColorPrimary.withOpacity(0.6),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Icon(
//                       Icons.favorite,
//                       color: Colors.white,
//                       size: 28,
//                     ),
//                   ),
//                   16.width,
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Help Us Grow',
//                           style: boldTextStyle(size: 28, color: Colors.white),
//                         ),
//                         8.height,
//                         Text(
//                           'Your support helps us create amazing content and improve our platform for everyone.',
//                           style: secondaryTextStyle(
//                               size: 16, color: Colors.white70),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildProgressSection(DonationController controller) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.grey[900],
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey[700]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: appColorPrimary.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Icon(
//                       Icons.trending_up,
//                       color: appColorPrimary,
//                       size: 20,
//                     ),
//                   ),
//                   12.width,
//                   Text(
//                     'Fundraising Progress',
//                     style: boldTextStyle(size: 18, color: Colors.white),
//                   ),
//                 ],
//               ),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: appColorPrimary.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   'controller.raisedAmount%',
//                   style: boldTextStyle(size: 18, color: appColorPrimary),
//                 ),
//               ),
//             ],
//           ),
//           16.height,
//           LinearProgressIndicator(
//             value: 100,
//             backgroundColor: Colors.grey[700],
//             valueColor: AlwaysStoppedAnimation<Color>(appColorPrimary),
//             minHeight: 12,
//             borderRadius: BorderRadius.circular(6),
//           ),
//           16.height,
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.attach_money,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                   8.width,
//                   Text(
//                     '\${controller.currentRaised.value.toStringAsFixed(0)} raised',
//                     style: boldTextStyle(size: 16, color: Colors.white),
//                   ),
//                 ],
//               ),
//               Text(
//                 'of \${controller.targetAmount.value.toStringAsFixed(0)} goal',
//                 style: secondaryTextStyle(size: 14, color: Colors.grey),
//               ),
//             ],
//           ),
//           12.height,
//           Row(
//             children: [
//               const Icon(
//                 Icons.people,
//                 color: Colors.grey,
//                 size: 18,
//               ),
//               8.width,
//               Text(
//                 '{controller.donorCount.value} donors',
//                 style: secondaryTextStyle(size: 14, color: Colors.grey),
//               ),
//               16.width,
//               const Icon(
//                 Icons.schedule,
//                 color: Colors.grey,
//                 size: 18,
//               ),
//               8.width,
//               Text(
//                 '30 days left',
//                 style: secondaryTextStyle(size: 14, color: Colors.grey),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDonationAmountSection(DonationController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Choose Amount',
//           style: boldTextStyle(size: 18, color: Colors.white),
//         ),
//         16.height,
//
//         Text("Commented"),
//         // Obx(() => Wrap(
//         //       spacing: 12,
//         //       runSpacing: 12,
//         //       children: controller.presetAmounts.map((amount) {
//         //         final isSelected = controller.selectedAmount.value == amount;
//         //         return GestureDetector(
//         //           onTap: () => controller.selectAmount(amount),
//         //           child: Container(
//         //             padding: const EdgeInsets.symmetric(
//         //                 horizontal: 20, vertical: 12),
//         //             decoration: BoxDecoration(
//         //               color: isSelected ? appColorPrimary : Colors.grey[900],
//         //               borderRadius: BorderRadius.circular(25),
//         //               border: Border.all(
//         //                 color: isSelected ? appColorPrimary : Colors.grey[700]!,
//         //               ),
//         //             ),
//         //             child: Text(
//         //               '\$${amount.toStringAsFixed(0)}',
//         //               style: boldTextStyle(
//         //                 size: 16,
//         //                 color: isSelected ? Colors.white : Colors.white,
//         //               ),
//         //             ),
//         //           ),
//         //         );
//         //       }).toList(),
//         //     )
//         // ),
//         16.height,
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.grey[900],
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey[700]!),
//           ),
//           child: TextField(
//             // controller: controller.customAmountController,
//             keyboardType: TextInputType.number,
//             style: primaryTextStyle(size: 16, color: Colors.white),
//             decoration: InputDecoration(
//               hintText: 'Enter custom amount',
//               hintStyle: secondaryTextStyle(size: 16, color: Colors.grey),
//               border: InputBorder.none,
//               prefixText: '\$ ',
//               prefixStyle: primaryTextStyle(size: 16, color: Colors.white),
//             ),
//             onChanged: (value) {
//               if (value.isNotEmpty) {
//                 // controller.selectAmount(double.tryParse(value) ?? 0);
//               }
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDonationOptions(DonationController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Donation Options',
//           style: boldTextStyle(size: 18, color: Colors.white),
//         ),
//         16.height,
//         Obx(() => Column(
//               children: [
//                 _buildOptionTile(
//                   icon: Icons.favorite,
//                   title: 'One-time Donation',
//                   subtitle: 'Make a single contribution',
//                   isSelected: true,
//                   onTap: () {},
//                 ),
//                 12.height,
//                 _buildOptionTile(
//                   icon: Icons.repeat,
//                   title: 'Monthly Donation',
//                   subtitle: 'Support us every month',
//                   isSelected: true,
//                   onTap: () {},
//                 ),
//                 12.height,
//                 _buildOptionTile(
//                   icon: Icons.celebration,
//                   title: 'Special Occasion',
//                   subtitle: 'Celebrate with us',
//                   isSelected: true,
//                   onTap: () {},
//                 ),
//               ],
//             )),
//       ],
//     );
//   }
//
//   Widget _buildOptionTile({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color:
//               isSelected ? appColorPrimary.withOpacity(0.1) : Colors.grey[900],
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? appColorPrimary : Colors.grey[700]!,
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               color: isSelected ? appColorPrimary : Colors.grey,
//               size: 24,
//             ),
//             16.width,
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: boldTextStyle(
//                       size: 16,
//                       color: isSelected ? appColorPrimary : Colors.white,
//                     ),
//                   ),
//                   4.height,
//                   Text(
//                     subtitle,
//                     style: secondaryTextStyle(size: 14, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//             if (isSelected)
//               Icon(
//                 Icons.check_circle,
//                 color: appColorPrimary,
//                 size: 20,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Recent Transactions Section
//   Widget _buildRecentTransactionsSection(
//       DonationHistoryController historyController) {
//     return Obx(() {
//       // Load history if not loaded
//       if (historyController.donations.isEmpty &&
//           !historyController.isLoading.value) {
//         historyController.loadDonationHistory();
//       }
//
//       final recentDonations = historyController.donations.take(3).toList();
//
//       if (recentDonations.isEmpty && historyController.isLoading.value) {
//         return Container(
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           padding: const EdgeInsets.all(16),
//           child: const Center(
//             child: CircularProgressIndicator(color: appColorPrimary),
//           ),
//         );
//       }
//
//       if (recentDonations.isEmpty) {
//         return const SizedBox.shrink();
//       }
//
//       return Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.grey[900],
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey[800]!),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8),
//               child: Text(
//                 'Recent Transactions',
//                 style: boldTextStyle(size: 16, color: Colors.white),
//               ),
//             ),
//             ...recentDonations.map((donation) => _buildRecentTransactionCard(
//                   donation,
//                   historyController,
//                 )),
//           ],
//         ),
//       );
//     });
//   }
//
//   // Recent Transaction Card
//   Widget _buildRecentTransactionCard(
//       Donation donation, DonationHistoryController historyController) {
//     final donationDetails = donation.donationDetails;
//     final projectDetails = donation.projectDetails;
//
//     final projectImage = null; // Placeholder for now
//
//     String amountText = '';
//     if (donationDetails?.donatedAmountUsd != null) {
//       amountText = '\$${donationDetails!.donatedAmountUsd!.toStringAsFixed(2)}';
//     } else {
//       amountText = donationDetails?.donatedBoltsDisplay ?? '0 Bolts';
//     }
//
//     return GestureDetector(
//       onTap: () {
//         Get.to(() => const DonationHistoryScreen());
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//         decoration: BoxDecoration(
//           color: Colors.grey[800]!.withOpacity(0.5),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           children: [
//             // Project Logo/Image
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//                 color: Colors.grey[700],
//               ),
//               child: projectImage != null && projectImage.isNotEmpty
//                   ? ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: CachedNetworkImage(
//                         imageUrl: projectImage,
//                         fit: BoxFit.cover,
//                         placeholder: (context, url) => Container(
//                           color: Colors.grey[700],
//                           child: const Center(
//                             child: CircularProgressIndicator(
//                               color: appColorPrimary,
//                               strokeWidth: 2,
//                             ),
//                           ),
//                         ),
//                         errorWidget: (context, url, error) => Container(
//                           color: Colors.grey[700],
//                           child: const Icon(
//                             Icons.image_not_supported,
//                             color: Colors.grey,
//                             size: 20,
//                           ),
//                         ),
//                       ),
//                     )
//                   : Image.asset("assets/launcher_icons/image_placeHolder.png"),
//             ),
//             12.width,
//             // Project Name
//             Expanded(
//               child: Text(
//                 projectDetails?.title ?? 'Unknown Project',
//                 style: primaryTextStyle(size: 14, color: Colors.white),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             8.width,
//             // Amount
//             Text(
//               amountText,
//               style: boldTextStyle(size: 14, color: appColorPrimary),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatItem(String value, String label, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, color: appColorPrimary, size: 20),
//           6.height,
//           Text(
//             value,
//             style: boldTextStyle(size: 14, color: Colors.white),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           2.height,
//           Text(
//             label,
//             style: secondaryTextStyle(size: 10, color: Colors.white70),
//             textAlign: TextAlign.center,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/model/campain_cat_responce_model.dart';
import 'package:streamit_laravel/screens/donation/donation_controller.dart';
import 'package:streamit_laravel/screens/donation/model/get_project_list_responce_model.dart';
import 'package:streamit_laravel/screens/donation/project_detail_screen.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/impact_profile_screen.dart';
import 'package:streamit_laravel/utils/colors.dart';

class ImpactDashboardScreen extends StatelessWidget {
  const ImpactDashboardScreen({super.key});

  static const LinearGradient appGradient = LinearGradient(
    colors: [
      Color(0xFFFFF176), // yellow.shade400
      Color(0xFFFF9800), // orange.shade500
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already registered
    final DonationController controller = Get.isRegistered<DonationController>()
        ? Get.find<DonationController>()
        : Get.put(DonationController());
    
    return Scaffold(
          backgroundColor: const Color(0xFF0D0D0F),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header – Impact Dashboard title + icon to go to My Impact (create/manage)
                  Row(
                    children: [
                      _gradientIcon(Icons.favorite, 34),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Impact Dashboard',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Get.to(() => const ImpactProfileScreen()),
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: ShaderMask(
                              shaderCallback: (bounds) => appGradient.createShader(bounds),
                              child: const Icon(
                                Icons.dashboard_customize,
                                size: 28,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Make a positive impact by supporting important projects.',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  const SizedBox(height: 10),
                  // Filters: Near Me + Worldwide (static), Category from API, Urgency (static)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                    child: Obx(() {
                      if (controller.categoriesLoading.value) {
                        return const SizedBox(
                          height: 36,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF9800)),
                            ),
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const FilterChipWidget(icon: Icons.public, text: 'Near Me + Worldwide'),
                            const SizedBox(width: 8),
                            // All categories chip
                            FilterChipWidget(
                              icon: Icons.category,
                              text: 'All',
                              isSelected: controller.selectedCategoryId.value == null,
                              onTap: () => controller.setSelectedCategoryId(null),
                            ),
                            ...controller.categories.map((Datum cat) {
                              final isSelected = controller.selectedCategoryId.value == cat.id;
                              return Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: FilterChipWidget(
                                  icon: Icons.category,
                                  text: cat.name ?? 'Category',
                                  isSelected: isSelected,
                                  onTap: () => controller.setSelectedCategoryId(cat.id),
                                ),
                              );
                            }),
                            const SizedBox(width: 8),
                            const FilterChipWidget(icon: Icons.local_fire_department, text: 'Urgency'),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 0),
                  // API se content - loading / empty / list
                  Expanded(
                    child: Obx(() {
                      if (controller.loading.value) {
                        return const Center(
                          child: CircularProgressIndicator(color: appColorPrimary),
                        );
                      }
                      final list = controller.filteredProjectList;
                      if (list.isEmpty) {
                        return const Center(
                          child: Text(
                            'No Data',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          await controller.getProjectlist(refresh: true);
                        },
                        color: appColorPrimary,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 10, bottom: 20),
                          itemCount: list.length + (controller.hasMorePages.value ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Load more indicator at the end
                            if (index == list.length) {
                              if (controller.isLoadingMore.value) {
                                return const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Center(
                                    child: CircularProgressIndicator(color: appColorPrimary),
                                  ),
                                );
                              }
                              // Trigger load more when near end
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                controller.loadMoreProjects();
                              });
                              return const SizedBox.shrink();
                            }
                            
                            final project = list[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _donationCard(project),
                                if (index < list.length - 1) _divider(),
                              ],
                            );
                          },
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        );
  }

  static Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Divider(
        color: Colors.grey.withOpacity(0.19),
        thickness: 1,
      ),
    );
  }

  static Widget _donationCard(Project project) {
    final imageUrl = project.projectImages != null && project.projectImages!.isNotEmpty
        ? project.projectImages!.first
        : 'https://images.unsplash.com/photo-1546182990-dffeafbe841d';
    final raised = project.fundingRaised ?? 0.0;
    final goal = project.fundingGoal ?? 0.0;
    final percent = ((project.fundingPercentage ?? 0) / 100).clamp(0.0, 1.0);
    final donorsCount = project.donorsCount ?? 0;
    final daysRemaining = project.daysRemaining ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Get.to(() => ProjectDetailScreen(id: project.id ?? 0));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 110,
                height: 130,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                width: 110,
                height: 130,
                color: Colors.grey.shade800,
                child: const Center(
                  child: CircularProgressIndicator(color: appColorPrimary, strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 110,
                height: 130,
                color: Colors.grey.shade800,
                child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 32),
              ),
            ),
          ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  project.title ?? 'Untitled Project',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Funding info - GoFundMe style
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => appGradient.createShader(bounds),
                            child: Text(
                              '\$${raised.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'raised of \$${goal.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: appGradient.colors.first.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(percent * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: appGradient.colors.first,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 8,
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return appGradient.createShader(bounds);
                      },
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Stats row
                Row(
                  children: [
                    Icon(Icons.people, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      '$donorsCount donors',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      daysRemaining > 0 ? '$daysRemaining days left' : 'Ended',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      Get.to(() => ProjectDetailScreen(id: project.id ?? 0));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: appGradient,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite, color: Colors.black, size: 18),
                          SizedBox(width: 2),
                          Text(
                            'Donate',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _gradientIcon(IconData icon, double size) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return appGradient.createShader(bounds);
      },
      child: Icon(icon, size: size, color: Colors.white),
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;

  const FilterChipWidget({
    super.key,
    required this.icon,
    required this.text,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected
            ? ImpactDashboardScreen.appGradient.colors.first.withOpacity(0.25)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: isSelected
            ? Border.all(color: ImpactDashboardScreen.appGradient.colors.first)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) {
              return ImpactDashboardScreen.appGradient.createShader(bounds);
            },
            child: Icon(icon, size: 19, color: Colors.white),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: chip,
      );
    }
    return chip;
  }
}
