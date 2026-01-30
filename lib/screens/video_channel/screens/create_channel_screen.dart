import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/video_channel/video_channel_api.dart';

class CreateVideoChannelScreen extends StatefulWidget {
  const CreateVideoChannelScreen({super.key});

  @override
  State<CreateVideoChannelScreen> createState() =>
      _CreateVideoChannelScreenState();
}

class _CreateVideoChannelScreenState extends State<CreateVideoChannelScreen> {
  final PageController pageController = PageController();

  String? channelImage;
  int pageIndex = 0;
  TextEditingController channelNameController = TextEditingController();
  TextEditingController channelDescriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //
      appBar: AppBar(
        //
        leading: IconButton(

            //
            onPressed: () {
              if (pageIndex == 0) {
                Navigator.pop(context);
              } else {
                pageController.previousPage(
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.linear);
              }
            },

            //
            icon: const Icon(Icons.arrow_back)),
        //
        title: const Text('Create Channel'),
      ),

      //
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      //
      floatingActionButton: Container(
          margin:
              const EdgeInsetsGeometry.symmetric(horizontal: 15, vertical: 10),
          width: double.infinity,
          child: ElevatedButton(
              onPressed: () {
                if (pageIndex == 0) {
                  if (channelImage != null) {
                    pageController.nextPage(
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.linear);
                  }
                } else {
                  createVideoChannel();
                }
              },
              child: Text((pageIndex == 0) ? "Next" : 'Create'))),

      //
      body: PageView(

        //
        physics: const NeverScrollableScrollPhysics(),

        //
        onPageChanged: (d) {
          pageIndex = d;
          setState(() {});
        },
        controller: pageController,
        children: [
          //
          _selectChannelImageWidget(),

          //
          _buildFields(),
        ],
      ),
    );
  }

  //_selectChannelImage
  Widget _selectChannelImageWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _selectProfileImage,
            child: Container(
                height: 120,
                width: 120,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  shape: BoxShape.circle,
                  image: (channelImage != null)
                      ? DecorationImage(
                          image: FileImage(File(channelImage!)),
                          fit: BoxFit.cover)
                      : null,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: (channelImage == null)
                    ? const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 40,
                      )
                    // : Image.file(File(channelImage!),
                    //     : Image.file(File(channelImage!),
                    // fit: BoxFit.cover,),
                    : SizedBox()),
          ),
          24.height,

          //
          Text(
            "Image For Your Channel Profile",
            style: TextStyle(
                fontFamily: GoogleFonts.poppins().fontFamily,
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),

          35.height,

          ElevatedButton(
              onPressed: _selectProfileImage,
              child: Text(
                  (channelImage == null) ? "Select Image" : 'Change Image'))
        ],
      ),
    );
  }

  Widget _buildFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(

        children: [
          24.height,

          //
          TextFormField(
            controller: channelNameController,
            style: TextStyle(
                color: Colors.white,
                fontFamily: GoogleFonts.poppins().fontFamily),
            decoration: const InputDecoration(hintText: 'Channel Name'),
          ),

          24.height,

          //
          TextFormField(
            controller: channelDescriptionController,
            maxLines:10,

            style: TextStyle(
                color: Colors.white,
                fontFamily: GoogleFonts.poppins().fontFamily),
            decoration: const InputDecoration(
              hintText: 'Channel Description',
            ),
          )
        ],
      ),
    );
  }


  //
  Future<void> _selectProfileImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    print("Select  image Result");
    if (image != null) {
      channelImage = image.path;
      setState(() {});
    }
  }


  //
 Future<void> createVideoChannel() async
  {
    if(channelNameController.text.trim().isEmpty||channelDescriptionController.text.trim().isEmpty)
      {
        toast("Enter Channel Name and Description");
      }
    else
      {
        var username = await DB().getUser();

        showDialog(context: context, builder: (context) => WillPopScope(
          onWillPop: ()async{return false;},
            child: const Center(child: CircularProgressIndicator(),)),
        barrierDismissible: false);

        await VideoChannelApi().createVideoChanel(
            channelImage: channelImage!,
            channelName: channelNameController.text.trim(),
            description: channelDescriptionController.text.trim(),
            username: username?.fullName??'',
            onSuccess: (){
              toast("Channel Created Successfully");
              Navigator.pop(context);
            },
            onError: onError,
            onFail: (d){
              toast("Failed To create channel With status ${d.statusCode}");
            });

        Navigator.pop(context);

      }
  }


}
