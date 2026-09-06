import 'dart:developer';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:fgtracker/app/Model/UsersWithinRadiusRes.dart';
import 'package:fgtracker/app/Model/member_live_status.dart';
import 'package:flutter/foundation.dart';

class TrackRepo {
  static Future<UsersWithinRadiusRes> getUsersWithinRadius({
    required dynamic userId,
    required dynamic userLat,
    required dynamic userLong,
    required dynamic radius,
  }) async {
    try {
      debugPrint("📍 [TrackRepo] GET ${Urls.usersWithinRadius} - params: userId: $userId, userLat: $userLat, userLong: $userLong, radius: $radius");
      var response = await HttpUtil().get(
        Urls.usersWithinRadius,
        data: {
          "userId": userId,
          "userLat": userLat,
          "userLong": userLong,
          "radius": radius,
        },
      );
      debugPrint("📍 [TrackRepo] Response from /users-within-radius: $response");
      if (response is Map<String, dynamic>) {
        return UsersWithinRadiusRes.fromJson(response);
      } else if (response is Map) {
        return UsersWithinRadiusRes.fromJson(Map<String, dynamic>.from(response));
      } else if (response is List) {
        return UsersWithinRadiusRes.fromJson({"status": true, "data": response});
      }
      return UsersWithinRadiusRes.fromJson({});
    } catch (e) {
      debugPrint("❌ [TrackRepo] Error in getUsersWithinRadius: $e");
      return UsersWithinRadiusRes(status: false, message: e.toString(), data: []);
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

  static Future<MemberLiveStatus> getGroupMember({
    String page = '0',
    String filter = 'online',
  }) async {
    try {
      final response = await HttpUtil().get(
        '${Urls.allGroupMembers}'
        '?page=$page'
        '&filter=$filter',
      );
      return MemberLiveStatus.fromJson(response);
    } catch (e) {
      return MemberLiveStatus(status: false, message: e.toString(), data: []);
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