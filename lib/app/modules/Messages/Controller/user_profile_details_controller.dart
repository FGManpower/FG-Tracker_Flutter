import 'package:get/get.dart';

import '../../../Data/Repositories/GetMessageRepo.dart';
import '../../../Model/profile_details_model.dart';

class UserProfileDetailsController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<ProfileDetailsData?> profileData = Rx<ProfileDetailsData?>(null);

  /// [silent] = refresh without the skeleton loader and keep the current
  /// data on failure (used after "Clear chat").
  Future<void> fetchProfileDetails(int chatId, {bool silent = false}) async {
    try {
      if (!silent) isLoading.value = true;

      final response = await MessageRepo.getProfileDetails(chatId: chatId);

      if (response.status == true) {
        profileData.value = response.data;
      } else if (!silent) {
        profileData.value = null;
      }
    } catch (e) {
      if (!silent) profileData.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  /// After "Clear chat": the Media / Links / Docs card must not keep showing
  /// the cleared files until the screen is reopened.
  void clearMediaLocally() {
    final data = profileData.value;
    if (data == null) return;
    data.media = null;
    data.mediaSummary = null;
    profileData.refresh();
  }
}
