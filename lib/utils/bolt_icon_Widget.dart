import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BoltIconWidget extends StatelessWidget {
  final double? size;
  const BoltIconWidget({this.size,super.key});

  @override
  Widget build(BuildContext context) {
    double exp = -5;
    return Container(
      height: size??24,
      width: size??24,
      // color: kDebugMode?Colors.grey:null,
        child: Stack(children: [
          Positioned(
            top: exp,
              bottom: exp,
              left: exp,
              right: exp,
              child: Image.asset("assets/icons/boalt_Icons.png",fit: BoxFit.cover,))
        ],));
  }
}
