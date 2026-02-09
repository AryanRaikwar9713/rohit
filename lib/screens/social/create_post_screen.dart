import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/api/otherModels/follower_controoelrs.dart';
import 'package:streamit_laravel/screens/api/otherModels/follower_responce_model.dart';
import 'package:streamit_laravel/screens/auth/model/login_response.dart';

import '../../utils/colors.dart';
import '../../widgets/bottom_navigation_wrapper.dart';
import 'social_controller.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  late SocialController _socialController;
  File? _selectedImage;
  final bool _isPosting = false;
  List<String> hashtags = [];
  final hashTagController = TextEditingController();
  bool _switchOne = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _socialController = (Get.isRegistered<SocialController>())
        ? Get.find<SocialController>()
        : Get.put(SocialController());
    loadUser();
    _socialController.onCreatePostScreen.value = true;
  }

  @override
  void dispose() {
    _captionController.dispose();
    _socialController.onCreatePostScreen.value = false;
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      toast('Error picking image: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      toast('Error taking photo: $e');
    }
  }

  Future<void> _showImageSourceDialog() async {
    await showModalBottomSheet(
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
                      _pickImage();
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
                      _takePhoto();
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

  Future<void> _createPost() async {
    if (_captionController.text.trim().isNotEmpty &&
        _titleController.text.trim().isNotEmpty) {
      _socialController.createPost(
        title: _titleController.text.trim(),
        imagePath: _selectedImage?.path,
        hashtags: hashtags,
        caption: _captionController.text.trim(),
        showDonateButton: _switchOne,
      );
    } else {
      toast("Please fill all fields", print: true);
    }
  }

  UserData? user;

  Future<void> loadUser() async {
    user = await DB().getUser();
    if (mounted) {
      setState(() {});
    }
  }

  /// Same as image: dark green banner, green checkmark box, "Your account is approved and active"
  Widget _buildAccountApprovedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3D2C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF3CC46F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Your account is approved and active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You can create projects and receive funding.',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_socialController.isUploadingPost.value,
      onPopInvoked: (didPop) {
        if (!didPop && _socialController.isUploadingPost.value) {
          // Show a message that upload is in progress
          Get.snackbar(
            'Upload in Progress',
            'Please wait for the upload to complete',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      },
      child: BottomNavigationWrapper(
        child: Scaffold(
          backgroundColor: appScreenBackgroundDark,
          appBar: AppBar(
            backgroundColor: Colors.grey[900],
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                if (!_socialController.isUploadingPost.value) {
                  Get.back();
                }
              },
              icon: const Icon(Icons.close, color: Colors.white),
            ),
            title: Text(
              'Create Post',
              style: boldTextStyle(size: 20, color: Colors.white),
            ),
            actions: [
              Obx(() => TextButton(
                onPressed:
                (_isPosting || _socialController.isUploadingPost.value)
                    ? null
                    : _createPost,
                child: (_isPosting || _socialController.isUploadingPost.value)
                    ? Text(
                  'Post',
                  style: boldTextStyle(
                    size: 18,
                    color: Colors.grey,
                  ),
                )
                    : ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [
                        Colors.yellow.shade400,  // Yellow
                        Colors.orange.shade400,  // Orange
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    'Post',
                    style: boldTextStyle(
                      size: 18,
                      color: Colors.white, // IMPORTANT: White रखें
                    ),
                  ),
                ),
              ),),
            ],
          ),
          body: Column(
            children: [
              // Facebook-style header with user info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[800]!),
                  ),
                ),
                child: Row(
                  children: [
                    // User Avatar
                    if (user != null) CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(
                              user!.profileImage,
                            ),
                            backgroundColor: Colors.grey[700],
                            child: user!.profileImage.isEmpty
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ) else CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey[700],
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                    const SizedBox(width: 12),
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.firstName ?? 'You',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.public,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Public',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main content area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Input
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Post title...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Caption Input
                      TextField(
                        controller: _captionController,
                        maxLines: 8,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.4,
                        ),
                        decoration: const InputDecoration(
                          hintText: "What's on your mind?",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      
                      // Image Section
                      if (_selectedImage != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[700]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton.icon(
                                  onPressed: _showImageSourceDialog,
                                  icon: const Icon(Icons.edit, color: appColorPrimary),
                                  label: const Text(
                                    'Edit',
                                    style: TextStyle(color: appColorPrimary),
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 24,
                                color: Colors.grey[600],
                              ),
                              Expanded(
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _selectedImage = null;
                                    });
                                  },
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  label: const Text(
                                    'Remove',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 20),
                      
                      // Hashtags Section
                      if (hashtags.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: hashtags
                              .map((hashtag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6,),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.yellow.shade400,
                                          Colors.orange.shade400,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '#$hashtag',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: () {
                                            hashtags.remove(hashtag);
                                            setState(() {});
                                          },
                                          child: const Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),)
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Add Hashtag Input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[700]!),
                        ),
                        child: TextField(
                          controller: hashTagController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Add hashtag...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(12),
                            suffixIcon: IconButton(
                              onPressed: () {
                                if (hashTagController.text.trim().isNotEmpty) {
                                  hashtags.add(hashTagController.text.trim());
                                  hashTagController.clear();
                                  setState(() {});
                                }
                              },
                              icon: const Icon(
                                Icons.add,
                                color: appColorPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Tag People Button
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.yellow.shade400,
                              Colors.orange.shade400,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            final FollowerController followController =
                                Get.put(FollowerController());
                            followController.initData();
                            await showModalBottomSheet(
                                context: context,
                                clipBehavior: Clip.hardEdge,
                                builder: (context) => _FollowBottomSheet(
                                      controller: followController,
                                    ),);
                            followController.cleareData();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Tag People",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Two boxes at bottom
                      _buildAccountApprovedBanner(),
                      const SizedBox(height: 24),
                      
                      // Single toggle - left side, gradient theme when on
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Switch(
                          value: _switchOne,
                          onChanged: (v) => setState(() => _switchOne = v),
                          activeTrackColor: Colors.orange.shade400,
                          activeColor: Colors.white,
                          inactiveTrackColor: Colors.grey.shade700,
                          inactiveThumbColor: Colors.grey.shade400,
                        ),
                      ),
                      
                      const SizedBox(height: 40), // Bottom padding (scroll end)
                    ],
                  ),
                ),
              ),
              
              // Facebook-style bottom action bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  border: Border(
                    top: BorderSide(color: Colors.grey[800]!),
                  ),
                ),
                child: Column(
                  children: [
                    // Add to post section
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12,),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return LinearGradient(
                                        colors: [
                                          Colors.yellow.shade400,
                                          Colors.orange.shade400,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ).createShader(bounds);
                                    },
                                    child: const Icon(
                                      Icons.photo_library,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Add Photo',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Posting Indicator
                    Obx(() => _socialController.isUploadingPost.value
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      appColorPrimary,),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Uploading post...',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FollowBottomSheet extends StatelessWidget {
  final FollowerController controller;
  const _FollowBottomSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade800,
      width: double.infinity,
      child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
               TabBar(
                 labelStyle: const TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 20),
                 unselectedLabelStyle: const TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 20),
                 dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor: appColorPrimary,
                  padding: const EdgeInsetsGeometry.symmetric(horizontal: 10,vertical: 10),
                  indicator: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.yellow.shade400,
                        Colors.orange.shade400,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(200),
                  ),

                  tabs: const [
                Tab(text: "Followers"),
                Tab(text: "Following"),
                // Tab(text: "Following"),
              ],),
              const Divider(height: 0,),
              Expanded(
                  child: TabBarView(children: [
                _buildFollowersList(),
                _buildFollowingList(),
              ],),),
            ],
          ),),
    );
  }

  Widget _buildFollowersList() {
    return Obx(() {

      if(controller.loading.value)
        {
          return const Center(child: CircularProgressIndicator(),);
        }

      if (controller.followersList.isEmpty) {
        return const Center(
          child: Text(
            "No Followers",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20,),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await controller.refrashFollowers();
        },
        child: ListView.builder(
          padding: const EdgeInsetsGeometry.symmetric(vertical: 10),
          itemCount: controller.followersList.length,
          itemBuilder: (context, index) {
            return _buldFollowersTile(controller.followersList[index]);
          },
        ),
      );
    });
  }

  Widget _buildFollowingList() {
    return Obx(() {

      if(controller.loading.value)
        {
          return const Center(child: CircularProgressIndicator(),);
        }

      if (controller.followingList.isEmpty) {
        return const Center(
          child: Text(
            "No Followers",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20,),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await controller.refrashFollowings();
        },
        child: ListView.builder(
          padding: const EdgeInsetsGeometry.symmetric(vertical: 10),
          itemCount: controller.followingList.length,
          itemBuilder: (context, index) {
            return _buldFollowersTile(controller.followingList[index]);
          },
        ),
      );
    });
  }

  Widget _buldFollowersTile(FollwerOrFlollowingUser user) {
    return Obx(
      () {

        final bool sel = controller.selectedUsers.contains(user.id??0);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: [
              //Image
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
                height: 50,
                width: 50,
                child: Image.network(
                  user.avatar ?? "",
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.person);
                  },
                ),
              ),

              5.width,

              //Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${user.firstName ?? ''} ${user.lastName ?? ''}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,),
                    ),
                    Text(
                      user.username ?? '',
                      style: TextStyle(
                          color: Colors.white.withOpacity(.5),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,),
                    ),
                  ],
                ),
              ),

              //
              Checkbox(
                  value: sel,
                  onChanged: (d) {
                    controller.selectUser(user.id ?? 0);
                    print(d);
                  },),
            ],
          ),
        );
      },
    );
  }
}
