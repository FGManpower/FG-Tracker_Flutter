import 'package:get/get.dart';
import 'package:fgtracker/app/Model/group_profile_details_model.dart';

import '../../../Data/Repositories/GetMessageRepo.dart';

class GroupProfileDetailsController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<GroupProfileData?> profileData = Rx<GroupProfileData?>(null);

  /// [silent] = refresh without the skeleton loader (used after group update)
  Future<void> fetchProfileDetails(int groupId, {bool silent = false}) async {
    try {
      if (!silent) isLoading.value = true;
      final response = await MessageRepo.getGroupProfileDetails(groupId: groupId);

      if (response.status == true) {
        profileData.value = response.data;
      } else if (!silent) {
        profileData.value = null;
      }
    } catch (e) {
      // Silent refresh keeps the current data on failure
      if (!silent) profileData.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}