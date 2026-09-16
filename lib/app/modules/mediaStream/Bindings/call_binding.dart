

import 'package:fgtracker/app/modules/mediaStream/Controller/calling_controller.dart';
import 'package:get/get.dart';

import '../Controller/call_controller.dart';
import '../Controller/incoming_call_controller.dart';



class StreamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CallingController>(
      () => CallingController(),
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

class CallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CallController>(
      () => CallController(),
    );
  }
}




