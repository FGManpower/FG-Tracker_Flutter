import 'dart:developer';

import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Model/callDetailRes.dart';
import 'package:fgtracker/app/Model/recent_call.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Core/constant/const_res.dart' show ConstRes;
import '../../Core/constant/pref_res.dart';

class CallRepo {
  static Future<callDetailRes> callDetailData(String callId) async {
    var response = await HttpUtil().get("/getCallDetail?callId=$callId");
    return callDetailRes.fromJson(response);
  }

  static Future<recent_Call_Res> getRecentCall(
      {String page = "0", String type = "all"}) async {
    var response =
        await HttpUtil().get("${Urls.recentCallHistory}?page=$page&type=$type");
    return recent_Call_Res.fromJson(response);
  }

  Future<bool> isCallActive(String callId) async {
    try {
      var pref = await SharedPreferences.getInstance();

      final token = pref.get(PrefConst.STORAGE_USER_TOKEN_KEY);
      final response = await http.get(
        Uri.parse(
          '${ConstRes.aBaseUrl}/getCallDetail?callId=$callId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final status = data['callDetail']?['status']?.toString().toLowerCase();

        return !(status == 'missed' ||
            status == 'rejected' ||
            status == 'ended');
      }
    } catch (e) {
      log("Call Status Check Error => $e");
    }

    return false;
  }
}
