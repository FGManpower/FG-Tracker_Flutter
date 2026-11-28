import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Model/CommonRes.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';

class GroupRepo {
  static Future<CommonResponse> createGroup(
    dynamic data, {
    String? imagePath,
  }) async {
    if (imagePath != null && imagePath.isNotEmpty) {
      final formData = FormData.fromMap({
        ...Map<String, dynamic>.from(data),
        'groupProfile': await MultipartFile.fromFile(imagePath),
      });

      final response = await HttpUtil().Authpost(
        "/createGroup",
        formdata: formData,
        type: "formdata",
      );

      return CommonResponse.fromJson(response);
    }

    final response = await HttpUtil().Authpost(
      "/createGroup",
      data: data,
    );

    return CommonResponse.fromJson(response);
  }

  static Future<CommonResponse> updateGroup(
    dynamic data, {
    String? imagePath,
    bool removeProfile = false,
  }) async {
    final formFields = Map<String, dynamic>.from(data);

    if (removeProfile) {
      formFields['removeProfile'] = 'true';
    }

    if (imagePath != null && imagePath.isNotEmpty) {
      formFields['groupProfile'] = await MultipartFile.fromFile(imagePath);
    }

    if (imagePath != null && imagePath.isNotEmpty || removeProfile) {
      final formData = FormData.fromMap(formFields);

      final response = await HttpUtil().Authpost(
        "/updateGroup",
        formdata: formData,
        type: "formdata",
      );

      return CommonResponse.fromJson(response);
    }

    final response = await HttpUtil().Authpost(
      "/updateGroup",
      data: data,
    );

    return CommonResponse.fromJson(response);
  }

  static Future<GroupRes> getGroupData() async {
    var response = await HttpUtil().get(Urls.getAllGroup);
    return GroupRes.fromJson(response);
  }

  static Future<UserProfileListRes> getAllUserData() async {
    var response = await HttpUtil().get("/getAllUser");
    return UserProfileListRes.fromJson(response);
  }

  static Future<CommonResponse> updateGroupStatus(dynamic param) async {
    var response = await HttpUtil().post(
      "/deActivateGroup",
      data: param,
    );
    return CommonResponse.fromJson(response);
  }

  static Future<CommonResponse> joinGroup(
    dynamic data, {
    String url = "joinGroup",
  }) async {
    var response = await HttpUtil().Authpost("/$url", data: data);
    return CommonResponse.fromJson(response);
  }

  static Future<MemberDataRes> getMemberData(String groupId) async {
    var response = await HttpUtil().get("/getMembers?groupId=$groupId");
    return MemberDataRes.fromJson(response);
  }

  static Future<CommonResponse> exitGroups(dynamic data) async {
    var response = await HttpUtil().Authpost("/exitGroup", data: data);
    return CommonResponse.fromJson(response);
  }

  static Future<CommonResponse> deleteGroupsMember(dynamic data) async {
    var response = await HttpUtil().Authpost(
      "/deleteGroupMember",
      data: data,
    );
    return CommonResponse.fromJson(response);
  }

  static Future<CommonResponse> deleteGroups(dynamic data) async {
    var response = await HttpUtil().Authpost("/deleteGroup", data: data);
    return CommonResponse.fromJson(response);
  }
}
