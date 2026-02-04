import 'package:flutter/material.dart';
import 'package:streamit_laravel/utils/colors.dart';


class WamimsProfileAvtar extends StatelessWidget {
  final bool story;
  final String image;
  final double? radious;
  final double? borderWidth;
  final Function()? onTap;
  const WamimsProfileAvtar({this.borderWidth,this.story = false,this.radious,this.onTap,required this.image,super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border:story? Border.all(color: Colors.yellow):null,
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
            color: story?Colors.yellow.withOpacity(0.7):appColorPrimary.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      padding:  EdgeInsets.all(borderWidth??3),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          clipBehavior: Clip.hardEdge,
          height: (radious??50)*2,
          width: (radious??50)*2,
          decoration:  const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF0D0D0D),
            // color: Colors.green

          ),
          padding: const EdgeInsetsGeometry.all(2),
          child: ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: BorderRadiusGeometry.circular((radious??50)*2),
            child: Image.network('$image?v=${DateTime.now().millisecondsSinceEpoch}',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.person_rounded,color: Colors.white,size: (radious??50)*1.5,);
              },
            ),
          ),
        ),
      ),
    );
  }
}
