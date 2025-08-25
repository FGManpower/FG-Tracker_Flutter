import 'package:fgtracker/app/modules/Notification/Controller/Notification_Controller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class Notification_Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(
          () => NotificationController(),
    );

  }
}