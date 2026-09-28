import 'package:get/get.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkie_order_summary_controller.dart';

class WalkieOrderSummaryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalkieOrderSummaryController>(
      () => WalkieOrderSummaryController(),
    );
  }
}

// Backwards compatibility alias
typedef WalkieTalkiePaymentBinding = WalkieOrderSummaryBinding;
