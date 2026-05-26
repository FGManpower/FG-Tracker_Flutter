import 'package:fgtracker/app/modules/Messages/Controller/GroupChatController.dart';
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

class GroupChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupMessageController>(
      () => GroupMessageController(),
    );
  }
}
