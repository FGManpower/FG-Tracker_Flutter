import 'package:get/get.dart';

import '../../../modules/Walkie-talkie/Controller/walkie_talkie_trial_controller.dart';

class WalkieTalkieTrialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalkieTalkieTrialController>(
          () => WalkieTalkieTrialController(),
    );
  }
}