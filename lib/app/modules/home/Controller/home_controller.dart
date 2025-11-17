import 'package:fgtracker/app/Data/Repositories/Profile_Repo.dart';
import 'package:fgtracker/app/Model/ProfileRes.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxBool ProfileData_loading = false.obs;
  var Respone_Error = "".obs;
  Rx<UserData> userData = UserData().obs;

  Future<void> getProfileData() async {
    try {
      ProfileData_loading.value = true;
      var profileData = await ProfileRepo.getProfileData();
      if (profileData.status == true) {
        userData.value = profileData.data!;
        Respone_Error.value = "";
      }
    } catch (e) {
      Respone_Error.value = e.toString();
    } finally {
      ProfileData_loading.value = false;
    }
  }
}
