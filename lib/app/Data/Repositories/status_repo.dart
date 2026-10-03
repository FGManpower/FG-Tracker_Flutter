import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Model/CommonRes.dart';
import 'package:fgtracker/app/Model/status_model.dart';


class StatusRepo {
  static Future<StatusCreateRes> createStatus({
    required String type,
    required String content,
    required String backgroundColor,
    String fontStyle = 'default',
    required int durationSeconds,
    required String privacyType,
    List<int>? targetUserIds,
    File? mediaFile,
  }) async {
    final Map<String, dynamic> map = {
      'type': type,
      'content': content,
      'backgroundColor': backgroundColor,
      'fontStyle': fontStyle,
      'durationSeconds': durationSeconds,
      'privacyType': privacyType,
      if (targetUserIds != null && targetUserIds.isNotEmpty)
        'targetUserIds': jsonEncode(targetUserIds),
    };

    if (mediaFile != null) {
      final fileName = mediaFile.path.split('/').last;
      map['media'] = await MultipartFile.fromFile(
        mediaFile.path,
        filename: fileName,
      );
    }

    final formData = FormData.fromMap(map);
    var response = await HttpUtil().Authpost(Urls.createStatus, data: formData);
    return StatusCreateRes.fromJson(response);
  }

  static Future<StatusFeedRes> getStatusFeed() async {
    var response = await HttpUtil().get(Urls.statusFeed);
    return StatusFeedRes.fromJson(response);
  }

  static Future<MyStatusRes> getMyStatus() async {
    var response = await HttpUtil().get(Urls.myStatus);
    return MyStatusRes.fromJson(response);
  }

  static Future<CommonResponse> viewStatus(
      int statusId, {
        String? reactionEmoji,
      }) async {
    final Map<String, dynamic> data = {
      if (reactionEmoji != null && reactionEmoji.isNotEmpty)
        'reactionEmoji': reactionEmoji,
    };
    var response = await HttpUtil().Authpost(
      Urls.viewStatus(statusId),
      data: data,
    );
    return CommonResponse.fromJson(response);
  }

  static Future<CommonResponse> replyStatus(
      int statusId, {
        required String comment,
        String? reactionEmoji,
      }) async {
    final Map<String, dynamic> data = {
      'comment': comment,
      if (reactionEmoji != null && reactionEmoji.isNotEmpty)
        'reactionEmoji': reactionEmoji,
    };
    var response = await HttpUtil().Authpost(
      Urls.replyStatus(statusId),
      data: data,
    );
    return CommonResponse.fromJson(response);
  }

  static Future<CommonResponse> deleteStatus(int statusId) async {
    var response = await HttpUtil().Authdelete(Urls.deleteStatus(statusId));
    return CommonResponse.fromJson(response);
  }
}