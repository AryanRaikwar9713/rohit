import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/donation_history_section/donation_history_controller.dart';
import 'package:streamit_laravel/screens/donation_history_section/model/donation_history_history_responce.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_screen.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/constants.dart';

class DonationHistoryListScreen extends StatelessWidget {
  const DonationHistoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DonationHistoryController controller =
        Get.isRegistered<DonationHistoryController>()
            ? Get.find<DonationHistoryController>()
            : Get.put(DonationHistoryController());

    return Scaffold(
      backgroundColor: appScreenBackgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'My Contributions',
          style: boldTextStyle(size: 18, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.donations.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: appColorPrimary),
          );
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.donations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.withOpacity(0.7),
                ),
                16.height,
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                24.height,
                ElevatedButton(
                  onPressed: () => controller.refreshDonationHistory(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColorPrimary,
                  ),
                  child: const Text('Retry',
                      style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshDonationHistory(),
          color: appColorPrimary,
          child: controller.donations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: Colors.grey.shade600,
                      ),
                      16.height,
                      Text(
                        'No donations yet',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: controller.donations.length +
                      (controller.hasMorePages.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.donations.length) {
                      // Load more indicator
                      controller.loadMoreDonations();
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: appColorPrimary,
                          ),
                        ),
                      );
                    }

                    final donation = controller.donations[index];
                    return _buildDonationCard(donation, controller);
                  },
                ),
        );
      }),
    );
  }

  // Donation Card (Full Card)
  Widget _buildDonationCard(
      Donation donation, DonationHistoryController controller,) {
    final donationDetails = donation.donationDetails;
    final projectDetails = donation.projectDetails;
    final projectOwner = donation.projectOwner;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Title and Owner
          GestureDetector(
            onTap: ()async{
              final u = await DB().getUser();
              Get.to(VammisProfileScreen(
                popButton: true,
                  userId: projectOwner?.userId??0, isOwnProfile: u?.id==projectOwner?.userId,),);
            },
            child: Row(
              children: [
                // Owner Avatar
                if (projectOwner?.avatarUrl != null &&
                    projectOwner!.avatarUrl!.isNotEmpty)
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: appColorPrimary.withOpacity(0.2),
                    backgroundImage:
                        CachedNetworkImageProvider(projectOwner.avatarUrl!),
                  )
                else
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: appColorPrimary.withOpacity(0.2),
                    child: const Icon(Icons.person, color: Colors.white70),
                  ),
                12.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (projectDetails?.title != null)
                        Text(
                          projectDetails!.title!,
                          style: boldTextStyle(size: 16, color: Colors.white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (projectOwner?.fullName != null ||
                          projectOwner?.username != null) ...[
                        4.height,
                        Text(
                          projectOwner?.fullName ?? projectOwner?.username ?? '',
                          style:
                              secondaryTextStyle(size: 12, color: Colors.white70),
                        ),
                      ],
                    ],
                  ),
                ),
                // Donation Amount
                IgnorePointer(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: appColorPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          donationDetails?.donatedBoltsDisplay ?? '0',
                          style: boldTextStyle(size: 14, color: appColorPrimary),
                        ),
                        if (donationDetails?.donatedAmountUsd != null) ...[
                          2.height,
                          Text(
                            '\$${donationDetails!.donatedAmountUsd!.toStringAsFixed(2)}',
                            style:
                                secondaryTextStyle(size: 11, color: Colors.white70),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          16.height,

          // Donation Message
          if (donationDetails?.message != null &&
              donationDetails!.message!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.message,
                      size: 16, color: Colors.white.withOpacity(0.7),),
                  8.width,
                  Expanded(
                    child: Text(
                      donationDetails.message!,
                      style:
                          secondaryTextStyle(size: 13, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
            12.height,
          ],

          // Project Progress (if available)
          if (projectDetails?.progressPercentage != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style:
                            secondaryTextStyle(size: 12, color: Colors.white70),
                      ),
                      4.height,
                      LinearProgressIndicator(
                        value: (projectDetails!.progressPercentage ?? 0) / 100,
                        backgroundColor: Colors.grey[800],
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(appColorPrimary),
                        minHeight: 6,
                      ),
                      4.height,
                      Text(
                        '${projectDetails.progressPercentage}%',
                        style:
                            secondaryTextStyle(size: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                16.width,
                if (projectDetails.daysRemaining != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${projectDetails.daysRemaining}',
                          style: boldTextStyle(size: 16, color: Colors.white),
                        ),
                        Text(
                          'Days Left',
                          style: secondaryTextStyle(
                              size: 10, color: Colors.white70,),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            0.height,
          ],
          // Donation Date and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 14, color: Colors.white.withOpacity(0.7),),
                  4.width,
                  Text(
                    controller.formatDate(donationDetails?.donatedAt),
                    style: secondaryTextStyle(size: 12, color: Colors.white70),
                  ),
                  10.width,
                  IconButton(onPressed: (){
                    Clipboard.setData(const ClipboardData(text: Constants.DUMMY_SHARE_LINK));
                    toast("Url Copied");
                  }, icon: const Icon(Icons.share),),
                ],
              ),
              if (donationDetails?.donationStatus != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(donationDetails!.donationStatus!)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    donationDetails.donationStatus!,
                    style: secondaryTextStyle(
                        size: 11,
                        color:
                            _getStatusColor(donationDetails.donationStatus!),),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
