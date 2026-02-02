import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'upload_reel_controller.dart';

/// Apna gradient - Create Reel (yellow-orange)
const LinearGradient _uploadReelGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class UploadReelScreen extends StatefulWidget {
  const UploadReelScreen({super.key});

  @override
  State<UploadReelScreen> createState() => _UploadReelScreenState();
}

class _UploadReelScreenState extends State<UploadReelScreen>
    with TickerProviderStateMixin {
  late UploadReelController _controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = Get.put(UploadReelController());
    _controller.onUploadScreen.value = true;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _controller.onUploadScreen.value = false;
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_controller.isUploading.value,
      onPopInvoked: (didPop) {
        if (!didPop && _controller.isUploading.value) {
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                const Color(0xFF0f0d0a),
              ],
            ),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Obx(() {
              if (_controller.isUploading.value) {
                return _buildUploadProgress();
              }
              if (!_controller.isVideoSelected.value) {
                return _buildVideoSelection();
              }
              return _buildUploadForm();
            }),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Obx(() => IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _controller.isUploading.value
                ? null
                : () => _controller.cancelUpload(),
          )),
      title: ShaderMask(
        shaderCallback: (bounds) => _uploadReelGradient.createShader(bounds),
        child: const Text(
          'Create Reel',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        Obx(() {
          if (_controller.isVideoSelected.value &&
              !_controller.isUploading.value) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: _uploadReelGradient,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9800).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _controller.uploadReel,
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Share',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildVideoSelection() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            // Camera icon with gradient
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _uploadReelGradient,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.videocam_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
            const SizedBox(height: 28),

            // Title with gradient
            ShaderMask(
              shaderCallback: (bounds) => _uploadReelGradient.createShader(bounds),
              child: const Text(
                'Add Video to Reel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle
            Text(
              'Choose a video from your gallery or record a new one',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: _controller.pickVideoFromGallery,
                ),
                const SizedBox(width: 20),
                _buildActionButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: _controller.pickVideoFromCamera,
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Video requirements card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1510),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.25),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => _uploadReelGradient.createShader(bounds),
                    child: const Text(
                      'Video Requirements',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildRequirementItem('Maximum 3 minutes duration'),
                  _buildRequirementItem('Vertical orientation preferred'),
                  _buildRequirementItem('High quality video'),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFF9800).withValues(alpha: 0.5),
              width: 1.5,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1a1510),
                const Color(0xFF0f0d0a),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _uploadReelGradient,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _uploadReelGradient,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildVideoPreview(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCaptionField(),
                const SizedBox(height: 16),
                _buildLocationField(),
                const SizedBox(height: 16),
                _buildHashtagsField(),
                const SizedBox(height: 16),
                _buildVideoInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.black,
      child: Obx(() {
        if (_controller.videoController.value != null) {
          return Stack(
            children: [
              // Video player
              Center(
                child: AspectRatio(
                  aspectRatio:
                      _controller.videoController.value!.value.aspectRatio,
                  child: VideoPlayer(_controller.videoController.value!),
                ),
              ),

              // Play/Pause overlay
              Center(
                child: GestureDetector(
                  onTap: _controller.toggleVideoPlayPause,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _controller.isVideoPlaying.value
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),

              // Change video button
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    _showVideoOptions();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }),
    );
  }

  Widget _buildCaptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Caption',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: _controller.updateCaption,
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Write a caption...',
            hintStyle: TextStyle(color: Colors.grey[500]),
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
              borderSide: const BorderSide(color: Color(0xFFFF9800), width: 1.5),
            ),
            filled: true,
            fillColor: Colors.grey[900],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Location',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _controller.toggleLocationField,
                  child: Icon(
                    _controller.showLocationField.value
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            if (_controller.showLocationField.value) ...[
              const SizedBox(height: 8),
              TextField(
                onChanged: _controller.updateLocation,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Add location...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
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
                    borderSide: const BorderSide(color: Color(0xFFFF9800), width: 1.5),
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                  prefixIcon: const Icon(Icons.location_on, color: Colors.grey),
                ),
              ),
            ],
          ],
        ));
  }

  Widget _buildHashtagsField() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Hashtags',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _controller.toggleHashtagField,
                  child: Icon(
                    _controller.showHashtagField.value
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            if (_controller.showHashtagField.value) ...[
              const SizedBox(height: 8),
              TextField(
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _controller.addHashtag(value.trim().replaceAll('#', ''));
                  }
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Add hashtags...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
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
                    borderSide: const BorderSide(color: Color(0xFFFF9800), width: 1.5),
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                  prefixIcon: const Icon(Icons.tag, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _controller.hashtags
                    .map((hashtag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFF9800).withValues(alpha: 0.2),
                                const Color(0xFFFFF176).withValues(alpha: 0.15),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFF9800).withValues(alpha: 0.6)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ShaderMask(
                                shaderCallback: (b) => _uploadReelGradient.createShader(b),
                                child: Text(
                                  '#$hashtag',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _controller.removeHashtag(hashtag),
                                child: const Icon(
                                  Icons.close,
                                  color: Color(0xFFFF9800),
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ));
  }

  Widget _buildVideoInfo() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1510),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFF9800).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Video Information',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule, color: Colors.grey[400], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Duration: ${_controller.videoDuration.value}',
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.storage, color: Colors.grey[400], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Size: ${_controller.videoSize.value}',
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildUploadProgress() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Progress indicator with gradient
          SizedBox(
            width: 120,
            height: 120,
            child: Obx(() => CircularProgressIndicator(
                  value: _controller.uploadProgress.value,
                  strokeWidth: 4,
                  backgroundColor: const Color(0xFF1a1510),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
                )),
          ),
          const SizedBox(height: 32),

          // Progress text
          Obx(() => Text(
                '${(_controller.uploadProgress.value * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )),
          const SizedBox(height: 16),

           Obx(() => Text(
            (_controller.uploadProgress.value==1)?'Please wait your video is processing...':'Uploading your reel...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),),
          const SizedBox(height: 8),

          Text(
            'Please don\'t close the app',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showVideoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Choose from Gallery',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _controller.pickVideoFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Record New Video',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _controller.pickVideoFromCamera();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
