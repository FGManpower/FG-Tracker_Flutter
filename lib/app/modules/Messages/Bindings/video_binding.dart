import 'package:fgtracker/app/modules/Messages/Controller/VideoController.dart';
import 'package:get/get.dart';

class VideoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoControllerX>(
      () => VideoControllerX(),
    );
  }
}
