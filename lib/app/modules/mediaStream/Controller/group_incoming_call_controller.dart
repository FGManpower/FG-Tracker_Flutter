import 'package:fgtracker/app/Data/Services/Socket/Socket_Group_Calling.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import '../../../../gen/assets.gen.dart';
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
        (args["callerName"] ?? args["name"] ?? "Unknown User").toString();
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
    _playRingtone();
  }

  void _playRingtone() {
    // try {
    //   FlutterRingtonePlayer().play(
    //     asAlarm: false,
    //     fromAsset: Assets.music.incomingCall,
    //     looping: true,
    //     volume: 1.0,
    //   );
    // } catch (_) {
    //   try {
    //     FlutterRingtonePlayer().playRingtone(
    //       asAlarm: false,
    //       looping: true,
    //       volume: 1.0,
    //     );
    //   } catch (_) {}
    // }
  }

  void _stopRingtone() {
    try {
      // FlutterRingtonePlayer().stop();
    } catch (_) {}
  }

  void joinCall() {
    _stopRingtone();

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
