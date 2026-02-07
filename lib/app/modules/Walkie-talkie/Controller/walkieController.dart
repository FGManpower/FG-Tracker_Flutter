import 'package:get/get.dart';
import 'package:fgtracker/app/routes/app_pages.dart';

enum WalkieRole { caller, receiver }
enum WalkieAudioState { idle, listening, talking }

class WalkieController extends GetxController {
  final role = WalkieRole.caller.obs;
  final audioState = WalkieAudioState.idle.obs;

  bool get isTalking => audioState.value == WalkieAudioState.talking;
  bool get isListening => audioState.value == WalkieAudioState.listening;
  final isSpeakerOn = true.obs;


  void onIncoming({
    required String remoteUserId,
    required String callerName,
    required String profileImage,
  }) {
    if (Get.currentRoute == Routes.walkieTalkieScreen) return;

    role.value = WalkieRole.receiver;
    audioState.value = WalkieAudioState.listening;

    Get.toNamed(
      Routes.walkieTalkieScreen,
      arguments: {
        "remoteUserId": remoteUserId,
        "callerName": callerName,
        "profileUrl": profileImage,
      },
    );
  }


  Future<void> startServices({
    required String callerName,
    String? profileImage,
    required String remoteUserId,
  }) async {
    if (Get.currentRoute == Routes.walkieTalkieScreen) return;

    role.value = WalkieRole.caller;
    audioState.value = WalkieAudioState.listening;

    await Future.delayed(const Duration(milliseconds: 300));

    Get.toNamed(
      Routes.walkieTalkieScreen,
      arguments: {
        "remoteUserId": remoteUserId,
        "callerName": callerName,
        "profileUrl": profileImage,
      },
    );
  }

  void startTalking() {
    audioState.value = WalkieAudioState.talking;
  }

  void stopTalking() {
    audioState.value = WalkieAudioState.listening;
  }

  void reset() {
    role.value = WalkieRole.caller;
    audioState.value = WalkieAudioState.idle;
  }
  void toggleSpeaker() {
    isSpeakerOn.value = !isSpeakerOn.value;
  }
}
