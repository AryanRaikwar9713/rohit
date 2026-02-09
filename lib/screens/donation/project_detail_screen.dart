import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/donation/numbar_input_formater.dart';
import 'package:streamit_laravel/screens/donation/project_detail_control.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_screen.dart';
import 'package:streamit_laravel/screens/donation/model/project_detail_responce_model.dart';
import 'package:streamit_laravel/utils/mohit/custom_like_button.dart';
import 'package:streamit_laravel/widgets/bottom_navigation_wrapper.dart';

class ProjectDetailScreen extends StatefulWidget {
  final int id;
  const ProjectDetailScreen({required this.id, super.key});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

/// Apna color combo - Impact Dashboard jaisa yellow-orange gradient
const LinearGradient _appGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late ProjectDetailController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProjectDetailController());
    controller.getProject(widget.id);
  }

  @override
  void dispose() {
    Get.delete<ProjectDetailController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationWrapper(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFF0D0D0D),
          body: Obx(() {
            if (controller.loading.value) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white),);
            }

            final detail = controller.detail;

            return RefreshIndicator(
              onRefresh: () async {
                controller.getProject(widget.id);
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🖼 Main Image

                      ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        detail.value.mainImage ?? '',
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 220,
                          width: double.infinity,
                          color: Colors.grey.shade800,
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.white54,),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🧾 Title + Category
                    Text(
                      detail.value.title ?? "Untitled Project",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (detail.value.category != null)
                      Row(
                        children: [
                          const SizedBox(width: 6),
                          Text(
                            detail.value.category?.name ?? '',
                            style: const TextStyle(
                                color: Colors.white54,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,),
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),

                    // 💰 Funding Progress (gradient) - GoFundMe style
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _appGradient.colors.first.withOpacity(0.15),
                            _appGradient.colors.last.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _appGradient.colors.first.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Progress percentage
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ShaderMask(
                                shaderCallback: (b) => _appGradient.createShader(b),
                                child: Text(
                                  "${(detail.value.progressPercentage ?? 0).toStringAsFixed(1)}%",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _appGradient.colors.first.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.people, size: 16, color: _appGradient.colors.first),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${detail.value.donorsCount ?? 0} donors",
                                      style: TextStyle(
                                        color: _appGradient.colors.first,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 14,
                              child: ShaderMask(
                                shaderCallback: (bounds) => _appGradient.createShader(bounds),
                                child: LinearProgressIndicator(
                                  value: ((detail.value.progressPercentage ?? 0) / 100).clamp(0.0, 1.0),
                                  backgroundColor: Colors.grey.shade800,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  minHeight: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Amount details
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Raised",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ShaderMask(
                                    shaderCallback: (b) => _appGradient.createShader(b),
                                    child: Text(
                                      "🪙 ${(detail.value.fundingRaised ?? 0).toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    "Goal",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "🪙 ${(detail.value.fundingGoal ?? 0).toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 📅 Duration & Location card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade800),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _iconText(Icons.timer_outlined,
                                  "${detail.value.daysRemaining ?? 0} days left",),
                              _iconText(Icons.access_time,
                                  "Duration: ${detail.value.durationDays ?? 0} days",),
                            ],
                          ),
                          if (detail.value.location != null) ...[
                            const SizedBox(height: 8),
                            _iconText(
                                Icons.location_on_outlined, detail.value.location!,
                                color: _appGradient.colors.first,),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🧠 About the Project (gradient section)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _appGradient.colors.first.withOpacity(0.08),
                            _appGradient.colors.last.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade800),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (b) => _appGradient.createShader(b),
                            child: const Text("About the Project",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,),),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            detail.value.description?.isNotEmpty == true
                                ? detail.value.description!
                                : (detail.value.description ??
                                    'No description available.'),
                            style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    if (detail.value.images != null &&
                        detail.value.images!.isNotEmpty) ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final String i in detail.value.images ?? [])
                              GestureDetector(
                                onTap: (){
                                  final int? imIn = detail.value.images?.indexWhere((element) => element==i,);

                                  final pac = PageController(initialPage: ((imIn!=null)&&(imIn>=0))?imIn:0);

                                  showDialog(context: context, builder: (context) {
                                    return Blur(
                                      child: PageView(
                                        controller: pac,
                                        children: [
                                          for(final String l in detail.value.images ?? [])
                                            GestureDetector(
                                                child: Image.network(l),),
                                        ],
                                      ),
                                    );
                                  } ,);
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.white),
                                  ),
                                  height: 150,
                                  width: 150,
                                  child: Image.network(
                                    i,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // 📖 Story (gradient section)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _appGradient.colors.last.withOpacity(0.06),
                            _appGradient.colors.first.withOpacity(0.06),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade800),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (b) => _appGradient.createShader(b),
                            child: const Text("Story",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,),),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            detail.value.story?.isNotEmpty == true
                                ? detail.value.story!
                                : (detail.value.description ??
                                    'No description available.'),
                            style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 👤 Creator Info
                    if (detail.value.creator != null) ...[
                      ShaderMask(
                        shaderCallback: (b) => _appGradient.createShader(b),
                        child: const Text("Project Creator",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,),),
                      ),

                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final u = await DB().getUser();
                          if (detail.value.creator?.id != null) {
                            Get.to(() => VammisProfileScreen(
                                  userId: detail.value.creator!.id!,
                                  popButton: true,
                                  isOwnProfile:
                                      detail.value.creator!.id == (u?.id ?? 0),
                                ),);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade800),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundImage: NetworkImage(
                                    detail.value.creator?.avatar ?? '',),
                                backgroundColor: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "${detail.value.creator?.firstName ?? ''} ${detail.value.creator?.lastName ?? ''}",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,),),
                                    const SizedBox(height: 2),
                                    Text(
                                      "@${detail.value.creator?.username ?? ''}",
                                      style: const TextStyle(
                                          color: Colors.white54, fontSize: 13,),
                                    ),
                                  ],
                                ),
                              ),
                              const CustomStreamButton(),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ❤️ User Interaction
                    if (detail.value.userInteraction != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _iconStat(
                              Icons.favorite, detail.value.likesCount ?? 0,
                              active: detail.value.userInteraction?.hasLiked ??
                                  false,),
                          _iconStat(
                              Icons.people, detail.value.donorsCount ?? 0,),
                          _iconStat(
                              Icons.comment, detail.value.commentsCount ?? 0,),
                          _iconStat(Icons.remove_red_eye,
                              detail.value.viewsCount ?? 0,),
                        ],
                      ),

                    const SizedBox(height: 24),

                    // 👥 Donors Section with Tabs (gradient title)
                    if (detail.value.recentDonors != null &&
                        detail.value.recentDonors!.isNotEmpty) ...[
                      ShaderMask(
                        shaderCallback: (b) => _appGradient.createShader(b),
                        child: const Text(
                          "Donors",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDonorsTabView(detail.value.recentDonors!),
                      const SizedBox(height: 24),
                    ],

                    // 🎁 Donate Button (gradient)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final amountTextFiel = TextEditingController();
                          final messageTextField = TextEditingController();
                          await showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context) => _DonatSheet(
                              amountController: amountTextFiel,
                              messageController: messageTextField,
                              controller: controller,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: _appGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _appGradient.colors.first.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite, color: Colors.black, size: 22),
                              SizedBox(width: 8),
                              Text("Donate Now",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,),),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _iconText(IconData icon, String text, {Color color = Colors.white70}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: color, fontSize: 14)),
      ],
    );
  }

  Widget _iconStat(IconData icon, int count, {bool active = false}) {
    return Row(
      children: [
        Icon(icon, color: active ? Colors.redAccent : Colors.white70),
        const SizedBox(width: 4),
        Text("$count", style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildDonorsTabView(List<RecentDonation> donors) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade800,
              ),
            ),
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _appGradient.colors.first.withOpacity(0.35),
                    _appGradient.colors.last.withOpacity(0.35),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorColor: _appGradient.colors.first,
              labelColor: _appGradient.colors.first,
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Top Donors'),
                Tab(text: 'Recent Donors'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Tab Bar View
          Container(
            height: 300, // Fixed height for the list
            decoration: BoxDecoration(
              color: Colors.grey.shade900.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade800,
              ),
            ),
            child: TabBarView(
              children: [
                // Top Donors Tab - sorted by amount (descending)
                _buildDonorsList(
                  List<RecentDonation>.from(donors)
                    ..sort((a, b) => (b.amount ?? 0).compareTo(a.amount ?? 0)),
                ),
                // Recent Donors Tab - sorted by date (descending)
                _buildDonorsList(
                  List<RecentDonation>.from(donors)
                    ..sort((a, b) {
                      if (a.donatedAt == null && b.donatedAt == null) return 0;
                      if (a.donatedAt == null) return 1;
                      if (b.donatedAt == null) return -1;
                      return b.donatedAt!.compareTo(a.donatedAt!);
                    }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorsList(List<RecentDonation> donors) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: donors.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Colors.grey.shade800,
        indent: 60,
      ),
      itemBuilder: (context, index) {
        final donor = donors[index];
        return _buildDonorItem(donor);
      },
    );
  }

  Widget _buildDonorItem(RecentDonation donor) {
    final isAnonymous = donor.isAnonymous == 1;
    final displayName =
        isAnonymous ? "Anonymous" : (donor.username ?? "Unknown");
    final displayAvatar = isAnonymous
        ? null
        : (donor.avatar != null && donor.avatar!.isNotEmpty
            ? donor.avatar
            : null);

    String timeAgo = "Recently";
    if (donor.donatedAt != null) {
      final now = DateTime.now();
      final difference = now.difference(donor.donatedAt!);
      if (difference.inDays > 0) {
        timeAgo =
            "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
      } else if (difference.inHours > 0) {
        timeAgo =
            "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
      } else if (difference.inMinutes > 0) {
        timeAgo =
            "${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago";
      } else {
        timeAgo = "Just now";
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: InkWell(
        onTap: () async {
          print('aghd');
          final user = await DB().getUser();
          Get.to(VammisProfileScreen(
              userId: donor.id ?? 0,
              isOwnProfile: user?.id == donor.id,
              popButton: true,),);
        },
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade800,
              backgroundImage:
                  displayAvatar != null ? NetworkImage(displayAvatar) : null,
              child: displayAvatar == null
                  ? Icon(
                      isAnonymous ? Icons.person_outline : Icons.person,
                      color: Colors.white70,
                      size: 24,
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Name and Time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeAgo,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.greenAccent.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${donor.amount ?? '0'}",
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    3.width,
                    Image.asset(
                      "assets/icons/boalt_Icons.png",
                      height: 18,
                      width: 18,
                      color: Colors.greenAccent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonatSheet extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController messageController;
  final ProjectDetailController controller;
  const _DonatSheet({
    required this.messageController,
    required this.amountController,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      gradient: _appGradient,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                ShaderMask(
                  shaderCallback: (b) => _appGradient.createShader(b),
                  child: const Text(
                    "Enter Bolt Amount",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Amount input
                TextField(
                  controller: amountController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [NumberInputFormatter(decimalRange: 3)],
                  decoration: InputDecoration(
                    hintText: "Amount",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF2E2E2E)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF2E2E2E)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFFF9800), width: 1.5),
                    ),
                  ),
                ),

                14.height,

                // Message input
                TextField(
                  controller: messageController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: "Add Message",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF2E2E2E)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF2E2E2E)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFFF9800), width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Donate button - apna gradient
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: () async {
                        final amountText = amountController.text.trim();
                        final messageText = messageController.text.trim();
                        
                        if (amountText.isEmpty) {
                          Get.snackbar(
                            "Error",
                            "Please enter an amount",
                            backgroundColor: Colors.redAccent.withOpacity(0.8),
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                          return;
                        }
                        
                        final amount = double.tryParse(amountText);
                        if (amount == null || amount <= 0) {
                          Get.snackbar(
                            "Error",
                            "Please enter a valid amount",
                            backgroundColor: Colors.redAccent.withOpacity(0.8),
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                          return;
                        }
                        
                        if (messageText.isEmpty) {
                          Get.snackbar(
                            "Error",
                            "Please enter a message",
                            backgroundColor: Colors.redAccent.withOpacity(0.8),
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                          return;
                        }
                        
                        // Validate project ID before proceeding
                        final projectId = controller.projectId ?? controller.detail.value.id;
                        if (projectId == null || projectId <= 0) {
                          Get.snackbar(
                            "Error",
                            "Invalid project. Please refresh and try again.",
                            backgroundColor: Colors.redAccent.withOpacity(0.8),
                            colorText: Colors.white,
                          );
                          Navigator.pop(context);
                          // Refresh project using stored ID
                          final refreshId = controller.projectId ?? controller.detail.value.id;
                          if (refreshId != null && refreshId > 0) {
                            controller.getProject(refreshId);
                          }
                          return;
                        }
                        
                        Navigator.pop(context);
                        // Show loading
                        Get.dialog(
                          const Center(
                            child: CircularProgressIndicator(color: Color(0xFFFF9800)),
                          ),
                          barrierDismissible: false,
                        );
                        
                        await controller.donate(amount, messageText);
                        
                        // Close loading
                        if (Get.isDialogOpen ?? false) {
                          Get.back();
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: _appGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF9800).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite_rounded, color: Colors.white, size: 22),
                              SizedBox(width: 10),
                              Text(
                                "Donate",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
