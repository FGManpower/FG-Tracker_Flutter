import 'package:fgtracker/l10n/l10n.dart';
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

  /// Server status of a call (`callDetail.status`, lower case), or `null`
  /// when it is unknown: no token, no network, timeout, non-200, bad body.
  ///
  /// `null` must never be read as "ended": the old [isCallActive] returned
  /// `false` on any error, which would dismiss a real ringing call when the
  /// phone is offline (BUG-CALL-24). Used to clear stale ringing calls on
  /// app start / resume (BUG-CALL-10).
  static Future<String?> fetchCallStatus(
    String callId, {
    Duration timeout = const Duration(seconds: 4),
  }) async {
    if (callId.isEmpty) return null;
    try {
      final pref = await SharedPreferences.getInstance();
      final token = pref.get(PrefConst.STORAGE_USER_TOKEN_KEY);
      if (token == null || token.toString().isEmpty) return null;

      final Uri uri = Uri.parse('${ConstRes.aBaseUrl}getCallDetail')
          .replace(queryParameters: <String, String>{'callId': callId});
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(timeout);
      if (response.statusCode != 200) return null;

      final dynamic data = jsonDecode(response.body);
      if (data is! Map) return null;
      final dynamic detail = data['callDetail'];
      if (detail is! Map) return null;
      final String? status =
          detail['status']?.toString().trim().toLowerCase();
      return (status == null || status.isEmpty) ? null : status;
    } catch (e) {
      log("[CALL] fetchCallStatus unknown: ${e.runtimeType}");
      return null;
    }
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
        message: appL10n.repo_callDeleted,
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
        message: appL10n.repo_selectedCallsDeleted,
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
        message: appL10n.repo_allCallsCleared,
      );
    } catch (e) {
      log("[CallRepo] clearAllCallHistory error: $e");
      return CommonResponse(status: false, message: e.toString());
    }
  }
}