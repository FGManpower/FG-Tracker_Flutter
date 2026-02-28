

import 'package:fgtracker/app/modules/mediaStream/controller/call_controller.dart';
import 'package:get/get.dart';

import '../controller/incoming_call_controller.dart';



class StreamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CallController>(
      () => CallController(),
    );
  }
}

class IncomingCallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IncomingCallController>(
      () => IncomingCallController(),
    );
  }
}




