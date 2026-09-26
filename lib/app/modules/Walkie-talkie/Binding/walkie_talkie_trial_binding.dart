
import 'package:get/get.dart';

import '../../../Data/Repositories/walkie_talkie_trial_details_repository.dart';
import '../../../Data/Services/walkie_talkie_trial_service.dart';

import '../../../modules/Walkie-talkie/Controller/walkie_talkie_trial_controller.dart';

class WalkieTalkieTrialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalkieTalkieTrialRepo>(
          () => const WalkieTalkieTrialRepo(),
    );

    Get.lazyPut<WalkieTalkieTrialService>(
          () => WalkieTalkieTrialService(
        repository: Get.find<WalkieTalkieTrialRepo>(),
      ),
    );

    Get.lazyPut<WalkieTalkieTrialController>(
          () => WalkieTalkieTrialController(
        service: Get.find<WalkieTalkieTrialService>(),
      ),
    );
  }
}