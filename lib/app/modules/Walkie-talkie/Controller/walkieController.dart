import 'dart:async';
import 'dart:io';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum WalkieRole { caller, receiver }

enum WalkieAudioState { idle, listening, talking }

class WalkieParticipant {
  final String userId;
  final String name;
  final String image;
  bool isMuted;
  bool isListening;
  bool isSpeaking;
  final bool hasExplicitMute;

  WalkieParticipant({
    required this.userId,
    required this.name,
    required this.image,
    this.isMuted = false,
    this.isListening = true,
    this.isSpeaking = false,
    this.hasExplicitMute = false,
  });

  factory WalkieParticipant.fromMap(Map<String, dynamic> map, {bool? defaultMuted}) {
    final hasMuteField = map.containsKey('isMuted') ||
        map.containsKey('muted') ||
        map.containsKey('is_muted') ||
        map.containsKey('status');
    final isMutedVal = hasMuteField
        ? ((map['isMuted'] ?? map['muted'] ?? map['is_muted'] ?? (map['status'] == 'muted')) == true)
        : (defaultMuted ?? false);

    return WalkieParticipant(
      userId: (map['userId'] ?? map['user_id'] ?? map['id'])?.toString() ?? "",
      name: (map['name'] ?? map['userName'])?.toString() ?? "User",
      image: (map['image'] ?? map['profileImage'] ?? map['userImage'])?.toString() ?? "",
      isMuted: isMutedVal,
      isListening: map['isListening'] != false,
      isSpeaking: map['isSpeaking'] == true,
      hasExplicitMute: hasMuteField,
    );
  }
}

class GroupWalkieController extends GetxController {
  static const int lockDurationSeconds = 30;

  final role = WalkieRole.caller.obs;
  final audioState = WalkieAudioState.idle.obs;

  final isSpeakerOn = true.obs;
  final audioRoute = WalkieAudioRoute.speaker.obs;
  final hasBluetooth = false.obs;
  final bluetoothName = "Bluetooth".obs;
  final hasHeadset = false.obs;
  final headsetName = "Headset".obs;

  final isMuted = false.obs;
  final isSelfLocked = false.obs;
  final isChannelLocked = false.obs;
  final isConnected = false.obs;
  final hasMicPermission = true.obs;

  final isPressed = false.obs;
  final dragOffset = 0.0.obs;

  final lockRemainingSeconds = 0.obs;

  final participants = <WalkieParticipant>[].obs;
  final totalParticipants = 0.obs;

  final activeSpeakerId = "".obs;
  final activeSpeakerName = "".obs;
  final activeSpeakerImage = "".obs;

  final statusMessage = "".obs;
  final showStatus = false.obs;
  final statusColor = Rx<Color>(Colors.orange);

  String? currentGroupId;
  Timer? _bannerTimer;
  Timer? _lockCountdownTimer;

  bool get isTalking => audioState.value == WalkieAudioState.talking;
  bool get isListening => audioState.value == WalkieAudioState.listening;
  bool get hasActiveSpeaker => activeSpeakerId.value.isNotEmpty;
  bool get isVoiceActive => isTalking || hasActiveSpeaker;

