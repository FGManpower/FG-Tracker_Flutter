import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import '../../../Core/util/http/Constant.dart';



class CallController extends GetxController {
  late RtcEngine engine;
  RxBool localJoined = false.obs;
  var remoteUid = "".obs;
  RxBool isMuted = false.obs;
  // RxBool switchCamera = false.obs;
  RxBool isVideo = true.obs;
  RxBool isSpeakerOn = true.obs;
  String channelId = '';
  final isTimerStarted = false.obs;
  Timer? callTimeoutTimer;
  var countdownSeconds = 60.obs;

  Future<String?> getToken(String channelId) async {
    final response = await http.get(Uri.parse("${Constant.Baseurl}/rtc-token?channelName=$channelId"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token'];
    } else {
      return null;
    }
  }

  Future<void> initAgora({
    required String channelId,
    required bool isVideo,

  }) async {
    try {
      this.channelId = channelId;
      engine = createAgoraRtcEngine();
      await engine
          .initialize( RtcEngineContext(appId: agoraAppId,));

      log("[DEBUG] Agora Engine Initialized");

      await engine.enableAudio();
      if (isVideo) {
        await engine.enableVideo();
        await engine.startPreview();
        log("[DEBUG] Video Enabled & Preview Started");
      }

      engine.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          localJoined.value = true;
          log('[DEBUG] Local user \${connection.localUid} joined');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          this.remoteUid?.value = remoteUid.toString();
          log('[DEBUG] Remote user \$remoteUid joined');
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          this.remoteUid?.value = "";
          log('[DEBUG] Remote user \n${remoteUid} left channel');
        },
        onError: (ErrorCodeType code, String message) {
          log('[DEBUG] Agora Error: \n${code} - \n${message}');
        },
      ));

      var tokens = await getToken(channelId);
      log("serverToken--------${tokens}");
      await engine.joinChannel(
        token: tokens.toString(),
        channelId: channelId,
        uid: 0,
        options: isVideo
            ? ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishCameraTrack: isVideo,
          publishMicrophoneTrack: true,
        )
            : ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishCameraTrack: false,
          publishMicrophoneTrack: true,
        ),
      );

      await engine.setEnableSpeakerphone(isSpeakerOn.value);
      log("[DEBUG] Joined Channel \$channelId with Video: \$isVideo");
    } catch (e) {
      log("[DEBUG] initAgora Exception: ${e.toString()}");
    }
  }

  void toggleMute() {
    isMuted.value = !isMuted.value;
    engine.muteLocalAudioStream(isMuted.value);
    log("[DEBUG] Mic Muted: \${isMuted.value}");
  }
  // void switchCamera() {
  //   engine.switchCamera();
  //   log("[DEBUG] Camera Switched");
  // }
  final RxBool isEndingCall = false.obs;

  Future<void> endCall(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('calls')
        .doc(channelId)
        .set({'hasEnded': true});
    disposeAgora();

    Navigator.pop(context);
    // Get.offAllNamed(Routes.Home_Screen);
    log("[DEBUG] Call Ended and Disposed");
  }

  void toggleSpeaker() async {
    isSpeakerOn.value = !isSpeakerOn.value;
    await engine.setEnableSpeakerphone(isSpeakerOn.value);
    log("[DEBUG] Speakerphone Enabled: \${isSpeakerOn.value}");
  }






  void disposeAgora() async {
    try {
      log("[DEBUG] Disposing Agora Engine");
      await engine.leaveChannel();
      await engine.stopPreview();
      await engine.disableVideo();
      await engine.disableAudio();
      await engine.release();
      callTimeoutTimer?.cancel();
      isTimerStarted.value = false;
      log("[DEBUG] Agora Engine Released Successfully");
    } catch (e) {
      log("[DEBUG] disposeAgora Exception: \$e");
    }
  }


  void switchCamera() {
    engine.switchCamera();
    log("[DEBUG] Camera Switched");
  }
  @override
  void onClose() {
    disposeAgora();
    super.onClose();
  }
}