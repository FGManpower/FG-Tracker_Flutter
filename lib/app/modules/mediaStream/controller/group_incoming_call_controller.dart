import 'package:fgtracker/app/Data/Services/Socket/Socket_Group_Calling.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import '../../../../gen/assets.gen.dart';
import '../../../Data/Services/group_call_service.dart'; // IMPORTANT
import '../../../routes/app_pages.dart';

class GroupIncomingCallController extends GetxController {
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
    callId = args["callId"]?.toString();

    _playRingtone();
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

  void joinCall() {
    _stopRingtone();

    // Controller handles emitting join_group_call inside onInit
    Get.offNamed(
      Routes.groupCallingScreen,
      arguments: {
        "groupId": groupId,
        "groupName": groupName,
        "groupProfile": groupProfile,
        "isVideo": isVideo,
        "memberCount": totalMemberCount,
        "callId": callId,
        "callType": "incoming", // Important!
      },
    );
  }

  void declineCall() {
    _stopRingtone();
    if (callId != null) {
      Socket_GroupCallService.instance.rejectGroupCall(callId!, groupId);
    }
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