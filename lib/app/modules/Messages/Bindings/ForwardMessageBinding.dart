import 'package:get/get.dart';

import '../../Group/controller/Group_Controller.dart';
import '../Controller/ForwardMessageController.dart';
import '../../Group/controller/search_controller.dart';

class ForwardMessageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchUserController>(
          () => SearchUserController(),
    );

    Get.lazyPut<GroupController>(
          () => GroupController(),
    );

    Get.lazyPut<ForwardMessageController>(
          () => ForwardMessageController(),
    );
  }
}