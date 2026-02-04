import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_api.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/vammis_profile_controller.dart';
import 'package:streamit_laravel/utils/colors.dart';

class EditVammisProfileController extends GetxController {
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  // State
  RxBool isLoading = false.obs;
  Rx<File?> selectedImage = Rx<File?>(null);
  RxString currentAvatarUrl = ''.obs;
  int? userId;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    try {
      final user = await DB().getUser();
      userId = user?.id;

      // Get current profile from VammisProfileController if available
      if (Get.isRegistered<VammisProfileController>()) {
        final profileController = Get.find<VammisProfileController>();
        final profileData = profileController.profileResponse.value?.data?.user;

        if (profileData != null) {
          usernameController.text = profileData.username ?? '';
          bioController.text = profileData.bio ?? '';
          currentAvatarUrl.value =
              profileData.avatarUrl ??'';
        }
      }
    } catch (e) {
      Logger().e('Error loading current profile: $e');
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        uploadProfileImage();
      }
    } catch (e) {
      toast('Error picking image: $e');
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        uploadProfileImage();
      }
    } catch (e) {
      toast('Error taking photo: $e');
    }
  }


  RxBool isUploadingImage = false.obs;
  Future<void> uploadProfileImage() async {
    isUploadingImage.value = true;
    await VammisProfileApi().changeProfileImage(
        image: selectedImage.value?.path ?? '',
        onError: onError,
        onFailure: (d) {
          Logger().e("Feiled To upload Image ${d.statusCode}");
        },
        onSuccess: (d) {
          toast("Profile Image Updated");
        },);
    isUploadingImage.value = false;
  }

  void showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            20.height,
            Text(
              'Select Image Source',
              style: boldTextStyle(size: 18, color: Colors.white),
            ),
            20.height,
            Row(
              children: [
                Expanded(
                  child: _buildSourceOption(
                    icon: Icons.photo_library,
                    title: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      pickImageFromGallery();
                    },
                  ),
                ),
                16.width,
                Expanded(
                  child: _buildSourceOption(
                    icon: Icons.camera_alt,
                    title: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      pickImageFromCamera();
                    },
                  ),
                ),
              ],
            ),
            20.height,
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[700]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: appColorPrimary, size: 32),
            8.height,
            Text(
              title,
              style: primaryTextStyle(size: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateProfile() async {
    if (isLoading.value || userId == null) return;

    final username = usernameController.text.trim();
    final bio = bioController.text.trim();

    if (username.isEmpty) {
      toast('Please enter a username');
      return;
    }

    isLoading.value = true;

    try {
      // Use existing avatar URL or static string
      // As per requirement: if image is not being sent, use static string
      final String? fileUrl = currentAvatarUrl.value.isNotEmpty
          ? currentAvatarUrl.value
          : 'default_avatar.jpg';

      await VammisProfileApi().updateProfile(
        userId: userId!,
        username: username,
        bio: bio,
        onSuccess: (data) {
          isLoading.value = false;
          toast('Profile updated successfully');

          // Refresh profile in VammisProfileController
          if (Get.isRegistered<VammisProfileController>()) {
            final profileController = Get.find<VammisProfileController>();
            profileController.refreshProfile();
          }

          Get.back(result: true);
        },
        onError: (error) {
          isLoading.value = false;
          toast('Error: $error');
        },
        onFailure: (response) {
          isLoading.value = false;
          try {
            final errorData = response.body;
            toast('Failed to update profile: $errorData');
          } catch (e) {
            toast('Failed to update profile');
          }
        },
      );
    } catch (e) {
      isLoading.value = false;
      toast('Error: $e');
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    bioController.dispose();
    super.onClose();
  }
}
