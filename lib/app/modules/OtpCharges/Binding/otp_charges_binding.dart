import 'package:get/get.dart';
import 'package:fgtracker/app/modules/OtpCharges/Controller/otp_charges_controller.dart';

class OtpChargesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpChargesController>(
      () => OtpChargesController(),
    );
  }
}
