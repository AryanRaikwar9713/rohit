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
      backgroundColor: appScreenBackgroundDark,
      appBar: AppBar(
        backgroundColor: appScreenBackgroundDark,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: ShaderMask(
          shaderCallback: (b) => _addStoryGradient.createShader(b),
          child: Text(
            'Add Story',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildBody(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    appScreenBackgroundDark.withOpacity(0.85),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                          hintText: 'Caption',
                          hintStyle: TextStyle(
                            color: Colors.white54,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                          filled: true,
                          fillColor: Colors.grey[900],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: _addStoryGradient.colors.first.withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: _addStoryGradient.colors.first.withOpacity(0.35),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: _addStoryGradient.colors.first,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    12.width,
                    GestureDetector(
                      onTap: _createStory,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: _addStoryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _addStoryGradient.colors.first.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
          }),
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
        });

    //
    Navigator.pop(context);
  }

  Widget _buildBody() {
    if (mediaUrl == null) {
      return Center(
        child: GestureDetector(
          onTap: _selectimage,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _addStoryGradient.colors.first.withOpacity(0.15),
                  _addStoryGradient.colors.last.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: _addStoryGradient.colors.first.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _addStoryGradient.colors.first.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (b) => _addStoryGradient.createShader(b),
                  child: const Icon(Icons.add_rounded, size: 48, color: Colors.white),
                ),
                12.height,
                ShaderMask(
                  shaderCallback: (b) => _addStoryGradient.createShader(b),
                  child: Text(
                    'Add Story',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (mediaUrl.isImage) {
      return Center(
          child: GestureDetector(
            onTap: _selectimage,
            child: SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: Image.file(
            File(mediaUrl!),
                    ),
                  ),
          ));
    }
    if (mediaUrl.isVideo) {
      return const Center(child: Text('This is Video'));
    }
    return SizedBox();
  }

  _selectimage() async {
    var reselt = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        allowCompression: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg', 'mp4']);

    if (reselt != null) {
      mediaUrl = reselt.files.first.path;
      setState(() {});
    }
  }
}
