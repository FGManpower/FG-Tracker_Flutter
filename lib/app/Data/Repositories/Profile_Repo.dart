import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Model/ProfileRes.dart';

class ProfileRepo {
  static Future<ProfileRes> getProfileData() async {
    var response = await HttpUtil().get("/getProfile");
    return ProfileRes.fromJson(response);
  }
}
