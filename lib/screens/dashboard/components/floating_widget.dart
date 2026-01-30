import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

class FloatingWidget extends StatelessWidget {
  const FloatingWidget({
    super.key,
    required this.label,
  });
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: boxDecorationDefault(
            borderRadius: BorderRadius.circular(32),
            color: white,
          ),
          child: Text(
            label,
            style: boldTextStyle(size: 16, color: black, weight: FontWeight.w600),
          ),
          
        ),
        InkWell(
          onTap: () {
            Get.back();
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: boxDecorationDefault(
              borderRadius: BorderRadius.circular(32),
              shape: BoxShape.circle,
              color: white,
            ),
            child: const Icon(
              Icons.close,
              size: 16,
              color: black,
            ),
            
          ),
        ),
      ],
    );
  }
}