  List<WalkieParticipant> get sortedParticipants {
    if (participants.isEmpty) return const [];
    final list = List<WalkieParticipant>.from(participants);
    final selfId = GroupWalkieService.instance.selfUserId ??
        Global.storageServices.get(PrefConst.userId)?.toString() ??
        '';

    list.sort((a, b) {
      if (selfId.isNotEmpty) {
        if (a.userId == selfId && b.userId != selfId) return -1;
        if (b.userId == selfId && a.userId != selfId) return 1;
      }
      if (a.isSpeaking && !b.isSpeaking) return -1;
      if (!a.isSpeaking && b.isSpeaking) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    audioRoute.value = GroupWalkieService.instance.audioRoute.value;
    isSpeakerOn.value = GroupWalkieService.instance.isSpeakerOn;
    hasBluetooth.value = GroupWalkieService.instance.hasBluetoothDevice.value;
    bluetoothName.value = GroupWalkieService.instance.bluetoothDeviceName.value;
    hasHeadset.value = GroupWalkieService.instance.hasHeadsetDevice.value;
    headsetName.value = GroupWalkieService.instance.headsetDeviceName.value;
    isMuted.value = GroupWalkieService.instance.isMuted;
    isConnected.value = GroupWalkieService.instance.socket?.connected ?? false;
  }

  @override
  void onClose() {
    _bannerTimer?.cancel();
    _lockCountdownTimer?.cancel();
    reset();
    super.onClose();
  }

  void setCurrentGroup(String groupId) {
    currentGroupId = groupId;
  }

  void setAudioRoute(WalkieAudioRoute route) {
    audioRoute.value = route;
    isSpeakerOn.value = route == WalkieAudioRoute.speaker;
  }

  void updateAvailableRoutes({
    required bool hasBt,
    required String btName,
    required bool hasHeadset,
    required String headsetName,
  }) {
    hasBluetooth.value = hasBt;
    bluetoothName.value = btName.isNotEmpty ? btName : "Bluetooth";
    this.hasHeadset.value = hasHeadset;
    this.headsetName.value = headsetName.isNotEmpty ? headsetName : "Headset";
  }

  Future<void> setRoute(WalkieAudioRoute route) async {
    await GroupWalkieService.instance.setAudioRoute(route);
  }

  void setConnected(bool value) {
    isConnected.value = value;
  }

  void setMicPermission(bool granted) {
    hasMicPermission.value = granted;
  }

  void setMuteFromService(bool muted) {
    isMuted.value = muted;
    final selfId = GroupWalkieService.instance.selfUserId ??
        Global.storageServices.get(PrefConst.userId)?.toString() ??
        '';
    if (selfId.isNotEmpty) {
      setParticipantMuted(selfId, muted);
    }
  }

  void setParticipantMuted(String userId, bool muted) {
    final cleanId = userId.trim();
    if (cleanId.isEmpty) return;
    final index = participants.indexWhere((p) =>
        p.userId.trim() == cleanId ||
        (int.tryParse(p.userId) != null &&
            int.tryParse(p.userId) == int.tryParse(cleanId)));
    if (index != -1) {
      final p = participants[index];
      p.isMuted = muted;
      if (muted) {
        p.isSpeaking = false;
      }
      participants[index] = WalkieParticipant(
        userId: p.userId,
        name: p.name,
        image: p.image,
        isMuted: muted,
        isListening: p.isListening,
        isSpeaking: muted ? false : p.isSpeaking,
        hasExplicitMute: true,
      );
    } else {
      participants.add(
        WalkieParticipant(
          userId: cleanId,
          name: 'User',
          image: '',
          isMuted: muted,
          isListening: true,
          isSpeaking: false,
          hasExplicitMute: true,
        ),
      );
    }
    totalParticipants.value = participants.length;
    participants.refresh();
  }

  IconData get audioRouteIcon {
    switch (audioRoute.value) {
      case WalkieAudioRoute.bluetooth:
        return Icons.bluetooth_audio_rounded;
      case WalkieAudioRoute.headset:
        return Icons.headphones_rounded;
      case WalkieAudioRoute.earpiece:
        return Platform.isIOS
            ? Icons.phone_iphone_rounded
            : Icons.phone_android_rounded;
      case WalkieAudioRoute.speaker:
      default:
        return Icons.volume_up_rounded;
    }
  }

  String get audioRouteLabel {
    switch (audioRoute.value) {
      case WalkieAudioRoute.bluetooth:
        return bluetoothName.value.isNotEmpty
            ? bluetoothName.value
            : "Bluetooth";
      case WalkieAudioRoute.headset:
        return headsetName.value.isNotEmpty ? headsetName.value : "Headset";
      case WalkieAudioRoute.earpiece:
        return Platform.isIOS ? "iPhone" : "Phone";
      case WalkieAudioRoute.speaker:
      default:
        return "Speaker";
    }
  }

  void addOrUpdateParticipant(WalkieParticipant p) {
    if (p.userId.isEmpty) return;
    final cleanId = p.userId.trim();
    final index = participants.indexWhere((item) =>
        item.userId.trim() == cleanId ||
        (int.tryParse(item.userId) != null &&
            int.tryParse(item.userId) == int.tryParse(cleanId)));
    if (index != -1) {
      final existing = participants[index];
      participants[index] = WalkieParticipant(
        userId: p.userId,
        name: (p.name.isNotEmpty && p.name != 'User') ? p.name : existing.name,
        image: p.image.isNotEmpty ? p.image : existing.image,
        isMuted: p.hasExplicitMute ? p.isMuted : existing.isMuted,
        isListening: p.isListening,
        isSpeaking: p.isSpeaking,
        hasExplicitMute: p.hasExplicitMute || existing.hasExplicitMute,
      );
    } else {
      participants.add(p);
    }
    totalParticipants.value = participants.length;
    participants.refresh();
  }

  void removeParticipant(String userId) {
    if (userId.isEmpty) return;
    final cleanId = userId.trim();
    participants.removeWhere((p) =>
        p.userId.trim() == cleanId ||
        (int.tryParse(p.userId) != null &&
            int.tryParse(p.userId) == int.tryParse(cleanId)));
    totalParticipants.value = participants.length;
    participants.refresh();
  }

  void updateParticipants(
    List<WalkieParticipant> list, {
    String? activeSpeaker,
  }) {
    final mergedList = list.map((newP) {
      final cleanId = newP.userId.trim();
      final existing = participants.firstWhereOrNull((p) =>
          p.userId.trim() == cleanId ||
          (int.tryParse(p.userId) != null &&
              int.tryParse(p.userId) == int.tryParse(cleanId)));
      if (existing != null) {
        return WalkieParticipant(
          userId: newP.userId,
          name: (newP.name.isNotEmpty && newP.name != 'User') ? newP.name : existing.name,
          image: newP.image.isNotEmpty ? newP.image : existing.image,
          isMuted: newP.hasExplicitMute ? newP.isMuted : existing.isMuted,
          isListening: newP.isListening,
          isSpeaking: newP.isSpeaking,
          hasExplicitMute: newP.hasExplicitMute || existing.hasExplicitMute,
        );
      }
      return newP;
    }).toList();

    participants.assignAll(mergedList);
    totalParticipants.value = mergedList.length;

    if (activeSpeaker != null && activeSpeaker.isNotEmpty) {
      activeSpeakerId.value = activeSpeaker;
      final speaker = mergedList.firstWhereOrNull((p) => p.userId == activeSpeaker);
      if (speaker != null) {
        activeSpeakerName.value = speaker.name;
        activeSpeakerImage.value = speaker.image;
        for (final p in participants) {
          p.isSpeaking = p.userId == activeSpeaker;
        }
      }
    } else {
      activeSpeakerId.value = "";
      activeSpeakerName.value = "";
      activeSpeakerImage.value = "";
      for (final p in participants) {
        p.isSpeaking = false;
      }
    }
    participants.refresh();
  }

  void onSpeakerActive({
    required String speakerId,
    required String speakerName,
    required String speakerImage,
  }) {
    activeSpeakerId.value = speakerId;
    activeSpeakerName.value = speakerName;
    activeSpeakerImage.value = speakerImage;

    if (!isTalking) {
      audioState.value = WalkieAudioState.listening;
    }

    if (speakerId.isNotEmpty) {
      final index = participants.indexWhere((p) => p.userId == speakerId);
      if (index != -1) {
        participants[index].isSpeaking = true;
        if (speakerName.isNotEmpty && speakerName != 'User') {
          final existing = participants[index];
          participants[index] = WalkieParticipant(
            userId: speakerId,
            name: speakerName,
            image: speakerImage.isNotEmpty ? speakerImage : existing.image,
            isMuted: existing.isMuted,
            isListening: existing.isListening,
            isSpeaking: true,
          );
        }
      } else {
        participants.add(WalkieParticipant(
          userId: speakerId,
          name: speakerName.isNotEmpty ? speakerName : "User",
          image: speakerImage,
          isSpeaking: true,
          isListening: true,
        ));
      }
    }

    for (final p in participants) {
      if (p.userId != speakerId) {
        p.isSpeaking = false;
      }
    }
    totalParticipants.value = participants.length;
    participants.refresh();
  }

  void onSpeakerStopped() {
    activeSpeakerId.value = "";
    activeSpeakerName.value = "";
    activeSpeakerImage.value = "";

    for (final p in participants) {
      p.isSpeaking = false;
    }
    participants.refresh();

    if (!isTalking) {
      audioState.value = WalkieAudioState.listening;
    }
  }

  void startTalking() {
    if (isChannelLocked.value) return;
    audioState.value = WalkieAudioState.talking;
  }

  void stopTalking() {
    if (audioState.value == WalkieAudioState.talking) {
      audioState.value = WalkieAudioState.listening;
    }
  }

  void setPressed(bool value) {
    isPressed.value = value;
  }

  void setDragOffset(double value) {
    dragOffset.value = value;
  }

  void activateSelfLock(VoidCallback onExpire) {
    isSelfLocked.value = true;
    _startLockCountdown(onExpire);
  }

  void _startLockCountdown(VoidCallback onExpire) {
    _lockCountdownTimer?.cancel();
    lockRemainingSeconds.value = lockDurationSeconds;

    _lockCountdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (lockRemainingSeconds.value <= 1) {
        t.cancel();
        lockRemainingSeconds.value = 0;
        onExpire();
      } else {
        lockRemainingSeconds.value--;
      }
    });
  }

