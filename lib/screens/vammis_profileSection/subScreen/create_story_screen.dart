import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_api.dart';
import 'package:streamit_laravel/utils/colors.dart';

/// Apna gradient - Add Story (yellow-orange)
const LinearGradient _addStoryGradient = LinearGradient(
  colors: [Color(0xFFFFF176), Color(0xFFFF9800)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  String? mediaUrl;

  TextEditingController captionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              appScreenBackgroundDark,
              Color(0xFF0f0d0a),
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildBody(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildCaptionBar(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
      ),
      title: ShaderMask(
        shaderCallback: (b) => _addStoryGradient.createShader(b),
        child: Text(
          'Add Story',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildCaptionBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            appScreenBackgroundDark.withValues(alpha: 0.95),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1510),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _addStoryGradient.colors.first.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: captionController,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Add a caption...',
                  hintStyle: TextStyle(
                    color: Colors.white54,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
            GestureDetector(
              onTap: _createStory,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: _addStoryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _addStoryGradient.colors.last.withValues(alpha: 0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createStory() async {
    if (mediaUrl == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => WillPopScope(
          child: const Center(
            child: CircularProgressIndicator(),
          ),
          onWillPop: () async {
            return false;
          },),
    );

    //
    await StoryApi().createStory(
        mediaUrl: mediaUrl!,
        caption: (captionController.text.trim().isNotEmpty)?captionController.text.trim():null,
        onSuccess: () {
          toast("Story Created Successfully");
          Navigator.pop(context);
        },
        onError: onError,
        onFail: (d) {
          toast("Failed To create Story with ${d.statusCode}");
        },);

    //
    Navigator.pop(context);
    return;
  }

  Widget _buildBody() {
    if (mediaUrl == null) {
      return _buildEmptyState();
    }
    if (mediaUrl.isImage) {
      return _buildImagePreview();
    }
    if (mediaUrl.isVideo) {
      return const Center(child: Text('This is Video', style: TextStyle(color: Colors.white)));
    }
    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          // Main tap area - card style
          GestureDetector(
            onTap: _selectimage,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 280),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1510),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _addStoryGradient.colors.first.withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _addStoryGradient.colors.first.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _addStoryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: _addStoryGradient.colors.last.withValues(alpha: 0.45),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 20),
                  ShaderMask(
                    shaderCallback: (b) => _addStoryGradient.createShader(b),
                    child: Text(
                      'Add Story',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to add a photo or video',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 15,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Story tips card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1510).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _addStoryGradient.colors.first.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 20, color: _addStoryGradient.colors.first),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Photo or video • Stays 24 hours • Add a caption when ready',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.file(File(mediaUrl!), fit: BoxFit.cover),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            onTap: _selectimage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: _addStoryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _addStoryGradient.colors.last.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Change',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectimage() async {
    final reselt = await FilePicker.platform.pickFiles(
        allowCompression: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg', 'mp4'],);

    if (reselt != null) {
      mediaUrl = reselt.files.first.path;
      setState(() {});
    }
  }
}
