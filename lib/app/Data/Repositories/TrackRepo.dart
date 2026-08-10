import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';

class TrackRepo {
  static Future<LocationDataRes> getUserLocationData(int groupId) async {
    var response =
        await HttpUtil().get("/getGrouplocationsData?groupId=$groupId");
    return LocationDataRes.fromJson(response);
  }

  static Future<bool> updateLocationSharing(bool locationSharing) async {
    final response = await HttpUtil().post(
      "/location-sharing/update",
      data: {
        "userId": int.parse(
          Global.storageServices.get(PrefConst.userId).toString(),
        ),
        "locationSharing": locationSharing,
      },
    );

    return response["status"] == true;
  }
}
