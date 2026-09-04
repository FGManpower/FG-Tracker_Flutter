import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import '../../../../gen/assets.gen.dart';
import '../../../Core/constant/pref_res.dart';
import '../../../Core/values/global.dart';
import '../../../Data/Services/Socket/Socket_SignallingService.dart';
import '../../../routes/app_pages.dart';

class GroupIncomingCallController extends GetxController {
  final socket = SignallingService.instance.socket;
  final args = Get.arguments;

  late String groupId;
  late String groupName;
  late String callerName;
  String? groupProfile;
  late int activeMemberCount;
  late int totalMemberCount;
  late bool isVideo;
  String? callId;

  RxBool isMuted = false.obs;

  @override
  void onInit() {
    super.onInit();
    groupId = args["groupId"]?.toString() ?? "";
    groupName = args["groupName"]?.toString() ?? "Unknown Group";
    callerName = args["callerName"]?.toString() ?? "Unknown User";
    groupProfile = args["groupProfile"];
    activeMemberCount = args["activeMemberCount"] ?? 1;
    totalMemberCount = args["totalMemberCount"] ?? 0;
    isVideo = args["isVideo"] == true;
    callId = args["callId"];

    _playRingtone();
    _listenForSocketEvents();
  }

  void _playRingtone() {
    FlutterRingtonePlayer().play(
      asAlarm: false,
      fromAsset: Assets.music.incomingCall,
      looping: true,
      volume: 1.0,
    );
  }

  void _stopRingtone() {
    FlutterRingtonePlayer().stop();
  }

  void _listenForSocketEvents() {
    // TODO: Add listeners for group call ended/cancelled.
  }

  void joinCall() {
    _stopRingtone();

    // TODO: Emit group call accept/join event to backend socket

    Get.offNamed(
      Routes.groupCallingScreen,
      arguments: {
        "groupId": groupId,
        "groupName": groupName,
        "groupProfile": groupProfile,
        "isVideo": isVideo,
        "memberCount": totalMemberCount,
        "callId": callId,
        "callType": "incoming",
      },
    );
  }

  void declineCall() {
    _stopRingtone();
    // TODO: Emit group call reject event to backend socket
    Get.back();
  }

  void toggleMute() {
    isMuted.value = !isMuted.value;
  }

  @override
  void onClose() {
    _stopRingtone();
    super.onClose();
  }
}