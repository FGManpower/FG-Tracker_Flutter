import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fgtracker/app/routes/app_pages.dart';

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
      name: map['name'] ?? "User",
      image: map['image'] ?? "",
      isMuted: map['isMuted'] ?? false,
      isListening: map['isListening'] ?? true,
      isSpeaking: map['isSpeaking'] ?? false,
    );
  }
}

class GroupWalkieController extends GetxController {
  final role = WalkieRole.caller.obs;
  final audioState = WalkieAudioState.idle.obs;
  final isSpeakerOn = true.obs;
  final isChannelLocked = false.obs;

  final participants = <WalkieParticipant>[].obs;
  final totalParticipants = 0.obs;

  final activeSpeakerId = "".obs;
  final activeSpeakerName = "".obs;
  final activeSpeakerImage = "".obs;

  final statusMessage = "".obs;
  final showStatus = false.obs;
  String? currentGroupId;

  bool get isTalking => audioState.value == WalkieAudioState.talking;
  bool get isListening => audioState.value == WalkieAudioState.listening;

  void setCurrentGroup(String groupId) {
    currentGroupId = groupId;
  }

  void onIncoming({
    required String remoteUserId,
    required String callerName,
    required String profileImage,
  }) {
    if (Get.currentRoute == Routes.groupWalkieScreen) return;

    role.value = WalkieRole.receiver;
    audioState.value = WalkieAudioState.listening;

    Get.toNamed(
      Routes.groupWalkieScreen,
      arguments: {
        "groupId": remoteUserId,
        "groupName": callerName,
        "profileUrl": profileImage,
      },
    );
  }

  void updateParticipants(List<WalkieParticipant> list, {String? activeSpeaker}) {
    participants.value = list;
    totalParticipants.value = list.length;

    if (activeSpeaker != null && activeSpeaker.isNotEmpty) {
      activeSpeakerId.value = activeSpeaker;
    } else {
      activeSpeakerId.value = "";
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
    audioState.value = WalkieAudioState.listening;

    for (var p in participants) {
      p.isSpeaking = p.userId == speakerId;
    }
    participants.refresh();
  }

  void onSpeakerStopped() {
    activeSpeakerId.value = "";
    activeSpeakerName.value = "";
    activeSpeakerImage.value = "";

    for (var p in participants) {
      p.isSpeaking = false;
    }
    participants.refresh();
  }

  void startTalking() {
    if (isChannelLocked.value) return;
    audioState.value = WalkieAudioState.talking;
  }

  void stopTalking() {
    audioState.value = WalkieAudioState.listening;
  }

  void showBusyMessage(String speakerName) {
    _displayBanner("$speakerName is talking...", Colors.orange);
  }

  void showMutedMessage() {
    _displayBanner("You are currently muted", Colors.red);
  }

  void showLockedMessage() {
    _displayBanner("The channel has been locked", Colors.red);
  }

  void onChannelLocked({required bool isLocked}) {
    isChannelLocked.value = isLocked;
    _displayBanner(
      isLocked ? "Channel locked by Admin" : "Channel unlocked",
      isLocked ? Colors.red : Colors.green,
    );
  }

  void _displayBanner(String msg, Color color) {
    statusMessage.value = msg;
    showStatus.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      showStatus.value = false;
    });
  }

  void toggleSpeaker() {
    isSpeakerOn.value = !isSpeakerOn.value;
  }

  void reset() {
    role.value = WalkieRole.caller;
    audioState.value = WalkieAudioState.idle;
    isChannelLocked.value = false;
    participants.clear();
  }

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}