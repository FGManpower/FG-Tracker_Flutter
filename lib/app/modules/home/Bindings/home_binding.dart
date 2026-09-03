

// ignore_for_file: unused_import

import 'package:fgtracker/app/modules/home/Controller/LiveStatus_controller.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:get/get.dart';



class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<HomeController>(
    //   () => HomeController(),
    // );
  }
}





class TrackBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LivesStatusController>(
          () => LivesStatusController(),
    );
  }
}
