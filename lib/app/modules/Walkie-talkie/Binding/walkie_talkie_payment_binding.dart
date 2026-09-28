import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkie_talkie_payment_controller.dart';
import 'package:get/get.dart';

class WalkieTalkiePaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalkieTalkiePaymentController>(
      () => WalkieTalkiePaymentController(),
    );
  }
}
