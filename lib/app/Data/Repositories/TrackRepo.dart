import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:fgtracker/app/Model/UsersWithinRadiusRes.dart';
import 'package:fgtracker/app/Model/group_member_model.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'GroupRepo.dart';

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

    // 1. Primary: query /users-within-radius
    try {
      debugPrint(
        "📍 [TrackRepo] GET ${Urls.usersWithinRadius} - params: $queryParams",
      );

      response = await HttpUtil().get(
        Urls.usersWithinRadius,
        data: queryParams,
      );

      debugPrint(
        "📍 [TrackRepo] Response from /users-within-radius: $response",
      );
    } catch (e) {
      debugPrint(
        "⚠️ /users-within-radius failed: $e, trying fallback",
      );
    }

    // 2. Fallback if primary returned no data
    final bool hasData = response != null &&
        ((response is Map &&
                response['data'] is List &&
                (response['data'] as List).isNotEmpty) ||
            (response is List && response.isNotEmpty));

    if (!hasData) {
      try {
        final res2 = await HttpUtil().get(
          Urls.userWithinRadiusFallback,
          data: queryParams,
        );
        if (res2 != null) {
          response = res2;
        }
      } catch (_) {}
    }

    try {
      if (response is Map<String, dynamic>) {
        return UsersWithinRadiusRes.fromJson(response);
      } else if (response is Map) {
        return UsersWithinRadiusRes.fromJson(
          Map<String, dynamic>.from(response),
        );
      } else if (response is List) {
        return UsersWithinRadiusRes.fromJson({
          "status": true,
          "data": response,
        });
      }

      return UsersWithinRadiusRes.fromJson({});
    } catch (parseErr) {
      debugPrint(
        "❌ [TrackRepo] JSON parse error in getUsersWithinRadius: $parseErr",
      );

      return UsersWithinRadiusRes(
        status: false,
        message: parseErr.toString(),
        data: [],
      );
    }
  }

  static Future<LocationDataRes> getUserLocationData(
    int groupId,
  ) async {
    try {
      debugPrint(
        "📍 [TrackRepo] GET /getGrouplocationsData?groupId=$groupId",
      );

      final response = await HttpUtil().get(
        "/getGrouplocationsData?groupId=$groupId",
      );

      debugPrint(
        "📍 [TrackRepo] Response from /getGrouplocationsData: $response",
      );

      final parsed = LocationDataRes.fromJson(response);

      if (parsed.status == true &&
          parsed.locations != null &&
          parsed.locations!.isNotEmpty) {
        return parsed;
      }
    } catch (e) {
      debugPrint(
        "❌ [TrackRepo] Error in getUserLocationData: $e",
      );
    }

    try {
      debugPrint(
        "🔄 [TrackRepo] Falling back to /getMembers?groupId=$groupId",
      );

      final membersRes = await GroupRepo.getMemberData(
        groupId.toString(),
      );

      if (membersRes.status == true && membersRes.memberData != null) {
        final List<LocationData> fallbackList = membersRes.memberData!.map((m) {
          return LocationData(
            id: m.id,
            userId: m.userId,
            groupId: m.groupId,
            name: m.name,
            profileImage: m.profileImage,
            isCreator: m.isCreator,
            isOnline: m.isOnline,
            lastSeen: m.lastSeen,
            locationSharing: m.locationSharing ?? true,
            latitude: 0.0,
            longitude: 0.0,
          );
        }).toList();

        return LocationDataRes(
          status: true,
          message: "Loaded members",
          locations: fallbackList,
        );
      }
    } catch (fallbackErr) {
      debugPrint(
        "❌ [TrackRepo] Fallback error: $fallbackErr",
      );
    }

    return LocationDataRes(
      status: false,
      message: "Failed to load group locations",
      locations: [],
    );
  }

  static Future<GroupMemberModel> getGroupMember({
    String page = '1',
    String filter = 'all',
    int limit = 20,
  }) async {
    try {
      final String url = '${Urls.allGroupMembers}'
          '?filter=$filter'
          '&page=$page'
          '&limit=$limit';

      log("🟢 [TrackRepo] GET Group Members ($filter): $url");
      debugPrint("🟢 [TrackRepo] GET Group Members ($filter): $url");

      final response = await HttpUtil().get(url);

      if (response is Map<String, dynamic>) {
        return GroupMemberModel.fromJson(response);
      }

      if (response is Map) {
        return GroupMemberModel.fromJson(
          Map<String, dynamic>.from(response),
        );
      }

      if (response is List) {
        return GroupMemberModel.fromJson({
          "status": true,
          "filter": filter,
          "data": {
            filter == 'all'
                ? "allMember"
                : (filter == 'private' ? "private" : "active"): response,
          },
        });
      }

      return GroupMemberModel(
        status: false,
        message: "Invalid response format",
      );
    } catch (e) {
      log("❌ [TrackRepo] getGroupMember Error: $e");
      debugPrint("❌ [TrackRepo] getGroupMember Error: $e");

      return GroupMemberModel(
        status: false,
        message: e.toString(),
      );
    }
  }

  static Future<GroupMemberModel> getPrivateMembers({
    String page = '1',
    int limit = 20,
  }) async {
    return getGroupMember(
      page: page,
      filter: 'private',
      limit: limit,
    );
  }

  static Future<bool> updateLocationSharing(
    bool locationSharing,
  ) async {
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
