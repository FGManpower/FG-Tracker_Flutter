import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Core/constant/const_res.dart' show ConstRes;
import '../../Core/constant/pref_res.dart';
import '../../Core/constant/urls.dart';
import '../../Core/util/http/http_util.dart';
import '../../Model/CallDetail.dart';
import '../../Model/CommonRes.dart';
import '../../Model/callDetailRes.dart';
import '../../Model/recent_call.dart';

class CallRepo {
  static Future<callDetailRes> callDetailData(String callId) async {
    var response = await HttpUtil().get("/getCallDetail?callId=$callId");
    return callDetailRes.fromJson(response);
  }

  static Future<recent_Call_Res> getRecentCall({
    String page = "0",
    String type = "all",
  }) async {
    var response = await HttpUtil().getRecentCall(
      "${Urls.recentCallHistory}?page=$page&type=$type",
    );
    log("[CallRepo] Recent Calls Response: $response");
    return recent_Call_Res.fromJson(response);
  }

  static Future<CommonResponse> updateCallingStatus({
    required dynamic callId,
    remoteUserId,
    callingStatus,
  }) async {
    dynamic param = {
      "callId": callId,
      "remoteUserId": remoteUserId,
      "callingStatus": callingStatus,
    };
    var response = await HttpUtil().updateCallingStatusPost(
      Urls.callingStatus,
      data: param,
    );
    log("[CallRepo] Update Calling Status Response: $response");
    return CommonResponse.fromJson(response);
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

  static Future<CallHistoryDetailRes> getCallHistoryDetail(String callId) async {
    var response = await HttpUtil().get("/api/call/getCallDetail?callId=$callId");
    log("[CallRepo] Call History Detail ($callId) Response: $response");

    if (response is String) {
      return CallHistoryDetailRes.fromJson(jsonDecode(response));
    }
    return CallHistoryDetailRes.fromJson(response);
  }
}