// audio_call_controller.dart
import 'package:get/get.dart';

class AudioCallController extends GetxController {
  var isSpeakerOn = false.obs;
  var isMicOn = true.obs;

  void toggleMic() => isMicOn.value = !isMicOn.value;
  void toggleSpeaker() => isSpeakerOn.value = !isSpeakerOn.value;
}
