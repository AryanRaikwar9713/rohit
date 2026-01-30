import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:streamit_laravel/local_db.dart';
import 'package:streamit_laravel/screens/api/otherModels/follower_responce_model.dart';
import 'package:streamit_laravel/screens/shops_section/p/order_api.dart';


class FollowersApi {


  Future<void> getFollowersApi({
    int page = 1,
    String? search,
    required void Function(String) onError,
    required void Function(GetFollowingListResponcModel data) onSuccess,
    required void Function(http.Response) onFail,
}) async
  {
    try
        {

          String uri ='https://app.wamims.world/public/social/followers_following_list_api.php';

          var head = await DB().getHeaderForRow();
          var user = await DB().getUser();

          Logger().i(head);

          var data  = {
            "action": "get_followers",
            "token": '${user?.apiToken}',
            "page": page,
            "limit": 20,
          };

          if(search!=null)
            {
              data['search'] = search;
            }



          var resp = await http.post(Uri.parse(uri),headers:head,
           body: jsonEncode(data),);
          respPrinter(resp.statusCode, resp.body);

          if(resp.statusCode==200)
            {
              onSuccess(getFollowingListResponcModelFromJson(resp.body));
            }
          else
            {
              onFail(resp);
            }

        }
        catch(e)
    {
      onError(e.toString());
    }


    }



  Future<void> getFollowingsApi({
    int page = 1,
    String? search,
    required void Function(String) onError,
    required void Function(GetFollowingListResponcModel data) onSuccess,
    required void Function(http.Response) onFail,
  }) async
  {
    try
    {

      String uri ='https://app.wamims.world/public/social/followers_following_list_api.php';

      var head = await DB().getHeaderForRow();
      var user = await DB().getUser();

      Logger().i(head);

      var data  = {
        "action": "get_following",
        "token": '${user?.apiToken}',
        "page": page,
        "limit": 20,
      };

      if(search!=null)
      {
        data['search'] = search;
      }



      var resp = await http.post(Uri.parse(uri),headers:head,
        body: jsonEncode(data),);
      respPrinter(resp.statusCode, resp.body);

      if(resp.statusCode==200)
      {
        onSuccess(getFollowingListResponcModelFromJson(resp.body));
      }
      else
      {
        onFail(resp);
      }

    }
    catch(e)
    {
      onError(e.toString());
    }


  }

}