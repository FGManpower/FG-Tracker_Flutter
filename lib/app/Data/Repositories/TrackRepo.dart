import 'dart:developer';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:fgtracker/app/Model/UsersWithinRadiusRes.dart';
import 'package:fgtracker/app/Model/ghost_member_model.dart';
import 'package:fgtracker/app/Model/online_member_model.dart';
import 'package:flutter/foundation.dart';

class TrackRepo {
  static Future<UsersWithinRadiusRes> getUsersWithinRadius({
    required dynamic userId,
    required dynamic userLat,
    required dynamic userLong,
    required dynamic radius,
  }) async {
    final queryParams = {
      "userId": userId,
      "userLat": userLat,
      "userLong": userLong,
      "lat": userLat,
      "long": userLong,
      "radius": radius,
    };

    dynamic response;
    try {
      debugPrint("📍 [TrackRepo] GET ${Urls.usersWithinRadius} - params: $queryParams");
      response = await HttpUtil().get(
        Urls.usersWithinRadius,
        data: queryParams,
      );
      debugPrint("📍 [TrackRepo] Response from /users-within-radius: $response");
    } catch (e) {
      debugPrint("⚠️ Primary ${Urls.usersWithinRadius} failed: $e, trying /user-within-radius fallback");
      try {
        response = await HttpUtil().get(
          Urls.userWithinRadiusFallback,
          data: queryParams,
        );
        debugPrint("📍 [TrackRepo] Response from /user-within-radius: $response");
      } catch (e2) {
        debugPrint("❌ [TrackRepo] Error in getUsersWithinRadius: $e2");
        return UsersWithinRadiusRes(status: false, message: e2.toString(), data: []);
      }
    }

    try {
      if (response is Map<String, dynamic>) {
        return UsersWithinRadiusRes.fromJson(response);
      } else if (response is Map) {
        return UsersWithinRadiusRes.fromJson(Map<String, dynamic>.from(response));
      } else if (response is List) {
        return UsersWithinRadiusRes.fromJson({"status": true, "data": response});
      }
      return UsersWithinRadiusRes.fromJson({});
    } catch (parseErr) {
      debugPrint("❌ [TrackRepo] JSON parse error in getUsersWithinRadius: $parseErr");
      return UsersWithinRadiusRes(status: false, message: parseErr.toString(), data: []);
    }
  }

  static Future<LocationDataRes> getUserLocationData(int groupId) async {
    try {
      debugPrint("📍 [TrackRepo] GET /getGrouplocationsData?groupId=$groupId");
      var response =
          await HttpUtil().get("/getGrouplocationsData?groupId=$groupId");
      debugPrint("📍 [TrackRepo] Response from /getGrouplocationsData: $response");
      return LocationDataRes.fromJson(response);
    } catch (e) {
      debugPrint("❌ [TrackRepo] Error in getUserLocationData: $e");
      return LocationDataRes(status: false, message: e.toString(), locations: []);
    }
  }

  static Future<OnlineMemberModel> getGroupMember({
    String page = '1',
    String filter = 'online',
    int limit = 20,
  }) async {
    try {
      final response = await HttpUtil().get(
        '${Urls.allGroupMembers}'
        '?filter=$filter'
        '&page=$page'
        '&limit=$limit',
      );
      return OnlineMemberModel.fromJson(response);
    } catch (e) {
      return OnlineMemberModel(status: false, message: e.toString(), data: []);
    }
  }

  static Future<GhostMemberModel> getPrivateMembers({
    String page = '1',
    int limit = 20,
  }) async {
    try {
      final response = await HttpUtil().get(
        '${Urls.allGroupMembers}'
        '?filter=private'
        '&page=$page'
        '&limit=$limit',
      );
      return GhostMemberModel.fromJson(response);
    } catch (e) {
      return GhostMemberModel(status: false, message: e.toString(), data: []);
    }
  }

  static Future<bool> updateLocationSharing(bool locationSharing) async {
    try {
      final response = await HttpUtil().post(
        "/location-sharing/update",
        data: {
          "userId": int.parse(
            Global.storageServices.get(PrefConst.userId).toString(),
          ),
          "locationSharing": locationSharing,
        },
      );

      return response["status"] == true;
    } catch (_) {
      return false;
    }
  }
}