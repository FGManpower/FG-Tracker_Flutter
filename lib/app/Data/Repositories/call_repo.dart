import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
    var response = await HttpUtil().get("/getCallDetail?callId=$callId");
    log("[CallRepo] Call History Detail ($callId) Response: $response");

    if (response is String) {
      return CallHistoryDetailRes.fromJson(jsonDecode(response));
    }
    return CallHistoryDetailRes.fromJson(response);
  }

  static Future<CommonResponse> deleteSingleCallHistory({
    required String callId,
  }) async {
    try {
      final response = await HttpUtil().Authdelete(
        Urls.recentCallHistory,
        queryParameteres: {"callId": callId},
        data: {"callId": callId},
      );
      log("[CallRepo] deleteSingleCallHistory ($callId) Response: $response");
      if (response is Map<String, dynamic>) {
        return CommonResponse.fromJson(response);
      } else if (response is Map) {
        return CommonResponse.fromJson(Map<String, dynamic>.from(response));
      }
      return CommonResponse(
        status: true,
        message: "Call history deleted successfully",
      );
    } catch (e) {
      log("[CallRepo] deleteSingleCallHistory ($callId) error: $e");
      return CommonResponse(status: false, message: e.toString());
    }
  }

  static Future<CommonResponse> deleteMultipleCallHistory({
    required List<String> callIds,
  }) async {
    try {
      final response = await HttpUtil().Authdelete(
        Urls.recentCallHistory,
        data: {"callIds": callIds},
      );
      log("[CallRepo] deleteMultipleCallHistory ($callIds) Response: $response");
      if (response is Map<String, dynamic>) {
        return CommonResponse.fromJson(response);
      } else if (response is Map) {
        return CommonResponse.fromJson(Map<String, dynamic>.from(response));
      }
      return CommonResponse(
        status: true,
        message: "Selected calls deleted successfully",
      );
    } catch (e) {
      log("[CallRepo] deleteMultipleCallHistory error: $e");
      return CommonResponse(status: false, message: e.toString());
    }
  }

  static Future<CommonResponse> clearAllCallHistory() async {
    try {
      final response = await HttpUtil().Authdelete(
        Urls.recentCallHistory,
        data: {"clearAll": true},
      );
      log("[CallRepo] clearAllCallHistory Response: $response");
      if (response is Map<String, dynamic>) {
        return CommonResponse.fromJson(response);
      } else if (response is Map) {
        return CommonResponse.fromJson(Map<String, dynamic>.from(response));
      }
      return CommonResponse(
        status: true,
        message: "All call history cleared successfully",
      );
    } catch (e) {
      log("[CallRepo] clearAllCallHistory error: $e");
      return CommonResponse(status: false, message: e.toString());
    }
  }
}