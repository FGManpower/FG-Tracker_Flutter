import 'package:get/get.dart';

import '../../../Data/Repositories/GetMessageRepo.dart';
import '../../../Model/profile_details_model.dart';

class UserProfileDetailsController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<ProfileDetailsData?> profileData = Rx<ProfileDetailsData?>(null);

  Future<void> fetchProfileDetails(int chatId) async {
    try {
      isLoading.value = true;

      final response = await MessageRepo.getProfileDetails(chatId: chatId);

      if (response.status == true) {
        profileData.value = response.data;
      } else {
        profileData.value = null;
      }
    } catch (e) {
      profileData.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}
