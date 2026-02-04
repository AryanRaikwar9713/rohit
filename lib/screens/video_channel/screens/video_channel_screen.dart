import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/video_channel/video_channle_controller.dart';

class VideoChannelScreen extends StatefulWidget {
  const VideoChannelScreen({super.key});

  @override
  State<VideoChannelScreen> createState() => _VideoChannelScreenState();
}

class _VideoChannelScreenState extends State<VideoChannelScreen> {
  late VideoChannelController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Get or create the controller to ensure it's initialized
    controller = Get.isRegistered<VideoChannelController>()
        ? Get.find<VideoChannelController>()
        : Get.put(VideoChannelController());

    // Load channel data when screen is initialized if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.loading.value && controller.channel.value == null) {
        controller.getChannel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Channel'),
      ),
      body: Obx(() {
        // Show loading indicator while channel data is being loaded
        if (controller.loading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Show channel profile if channel exists
        if (controller.hasChannel.value && controller.channel.value != null) {
          return Column(
            children: [
              const SizedBox(width: double.infinity, height: 40),
              Container(
                height: 100,
                width: 100,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  shape: BoxShape.circle,
                ),
                child: Image.network(
                  controller.channel.value?.profileImageUrl ?? "",
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image);
                  },
                ),
              ),
              10.height,

              // Channel Name
              Text(
                controller.channel.value?.channelName ?? "",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontWeight: FontWeight.bold,),
              ),
              10.height,
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: controller.channel.value?.status == "approved"
                      ? Colors.green
                      : Colors.orange,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  (controller.channel.value?.status ?? "")
                      .capitalizeFirstLetter(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontWeight: FontWeight.bold,),
                ),
              ),
              10.height,

              //Rejection Reason
              if (controller.channel.value?.status == "rejected" &&
                  controller.channel.value?.rejectionReason != null)
                Text(
                  'Abe gandu ese channel banate h kya',
                  style: TextStyle(
                      color: Colors.red,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,),
                ),

              // Description
              Text(
                controller.channel.value?.description ?? "",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontWeight: FontWeight.bold,),
              ),
            ],
          );
        }

        // Show message if no channel exists
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.video_library_outlined,
                  size: 64, color: Colors.grey,),
              16.height,
              Text(
                'No Channel Found',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
