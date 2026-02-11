import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/configs.dart';
import 'package:streamit_laravel/screens/reels/reels_api.dart';
import 'package:streamit_laravel/screens/walletSection/wallet_api.dart';
import 'package:video_player/video_player.dart';

class UploadReelController extends GetxController {
  // Video file
  final Rx<File?> selectedVideo = Rx<File?>(null);
  final Rx<VideoPlayerController?> videoController =
      Rx<VideoPlayerController?>(null);

  // Form fields
  final RxString caption = ''.obs;
  final RxString location = ''.obs;
  final RxList<String> hashtags = <String>[].obs;
  final RxBool isUploading = false.obs;
  final RxDouble uploadProgress = 0.0.obs;

  final RxBool onUploadScreen = false.obs;

  // UI states
  final RxBool isVideoSelected = false.obs;
  final RxBool isVideoPlaying = false.obs;
  final RxBool showLocationField = false.obs;
  final RxBool showHashtagField = false.obs;

  // Video info
  final RxString videoDuration = ''.obs;
  final RxString videoSize = ''.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onClose() {
    // Dispose video controller
    if (videoController.value != null) {
      videoController.value!.dispose();
    }
    super.onClose();
  }

  // Pick video from gallery
  Future<void> pickVideoFromGallery() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 3), // Max 3 minutes for reels
      );

      if (video != null) {
        selectedVideo.value = File(video.path);
        await _initializeVideoController();
        isVideoSelected.value = true;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick video: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Pick video from camera
  Future<void> pickVideoFromCamera() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 3),
      );

      if (video != null) {
        selectedVideo.value = File(video.path);
        await _initializeVideoController();
        isVideoSelected.value = true;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to record video: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Initialize video controller
  Future<void> _initializeVideoController() async {
    if (selectedVideo.value != null) {
      videoController.value?.dispose();
      videoController.value = VideoPlayerController.file(selectedVideo.value!);

      await videoController.value!.initialize();
      videoController.value!.setLooping(true);

      // Get video duration
      final duration = videoController.value!.value.duration;
      videoDuration.value = _formatDuration(duration);

      // Get video size (approximate)
      final file = selectedVideo.value;
      final fileSize = file != null ? await file.length() : 0;
      videoSize.value = _formatFileSize(fileSize);
    }
  }

  // Toggle video play/pause
  void toggleVideoPlayPause() {
    if (videoController.value != null) {
      if (isVideoPlaying.value) {
        videoController.value!.pause();
        isVideoPlaying.value = false;
      } else {
        videoController.value!.play();
        isVideoPlaying.value = true;
      }
    }
  }

  // Update caption
  void updateCaption(String text) {
    caption.value = text;
  }

  // Update location
  void updateLocation(String text) {
    location.value = text;
  }

  // Add hashtag
  void addHashtag(String hashtag) {
    if (hashtag.isNotEmpty && !hashtags.contains(hashtag)) {
      hashtags.add(hashtag);
    }
  }

  // Remove hashtag
  void removeHashtag(String hashtag) {
    hashtags.remove(hashtag);
  }

  // Toggle location field
  void toggleLocationField() {
    showLocationField.value = !showLocationField.value;
  }

  // Toggle hashtag field
  void toggleHashtagField() {
    showHashtagField.value = !showHashtagField.value;
  }

  // Upload reel
  Future<void> uploadReel() async {
    if (selectedVideo.value == null) {
      Get.snackbar(
        'Error',
        'Please select a video first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (caption.value.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please add a caption',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isUploading.value = true;
      uploadProgress.value = 0.0;

      await ReelsApi().createReel(
          caption: caption.value,
          videoPath: selectedVideo.value?.path ?? '',
          onProgress: (d) {
            uploadProgress.value = d;
            print("Upload Progress $d");
          },
          onError: (e) {
            isUploading.value = false;
            uploadProgress.value = 0.0;
            Get.snackbar(
              'Error',
              'Failed to upload reel: $e',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          },
          onFailure: (e) {
            isUploading.value = false;
            uploadProgress.value = 0.0;
            Get.snackbar(
              'Error',
              'Failed to upload reel: $e',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          },
          onSuccess: (reel) {
            if (ENABLE_POINT_EARNINGS_SYSTEM) {
              WalletApi().getPointsAndBolt(
                  action: PointAction.reelUpload,
                  targetId: reel,
                  getBolt: false,
                  contentType: "reel",
                  onError: onError,
                  onFailure: (d) {},);
            }
            // Clear form after successful upload
            clearForm();
            // Only pop if user is still on the upload screen
            if (onUploadScreen.value) {
              Navigator.pop(navigatorKey.currentContext!);
            }
          },);

      // Note: Navigation is handled in onSuccess callback based on onUploadScreen flag
      // Don't clear form here as upload might still be in progress
    } catch (e) {
      isUploading.value = false;
      uploadProgress.value = 0.0;

      Get.snackbar(
        'Error',
        'Failed to upload reel: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Clear form and reset state
  void clearForm() {
    selectedVideo.value = null;
    videoController.value?.dispose();
    videoController.value = null;
    caption.value = '';
    location.value = '';
    hashtags.clear();
    isUploading.value = false;
    uploadProgress.value = 0.0;
    isVideoSelected.value = false;
    isVideoPlaying.value = false;
    showLocationField.value = false;
    showHashtagField.value = false;
    videoDuration.value = '';
    videoSize.value = '';
  }

  // Cancel upload and clear form
  void cancelUpload() {
    clearForm();
    Get.back();
  }

  // Format duration
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  // Format file size
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Get hashtags as string
  String get hashtagsString => hashtags.map((tag) => '#$tag').join(' ');

  // Get full caption with hashtags
  String get fullCaption => '${caption.value} $hashtagsString'.trim();
}
