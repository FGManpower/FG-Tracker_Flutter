import 'dart:async';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/walkie_channel_repo.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';
import 'package:fgtracker/app/Model/walkie_channel_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalkieChannelController extends GetxController {
  final RxList<WalkieChannelItem> channels = <WalkieChannelItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxnInt activeChannelId = RxnInt();
  final RxMap<int, bool> isTogglingPreference = <int, bool>{}.obs;
  final RxBool isSwitchingChannel = false.obs;
  final RxBool isSubscriptionExpired = false.obs;

  StreamSubscription? _socketSub;

  @override
  void onInit() {
    super.onInit();
    fetchChannels();
    _setupSocketListeners();
  }

  @override
  void onClose() {
    _socketSub?.cancel();
    _unbindSocketListeners();
    super.onClose();
  }

  void _setupSocketListeners() {
    final socket = GroupWalkieService.instance.socket;
    if (socket != null) {
      _bindSocketEvents();
    }

    // Also watch when socket connects
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      final s = GroupWalkieService.instance.socket;
      if (s != null && s.connected) {
        _bindSocketEvents();
        timer.cancel();
      }
    });
  }

  dynamic _speakerActiveHandler;
  dynamic _pttReleaseHandler;
  dynamic _speakerStoppedHandler;
  dynamic _channelChangedHandler;

  void _bindSocketEvents() {
    final socket = GroupWalkieService.instance.socket;
    if (socket == null) return;

    _unbindSocketListeners();

    _speakerActiveHandler = (data) {
      if (data == null) return;
      final gIdStr = data['groupId']?.toString();
      if (gIdStr == null || gIdStr.isEmpty) return;

      final gId = int.tryParse(gIdStr);
      final idx = channels.indexWhere((c) => c.groupId == gId);
      if (idx != -1) {
        channels[idx].isChannelSpeaking = true;
        channels[idx].activeSpeakerName = data['speakerName']?.toString();
        channels[idx].activeSpeakerId =
            int.tryParse(data['speakerId']?.toString() ?? '');
        channels[idx].activeSpeakerImage = data['speakerImage']?.toString();
        channels.refresh();
      }
    };
    socket.on('walkie_speaker_active', _speakerActiveHandler);

    _pttReleaseHandler = (data) {
      if (data == null) return;
      final gIdStr = data['groupId']?.toString();
      if (gIdStr == null || gIdStr.isEmpty) return;

      final gId = int.tryParse(gIdStr);
      final idx = channels.indexWhere((c) => c.groupId == gId);
      if (idx != -1) {
        channels[idx].isChannelSpeaking = false;
        channels[idx].activeSpeakerName = null;
        channels[idx].activeSpeakerId = null;
        channels.refresh();
      }
    };
    socket.on('ptt_release', _pttReleaseHandler);

    _speakerStoppedHandler = (data) {
      if (data == null) return;
      final gIdStr = data['groupId']?.toString();
      if (gIdStr == null || gIdStr.isEmpty) return;

      final gId = int.tryParse(gIdStr);
      final idx = channels.indexWhere((c) => c.groupId == gId);
      if (idx != -1) {
        channels[idx].isChannelSpeaking = false;
        channels[idx].activeSpeakerName = null;
        channels[idx].activeSpeakerId = null;
        channels.refresh();
      }
    };
    socket.on('walkie_speaker_stopped', _speakerStoppedHandler);

    _channelChangedHandler = (data) {
      if (data == null) return;
      final activeGroupIdStr =
          (data['activeNotificationGroupId'] ?? data['groupId'])?.toString();
      final bool enabled = data['enabled'] == true ||
          data['enabled'] == 1 ||
          data['enabled']?.toString() == 'true';
      final activeGroupId = int.tryParse(activeGroupIdStr ?? '');

      for (var c in channels) {
        if (activeGroupId != null && enabled) {
          c.notificationsEnabled = (c.groupId == activeGroupId);
        } else {
          c.notificationsEnabled = false;
        }
      }
      channels.refresh();
    };
    socket.on('walkie_notification_channel_changed', _channelChangedHandler);
  }

  void _unbindSocketListeners() {
    final socket = GroupWalkieService.instance.socket;
    if (socket == null) return;
    if (_speakerActiveHandler != null) {
      socket.off('walkie_speaker_active', _speakerActiveHandler);
      _speakerActiveHandler = null;
    }
    if (_pttReleaseHandler != null) {
      socket.off('ptt_release', _pttReleaseHandler);
      _pttReleaseHandler = null;
    }
    if (_speakerStoppedHandler != null) {
      socket.off('walkie_speaker_stopped', _speakerStoppedHandler);
      _speakerStoppedHandler = null;
    }
    if (_channelChangedHandler != null) {
      socket.off('walkie_notification_channel_changed', _channelChangedHandler);
      _channelChangedHandler = null;
    }
  }

  Future<void> fetchChannels({bool showLoading = true}) async {
    if (showLoading) isLoading.value = true;
    errorMessage.value = '';

    try {
      final res = await WalkieChannelRepo.getWalkieChannels();
      final loadedChannels = res.data?.channels ?? [];

      activeChannelId.value = res.data?.activeChannelId;

      // Sync active channel flag if present
      if (activeChannelId.value != null) {
        for (var c in loadedChannels) {
          c.isSelectedChannel = (c.groupId == activeChannelId.value);
        }
      }

      // If server provides top-level activeNotificationGroupId, respect it directly
      final serverActiveNotifId = res.data?.activeNotificationGroupId;
      if (serverActiveNotifId != null) {
        for (var c in loadedChannels) {
          c.notificationsEnabled = (c.groupId == serverActiveNotifId);
        }
      } else {
        // Enforce business rule: At most ONE group notification active in entire list
        int activeNotificationGroupId = -1;
        final activeChannelMatch = loadedChannels.firstWhereOrNull(
            (c) => c.groupId == activeChannelId.value && c.notificationsEnabled);
        if (activeChannelMatch != null) {
          activeNotificationGroupId = activeChannelMatch.groupId;
        } else {
          final firstEnabled =
              loadedChannels.firstWhereOrNull((c) => c.notificationsEnabled);
          if (firstEnabled != null) {
            activeNotificationGroupId = firstEnabled.groupId;
          }
        }

        // Ensure ONLY the active notification group is enabled, all others are disabled
        if (activeNotificationGroupId != -1) {
          for (var c in loadedChannels) {
            c.notificationsEnabled = (c.groupId == activeNotificationGroupId);
          }
        }
      }

      channels.assignAll(loadedChannels);
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint("❌ [WalkieChannelController] fetchChannels error: $e");
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  Future<void> toggleNotificationPreference(WalkieChannelItem channel) async {
    final groupId = channel.groupId;

    // Prevent concurrent taps on the same row
    if (isTogglingPreference[groupId] == true) return;
    isTogglingPreference[groupId] = true;

    // Snapshot previous states for rollback on failure
    final previousStates = {
      for (var c in channels) c.groupId: c.notificationsEnabled
    };
    final bool willBeEnabled = !channel.notificationsEnabled;

    // 1. Optimistic UI update: ONLY ONE group notification can be active at a time!
    // If turning ON: turn OFF all other groups, set this one to true.
    // If turning OFF: set this one to false.
    for (var c in channels) {
      if (willBeEnabled) {
        c.notificationsEnabled = (c.groupId == groupId);
      } else if (c.groupId == groupId) {
        c.notificationsEnabled = false;
      }
    }
    channels.refresh();

    // 2. Real-time Socket Event (emit to /groupWalkie namespace if connected)
    final socket = GroupWalkieService.instance.socket;
    if (socket != null && socket.connected) {
      socket.emit('set_active_notification_channel', {
        'groupId': groupId,
        'enabled': willBeEnabled,
      });
    }

    try {
      final success = await WalkieChannelRepo.updateNotificationPreference(
        groupId: groupId,
        enabled: willBeEnabled,
      );

      if (!success) {
        throw Exception("Server rejected preference change");
      }
    } catch (e) {
      // Revert on failure
      for (var c in channels) {
        if (previousStates.containsKey(c.groupId)) {
          c.notificationsEnabled = previousStates[c.groupId]!;
        }
      }
      channels.refresh();

      Get.snackbar(
        "Notification Setting",
        "Could not update notification setting for ${channel.groupName}. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(12),
      );
    } finally {
      isTogglingPreference[groupId] = false;
    }
  }

  Future<bool> selectActiveSpeakingChannel(WalkieChannelItem channel) async {
    if (isSwitchingChannel.value) return false;
    isSwitchingChannel.value = true;

    final previousActiveId = activeChannelId.value;

    try {
      // 1. Release previous channel speaker state / session if needed
      if (previousActiveId != null && previousActiveId != channel.groupId) {
        if (GroupWalkieService.instance.isTalking) {
          await GroupWalkieService.instance.stopTalking();
        }
        await GroupWalkieService.instance.leaveGroup();
      }

      // 2. Persist new selection on backend
      await WalkieChannelRepo.selectActiveChannel(groupId: channel.groupId);

      // 3. Update local state
      activeChannelId.value = channel.groupId;
      for (var c in channels) {
        c.isSelectedChannel = (c.groupId == channel.groupId);
      }
      channels.refresh();

      // 4. Ensure socket is connected and join new channel session
      final selfId = Global.storageServices.get(PrefConst.userId)?.toString();
      if (selfId != null && selfId.isNotEmpty) {
        await GroupWalkieService.instance.joinGroup(channel.groupId.toString());
      }

      return true;
    } catch (e) {
      debugPrint("❌ [WalkieChannelController] selectActiveSpeakingChannel error: $e");
      final errStr = e.toString().toLowerCase();
      if (errStr.contains("subscription") ||
          errStr.contains("trial") ||
          errStr.contains("expired") ||
          errStr.contains("402") ||
          errStr.contains("403")) {
        isSubscriptionExpired.value = true;
      } else {
        isSubscriptionExpired.value = false;
        Get.snackbar(
          "Channel Switch Error",
          "Could not set ${channel.groupName} as active speaking channel.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(12),
        );
      }
      return false;
    } finally {
      isSwitchingChannel.value = false;
    }
  }

  Future<void> clearActiveChannel() async {
    try {
      if (GroupWalkieService.instance.isTalking) {
        await GroupWalkieService.instance.stopTalking();
      }
      await GroupWalkieService.instance.leaveGroup();
      await WalkieChannelRepo.clearActiveChannel();

      activeChannelId.value = null;
      for (var c in channels) {
        c.isSelectedChannel = false;
      }
      channels.refresh();
    } catch (e) {
      debugPrint("❌ [WalkieChannelController] clearActiveChannel error: $e");
    }
  }
}
