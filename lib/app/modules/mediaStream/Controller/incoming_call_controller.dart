import 'package:fgtracker/gen/assets.gen.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' show Socket;
import '../../../Core/util/decomPress.dart';
import '../../../Data/Services/CallStateTracker.dart';
import '../../../Data/Services/Socket/Socket_SignallingService.dart';
import '../../../Model/call_model.dart';
import '../../../routes/app_pages.dart';
import '../Services/call_entry.dart';
import '../Services/call_events.dart';
import '../Services/call_socket_handlers.dart';

class IncomingCallController extends GetxController {
  final args = Get.arguments;

  /// Always the current signaling socket (re-created on login, BUG-CALL-02).
  Socket? get socket => SignallingService.instance.socket;

  /// Only this screen's handlers; global ones are never removed (BUG-CALL-03).
  late final CallSocketHandlers _handlers = CallSocketHandlers(() => socket);

  late IncomingCallModel call;
  Map<String, dynamic>? offer;
  bool gotSDP = false;

  @override
  void onInit() {
    super.onInit();

    FlutterRingtonePlayer().play(
      asAlarm: false,
      fromAsset: Assets.music.incomingCall,
      looping: true,
      volume: 1.0,
    );

    call = args['callDetail'];
    update();
    offer = decomPress().decompressSDPOffer(call.sdpOfferCompressed);

    if (offer != null) {
      gotSDP = true;
      update();
    } else {
      _handlers.on("newCall", _onNewCallOffer);
    }

    _handlers.on("callEnded", _onCallGone);
    _handlers.on("endCall", _onCallGone);
    _handlers.on("missedCall", _onCallGone);
    // Caller cancelled / ring timed out (agreed with the backend).
    for (final String ev in kCallCancelSignals) {
      if (ev == 'cancelCall') continue;
      _handlers.on(ev, _onCallGone);
    }
  }

  /// False when [data] names another call (late event from an earlier one).
  bool isForThisCall(dynamic data) {
    if (data is! Map) return true;
    final String theirs =
        (data['callId'] ?? data['call_id'] ?? '').toString().trim();
    final String ours = call.callId?.toString() ?? '';
    if (theirs.isEmpty || theirs == 'null' || ours.isEmpty || ours == 'null') {
      return true;
    }
    return theirs == ours;
  }

  void _onCallGone(dynamic data) {
    if (!isForThisCall(data)) return;
    FlutterRingtonePlayer().stop();
    CallStateTracker.isIncomingCallScreenOpen = false;
    _handlers.offAll();
    Get.back();
  }

  void _onNewCallOffer(dynamic data) {
    final incomingRemoteId =
        (data["callerId"] ?? data["remoteUserId"])?.toString() ?? "";
    if (incomingRemoteId.isNotEmpty && incomingRemoteId != call.callerId) {
      return;
    }

    offer = data["sdpOffer"];
    gotSDP = true;
    update();
  }

  @override
  void onClose() {
    FlutterRingtonePlayer().stop();
    CallStateTracker.isIncomingCallScreenOpen = false;
    _handlers.offAll();
    super.onClose();
  }

  void rejectCall() {
    FlutterRingtonePlayer().stop();
    _handlers.offAll();
    // The server routes the reject to `remoteUserId`: it must be the CALLER,
    // not me, or the caller keeps ringing (BUG-CALL-04).
    socket?.emit(
      "rejectCall",
      rejectCallPayload(callId: call.callId, callerId: call.callerId),
    );
    CallStateTracker.isIncomingCallScreenOpen = false;
    Get.back();
  }

  void acceptCall() {
    FlutterRingtonePlayer().stop();
    CallStateTracker.isIncomingCallScreenOpen = false;
    _handlers.offAll();

    Get.offNamed(
      Routes.callScreen,
      arguments: incomingCallArgs(
        callerId: call.callerId,
        callId: call.callId,
        isVideo: call.isVideo,
        callerName: call.callerName,
        profileImage: call.callerProfileImage,
        offer: offer,
        fromCallKit: false,
      ),
    );
  }
}
