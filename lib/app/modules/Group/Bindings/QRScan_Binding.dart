import 'package:get/get.dart';

import '../controller/QrScanController.dart';

class QrScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QRScanController>(
          () => QRScanController(),
    );
  }
}