  void resetSelfLock() {
    _lockCountdownTimer?.cancel();
    _lockCountdownTimer = null;
    lockRemainingSeconds.value = 0;
    isSelfLocked.value = false;
  }

  void forceUnlockAndReset() {
    _lockCountdownTimer?.cancel();
    _lockCountdownTimer = null;
    lockRemainingSeconds.value = 0;
    isSelfLocked.value = false;
    isPressed.value = false;
    dragOffset.value = 0.0;
    stopTalking();
  }

  void showBusyMessage(String speakerName) {
    _displayBanner(
      speakerName.isEmpty ? "Channel is busy" : "$speakerName is talking...",
      Colors.orange,
    );
  }

  void showMutedMessage() {
    _displayBanner("You are muted — Listening only", Colors.redAccent);
  }

  void showLockedMessage() {
    _displayBanner("Channel locked", Colors.redAccent);
  }

  void showPermissionDeniedMessage() {
    _displayBanner("Microphone permission required", Colors.redAccent);
  }

  void showLockExpiredMessage() {
    _displayBanner("Lock timeout — Mic released", Colors.orange);
  }

  void showTrialEndedMessage() {
    _displayBanner("Free trial ended — Please subscribe to continue", Colors.redAccent);
  }

  void showNoVoiceSeatMessage() {
    _displayBanner("No voice seat assigned — You are in Listen-Only mode", Colors.orange.shade800);
  }

