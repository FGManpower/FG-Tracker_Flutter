import 'package:fgtracker/app/modules/Group/controller/MemberController.dart';
import 'package:get/get.dart';

class MemberBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MemberController>(
      () => MemberController(),
    );
  }
}
