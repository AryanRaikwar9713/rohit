import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/auth/model/login_response.dart';
import 'package:streamit_laravel/screens/shops_section/model/user_order_history_model.dart';
import 'package:streamit_laravel/utils/constants.dart';

class DB {


  static UserData? _userData;
  static Map<String,String>? _rowHeader;
  static Map<String,String>? _formHeader;
  static bool? _isuseLogIn;

  //Get User Token
  static Future<String?> getUserToke() async {
    if(_userData!=null)
    {
      return _userData!.apiToken;
    }
    else
      {
        final db = await SharedPreferences.getInstance();
        final d = db.getString(SharedPreferenceConst.USER_DATA);
        if (d != null && d.isNotEmpty) {
          final UserData userData = UserData.fromJson(jsonDecode(d));
          final String userToken = userData.apiToken;
          _userData = userData;
          return userToken;
        } else {
          return null;
        }
      }


  }

  //Check User LogIn
  Future<bool> isUserLogIn() async {
    if(_isuseLogIn!=null)
      {
        return _isuseLogIn!;
      }
    else
      {
        final db = await SharedPreferences.getInstance();
        _isuseLogIn = db.getBool(SharedPreferenceConst.IS_LOGGED_IN) ?? false;
        return _isuseLogIn!;
      }

  }

  //get User
   Future<UserData?> getUser() async {

    if(_userData!=null)
      {
        return _userData;
      }

    final db = await SharedPreferences.getInstance();
    final d = db.getString(SharedPreferenceConst.USER_DATA);
    if (d != null && d.isNotEmpty) {
      final UserData userData = UserData.fromJson(jsonDecode(d));
      _userData = userData;
      return _userData;
    } else {
      return null;
    }

  }

  //get UserHeader for Row data
  Future<Map<String, String>?> getHeaderForRow() async
{
  if(_rowHeader!=null)
    {
      return _rowHeader;
    }
  else
    {
      _rowHeader = {
        'Authorization': 'Bearer ${await getUserToke()}',
        'Content-Type': 'application/json',
      };
      return _rowHeader;
    }
}

  Future<Map<String, String>?> getHeaderForForm() async
  {
    if(_formHeader!=null)
    {
      return _formHeader;
    }
    else
    {
      _formHeader = {
        'Authorization': 'Bearer ${await getUserToke()}',
      };
      return _formHeader;
    }
  }


  Future<void> addNewAddress(IngAddress address) async
  {
    List<IngAddress> addressList = [];
    final db = await SharedPreferences.getInstance();
    final d = db.getString(SharedPreferenceConst.USER_ORDER_ADDRESS);
    if (d != null && d.isNotEmpty) {
      addressList = List<IngAddress>.from(jsonDecode(d));
    }
    addressList.add(address);
    db.setString(SharedPreferenceConst.USER_ORDER_ADDRESS, jsonEncode(addressList));
  }

  Future<List<IngAddress>> getUserAddress() async
  {
    final List<IngAddress> addressList = [];
    final db = await SharedPreferences.getInstance();
    final d = db.getString(SharedPreferenceConst.USER_ORDER_ADDRESS);
    if (d != null && d.isNotEmpty) {
      final dataLsit = jsonDecode(d);
      dataLsit.forEach((element) {
        addressList.add(IngAddress.fromJson(element));
      });

    }
    return addressList;
  }

}
