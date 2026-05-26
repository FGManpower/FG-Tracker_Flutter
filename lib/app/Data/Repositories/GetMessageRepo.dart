// ignore_for_file: unused_import

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/ChatImageUploadResponse.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/Model/ProfileRes.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';

import '../../Core/values/utility.dart';
import '../../Model/CommonRes.dart';

class MessageRepo {
  static Future<GetMessage> MessageHistory(
      {required String recieverId, required int groupId}) async {
    var response = await HttpUtil().get(
        "/getMessageHistory?senderId=${Global.storageServices.get(PrefConst.userId)}&receiverId=$recieverId&groupId=$groupId");
    return GetMessage.fromJson(response);
  }

  static Future<GetMessage> groupMessageHistory({
    required int groupId,
  }) async {
    var response = await HttpUtil().get(
      "/getGroupMessageHistory?groupId=$groupId",
    );

    return GetMessage.fromJson(
      response,
    );
  }

  static Future<ChatImageUploadResponse> uploadChatImage(var imagePath) async {
    FormData data = FormData.fromMap({
      "chatImage": Utility.isNotNullEmptyOrFalse(imagePath)
          ? await MultipartFile.fromFile(imagePath.toString(),
              filename: imagePath.toString(),
              contentType: MediaType(
                'image',
                'jpeg',
              ))
          : "",
    });
    var response = await HttpUtil()
        .Authpost("/uploadChatImage", formdata: data, type: "formdata");
    return ChatImageUploadResponse.fromJson(response);
  }

  static Future<ChatImageUploadResponse> uploadChatAudio(
      String audioPath) async {
    FormData data = FormData.fromMap({
      "chatAudio": await MultipartFile.fromFile(
        audioPath,
        filename: audioPath.split('/').last,
        contentType: MediaType('audio', 'm4a'),
      )
    });

    var response = await HttpUtil()
        .Authpost("/uploadAudio", formdata: data, type: "formdata");

    return ChatImageUploadResponse.fromJson(response);
  }
}
