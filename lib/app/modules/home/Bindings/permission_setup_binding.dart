import 'package:get/get.dart';
import '../Controller/PermissionSetupController.dart';

class PermissionSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PermissionSetupController>(() => PermissionSetupController());
  }
}
