import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/colors.dart';
import '../reels_controller.dart';
import '../reels_screen.dart';

class ReelsWidget extends StatefulWidget {
  const ReelsWidget({super.key});

  @override
  State<ReelsWidget> createState() => _ReelsWidgetState();
}

class _ReelsWidgetState extends State<ReelsWidget> {


  bool isLiked = false;
  int likeCount =0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


  }


  @override
  Widget build(BuildContext context) {
    final ReelsController controller = Get.put(ReelsController());

    // return Text("agsdf",style: TextStyle(color: Colors.white),);

    return Obx(() {
      if (controller.isLoading.value) {
        return SizedBox(
          height: 200,
          child: const Center(
            child: CircularProgressIndicator(
              color: appColorPrimary,
            ),
          ),
        );
      }
      // return Text("Reel Widget");

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reels',
                  style: boldTextStyle(size: 18, color: white),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => const ReelsScreen());
                  },
                  child: Text(
                    'View All',
                    style: secondaryTextStyle(size: 14, color: appColorPrimary),
                  ),
                ),
              ],
            ),
          ),

          // Reels List
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.apiReels.length,
              itemBuilder: (context, index) {

                final reel = controller.apiReels[index];

                // return Center(child: Text("akszvnjbjkshjdfjkhakjkfdjkjkf laksflal f",style: TextStyle(color: Colors.white)),);


                return GestureDetector(
                  onTap: () {
                    Get.to(() => const ReelsScreen());
                  },
                  child: Container(
                    width: 120,
                    color: Colors.red,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Video Thumbnail
                        Container(
                          height: 150,
                          width: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[800],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [

                                CachedNetworkImage(
                                  imageUrl: reel.content?.videoUrl ?? '',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[800],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: appColorPrimary,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.play_circle_outline,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),

                                // Play button overlay
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.play_circle_fill,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ),

                                // Duration or other info
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2,),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      '2:30', // Dummy duration
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                
                                

                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Title
                        Text(
                          reel.content?.caption ?? 'Reel',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // User info
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white),
                              ),
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: reel.user?.avatar ?? '',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '@${reel.user?.fullName ?? 'user'}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
