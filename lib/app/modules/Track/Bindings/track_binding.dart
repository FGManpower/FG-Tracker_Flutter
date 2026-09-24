import 'package:fgtracker/app/modules/Track/Controller/SearchController.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackController.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackLiveLocationSocketService.dart';
import 'package:get/get.dart';

class SearchMember_Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchMemberController>(
      () => SearchMemberController(),
    );
  }
}

class LocationTracking_Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrackingController>(
      () => TrackingController(),
    );
  }
}

class TrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrackLiveLocationSocketService>(
      () => TrackLiveLocationSocketService(),
    );
    Get.lazyPut<TrackController>(
      () => TrackController(),
    );
  }
}
