import 'dart:io';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/ChatImageUploadResponse.dart';
import 'package:fgtracker/app/Model/ForwardMessageModel.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:fgtracker/app/Model/PrivateChatModel.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../Model/GroupChatListModel.dart';

class MessageRepo {
  static Future<GetMessage> MessageHistory({
    required String recieverId,
    required int groupId,
  }) async {
    var response = await HttpUtil().get(
      "/getMessageHistory?senderId=${Global.storageServices.get(PrefConst.userId)}&receiverId=$recieverId&groupId=$groupId",
    );

    return GetMessage.fromJson(response);
  }

  static Future<GetMessage> privateChatHistory({
    required String chatId,
    int page = 1,
    int limit = 50,
  }) async {
    final response = await HttpUtil().get(
      "/private-chat/$chatId/messages?page=$page&limit=$limit",
    );

    return GetMessage.fromJson(response);
  }

  static Future<GetMessage> groupMessageHistory({
    required int groupId,
  }) async {
    var response = await HttpUtil().get(
      "/getGroupMessageHistory?groupId=$groupId",
    );

    return GetMessage.fromJson(response);
  }

  static Future<ChatImageUploadResponse> uploadChatImage(
    File imageFile,
  ) async {
    FormData data = FormData.fromMap({
      "chatImage": await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      ),
    });

    var response = await HttpUtil().Authpost(
      "/uploadChatImage",
      formdata: data,
      type: "formdata",
    );

    return ChatImageUploadResponse.fromJson(response);
  }

  static Future<ChatImageUploadResponse> uploadChatAudio(
    String audioPath,
  ) async {
    FormData data = FormData.fromMap({
      "chatAudio": await MultipartFile.fromFile(
        audioPath,
        filename: audioPath.split('/').last,
        contentType: MediaType('audio', 'm4a'),
      ),
    });

    var response = await HttpUtil().Authpost(
      "/uploadAudio",
      formdata: data,
      type: "formdata",
    );

    return ChatImageUploadResponse.fromJson(response);
  }

  static Future<ChatImageUploadResponse> uploadChatVideo({
    required String videoPath,
    required String thumbnailPath,
    ProgressCallback? onSendProgress,
  }) async {
    print("Video Path: $videoPath");
    print("Thumbnail Path: $thumbnailPath");
    print("Video Exists: ${await File(videoPath).exists()}");
    print("Video Size: ${await File(videoPath).length()}");
    print("Extension: ${p.extension(videoPath)}");

    final ext = p.extension(videoPath).replaceFirst('.', '');

    FormData data = FormData.fromMap({
      "chatVideo": await MultipartFile.fromFile(
        videoPath,
        filename: p.basename(videoPath),
        contentType: MediaType("video", ext),
      ),
      "thumbnail": await MultipartFile.fromFile(
        thumbnailPath,
        filename: p.basename(thumbnailPath),
        contentType: MediaType("image", "jpeg"),
      ),
    });

    final response = await HttpUtil().Authpost(
      "/uploadVideo",
      formdata: data,
      type: "formdata",
      onSendProgress: onSendProgress,
    );

    return ChatImageUploadResponse.fromJson(response);
  }

  static Future<ChatImageUploadResponse> uploadChatDocument(
    String documentPath,
  ) async {
    final ext = p.extension(documentPath).replaceFirst('.', '');

    FormData data = FormData.fromMap({
      "chatDocument": await MultipartFile.fromFile(
        documentPath,
        filename: p.basename(documentPath),
        contentType: MediaType('document', ext),
      ),
    });

    var response = await HttpUtil().Authpost(
      "/uploadDocument",
      formdata: data,
      type: "formdata",
    );

    return ChatImageUploadResponse.fromJson(response);
  }

  static Future<LocationDataRes> getGroupMembers({
    required int groupId,
  }) async {
    var response = await HttpUtil().get(
      "/getMembers?groupId=$groupId",
    );

    return LocationDataRes.fromJson(response);
  }

  static Future<PrivateChatResponse> getPrivateChatList({
    int page = 1,
    int limit = 1,
  }) async {
    final response = await HttpUtil().get(
      "/private-chat-list?page=$page&limit=$limit",
    );

    return PrivateChatResponse.fromJson(response);
  }

  static Future<GroupChatListResponse> getGroupChatList({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await HttpUtil().get(
      "/group-chat-list?page=$page&limit=$limit",
    );

    return GroupChatListResponse.fromJson(response);
  }

  static Future<ForwardListResponse> getForwardList() async {
    final response = await HttpUtil().get(
      "/forward/list",
    );

    return ForwardListResponse.fromJson(response);
  }

  static Future<ForwardMessageResponse> forwardMessage({
    required int messageId,
    required String sourceType,
    required List<ForwardTarget> targets,
  }) async {
    final data = {
      "messageId": messageId,
      "sourceType": sourceType,
      "targets": targets.map((target) => target.toJson()).toList(),
    };

    final response = await HttpUtil().Authpost(
      "/forward/message",
      data: data,
    );

    return ForwardMessageResponse.fromJson(response);
  }




}
