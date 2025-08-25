
import 'dart:convert';

import 'package:fgtracker/app/Core/util/http/Constant.dart';
import 'package:fgtracker/app/Model/call_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class StorageServices {
  late final SharedPreferences _prefs;

  Future<StorageServices> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }
  Future<bool> getBool(String key) async {
    return  _prefs.getBool(key)??false;
  }

   Future<bool> setDefaultTheme(String key, bool value) async {
   return await _prefs.setBool(key, value);
  }

   Future<bool> getDefaultTheme() async {
     return _prefs.getBool(Constant.isDarkMode)??false;
  }

  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  Future<bool> remove(String key) {
    return _prefs.remove(key);
  }

  String? getaccesstoken() {
    return _prefs.getString(Constant.STORAGE_USER_TOKEN_KEY);
  }

  String? getDevice_Id() {
    return _prefs.getString(Constant.DEVICE_ID);
  }


  CallModel getInComingNotificationData() {
    final data = _prefs.getString(Constant.incomingCall);
    Map<String, dynamic> jsondatais = jsonDecode(data!);
    return CallModel.fromMap(jsondatais);
  }

  String? get(String key) {
    return _prefs.getString(key);
  }



}
