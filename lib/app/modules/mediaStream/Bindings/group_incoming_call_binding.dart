import 'package:get/get.dart';
import '../Controller/group_incoming_call_controller.dart';

class GroupIncomingCallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupIncomingCallController>(() => GroupIncomingCallController());
  }
}