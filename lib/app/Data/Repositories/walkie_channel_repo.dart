import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Model/walkie_channel_model.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';

class WalkieChannelRepo {
  static final HttpUtil _httpUtil = HttpUtil();

  /// Fetches dedicated walkie channels with backward-compatible fallback to getGroupData
  static Future<WalkieChannelsResponse> getWalkieChannels() async {
    try {
      debugPrint("📡 [WalkieChannelRepo] Fetching walkie channels: ${Urls.walkieChannels}");
      final response = await _httpUtil.get(Urls.walkieChannels);

      if (response != null && response is Map<String, dynamic>) {
        final parsed = WalkieChannelsResponse.fromJson(response);
        if (parsed.status == true && parsed.data != null) {
          return parsed;
        }
      }
      throw Exception("Unexpected format from walkie/channels");
    } catch (e) {
      debugPrint("⚠️ [WalkieChannelRepo] walkie/channels failed or unavailable ($e). Falling back to get-all-group.");
      try {
        final GroupRes groupRes = await GroupRepo.getGroupData();
        final rawGroups = groupRes.data?.groupData ?? [];

        final channels = rawGroups.map((g) {
          final gId = g.id ?? 0;
          return WalkieChannelItem(
            groupId: gId,
            groupName: g.groupName ?? 'Unnamed Group',
            groupDesc: g.groupDesc,
            groupProfile: g.groupProfile,
            groupImage: g.groupProfile,
            groupCode: g.groupCode,
            memberCount: g.memberCount ?? 0,
            isSelectedChannel: false,
            notificationsEnabled: true, // Default enabled
            isChannelSpeaking: false,
            isOnline: true,
          );
        }).toList();

        return WalkieChannelsResponse(
          status: true,
          message: "Loaded channels via fallback",
          data: WalkieChannelsData(
            activeChannelId: null,
            channels: channels,
          ),
        );
      } catch (fallbackError) {
        log("❌ [WalkieChannelRepo] Fallback getGroupData failed: $fallbackError");
        rethrow;
      }
    }
  }

  /// Updates channel-specific notification preference
  static Future<bool> updateNotificationPreference({
    required int groupId,
    required bool enabled,
  }) async {
    try {
      final url = Urls.walkieChannelNotifications(groupId);
      debugPrint("📡 [WalkieChannelRepo] PATCH $url -> enabled=$enabled");

      final response = await _httpUtil.Authpatch(
        url,
        data: {
          'enabled': enabled,
          'notificationsEnabled': enabled,
        },
      );

      if (response is Map) {
        final status = response['status'] ?? response['success'];
        return status == true;
      }
      return true;
    } catch (e) {
      debugPrint("❌ [WalkieChannelRepo] updateNotificationPreference error: $e");
      rethrow;
    }
  }

  /// Sets single active speaking channel on the backend
  static Future<bool> selectActiveChannel({required int groupId}) async {
    try {
      final url = Urls.walkieActiveChannel;
      debugPrint("📡 [WalkieChannelRepo] PUT $url -> groupId=$groupId");

      final response = await _httpUtil.Authput(
        url,
        data: {'groupId': groupId},
      );

      if (response is Map) {
        final status = response['status'] ?? response['success'];
        return status == true;
      }
      return true;
    } catch (e) {
      debugPrint("❌ [WalkieChannelRepo] selectActiveChannel error: $e");
      rethrow;
    }
  }

  /// Clears active channel selection
  static Future<bool> clearActiveChannel() async {
    try {
      final url = Urls.walkieActiveChannel;
      debugPrint("📡 [WalkieChannelRepo] DELETE $url");

      final response = await _httpUtil.Authdelete(url);
      if (response is Map) {
        final status = response['status'] ?? response['success'];
        return status == true;
      }
      return true;
    } catch (e) {
      debugPrint("❌ [WalkieChannelRepo] clearActiveChannel error: $e");
      return false;
    }
  }
}
