import 'dart:async';
import 'dart:convert';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/walkie_channel_repo.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';
import 'package:fgtracker/app/Model/walkie_channel_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

class WalkieChannelController extends GetxController {
  final RxList<WalkieChannelItem> channels = <WalkieChannelItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxnInt activeChannelId = RxnInt();
  final RxMap<int, bool> isTogglingPreference = <int, bool>{}.obs;
  final RxBool isSwitchingChannel = false.obs;
  final RxBool isSubscriptionExpired = false.obs;

  void _safeChannelsRefresh() {
    if (WidgetsBinding.instance.schedulerPhase ==
            SchedulerPhase.persistentCallbacks ||
        WidgetsBinding.instance.schedulerPhase ==
            SchedulerPhase.midFrameMicrotasks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        channels.refresh();
      });
    } else {
      channels.refresh();
    }
  }

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
    unsubscribeChannelUpdates();
    _unbindSocketListeners();
    super.onClose();
  }

  void _setupSocketListeners() {
    final socket = GroupWalkieService.instance.socket;
    if (socket != null) {
      _bindSocketEvents();
      if (socket.connected) {
        subscribeChannelUpdates();
      }
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
        subscribeChannelUpdates();
        timer.cancel();
      }
    });
  }

  dynamic _speakerActiveHandler;
  dynamic _pttReleaseHandler;
  dynamic _speakerStoppedHandler;
  dynamic _channelChangedHandler;
  dynamic _channelSpeakerUpdateHandler;
  dynamic _inviteHandler;

  void _bindSocketEvents() {
    final socket = GroupWalkieService.instance.socket;
    if (socket == null) return;

    _unbindSocketListeners();

    _speakerActiveHandler = (data) => onSpeakerActiveFromSocket(data);
    socket.on('walkie_speaker_active', _speakerActiveHandler);

    _pttReleaseHandler = (data) => onSpeakerStoppedFromSocket(data);
    socket.on('ptt_release', _pttReleaseHandler);

    _speakerStoppedHandler = (data) => onSpeakerStoppedFromSocket(data);
    socket.on('walkie_speaker_stopped', _speakerStoppedHandler);

    _channelSpeakerUpdateHandler = (data) => onChannelSpeakerUpdateFromSocket(data);
    socket.on('walkie_channel_speaker_update', _channelSpeakerUpdateHandler);

    _inviteHandler = (data) => onSpeakerActiveFromSocket(data);
    socket.on('walkie_invite', _inviteHandler);

    _channelChangedHandler = (data) {
      if (data == null) return;
      try {
        final Map<String, dynamic> map = data is Map
            ? Map<String, dynamic>.from(data)
            : (data is String ? jsonDecode(data) : {});
        final activeGroupIdStr =
            (map['activeNotificationGroupId'] ?? map['groupId'])?.toString();
        final bool enabled = map['enabled'] == true ||
            map['enabled'] == 1 ||
            map['enabled']?.toString() == 'true';
        final activeGroupId = int.tryParse(activeGroupIdStr ?? '');

        for (var c in channels) {
          if (activeGroupId != null && enabled) {
            c.notificationsEnabled = (c.groupId == activeGroupId);
          } else {
            c.notificationsEnabled = false;
          }
        }
        _safeChannelsRefresh();
      } catch (e) {
        debugPrint("⚠️ [WalkieChannelController] channelChangedHandler error: $e");
      }
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
    if (_channelSpeakerUpdateHandler != null) {
      socket.off('walkie_channel_speaker_update', _channelSpeakerUpdateHandler);
      _channelSpeakerUpdateHandler = null;
    }
    if (_inviteHandler != null) {
      socket.off('walkie_invite', _inviteHandler);
      _inviteHandler = null;
    }
    if (_channelChangedHandler != null) {
      socket.off('walkie_notification_channel_changed', _channelChangedHandler);
      _channelChangedHandler = null;
    }
  }

  void subscribeChannelUpdates() {
    try {
      final socket = GroupWalkieService.instance.socket;
      if (socket != null && socket.connected && channels.isNotEmpty) {
        final groupIds = channels.map((c) => c.groupId).toList();
        socket.emit('subscribe_channel_updates', {'groupIds': groupIds});
        debugPrint("📡 [WalkieChannelController] Emitted subscribe_channel_updates: $groupIds");
      }
    } catch (e) {
      debugPrint("⚠️ [WalkieChannelController] subscribeChannelUpdates error: $e");
    }
  }

  void unsubscribeChannelUpdates() {
    try {
      final socket = GroupWalkieService.instance.socket;
      if (socket != null && socket.connected && channels.isNotEmpty) {
        final groupIds = channels.map((c) => c.groupId).toList();
        socket.emit('unsubscribe_channel_updates', {'groupIds': groupIds});
      }
    } catch (_) {}
  }

  void onSpeakerActiveFromSocket(dynamic rawData) {
    if (rawData == null) return;
    try {
      final Map<String, dynamic> data = rawData is Map
          ? Map<String, dynamic>.from(rawData)
          : (rawData is String ? jsonDecode(rawData) : {});

      final gIdStr = (data['groupId'] ??
              data['group_id'] ??
              data['channelId'] ??
              data['id'])
          ?.toString();
      if (gIdStr == null || gIdStr.isEmpty) return;

      final gId = int.tryParse(gIdStr);
      if (gId == null) return;

      final idx = channels.indexWhere((c) => c.groupId == gId);
      if (idx != -1) {
        final parsedSpeakerName = (data['speakerName'] ??
                data['speaker_name'] ??
                data['activeSpeakerName'] ??
                data['name'] ??
                data['userName'])
            ?.toString();
        final parsedSpeakerId = int.tryParse((data['speakerId'] ??
                data['speaker_id'] ??
                data['activeSpeakerId'] ??
                data['userId'])
            ?.toString() ?? '');
        final parsedSpeakerImage = (data['speakerImage'] ??
                data['speaker_image'] ??
                data['activeSpeakerImage'] ??
                data['image'] ??
                data['profile'])
            ?.toString();

        // Avoid redundant refreshes if state already matches
        if (channels[idx].isChannelSpeaking &&
            channels[idx].activeSpeakerName == parsedSpeakerName &&
            channels[idx].activeSpeakerId == parsedSpeakerId) {
          return;
        }

        channels[idx].isChannelSpeaking = true;
        channels[idx].activeSpeakerName = parsedSpeakerName;
        channels[idx].activeSpeakerId = parsedSpeakerId;
        channels[idx].activeSpeakerImage = parsedSpeakerImage;
        _safeChannelsRefresh();
        debugPrint(
            "🎙️ [WalkieChannelController] Real-time active speaker updated: group $gId -> ${channels[idx].activeSpeakerName}");
      }
    } catch (e) {
      debugPrint("⚠️ [WalkieChannelController] onSpeakerActiveFromSocket error: $e");
    }
  }

  void onSpeakerStoppedFromSocket(dynamic rawData) {
    if (rawData == null) return;
    try {
      final Map<String, dynamic> data = rawData is Map
          ? Map<String, dynamic>.from(rawData)
          : (rawData is String ? jsonDecode(rawData) : {});

      final gIdStr = (data['groupId'] ??
              data['group_id'] ??
              data['channelId'] ??
              data['id'])
          ?.toString();
      if (gIdStr == null || gIdStr.isEmpty) return;

      final gId = int.tryParse(gIdStr);
      if (gId == null) return;

      final idx = channels.indexWhere((c) => c.groupId == gId);
      if (idx != -1) {
        // Avoid redundant refreshes if already stopped
        if (!channels[idx].isChannelSpeaking &&
            channels[idx].activeSpeakerName == null &&
            channels[idx].activeSpeakerId == null) {
          return;
        }

        channels[idx].isChannelSpeaking = false;
        channels[idx].activeSpeakerName = null;
        channels[idx].activeSpeakerId = null;
        _safeChannelsRefresh();
        debugPrint(
            "⏹️ [WalkieChannelController] Real-time speaker stopped: group $gId");
      }
    } catch (e) {
      debugPrint("⚠️ [WalkieChannelController] onSpeakerStoppedFromSocket error: $e");
    }
  }

  void onChannelSpeakerUpdateFromSocket(dynamic rawData) {
    if (rawData == null) return;
    try {
      final Map<String, dynamic> data = rawData is Map
          ? Map<String, dynamic>.from(rawData)
          : (rawData is String ? jsonDecode(rawData) : {});

      final bool isSpeaking = data['isSpeaking'] == true ||
          data['isChannelSpeaking'] == true ||
          data['speaking'] == true ||
          data['isSpeaking'] == 1 ||
          data['isChannelSpeaking'] == 1;

      if (isSpeaking) {
        onSpeakerActiveFromSocket(data);
      } else {
        onSpeakerStoppedFromSocket(data);
      }
    } catch (e) {
      debugPrint("⚠️ [WalkieChannelController] onChannelSpeakerUpdateFromSocket error: $e");
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
      subscribeChannelUpdates();
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
    _safeChannelsRefresh();

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
      _safeChannelsRefresh();

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
      _safeChannelsRefresh();

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
      _safeChannelsRefresh();
    } catch (e) {
      debugPrint("❌ [WalkieChannelController] clearActiveChannel error: $e");
    }
  }
}
