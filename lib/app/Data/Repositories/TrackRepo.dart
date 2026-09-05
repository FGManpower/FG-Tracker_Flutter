import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:fgtracker/app/Model/member_live_status.dart';

class TrackRepo {
  static Future<LocationDataRes> getUserLocationData(int groupId) async {
    var response =
        await HttpUtil().get("/getGrouplocationsData?groupId=$groupId");
    return LocationDataRes.fromJson(response);
  }

  static Future<MemberLiveStatus> getGroupMember({
    String page = '0',
    String filter = 'online',
  }) async {
    final response = await HttpUtil().get(
      '${Urls.allGroupMembers}'
          '?page=$page'
          '&filter=$filter',
    );

    return MemberLiveStatus.fromJson(response);
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
