import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/utils/colors.dart';


class AddSocialMedia extends StatefulWidget {
  const AddSocialMedia({super.key});

  @override
  State<AddSocialMedia> createState() => _AddSocialMediaState();
}

class _AddSocialMediaState extends State<AddSocialMedia> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18,),
        title: const Text("Other Social Media"),
      ),


      body: Column(
        children: [

          _buildTextField(label: "YouTube",icon: 'assets/icons/social_media/youtube.png',),

          _buildTextField(label: 'Instagram',icon: 'assets/icons/social_media/instagram.png'),

          _buildTextField(label: 'Facebook',icon: 'assets/icons/social_media/facebook.png'),

          _buildTextField(label: 'Twitter',icon: 'assets/icons/social_media/twitter.png',iconColor: Colors.white),

          // _buildTextField(label: 'Tiktok'),

          _buildTextField(label: 'Linkedin',icon: 'assets/icons/social_media/linkedin.png'),

          //
          // _buildTextField(label: 'Snapchat'),
          //
          // _buildTextField(label: 'Pinterest'),
          //


          40.height,
          Container(
            margin: const EdgeInsetsGeometry.symmetric(horizontal: 10),
            width: double.infinity,
            child: ElevatedButton(onPressed: (){

            }, child: const Text("Save"),),
          ),

        ],
      ),





    );



  }


  Widget _buildTextField({
    Color? iconColor,
    required String icon,
    required String label,
})
  {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 3),
      child: TextField(
        decoration: InputDecoration(

          prefixIcon: SizedBox(
            width: 30,
              height:30,
              child: Center(child: Image.asset(icon,width: 25,height: 25,color:iconColor,)),),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: appColorPrimary),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: appColorPrimary),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white),
          ),
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey.shade600),

        ),
      ),
    );
  }
}
