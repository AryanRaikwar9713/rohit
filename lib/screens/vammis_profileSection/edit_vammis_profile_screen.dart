import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/edit_vammis_profile_controller.dart';
import 'package:streamit_laravel/utils/colors.dart';

class EditVammisProfileScreen extends StatelessWidget {
  const EditVammisProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EditVammisProfileController controller =
        Get.put(EditVammisProfileController());

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
          'Edit Profile',
          style: boldTextStyle(size: 18, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          Obx(() => TextButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.updateProfile(),
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: controller.isLoading.value
                        ? Colors.grey
                        : appColorPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: appColorPrimary),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Picture Section
              GestureDetector(
                onTap: () => controller.showImageSourceDialog(context),
                child: Stack(
                  children: [
                    Obx(() {
                      final imageFile = controller.selectedImage.value;
                      final avatarUrl = controller.currentAvatarUrl.value;

                      ImageProvider? backgroundImage;
                      if (imageFile != null) {
                        backgroundImage = FileImage(imageFile);
                      } else if (avatarUrl.isNotEmpty) {
                        backgroundImage = NetworkImage('$avatarUrl?v=${DateTime.now().millisecondsSinceEpoch}');
                      }

                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              appColorPrimary,
                              appColorPrimary.withOpacity(0.6),
                              Colors.purple,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: appColorPrimary.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(3),
                        child: Stack(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF0D0D0D),
                              ),
                              padding: const EdgeInsets.all(2),
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.transparent,
                                backgroundImage: backgroundImage,
                                child: imageFile == null && avatarUrl.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                        size: 50,
                                      )
                                    : null,
                              ),
                            ),
                            if(controller.isUploadingImage.value)
                              Container(
                                color: Colors.black.withOpacity(.2),
                                  child: const Center(child: CircularProgressIndicator(),))
                          ],
                        ),
                      );
                    }),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: appColorPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: appScreenBackgroundDark,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              24.height,
              Text(
                'Tap to change profile picture',
                style: secondaryTextStyle(size: 14, color: Colors.white70),
              ),
              32.height,

              // Username Field
              TextField(
                controller: controller.usernameController,
                style: primaryTextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: secondaryTextStyle(color: Colors.white70),
                  hintText: 'Enter username',
                  hintStyle: secondaryTextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: appColorPrimary, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.person, color: Colors.white70),
                ),
              ),
              16.height,

              // Bio Field
              TextField(
                controller: controller.bioController,
                style: primaryTextStyle(color: Colors.white),
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  labelStyle: secondaryTextStyle(color: Colors.white70),
                  hintText: 'Tell us about yourself',
                  hintStyle: secondaryTextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: appColorPrimary, width: 2),
                  ),
                  prefixIcon:
                      const Icon(Icons.description, color: Colors.white70),
                ),
              ),
              32.height,

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.updateProfile(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColorPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Obx(() => controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: boldTextStyle(size: 16, color: Colors.white),
                        )),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
