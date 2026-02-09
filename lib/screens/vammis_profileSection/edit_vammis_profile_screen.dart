import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/edit_vammis_profile_controller.dart';
import 'package:streamit_laravel/utils/colors.dart';

/// Apna gradient - Edit Profile (yellow-orange)
const LinearGradient _editProfileGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class EditVammisProfileScreen extends StatelessWidget {
  const EditVammisProfileScreen({super.key});

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
                child: controller.isLoading.value
                    ? const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : ShaderMask(
                        shaderCallback: (b) => _editProfileGradient.createShader(b),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: _editProfileGradient.colors.first,
            ),
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
                          gradient: _editProfileGradient,
                          boxShadow: [
                            BoxShadow(
                              color: _editProfileGradient.colors.first.withOpacity(0.35),
                              blurRadius: 14,
                              spreadRadius: 1,
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
                                  child: const Center(child: CircularProgressIndicator(),),),
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
                          gradient: _editProfileGradient,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: appScreenBackgroundDark,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _editProfileGradient.colors.first.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              20.height,
              Text(
                'Tap to change profile picture',
                style: secondaryTextStyle(size: 13, color: Colors.white70),
              ),
              28.height,

              // Username Field (gradient border on focus)
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
                    borderSide: BorderSide(
                      color: _editProfileGradient.colors.first.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _editProfileGradient.colors.first.withOpacity(0.25),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _editProfileGradient.colors.first,
                      width: 1.5,
                    ),
                  ),
                  prefixIcon: ShaderMask(
                    shaderCallback: (b) => _editProfileGradient.createShader(b),
                    child: const Icon(Icons.person, color: Colors.white, size: 22),
                  ),
                ),
              ),
              18.height,

              // Bio Field (gradient border on focus)
              TextField(
                controller: controller.bioController,
                style: primaryTextStyle(color: Colors.white),
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  labelStyle: secondaryTextStyle(color: Colors.white70),
                  hintText: 'Tell us about yourself',
                  hintStyle: secondaryTextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _editProfileGradient.colors.first.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _editProfileGradient.colors.first.withOpacity(0.25),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _editProfileGradient.colors.first,
                      width: 1.5,
                    ),
                  ),
                  prefixIcon: ShaderMask(
                    shaderCallback: (b) => _editProfileGradient.createShader(b),
                    child: const Icon(Icons.description, color: Colors.white, size: 22),
                  ),
                ),
              ),
              28.height,

              // Save Button (gradient)
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => controller.updateProfile(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: _editProfileGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _editProfileGradient.colors.first.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Obx(() => controller.isLoading.value
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : Text(
                              'Save Changes',
                              textAlign: TextAlign.center,
                              style: boldTextStyle(size: 16, color: Colors.black),
                            ),),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
