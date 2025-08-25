import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';

class TrackRepo{
  static Future<LocationDataRes> getUserLocationData(int groupId) async {
    var response = await HttpUtil().get("/getGrouplocationsData?groupId=$groupId");
    return LocationDataRes.fromJson(response);
  }
}