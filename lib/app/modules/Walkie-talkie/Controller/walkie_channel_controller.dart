import 'dart:async';
import 'dart:convert';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/walkie_channel_repo.dart';
import 'package:fgtracker/app/Data/Services/app_cache.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';
import 'package:fgtracker/app/Model/walkie_channel_model.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import 'package:fgtracker/app/Core/util/app_log.dart';
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

  // ---- App cache (doc 07): the channel list shown at once ----

  /// "Couldn't refresh · Retry" over the channels already on screen.
  final RxBool refreshFailed = false.obs;
  bool _cacheReadDone = false;
  AppCachePerf? _perf;

  /// Saved WITHOUT live state: who is speaking / online now is never
  /// cached (it would show a stale "speaking" row); sockets fill it in.
  static Map<String, dynamic> _cacheJson(WalkieChannelItem c) => c.toJson()
    ..['isChannelSpeaking'] = false
    ..['activeSpeakerId'] = null
    ..['activeSpeakerName'] = null
    ..['activeSpeakerImage'] = null
    ..['isOnline'] = false;

  Future<void> _showCachedChannels() async {
    try {
      final cached = await AppCache.readAs(
          AppCache.walkieChannels, (m) => WalkieChannelItem.fromJson(m));
      if (isClosed || cached.isEmpty) return;
      // The API answer (or a socket update) that is already here wins (R3).
      if (channels.isEmpty) {
        channels.assignAll(cached);
        _perf?.mark('cache shown', extra: '${cached.length} channels');
        // The API failed before the cache was read: channels are on screen
        // now, so a small retry bar instead of the full error.
        if (errorMessage.value.isNotEmpty) {
          errorMessage.value = '';
          refreshFailed.value = true;
        }
      }
    } catch (_) {
    } finally {
      _cacheReadDone = true;
    }
  }

  void _scheduleChannelsSave() {
    if (!_cacheReadDone || isClosed) return;
    AppCache.scheduleWrite(
      AppCache.walkieChannels,
      () => [for (final c in channels) _cacheJson(c)],
    );
  }

  @override
  void onInit() {
    super.onInit();
    _perf = AppCachePerf('walkie_channels')..mark('open');
    // Socket listeners are set up as before and never wait for the cache.
    _showCachedChannels();
    ever<List<WalkieChannelItem>>(channels, (_) => _scheduleChannelsSave());
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

        final eventUserId = (map['userId'] ?? map['targetUserId'] ?? map['user_id'])?.toString();
        final selfId = Global.storageServices.get(PrefConst.userId)?.toString();
        if (eventUserId != null && selfId != null && eventUserId.trim() != selfId.trim()) {
          return;
        }

        final activeGroupIdStr =
            (map['activeNotificationGroupId'] ?? map['groupId'] ?? map['group_id'])?.toString();
        final rawEnabled = map['notifications_enabled'] ?? map['enabled'] ?? map['notificationsEnabled'];
        final bool enabled = rawEnabled == true ||
            rawEnabled == 1 ||
            rawEnabled?.toString() == '1' ||
            rawEnabled?.toString() == 'true';
        final activeGroupId = int.tryParse(activeGroupIdStr ?? '');

        if (activeGroupId != null) {
          for (var c in channels) {
            if (c.groupId == activeGroupId) {
              c.notificationsEnabled = enabled;
            }
          }
          _safeChannelsRefresh();
        }
      } catch (e) {
        AppLog.d("⚠️ [WalkieChannelController] channelChangedHandler error: $e");
      }
    };
    socket.on('walkie_notification_channel_changed', _channelChangedHandler);
    socket.on('walkie_member_notification_changed', _channelChangedHandler);
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
      socket.off('walkie_member_notification_changed', _channelChangedHandler);
      _channelChangedHandler = null;
    }
  }

  void subscribeChannelUpdates() {
    try {
      final socket = GroupWalkieService.instance.socket;
      if (socket != null && socket.connected && channels.isNotEmpty) {
        final groupIds = channels.map((c) => c.groupId).toList();
        socket.emit('subscribe_channel_updates', {'groupIds': groupIds});
        AppLog.d("📡 [WalkieChannelController] Emitted subscribe_channel_updates: $groupIds");
      }
    } catch (e) {
      AppLog.d("⚠️ [WalkieChannelController] subscribeChannelUpdates error: $e");
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
        AppLog.d(
            "🎙️ [WalkieChannelController] Real-time active speaker updated: group $gId -> ${channels[idx].activeSpeakerName}");
      }
    } catch (e) {
      AppLog.d("⚠️ [WalkieChannelController] onSpeakerActiveFromSocket error: $e");
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
        AppLog.d(
            "⏹️ [WalkieChannelController] Real-time speaker stopped: group $gId");
      }
    } catch (e) {
      AppLog.d("⚠️ [WalkieChannelController] onSpeakerStoppedFromSocket error: $e");
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
      AppLog.d("⚠️ [WalkieChannelController] onChannelSpeakerUpdateFromSocket error: $e");
    }
  }

  Future<void> fetchChannels({bool showLoading = true}) async {
    // Skeleton only when nothing (cached) is shown yet.
    if (showLoading) isLoading.value = channels.isEmpty;
    errorMessage.value = '';

    try {
      final res = await WalkieChannelRepo.getWalkieChannels()
          .timeout(const Duration(seconds: 10)); // never an endless loader
      final loadedChannels = res.data?.channels ?? [];

      activeChannelId.value = res.data?.activeChannelId;

      // Sync active channel flag if present
      if (activeChannelId.value != null) {
        for (var c in loadedChannels) {
          c.isSelectedChannel = (c.groupId == activeChannelId.value);
        }
      }

      // In multi-channel notification mode:
      // Each channel independently maintains its notificationsEnabled preference from server

      channels.assignAll(loadedChannels);
      refreshFailed.value = false;
      _perf?.mark('API done', extra: '${loadedChannels.length} channels');
      _perf?.markAfterFrame('rendered');
      subscribeChannelUpdates();
    } catch (e) {
      // Channels on screen (cached) stay with a retry bar; an empty screen
      // gets the error as before.
      if (channels.isNotEmpty) {
        refreshFailed.value = true;
      } else {
        errorMessage.value = e.toString();
      }
      AppLog.d("❌ [WalkieChannelController] fetchChannels error: $e");
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

    // 1. Optimistic UI update: Toggle target channel independently (Multi-Channel active)
    channel.notificationsEnabled = willBeEnabled;
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
        appL10n.walkie_notificationSettingTitle,
        appL10n.walkie_notificationSettingFailed(channel.groupName),
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
        await GroupWalkieService.instance
            .leaveGroup(targetGroupId: previousActiveId.toString());
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
      AppLog.d("❌ [WalkieChannelController] selectActiveSpeakingChannel error: $e");
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
          appL10n.walkie_channelSwitchErrorTitle,
          appL10n.walkie_channelSwitchErrorMessage(channel.groupName),
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
      AppLog.d("❌ [WalkieChannelController] clearActiveChannel error: $e");
    }
  }
}
