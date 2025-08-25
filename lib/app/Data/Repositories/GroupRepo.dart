import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Model/CommonRes.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';

class GroupRepo{
  static Future<CommonResponse> createGroup(dynamic data) async {
    var response = await HttpUtil().Authpost("/createGroup",data: data);
    return CommonResponse.fromJson(response);
  }

  static Future<GroupRes> getGroupData() async {
    var response = await HttpUtil().get("/getGroup");
    return GroupRes.fromJson(response);
  }



  static Future<CommonResponse> updateGroupStatus(dynamic param) async {
    var response = await HttpUtil().post("/deActivateGroup",data: param);
    return CommonResponse.fromJson(response);
  }


  static Future<CommonResponse> joinGroup(dynamic data) async {
    var response = await HttpUtil().Authpost("/joinGroup",data: data);
    return CommonResponse.fromJson(response);
  }

  static Future<MemberDataRes> getMemberData(String groupId) async {
    var response = await HttpUtil().get("/getMembers?groupId=$groupId");
    return MemberDataRes.fromJson(response);
  }

  static Future<CommonResponse> exitGroups(dynamic data) async {
    var response = await HttpUtil().Authpost("/exitGroup",data: data);
    return CommonResponse.fromJson(response);
  }

  static Future<CommonResponse> deleteGroups(dynamic data) async {
    var response = await HttpUtil().Authpost("/deleteGroup",data: data);
    return CommonResponse.fromJson(response);
  }
}