import 'package:fgtracker/app/Data/Services/CallStateTracker.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Group_Calling.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_platform.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:fgtracker/app/Data/Services/group_call_service.dart';
import '../../../routes/app_pages.dart';

class GroupIncomingCallController extends GetxController {
  final args = Get.arguments;

  late String groupId;
  late String groupName;
  late String callerName;
  String? groupProfile;
  String? callerProfileImage;
  late int activeMemberCount;
  late int totalMemberCount;
  late bool isVideo;
  String? callId;
  String? callerId;
  RxBool isMuted = false.obs;

  @override
  void onInit() {
    super.onInit();

    groupId = args["groupId"]?.toString() ?? "";
    groupName = args["groupName"]?.toString() ?? "Unknown Group";
    callerName =
        (args["callerName"] ?? args["name"] ?? appL10n.call_unknownUser).toString();
    groupProfile = args["groupProfile"]?.toString();
    callerProfileImage =
        (args["callerProfileImage"] ?? args["profileImage"] ?? groupProfile)
            ?.toString();
    activeMemberCount = args["activeMemberCount"] ?? 1;
    totalMemberCount = args["totalMemberCount"] ?? 0;
    isVideo = args["isVideo"] == true;
    callId = args["callId"]?.toString();
    callerId = args["callerId"]?.toString();
    if (callerId != null && callerId!.isNotEmpty) {
      Socket_GroupCallService.instance.participantMeta[callerId!] = {
        "name": callerName,
        "profileImage": callerProfileImage ?? "",
        "isMuted": false,
      };
    }
    Socket_GroupCallService.instance.onCallEnded = () {
      _stopRingtone();
      CallStateTracker.isIncomingCallScreenOpen = false;
      if (Get.currentRoute == Routes.groupIncomingCallScreen) {
        Get.back();
      }
    };
    _playRingtone();
  }

  void _playRingtone() {
    try {
      CallPlatform.instance.resetSoundState();
      CallPlatform.instance.playRingback(CallPlatform.instance.ringbackAsset);
    } catch (_) {
      try {
        FlutterRingtonePlayer().playRingtone(
          asAlarm: false,
          looping: true,
          volume: 1.0,
        );
      } catch (_) {}
    }
  }

  void _stopRingtone() {
    try {
      CallPlatform.instance.stopRingtone();
    } catch (_) {}
    try {
      FlutterRingtonePlayer().stop();
    } catch (_) {}
  }

  void joinCall() {
    _stopRingtone();
    CallStateTracker.isIncomingCallScreenOpen = false;
    if (!GroupCallService.isGroupCallEnabled) {
      GroupCallService.showComingSoon();
      Get.back();
      return;
    }
    Get.offNamed(
      Routes.groupCallingScreen,
      arguments: {
        "groupId": groupId,
        "groupName": groupName,
        "groupProfile": groupProfile ?? callerProfileImage,
        "callerId": callerId,
        "callerName": callerName,
        "callerProfileImage": callerProfileImage,
        "isVideo": isVideo,
        "memberCount": totalMemberCount,
        "callId": callId,
        "callType": "incoming",
      },
    );
  }

  void declineCall() {
    _stopRingtone();
    CallStateTracker.isIncomingCallScreenOpen = false;
    if (callId != null && callId!.isNotEmpty) {
      Socket_GroupCallService.instance.rejectGroupCall(callId!, groupId);
    }
    if (Get.currentRoute == Routes.groupIncomingCallScreen) {
      Get.back();
    }
  }

  void toggleMute() {
    isMuted.value = !isMuted.value;
  }

  @override
  void onClose() {
    _stopRingtone();
    CallStateTracker.isIncomingCallScreenOpen = false;
    super.onClose();
  }
}
