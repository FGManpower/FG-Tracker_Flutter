

import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/controller/call_controller.dart';
import 'package:get/get.dart';



class StreamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CallController>(
      () => CallController(),
    );
  }
}




