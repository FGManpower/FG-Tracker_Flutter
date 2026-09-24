import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/ProfileRes.dart';

class ProfileRepo {
  static Future<ProfileRes> getProfileData() async {
    var response = await HttpUtil().get("/getProfile");
    ProfileRes profileRes = ProfileRes.fromJson(response);
    if (profileRes.status == true && profileRes.data != null) {
      if (profileRes.data!.email != null &&
          profileRes.data!.email!.isNotEmpty &&
          profileRes.data!.email != "null") {
        Global.storageServices
            .setString(PrefConst.userEmail, profileRes.data!.email!);
      } else {
        Global.storageServices.remove(PrefConst.userEmail);
      }
      if (profileRes.data!.name != null && profileRes.data!.name!.isNotEmpty) {
        Global.storageServices
            .setString(PrefConst.userName, profileRes.data!.name!);
      }
      if (profileRes.data!.mobileNo != null &&
          profileRes.data!.mobileNo!.isNotEmpty) {
        Global.storageServices
            .setString(PrefConst.userPhone, profileRes.data!.mobileNo!);
      }
    }
    return profileRes;
  }
}
