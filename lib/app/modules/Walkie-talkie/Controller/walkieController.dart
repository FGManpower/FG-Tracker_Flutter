import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fgtracker/app/Data/Services/Walkie-Talkie-Service.dart';

enum WalkieRole { caller, receiver }
enum WalkieAudioState { idle, listening, talking }

class WalkieParticipant {
  final String userId;
  final String name;
  final String image;
  bool isMuted;
  bool isListening;
  bool isSpeaking;

  WalkieParticipant({
    required this.userId,
    required this.name,
    required this.image,
    this.isMuted = false,
    this.isListening = true,
    this.isSpeaking = false,
  });

  factory WalkieParticipant.fromMap(Map<String, dynamic> map) {
    return WalkieParticipant(
      userId: map['userId']?.toString() ?? "",
      name: map['name']?.toString() ?? "User",
      image: map['image']?.toString() ?? "",
      isMuted: map['isMuted'] == true,
      isListening: map['isListening'] != false,
      isSpeaking: map['isSpeaking'] == true,
    );
  }
}

class GroupWalkieController extends GetxController {
  final role = WalkieRole.caller.obs;
  final audioState = WalkieAudioState.idle.obs;

  final isSpeakerOn = true.obs;
  final audioRoute = WalkieAudioRoute.speaker.obs;

  final isMuted = false.obs;
  final isSelfLocked = false.obs;
  final isChannelLocked = false.obs;
  final isConnected = false.obs;
  final hasMicPermission = true.obs;

  final isPressed = false.obs;
  final dragOffset = 0.0.obs;

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

  bool get isTalking => audioState.value == WalkieAudioState.talking;
  bool get isListening => audioState.value == WalkieAudioState.listening;
  bool get hasActiveSpeaker => activeSpeakerId.value.isNotEmpty;

  List<WalkieParticipant> get sortedParticipants {
    if (participants.isEmpty) return const [];
    final list = List<WalkieParticipant>.from(participants);
    list.sort((a, b) {
      if (a.isSpeaking && !b.isSpeaking) return -1;
      if (!a.isSpeaking && b.isSpeaking) return 1;
      if (a.isMuted && !b.isMuted) return 1;
      if (!a.isMuted && b.isMuted) return -1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    audioRoute.value = GroupWalkieService.instance.audioRoute.value;
    isSpeakerOn.value = GroupWalkieService.instance.isSpeakerOn;
    isMuted.value = GroupWalkieService.instance.isMuted;
    isConnected.value =
        GroupWalkieService.instance.socket?.connected ?? false;
  }

  @override
  void onClose() {
    _bannerTimer?.cancel();
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

  void setConnected(bool value) {
    isConnected.value = value;
  }

  void setMicPermission(bool granted) {
    hasMicPermission.value = granted;
  }

  void setMuteFromService(bool muted) {
    isMuted.value = muted;
  }

  IconData get audioRouteIcon {
    switch (audioRoute.value) {
      case WalkieAudioRoute.bluetooth:
        return Icons.bluetooth_audio_rounded;
      case WalkieAudioRoute.headset:
        return Icons.headphones_rounded;
      case WalkieAudioRoute.earpiece:
        return Icons.phone_in_talk_rounded;
      case WalkieAudioRoute.speaker:
      default:
        return Icons.volume_up_rounded;
    }
  }

  String get audioRouteLabel {
    switch (audioRoute.value) {
      case WalkieAudioRoute.bluetooth:
        return "Bluetooth";
      case WalkieAudioRoute.headset:
        return "Headset";
      case WalkieAudioRoute.earpiece:
        return "Earpiece";
      case WalkieAudioRoute.speaker:
      default:
        return "Speaker";
    }
  }

  void updateParticipants(
      List<WalkieParticipant> list, {
        String? activeSpeaker,
      }) {
    participants.assignAll(list);
    totalParticipants.value = list.length;

    if (activeSpeaker != null && activeSpeaker.isNotEmpty) {
      activeSpeakerId.value = activeSpeaker;
      final speaker = list.firstWhereOrNull((p) => p.userId == activeSpeaker);
      if (speaker != null) {
        activeSpeakerName.value = speaker.name;
        activeSpeakerImage.value = speaker.image;
        for (final p in participants) {
          p.isSpeaking = p.userId == activeSpeaker;
        }
        participants.refresh();
      }
    } else {
      activeSpeakerId.value = "";
      activeSpeakerName.value = "";
      activeSpeakerImage.value = "";
      for (final p in participants) {
        p.isSpeaking = false;
      }
      participants.refresh();
    }
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

    for (final p in participants) {
      p.isSpeaking = p.userId == speakerId;
    }
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

  void toggleSelfLock(bool locked) {
    isSelfLocked.value = locked;
  }

  void resetSelfLock() {
    isSelfLocked.value = false;
  }

  void showBusyMessage(String speakerName) {
    _displayBanner(
      speakerName.isEmpty ? "Channel is busy" : "$speakerName is talking...",
      Colors.orange,
    );
  }

  void showMutedMessage() {
    _displayBanner("You are muted. Unmute to listen.", Colors.redAccent);
  }

  void showLockedMessage() {
    _displayBanner("Channel is locked", Colors.redAccent);
  }

  void showPermissionDeniedMessage() {
    _displayBanner("Microphone permission required", Colors.redAccent);
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
    _bannerTimer = null;
    role.value = WalkieRole.caller;
    audioState.value = WalkieAudioState.idle;
    isChannelLocked.value = false;
    isMuted.value = false;
    isSelfLocked.value = false;
    isPressed.value = false;
    dragOffset.value = 0.0;
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