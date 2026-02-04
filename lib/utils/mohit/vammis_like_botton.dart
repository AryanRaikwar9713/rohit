import 'package:flutter/material.dart';

import '../colors.dart';


class WammilsLikeBotton extends StatelessWidget {
  final bool like;
  const WammilsLikeBotton({required this.like,super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
      height: 22,
      width: 22,
      decoration: BoxDecoration(
          shape:BoxShape.circle,
          boxShadow: [
            if(like)
              BoxShadow(
                  color: appColorPrimary.withOpacity(.7),
                  blurRadius: 10,
              ),
          ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
        child: like
            ? Stack(
          children: [
            Positioned(
              top: -0,
              bottom: -0,
              left: -0,
              right: -0,
              child: Image.asset(
                'assets/icons/like_bulbe.png',
                color: appColorPrimary,

              ),
            ),
          ],
        )
            : Icon(
          Icons.lightbulb_outline,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
