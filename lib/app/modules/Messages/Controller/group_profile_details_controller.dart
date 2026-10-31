import 'package:get/get.dart';
import 'package:fgtracker/app/Model/group_profile_details_model.dart';

import '../../../Data/Repositories/GetMessageRepo.dart';

class GroupProfileDetailsController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<GroupProfileData?> profileData = Rx<GroupProfileData?>(null);

  Future<void> fetchProfileDetails(int groupId) async {
    try {
      isLoading.value = true;
      final response = await MessageRepo.getGroupProfileDetails(groupId: groupId);

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