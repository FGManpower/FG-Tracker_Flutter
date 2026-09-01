import 'package:get/get.dart';

import '../Controller/SosController.dart';

class SosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SosController>(() => SosController());
  }
}