import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/shops_section/p/order_api.dart';
import 'package:streamit_laravel/screens/video_channel/modals/channel_model.dart';

class VideoChannelApi {


  Future<void> getChannel({
    required void Function(GetChannelResponceModel data) onSuccess,
    required void Function(String) onError,
    required void Function(http.Response) onFail,
}) async
  {
    try {

      String uri = 'https://app.wamims.world/public/social/channel_api.php?action=get_channel';

      var head  = await DB().getHeaderForForm();

      var response = await http.post(Uri.parse(uri), headers: head);

      respPrinter(response.statusCode, response.body);

      if(response.statusCode==200)
        {
          var d = jsonDecode(response.body);
          onSuccess(GetChannelResponceModel.fromJson(d));
        }
      else
        {
          onFail(response);
        }

    } catch (e) {
      onError(e.toString());
      Logger().e("Error in Function $e");
    }
  }



  Future<void> createVideoChanel({
    required String channelImage,
    required String channelName,
    required String description,
    required String username,
    required void Function() onSuccess,
    required void Function(String) onError,
    required void Function(http.Response) onFail,
}) async
  {
    try {
      String uri = 'https://app.wamims.world/public/social/channel_api.php?action=create_channel';
      var d = {
        'channel_name':channelName,
        'description':description,
        'username':username,
      };


      var head = await DB().getHeaderForForm();

      var request = http.MultipartRequest('POST', Uri.parse(uri));

      request.headers.addAll(head);

      request.fields.addAll(d);

      request.files.add(await http.MultipartFile.fromPath('image', channelImage));

      var response = await request.send();

      var res = await response.stream.bytesToString();

      respPrinter(response.statusCode, res);

      if(response.statusCode==200||response.statusCode==201)
        {
          onSuccess();
        }
      else
        {
          onFail(http.Response(res, response.statusCode));
        }

    } catch (e) {
      onError(e.toString());
      Logger().e("Error in Function $e");
    }
  }

}