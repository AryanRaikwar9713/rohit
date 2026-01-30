import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/common_base.dart';
import 'package:streamit_laravel/video_players/model/video_model.dart';

import '../main.dart';

void showSuccessDialog(
  BuildContext context,
  String movieName,
  int days,
  VideoPlayerModel videoModel,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: appColorPrimary,
              child: Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              locale.value.successfullyRented,
              style: boldTextStyle(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              movieName,
              style: primaryTextStyle(),
            ),
            const SizedBox(height: 8),
            Text(
              locale.value.enjoyUntilDays(days),
              style: secondaryTextStyle(),
            ),
            const SizedBox(height: 20),
            AppButton(
              width: Get.width / 2 - 24,
              color: Colors.grey[850],
              onTap: () {
                Get.back(result: true);
              },
              child: Text(
                locale.value.beginWatching,
                style: boldTextStyle(),
              ),
            ),
          ],
        ),
      ),
    ),
  ).then(
    (value) {
      if (value == true) {
        playMovie(
          continueWatchDuration: '',
          newURL: videoModel.videoUrlInput,
          urlType: videoModel.videoUploadType,
          videoType: videoModel.type,
          videoModel: videoModel,
        );
      }
    },
  );
}