import 'package:get/get.dart';

import 'permission_gate_controller.dart';

class PermissionGateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PermissionGateController>(() => PermissionGateController());
  }
}
