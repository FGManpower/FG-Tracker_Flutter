import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/Socket/status_socket_service.dart';
import 'package:fgtracker/app/modules/status/controller/status_feed_controller.dart';
import 'package:get/get.dart';

class StatusBinding extends Bindings {
  StatusBinding();

  @override
  void dependencies() {
    if (!Get.isRegistered<StatusSocketService>()) {
      final socketService = Get.put<StatusSocketService>(
        StatusSocketService(),
        permanent: true,
      );
      socketService.connect(
        baseUrl: ConstRes.socketUrl,
        token: Global.storageServices.getaccesstoken(),
      );
    }

    if (!Get.isRegistered<StatusFeedController>()) {
      Get.put<StatusFeedController>(
        StatusFeedController(),
        permanent: true,
      );
    }
  }
}