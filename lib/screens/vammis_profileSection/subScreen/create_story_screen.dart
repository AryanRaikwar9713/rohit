import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/vammis_profileSection/subScreen/story_api.dart';
import 'package:streamit_laravel/utils/colors.dart';

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


      //
      appBar: AppBar(
        title: const Text("Add Story"),
      ),

      //
      body: Stack(
        children: [
          _buildBody(),

          //
          Positioned(
            left: 0,
              right: 0,
            bottom: 0,
            child: Blur(
              color: Colors.black54,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    //
                    Expanded(
                      child: TextFormField(
                        //
                        controller: captionController,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: GoogleFonts.poppins().fontFamily),

                        //
                        decoration: const InputDecoration(
                          filled: false,
                          hintText: 'Caption',
                        ),
                      ),
                    ),

                    10.width,

                    //
                    GestureDetector(
                      onTap:_createStory,
                      child: const CircleAvatar(
                        backgroundColor: appColorPrimary,
                        child: Icon(Icons.send),
                      ),
                    )
                  ],
                ),
                // child: Row(
                //   mainAxisSize: MainAxisSize.min,
                //   children: [
                //
                //     //
                //     TextFormField(
                //       //
                //       controller: captionController,
                //       style: TextStyle(
                //           color: Colors.white,
                //           fontFamily: GoogleFonts.poppins().fontFamily),
                //
                //       //
                //       decoration: InputDecoration(
                //         filled: false,
                //         hintText: 'Caption',
                //         suffixIcon: GestureDetector(
                //             onTap: _createStory,
                //             child: const Icon(
                //               Icons.send,
                //               color: Colors.white,
                //             )),
                //       ),
                //     ),
                //
                //     //
                //     const CircleAvatar(
                //       child: Icon(Icons.send),
                //     )
                //   ],
                // ),
              ),
            ),
          )
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

  //
  Widget _buildBody() {
    if (mediaUrl == null) {
      return Center(
        child: GestureDetector(
          onTap: _selectimage,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.grey.shade900, shape: BoxShape.circle),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add,
                  size: 40,
                ),
                Text(
                  "Add Story",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: GoogleFonts.poppins().fontFamily),
                )
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