  void showNoInternetMessage() {
    _displayBanner("No internet connection", Colors.redAccent);
  }

  void showPoorConnectionMessage() {
    _displayBanner("Poor network connection — Audio may lag", Colors.orange);
  }

  void showReconnectingMessage() {
    _displayBanner("Reconnecting to walkie server...", Colors.orange);
  }

  void showGenericErrorMessage(String msg) {
    _displayBanner(msg, Colors.redAccent);
  }

  void onChannelLocked({required bool isLocked}) {
    isChannelLocked.value = isLocked;
    _displayBanner(
      isLocked ? "Channel locked" : "Channel unlocked",
      isLocked ? Colors.redAccent : Colors.green,
    );
  }

  void _displayBanner(String msg, Color color) {
    _bannerTimer?.cancel();
    statusMessage.value = msg;
    statusColor.value = color;
    showStatus.value = true;
    _bannerTimer = Timer(const Duration(seconds: 2), () {
      showStatus.value = false;
    });
  }

  void reset() {
    _bannerTimer?.cancel();
    _lockCountdownTimer?.cancel();
    _bannerTimer = null;
    _lockCountdownTimer = null;
    role.value = WalkieRole.caller;
    audioState.value = WalkieAudioState.idle;
    isChannelLocked.value = false;
    isMuted.value = false;
    isSelfLocked.value = false;
    isPressed.value = false;
    dragOffset.value = 0.0;
    lockRemainingSeconds.value = 0;
    participants.clear();
    totalParticipants.value = 0;
    activeSpeakerId.value = "";
    activeSpeakerName.value = "";
    activeSpeakerImage.value = "";
    showStatus.value = false;
    statusMessage.value = "";
    statusColor.value = Colors.orange;
    currentGroupId = null;
  }
}
