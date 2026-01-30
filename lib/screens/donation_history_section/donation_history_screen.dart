import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:streamit_laravel/screens/donation_history_section/donation_history_controller.dart';
import 'package:streamit_laravel/screens/donation_history_section/model/donation_history_history_responce.dart';
import 'package:streamit_laravel/screens/donation_history_section/donation_history_list_screen.dart';
import 'package:streamit_laravel/utils/colors.dart';

class DonationHistoryScreen extends StatelessWidget {
  final bool showRecentOnly;

  const DonationHistoryScreen({Key? key, this.showRecentOnly = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DonationHistoryController controller =
        Get.put(DonationHistoryController());

    return Scaffold(
      backgroundColor: appScreenBackgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CupertinoSearchTextField(
                prefixIcon: Icon(Icons.search, color: Colors.white),
                style: TextStyle(color: Colors.white, fontSize: 16),
                placeholder: 'Search',
                placeholderStyle: TextStyle(color: Colors.white),
                decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(100)),
              ),
            )),
        title: Text(
          'Donation History',
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
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshDonationHistory(),
          color: appColorPrimary,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // User Stats Section
                if (controller.userStats.value != null)
                  _buildUserStatsSection(controller.userStats.value!),
              ],
            ),
          ),
        );
      }),
    );
  }

  // User Stats Section
  Widget _buildUserStatsSection(UserStats stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            appColorPrimary,
            appColorPrimary.withOpacity(0.7),
            Colors.purple,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appColorPrimary.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Impact',
            style: boldTextStyle(size: 20, color: Colors.white),
          ),
          20.height,
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => const DonationHistoryListScreen());
                  },
                  child: _buildStatItem(
                    '${stats.totalDonations ?? 0}',
                    'My Contributions',
                    Icons.favorite,
                  ),
                ),
              ),
              16.width,
              Expanded(
                child: _buildStatItem(
                  stats.totalBoltsDonatedDisplay ?? '0',
                  'Bolts Donated',
                  Icons.account_balance_wallet,
                ),
              ),
            ],
          ),
          16.height,
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '${stats.totalUsdDonated?.toStringAsFixed(2) ?? '0.00'} Bolt',
                  'Donated',
                  Icons.account_balance_sharp,
                ),
              ),
              16.width,
              Expanded(
                child: _buildStatItem(
                  '${stats.uniqueProjectsSupported ?? 0}',
                  'Projects',
                  Icons.folder,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          8.height,
          Text(
            value,
            style: boldTextStyle(size: 16, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          4.height,
          Text(
            label,
            style: secondaryTextStyle(size: 11, color: Colors.white70),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Compact Donation Card (for recent transactions view)
  Widget _buildCompactDonationCard(
      Donation donation, DonationHistoryController controller) {
    final donationDetails = donation.donationDetails;
    final projectDetails = donation.projectDetails;

    // Get project image - placeholder since ProjectDetails doesn't have image
    final projectImage = null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        children: [
          // Project Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[800],
            ),
            child: projectImage != null && projectImage.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: projectImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: appColorPrimary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 24,
                        ),
                      ),
                    ),
                  )
                : const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 24,
                  ),
          ),
          12.width,
          // Project Name and Amount
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  projectDetails?.title ?? 'Unknown Project',
                  style: boldTextStyle(size: 14, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                4.height,
                Text(
                  donationDetails?.donatedBoltsDisplay ?? '0 Bolts',
                  style: secondaryTextStyle(size: 12, color: appColorPrimary),
                ),
                if (donationDetails?.donatedAmountUsd != null) ...[
                  2.height,
                  Text(
                    '\$${donationDetails!.donatedAmountUsd!.toStringAsFixed(2)}',
                    style: secondaryTextStyle(size: 11, color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Donation Card (Full Card)
  Widget _buildDonationCard(
      Donation donation, DonationHistoryController controller) {
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
          Row(
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
              Container(
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
            ],
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
                      size: 16, color: Colors.white.withOpacity(0.7)),
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
                            AlwaysStoppedAnimation<Color>(appColorPrimary),
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
                              size: 10, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            12.height,
          ],

          // Donation Date and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 14, color: Colors.white.withOpacity(0.7)),
                  4.width,
                  Text(
                    controller.formatDate(donationDetails?.donatedAt),
                    style: secondaryTextStyle(size: 12, color: Colors.white70),
                  ),
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
                            _getStatusColor(donationDetails.donationStatus!)),
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
