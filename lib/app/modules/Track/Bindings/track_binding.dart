
import 'package:fgtracker/app/modules/Track/Controller/TrackController.dart';
import 'package:get/get.dart';

import '../Controller/SearchController.dart';



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


