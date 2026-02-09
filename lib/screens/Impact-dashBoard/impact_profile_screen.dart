import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/impact_profile_controller.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/model/profileresponcemodel.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/create_campaign_screen.dart';
import 'package:streamit_laravel/screens/Impact-dashBoard/crate_impact_profile_screen.dart';
import 'package:streamit_laravel/screens/donation/donation_screen.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:streamit_laravel/utils/mohit/vammis_profile_avtar.dart';
import 'package:streamit_laravel/screens/walletSection/wallet_tab_manage.dart';

void _showImpactMenu(BuildContext context, ImpactProfileController controller) {
  final hasAccount = controller.profileResponse.value?.data?.hasAccount == true;
  final isApproved = controller.profileResponse.value?.data?.accountDetails?.accountStatus == 'approved';

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.grey.shade900,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Impact',
              style: boldTextStyle(size: 18, color: Colors.white),
            ),
            8.height,
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: appColorPrimary),
              title: Text(
                hasAccount ? 'Edit Impact Profile' : 'Create Impact Profile',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(ctx);
                final f = Get.to(() => const CrateImpactProfileScreen());
                f?.then((_) => controller.checkImpactAccount());
              },
            ),
            ListTile(
              leading: const Icon(Icons.campaign, color: appColorPrimary),
              title: const Text(
                'Create Campaign / Project',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                isApproved ? 'Start a new campaign' : (hasAccount ? 'Account pending approval' : 'Create profile first'),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(ctx);
                if (isApproved) {
                  Get.to(() => const CreateCampaignScreen());
                } else {
                  toast(hasAccount ? 'Account pending approval' : 'Create Impact Profile first');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.explore, color: appColorPrimary),
              title: const Text(
                'Browse Projects & Donate',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(ctx);
                Get.to(() => const ImpactDashboardScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: appColorPrimary),
              title: const Text(
                'My Impact Profile',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'View dashboard (this page)',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(ctx);
                controller.checkImpactAccount();
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class ImpactProfileScreen extends StatelessWidget {
  const ImpactProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ImpactProfileController controller =
        Get.isRegistered<ImpactProfileController>()
            ? Get.find<ImpactProfileController>()
            : Get.put(ImpactProfileController());

    // Load profile data if not loaded
    if (controller.profileResponse.value == null) {
      controller.checkImpactAccount();
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Impact Profile',
          style: boldTextStyle(size: 20, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white, size: 22),
        actionsIconTheme: const IconThemeData(color: Colors.white, size: 22),
        actions: [
          // Impact menu
          IconButton(
            onPressed: () => _showImpactMenu(context, controller),
            icon: const Icon(Icons.dashboard_customize, color: Colors.white, size: 22),
            tooltip: 'Impact – Create profile, campaigns, browse projects',
          ),
          IconButton(
            onPressed: () => Get.to(() => const WalletTabManage()),
            icon: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 22),
            tooltip: 'Wallet',
          ),
          IconButton(
            onPressed: () => controller.checkImpactAccount(),
            icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isCheckingAccount.value) {
          return const Center(
            child: CircularProgressIndicator(color: appColorPrimary),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
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
                  onPressed: () => controller.checkImpactAccount(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColorPrimary,
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        final profileData = controller.profileResponse.value;
        if (profileData == null || profileData.data?.hasAccount != true) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    size: 80,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  16.height,
                  Text(
                    'No Impact Profile Found',
                    style: boldTextStyle(size: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  8.height,
                  Text(
                    'Create your impact profile to start raising funds and managing projects.',
                    style: secondaryTextStyle(size: 14, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  24.height,
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Get.to(() => const CrateImpactProfileScreen());
                      controller.checkImpactAccount();
                    },
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                    label: const Text(
                      'Create Impact Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColorPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  12.height,
                  TextButton.icon(
                    onPressed: () => _showImpactMenu(context, controller),
                    icon: const Icon(Icons.menu, color: appColorPrimary, size: 20),
                    label: const Text(
                      'More options',
                      style: TextStyle(color: appColorPrimary, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final accountDetails = profileData.data?.accountDetails;
        final limits = profileData.data?.limits;
        final projectsSummary = profileData.data?.projectsSummary;

        if (accountDetails == null) {
          return const SizedBox();
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image Section
              _buildCoverImageSection(accountDetails.media?.coverImage, accountDetails),
              70.height,

              // Profile Header
              _buildProfileHeader(accountDetails),

              15.height,

              // Create Campaign Button (only if approved)
              if (accountDetails.accountStatus == 'approved')
                _buildCreateCampaignButton(
                  (controller.userCampainLimitResponse.value?.data?.limits
                              ?.projectsRemaining ??
                          0) >
                      0,
                ),

              // Account Status Card
              _buildAccountStatusCard(accountDetails, limits),

              16.height,

              // Financial Limits
              if (accountDetails.financialLimits != null)
                _buildFinancialLimitsCard(accountDetails.financialLimits!),

              16.height,

              // Project Limits
              if (accountDetails.projectLimits != null)
                _buildProjectLimitsCard(accountDetails.projectLimits!),

              16.height,

              // Projects Summary
              if (projectsSummary != null)
                _buildProjectsSummaryCard(projectsSummary),

              16.height,

              // Graphs
              if (projectsSummary != null)
                _buildProjectsGraphCard(accountDetails, projectsSummary),

              16.height,

              // Account Details
              _buildAccountDetailsCard(accountDetails),

              24.height,
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCreateCampaignButton(bool hasLimit) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ElevatedButton(
        onPressed: !hasLimit
            ? null
            : () {
                Get.to(() => const CreateCampaignScreen());
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: appColorPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.campaign, color: Colors.white, size: 24),
            12.width,
            Text(
              (!hasLimit) ? "Don't have Limit" : 'Create Campaign',
              style: boldTextStyle(size: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildCoverImageSection(String? coverImageUrl,AccountDetails accountDetails) {
    return SizedBox(
      height: 225,
      child: Stack(
        children: [

          //Cover Image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 12,
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xff232526), Color(0xff414345)],

              ),
            ),
            child: coverImageUrl != null && coverImageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: coverImageUrl,
                    // imageUrl: 'https://tse2.mm.bing.net/th/id/OIP.sopZWRXm1j5S7DBDoyFgCwHaDe?pid=Api&P=0&h=180',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: appColorPrimary),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey,
                    ),
                  )
                : const Icon(Icons.image_outlined, color: Colors.grey, size: 64),
          ),

          Align(
            alignment: const Alignment(0, 1.8),
            child: WamimsProfileAvtar(
                image: accountDetails.media?.profileImage??'',
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildProfileHeader(accountDetails) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(5),
          // border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [

            // Title
            Text(
              accountDetails?.title ?? 'No Title',
              style: boldTextStyle(size: 22, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            8.height,

            // Account Type Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (accountDetails?.accountType ?? 'personal') ==
                        'organization'
                    ? Colors.blue.withOpacity(0.2)
                    : appColorPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                (accountDetails?.accountType ?? 'personal').toUpperCase(),
                style: primaryTextStyle(
                  size: 12,
                  color: (accountDetails?.accountType ?? 'personal') ==
                          'organization'
                      ? Colors.blue
                      : appColorPrimary,
                  weight: FontWeight.w700,
                ),
              ),
            ),
            12.height,

            // Description
            if (accountDetails?.description != null)
              Text(
                accountDetails!.description!,
                style: secondaryTextStyle(size: 14, color: Colors.white70),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountStatusCard(accountDetails, limits) {
    final status = accountDetails?.accountStatus ?? 'pending';
    final statusSummary = limits?.statusSummary;

    Color statusColor = Colors.orange;
    if (status == 'approved') {
      statusColor = Colors.green;
    } else if (status == 'rejected') {
      statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [statusColor.withOpacity(0.2), statusColor.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  status == 'approved'
                      ? Icons.check_circle
                      : status == 'rejected'
                          ? Icons.cancel
                          : Icons.pending,
                  color: statusColor,
                  size: 24,
                ),
              ),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusSummary?.message ?? status.toUpperCase(),
                      style: boldTextStyle(size: 18, color: Colors.white),
                    ),
                    if (statusSummary?.description != null) ...[
                      4.height,
                      Text(
                        statusSummary!.description!,
                        style: secondaryTextStyle(
                          size: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialLimitsCard(FinancialLimits financialLimits) {
    final percentage = financialLimits.maxFundingLimit != null &&
            financialLimits.maxFundingLimit! > 0
        ? (financialLimits.currentFundingUsed ?? 0) /
            financialLimits.maxFundingLimit! *
            100
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Financial Limits',
                style: boldTextStyle(size: 18, color: Colors.white),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: boldTextStyle(size: 16, color: appColorPrimary),
              ),
            ],
          ),
          16.height,
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(appColorPrimary),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLimitItem(
                'Used',
                '\$${financialLimits.currentFundingUsed ?? 0}',
                Colors.orange,
              ),
              _buildLimitItem(
                'Remaining',
                '\$${financialLimits.fundingRemaining ?? 0}',
                Colors.green,
              ),
              _buildLimitItem(
                'Total',
                '\$${financialLimits.maxFundingLimit ?? 0}',
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectLimitsCard(ProjectLimits projectLimits) {
    final percentage = projectLimits.maxProjectsLimit != null &&
            projectLimits.maxProjectsLimit! > 0
        ? (projectLimits.currentProjectsCount ?? 0) /
            projectLimits.maxProjectsLimit! *
            100
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Project Limits',
                style: boldTextStyle(size: 18, color: Colors.white),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: boldTextStyle(size: 16, color: appColorPrimary),
              ),
            ],
          ),
          16.height,
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(appColorPrimary),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLimitItem(
                'Current',
                '${projectLimits.currentProjectsCount ?? 0}',
                Colors.orange,
              ),
              _buildLimitItem(
                'Remaining',
                '${projectLimits.projectsRemaining ?? 0}',
                Colors.green,
              ),
              _buildLimitItem(
                'Total',
                '${projectLimits.maxProjectsLimit ?? 0}',
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLimitItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: boldTextStyle(size: 18, color: color)),
        4.height,
        Text(label, style: secondaryTextStyle(size: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _buildProjectsSummaryCard(ProjectsSummary projectsSummary) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff232526), Color(0xff414345)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            blurRadius: 2,
            offset: const Offset(0,2 ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Projects Summary',
            style: boldTextStyle(size: 18, color: Colors.white),
          ),
          20.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Total Projects',
                '${projectsSummary.totalProjects ?? 0}',
                Icons.folder,
              ),
              _buildSummaryItem(
                'Active',
                '${projectsSummary.activeProjects ?? 0}',
                Icons.play_circle,
              ),
              _buildSummaryItem(
                'Total Raised',
                '\$${projectsSummary.totalRaised ?? 0}',
                Icons.attach_money,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsGraphCard(
    AccountDetails? accountDetails,
    ProjectsSummary projectsSummary,
  ) {
    final financialLimits = accountDetails?.financialLimits;
    final projectLimits = accountDetails?.projectLimits;

    final double financialUsed = financialLimits?.currentFundingUsed ?? 0;
    final double financialMax = financialLimits?.maxFundingLimit ?? 0;
    final double projectUsed = projectLimits?.currentProjectsCount ?? 0;
    final double projectMax = projectLimits?.maxProjectsLimit ?? 0;

    final statusData = _parseStatusCounts(projectsSummary.byStatus);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff1f2128), Color(0xff181a20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Impact at a Glance',
              style: boldTextStyle(size: 18, color: Colors.white),),
          12.height,
          Row(
            children: [
              Expanded(
                child: _buildUsagePie(
                  title: 'Funding Used',
                  used: financialUsed,
                  max: financialMax,
                  color: appColorPrimary,
                  currency: true,
                ),
              ),
              12.width,
              Expanded(
                child: _buildUsagePie(
                  title: 'Projects Used',
                  used: projectUsed,
                  max: projectMax,
                  color: Colors.orangeAccent,
                  currency: false,
                ),
              ),
            ],
          ),
          12.height,
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _buildLegendItem('Used', appColorPrimary),
              _buildLegendItem('Remaining', Colors.white12),
            ],
          ),
          if (statusData.isNotEmpty) ...[
            20.height,
            Text(
              'Projects by Status',
              style: boldTextStyle(size: 16, color: Colors.white),
            ),
            12.height,
            SizedBox(height: 220, child: _buildStatusBarChart(statusData)),
          ],
        ],
      ),
    );
  }

  Widget _buildUsagePie({
    required String title,
    required double used,
    required double max,
    required Color color,
    required bool currency,
  }) {
    final double safeMax = max <= 0 ? used : max;
    final double safeUsed = used.clamp(0, safeMax);
    final double remaining = (safeMax - safeUsed).clamp(0, safeMax);
    final double pct =
        safeMax == 0 ? 0 : ((safeUsed / safeMax) * 100).clamp(0, 100);
    final sections = <PieChartSectionData>[
      PieChartSectionData(
        value: safeUsed,
        color: color,
        radius: 30,
        title: '',
      ),
      PieChartSectionData(
        value: remaining,
        color: Colors.white12,
        radius: 24,
        title: '',
      ),
    ];

    final label = currency
        ? '\$${safeUsed.toStringAsFixed(0)} / \$${safeMax.toStringAsFixed(0)}'
        : '${safeUsed.toStringAsFixed(0)} / ${safeMax.toStringAsFixed(0)}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 150,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 48,
                    startDegreeOffset: -90,
                    sections: sections,
                    centerSpaceColor: Colors.transparent,
                  ),
                ),
              ),
              8.height,
              Text(title, style: boldTextStyle(size: 14, color: Colors.white)),
              4.height,
              Text(
                label,
                style: secondaryTextStyle(size: 12, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${pct.toStringAsFixed(0)}%',
                    style: boldTextStyle(size: 18, color: Colors.white),
                  ),
                  2.height,
                  Text(
                    currency ? 'of funding' : 'of projects',
                    style: secondaryTextStyle(size: 10, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBarChart(List<_StatusCount> data) {
    final maxY = data.fold<double>(0, (m, e) => e.count > m ? e.count : m);
    return BarChart(
      BarChartData(
        maxY: maxY == 0 ? 1 : maxY * 1.1,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => const FlLine(
            color: Colors.white12,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: secondaryTextStyle(size: 10, color: Colors.white60),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    data[index].status,
                    style: secondaryTextStyle(size: 10, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          rightTitles:
              const AxisTitles(),
          topTitles:
              const AxisTitles(),
        ),
        barGroups: List.generate(
          data.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data[index].count,
                gradient: LinearGradient(
                  colors: [
                    appColorPrimary,
                    appColorPrimary.withOpacity(0.65),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 16,
                borderRadius: BorderRadius.circular(8),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY == 0 ? 1 : maxY * 1.2,
                  color: Colors.white10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        6.width,
        Text(label, style: secondaryTextStyle(size: 11, color: Colors.white70)),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: appColorPrimary, size: 32),
        8.height,
        Text(value, style: boldTextStyle(size: 20, color: Colors.white)),
        4.height,
        Text(
          label,
          style: secondaryTextStyle(size: 12, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAccountDetailsCard(accountDetails) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff28323d), Color(0xff151d26)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Account Details',
              style: boldTextStyle(size: 18, color: Colors.white),
            ),
          ),
          12.height,
          if (accountDetails?.contactInfo != null) ...[
            _buildDetailRow(
              Icons.person_outline,
              'Name',
              accountDetails!.contactInfo!.fullName ?? 'N/A',
            ),
            8.height,
            _buildDetailRow(
              Icons.email_outlined,
              'Email',
              accountDetails.contactInfo!.email ?? 'N/A',
            ),
            8.height,
            _buildDetailRow(
              Icons.phone_outlined,
              'Phone',
              accountDetails.contactInfo!.phone ?? 'N/A',
            ),
            8.height,
          ],
          if (accountDetails?.fundingPurpose != null) ...[
            _buildDetailRow(
              Icons.account_balance_wallet_outlined,
              'Funding Purpose',
              accountDetails!.fundingPurpose!,
            ),
            8.height,
          ],
          if (accountDetails?.dates?.createdAt != null) ...[
            _buildDetailRow(
              Icons.calendar_today_outlined,
              'Created At',
              _formatDate(accountDetails!.dates!.createdAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 320;
        final iconSize = isNarrow ? 18.0 : 20.0;
        final textSize = isNarrow ? 12.0 : 13.0;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: appColorPrimary, size: iconSize),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: secondaryTextStyle(size: 11, color: Colors.white60),
                  ),
                  2.height,
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: textSize,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  List<_StatusCount> _parseStatusCounts(List<dynamic>? rawList) {
    if (rawList == null || rawList.isEmpty) return [];
    return rawList.map((item) {
      if (item is Map) {
        final status = item['status']?.toString() ?? 'Unknown';
        final count = double.tryParse(item['count']?.toString() ?? '0') ?? 0;
        return _StatusCount(status, count);
      }
      return _StatusCount('Unknown', 0);
    }).toList();
  }
}

class _StatusCount {
  final String status;
  final double count;

  _StatusCount(this.status, this.count);
}
