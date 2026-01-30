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
  const ProjectDetailScreen({required this.id, Key? key}) : super(key: key);

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

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
                  child: CircularProgressIndicator(color: Colors.white));
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
                        detail.value?.mainImage ?? '',
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 220,
                          width: double.infinity,
                          color: Colors.grey.shade800,
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.white54),
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
                    if (detail.value?.category != null)
                      Row(
                        children: [
                          const SizedBox(width: 6),
                          Text(
                            detail.value?.category?.name ?? '',
                            style: const TextStyle(
                                color: Colors.white54,
                                fontWeight: FontWeight.w900,
                                fontSize: 20),
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),

                    // 💰 Funding Progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Raised: ${detail.value.fundingRaised ?? 0} Bolts",
                            style: const TextStyle(color: Colors.greenAccent)),
                        Text("Goal: ${detail.value.fundingGoal ?? 0} Bolts",
                            style: const TextStyle(color: Colors.white54)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (detail.value.progressPercentage ?? 0) / 100,
                      backgroundColor: Colors.grey.shade800,
                      color: Colors.greenAccent,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 16),

                    // 📅 Duration & Days Remaining
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _iconText(Icons.timer_outlined,
                            "${detail.value.daysRemaining ?? 0} days left"),
                        _iconText(Icons.access_time,
                            "Duration: ${detail.value.durationDays ?? 0} days"),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 📍 Location
                    if (detail.value.location != null)
                      _iconText(
                          Icons.location_on_outlined, detail.value.location!,
                          color: Colors.amberAccent),

                    const SizedBox(height: 16),

                    // 🧠 Description / Story
                    const Text("About the Project",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(
                      detail.value.description?.isNotEmpty == true
                          ? detail.value.description!
                          : (detail.value.description ??
                              'No description available.'),
                      style:
                          const TextStyle(color: Colors.white70, height: 1.4),
                    ),
                    const SizedBox(height: 20),

                    if (detail.value.images != null &&
                        detail.value.images!.isNotEmpty) ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (String i in detail.value.images ?? [])
                              GestureDetector(
                                onTap: (){
                                  int? imIn = detail.value.images?.indexWhere((element) => element==i,);

                                  final pac = PageController(initialPage: ((imIn!=null)&&(imIn>=0))?imIn:0);

                                  showDialog(context: context, builder: (context) {
                                    return Blur(
                                      child: PageView(
                                        controller: pac,
                                        children: [
                                          for(String l in detail.value.images ?? [])
                                            GestureDetector(
                                                child: Image.network(l))
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
                      )
                    ],

                    20.height,

                    const Text("Story",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(
                      detail.value.story?.isNotEmpty == true
                          ? detail.value.story!
                          : (detail.value.description ??
                              'No description available.'),
                      style:
                          const TextStyle(color: Colors.white70, height: 1.4),
                    ),
                    const SizedBox(height: 20),

                    // 👤 Creator Info
                    if (detail.value.creator != null) ...[
                      const Text("Project Creator",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),),

                      //
                      const SizedBox(height: 12),

                      //
                      GestureDetector(
                        onTap: () async {
                          var u = await DB().getUser();

                          if (detail.value.creator?.id != null) {
                            Get.to(() => VammisProfileScreen(
                                  userId: detail.value.creator!.id!,
                                  popButton: true,
                                  isOwnProfile:
                                      detail.value.creator!.id == (u?.id ?? 0),
                                ));
                          }
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(
                                  detail.value.creator?.avatar ?? ''),
                              backgroundColor: Colors.grey.shade700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "${detail.value.creator?.firstName ?? ''} ${detail.value.creator?.lastName ?? ''}",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                                  Text(
                                    "@${detail.value.creator?.username ?? ''}",
                                    style:
                                        const TextStyle(color: Colors.white54),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            const CustomStreamButton(),
                            // const Icon(Icons.arrow_forward_ios,
                            //     color: Colors.white54, size: 16),
                          ],
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
                                  false),
                          _iconStat(
                              Icons.people, detail.value.donorsCount ?? 0),
                          _iconStat(
                              Icons.comment, detail.value.commentsCount ?? 0),
                          _iconStat(Icons.remove_red_eye,
                              detail.value.viewsCount ?? 0),
                        ],
                      ),

                    const SizedBox(height: 24),

                    // 👥 Donors Section with Tabs
                    if (detail.value.recentDonors != null &&
                        detail.value.recentDonors!.isNotEmpty) ...[
                      const Text(
                        "Donors",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDonorsTabView(detail.value.recentDonors!),
                      const SizedBox(height: 24),
                    ],

                    // 🎁 Donate Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final amountTextFiel = TextEditingController();
                          final messageTextField = TextEditingController();

                          await showModalBottomSheet(
                            context: context,
                            builder: (context) => _DonatSheet(
                              amountController: amountTextFiel,
                              messageController: messageTextField,
                              controller: controller,
                            ),
                          );
                        },
                        child: const Text("Donate Now",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16)),
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
                width: 1,
              ),
            ),
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorColor: Colors.greenAccent,
              labelColor: Colors.greenAccent,
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
                width: 1,
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
          var user = await DB().getUser();
          Get.to(VammisProfileScreen(
              userId: donor.id ?? 0,
              isOwnProfile: user?.id == donor.id,
              popButton: true));
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
              ignoring: true,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.greenAccent.withOpacity(0.5),
                    width: 1,
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
                    )
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
  _DonatSheet(
      {required this.messageController,
      required this.amountController,
      required this.controller,
      super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        // is padding se keyboard ke open hone par bottom safe ho jaata hai
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Enter Bolt Amount",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // 💰 Input Field
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
                  fillColor: Colors.grey.shade900,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              10.height,

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
                  fillColor: Colors.grey.shade900,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 🔘 Donate Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    if (amountController.text.trim().isEmpty ||
                        messageController.text.trim().isEmpty) {
                      Get.snackbar(
                        "Error",
                        "Please enter an amount and message",
                        backgroundColor: Colors.redAccent.withOpacity(0.8),
                        colorText: Colors.white,
                      );
                      return;
                    }

                    // 👉 Call donation logic here
                    controller.donate(
                      double.parse(amountController.text.trim()),
                      messageController.text.trim(),
                    );

                    Navigator.pop(context); // close sheet
                  },
                  child: const Text(
                    "Donate",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
