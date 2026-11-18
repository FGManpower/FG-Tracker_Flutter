

import 'package:fgtracker/app/modules/mediaStream/Controller/calling_controller.dart';
import 'package:get/get.dart';

import '../../call/Controller/call_controller.dart';
import '../Controller/incoming_call_controller.dart';



class StreamBinding extends Bindings {
  @override
  void dependencies() {
    // Reuse ONLY a live call (expand from the overlay). A controller left
    // from a finished call is replaced, so every call starts clean
    // (BUG-CALL-01). `permanent` keeps a minimized call alive after its
    // route is popped; the controller deletes itself when the call ends.
    if (Get.isRegistered<CallingController>()) {
      final CallingController existing = Get.find<CallingController>();
      if (existing.isCallLive) return;
      existing.isMinimized.value = false;
      Get.delete<CallingController>(force: true);
    }
    Get.put<CallingController>(
      CallingController(),
      permanent: true,
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




