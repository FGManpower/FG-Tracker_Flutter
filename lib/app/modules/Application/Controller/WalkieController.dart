import 'package:get/get.dart';

enum WalkieStatus { idle, talking, listening }

class WalkieController extends GetxController {
  Rx<WalkieStatus> status = WalkieStatus.idle.obs;

  void startTalking() {
    status.value = WalkieStatus.talking;
    // start mic + send audio
  }

  void stopTalking() {
    status.value = WalkieStatus.listening;
    // stop mic
  }
}
