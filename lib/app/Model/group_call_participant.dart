import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

class GroupCallParticipant {
  final String userId;
  final String name;
  final String? profileImage;

  final bool isLocal;

  RxBool isMuted;
  RxBool isVideoOn;
  RxBool isSpeaking;
  RxBool isConnected;

  RTCVideoRenderer? renderer;
  MediaStream? stream;

  GroupCallParticipant({
    required this.userId,
    required this.name,
    this.profileImage,
    required this.isLocal,
    bool muted = false,
    bool videoOn = true,
    bool speaking = false,
    bool connected = false,
  })  : isMuted = muted.obs,
        isVideoOn = videoOn.obs,
        isSpeaking = speaking.obs,
        isConnected = connected.obs;
}
