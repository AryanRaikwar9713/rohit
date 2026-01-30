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
  bool _isPosting = false;
  List<String> hashtags = [];
  final hashTagController = TextEditingController();

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
      );
    } else {
      toast("Please fill all fields", print: true);
    }
  }

  UserData? user;

  loadUser() async {
    user = await DB().getUser();
    if (mounted) {
      setState(() {});
    }
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
              )),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info
                if (user != null)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          user!.profileImage,
                        ),
                      ),
                      12.width,
                      Text(
                        'You',
                        style: boldTextStyle(size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                20.height,

                //Title,
                TextField(
                  controller: _titleController,
                  style: primaryTextStyle(
                      size: 18, weight: FontWeight.w700, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: secondaryTextStyle(size: 16, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),

                // Caption Input
                TextField(
                  controller: _captionController,
                  maxLines: 5,
                  style: primaryTextStyle(size: 16, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'What\'s on your mind?',
                    hintStyle: secondaryTextStyle(size: 16, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                20.height,
                // Image Section
                if (_selectedImage != null) ...[
                  Container(
                    width: double.infinity,
                    height: 300,
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
                  16.height,
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showImageSourceDialog,
                          icon: const Icon(Icons.edit, color: appColorPrimary),
                          label: Text(
                            'Change Image',
                            style: primaryTextStyle(color: appColorPrimary),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: appColorPrimary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      12.width,
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: Text(
                            'Remove',
                            style: primaryTextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Add Image Button
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[700]!,
                          style: BorderStyle.solid,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShaderMask(
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
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 48,
                              color: Colors.white, // IMPORTANT: White रखें
                            ),
                          ),

                          SizedBox(height: 12),

                          // Text with Gradient
                          ShaderMask(
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
                              'Add Photo',
                              style: boldTextStyle(
                                size: 16,
                                color: Colors.white, // IMPORTANT: White रखें
                              ),
                            ),
                          ),
                          4.height,
                          Text(
                            'Tap to select from gallery or camera',
                            style: secondaryTextStyle(
                                size: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                20.height,
                // Posting Indicator
                Obx(() => _socialController.isUploadingPost.value
                    ? Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  appColorPrimary),
                            ),
                          ),
                          12.width,
                          Text(
                            'Uploading post...',
                            style: secondaryTextStyle(
                                size: 14, color: Colors.grey),
                          ),
                        ],
                      )
                    : const SizedBox.shrink()),

                if (hashtags.isNotEmpty)
                  Wrap(
                    children: hashtags
                        .map((hashtag) => Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 3, vertical: 5),
                              child: Text(
                                '#' + hashtag,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700),
                              ),
                            ))
                        .toList(),
                  ),

                // add Hash Tag
                TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: hashTagController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: grey, width: 1),
                    ),
                    hintText: 'Add Hashtag',
                    hintStyle: secondaryTextStyle(size: 14, color: Colors.grey),
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
                        )),
                  ),
                ),

                //
                10.height,
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
                    border: Border.all(
                      color: Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      // toast("Coming Soon");

                      //
                      FollowerController followController =
                          Get.put(FollowerController());

                      //
                      followController.initData();
                      await showModalBottomSheet(
                          context: context,
                          clipBehavior: Clip.hardEdge,
                          builder: (context) => _FollowBottomSheet(
                                controller: followController,
                              ));

                      //
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FollowBottomSheet extends StatelessWidget {
  final FollowerController controller;
  const _FollowBottomSheet({required this.controller, super.key});

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
                 labelStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 20),
                 unselectedLabelStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 20),
                 dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor: appColorPrimary,
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 10,vertical: 10),
                  indicator: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(200),
                  ),

                  tabs: const [
                Tab(text: "Followers"),
                Tab(text: "Following"),
                // Tab(text: "Following"),
              ]),
              Divider(height: 0,),
              Expanded(
                  child: TabBarView(children: [
                _buildFollowersList(),
                _buildFollowingList(),
              ]))
            ],
          )),
    );
  }

  Widget _buildFollowersList() {
    return Obx(() {

      if(controller.loading.value)
        {
          return Center(child: CircularProgressIndicator(),);
        }

      if (controller.followersList.isEmpty) {
        return Center(
          child: Text(
            "No Followers",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await controller.refrashFollowers();
        },
        child: ListView.builder(
          padding: EdgeInsetsGeometry.symmetric(vertical: 10),
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
          return Center(child: CircularProgressIndicator(),);
        }

      if (controller.followingList.isEmpty) {
        return const Center(
          child: Text(
            "No Followers",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await controller.refrashFollowings();
        },
        child: ListView.builder(
          padding: EdgeInsetsGeometry.symmetric(vertical: 10),
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

        bool sel = controller.selectedUsers.contains(user.id??0);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: [
              //Image
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
                height: 50,
                width: 50,
                child: Image.network(
                  '${user.avatar ?? ""}',
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
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${user.username ?? ''}',
                      style: TextStyle(
                          color: Colors.white.withOpacity(.5),
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
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
                  })
            ],
          ),
        );
      },
    );
  }
}
