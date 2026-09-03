import 'package:fgtracker/app/modules/Notification/Controller/Notification_Controller.dart';
import 'package:get/get.dart';

class Notification_Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(
          () => NotificationController(),
    );

  }
}