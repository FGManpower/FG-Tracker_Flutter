import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:get/get.dart';
import '../../../Core/constant/pref_res.dart';
import '../../../Core/util/decomPress.dart';
import '../../../Core/values/global.dart';
import '../../../Data/Services/CallStateTracker.dart';
import '../../../Data/Services/SignallingService.dart';
import '../../../Model/call_model.dart';
import '../../../routes/app_pages.dart';


class IncomingCallController extends GetxController {
  final args = Get.arguments;
  final socket = SignallingService.instance.socket;
  late IncomingCallModel call;
  Map<String, dynamic>? offer;
  bool gotSDP = false;

  @override
  void onInit() {
    super.onInit();
    call = args['callDetail'];
    update();
    offer = decomPress().decompressSDPOffer(call.sdpOfferCompressed);

    if (offer != null) {
      gotSDP = true;
      update();
    } else {
      _listenForSocketOffer();
    }

    socket?.off("callEnded");
    socket?.on("callEnded", (data) {
      CallStateTracker.isIncomingCallScreenOpen = false;
      Get.back();
    });

    socket?.on("missedCall", (data) {
      CallStateTracker.isIncomingCallScreenOpen = false;
      Get.back();
    });
  }



  void _listenForSocketOffer() {
    socket?.off("newCall");
    socket?.on("newCall", (data) {
      final incomingRemoteId = data["remoteUserId"].toString();
      if (incomingRemoteId != call.callerId) return;

      offer = data["sdpOffer"];
      gotSDP = true;
      update();
    });
  }

  void rejectCall() {
    final myId = Global.storageServices.get(PrefConst.userId).toString();
    socket?.emit("rejectCall", {
      "remoteUserId": myId == call.callerId ? call.receiverId : call.callerId,
    });
    CallStateTracker.isIncomingCallScreenOpen = false;
    Get.back();
  }

  void acceptCall() {
    if (offer == null) {
      Get.snackbar("Please wait", "Connecting…");
      return;
    }

    CallStateTracker.isIncomingCallScreenOpen = false;

    Get.offNamed(
      Routes.callScreen,
      arguments: {
        "callerId": call.callerId,
        "remoteUserId": Global.storageServices.get(PrefConst.userId).toString(),
        "offer": offer,
        "is_video": call.isVideo,
        "callerName": call.callerName,
        "callId": call.callId,
        "callerProfile": call.callerProfileImage,
      },
    );
  }
}
