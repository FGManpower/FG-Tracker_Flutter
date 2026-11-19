import 'package:fgtracker/app/modules/Messages/Controller/DocumentViewerController.dart';
import 'package:fgtracker/app/modules/Messages/Controller/GroupChatController.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:get/get.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<MessageController>()) {
      Get.delete<MessageController>(force: true);
    }
    Get.put<MessageController>(
      MessageController(),
    );
  }
}

class GroupChatBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<GroupMessageController>()) {
      Get.delete<GroupMessageController>(force: true);
    }
    Get.put<GroupMessageController>(
      GroupMessageController(),
    );
  }
}


class DocumentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DocumentViewerController>(
          () => DocumentViewerController(),
    );
  }
}