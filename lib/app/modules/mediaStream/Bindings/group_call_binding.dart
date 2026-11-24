import 'package:get/get.dart';
import '../Controller/group_calling_controller.dart';

class GroupCallBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<GroupCallingController>()) {
      final GroupCallingController existing = Get.find<GroupCallingController>();
      if (existing.isConnected || existing.isMinimized.value) return;
      existing.isMinimized.value = false;
      Get.delete<GroupCallingController>(force: true);
    }
    Get.put<GroupCallingController>(
      GroupCallingController(),
      permanent: true,
    );
  }
}
