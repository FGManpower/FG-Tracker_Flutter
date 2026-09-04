import 'package:get/get.dart';
import '../Controller/group_calling_controller.dart';

class GroupCallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupCallingController>(() => GroupCallingController());
  }
}