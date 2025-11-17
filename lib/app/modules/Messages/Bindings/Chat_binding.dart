import 'package:fgtracker/app/modules/Group/Controller/MemberController.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:get/get.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessageController>(
      () => MessageController(),
    );
  }
}
