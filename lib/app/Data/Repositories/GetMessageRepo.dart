import 'dart:io';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/ChatImageUploadResponse.dart';
import 'package:fgtracker/app/Model/ForwardMessageModel.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:fgtracker/app/Model/PrivateChatModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../Model/GroupChatListModel.dart';
import '../../Model/group_profile_details_model.dart';
import '../../Model/profile_details_model.dart';

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
    int limit = 15,
  }) async {
    final response = await HttpUtil().get(
      "/private-chat/$chatId/messages?page=$page&limit=$limit",
    );

    return GetMessage.fromJson(response);
  }

  static Future<GetMessage> groupMessageHistory({
    required int groupId,
    int page = 1,
    int limit = 15,
  }) async {
    final url = "/getGroupMessageHistory?groupId=$groupId&page=$page&limit=$limit";
    var response = await HttpUtil().get(url);

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

  /// Legacy Private Chat List API (Previously used for private chat tab; kept for backward compatibility)
  static Future<PrivateChatResponse> getPrivateChatList({
    int page = 1,
    int limit = 1,
  }) async {
    final response = await HttpUtil().get(
      "/private-chat-list?page=$page&limit=$limit",
    );

    return PrivateChatResponse.fromJson(response);
  }

  /// Legacy Group Chat List API (Previously used for groups tab; kept for backward compatibility)
  static Future<GroupChatListResponse> getGroupChatList({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await HttpUtil().get(
      "/group-chat-list?page=$page&limit=$limit",
    );

    return GroupChatListResponse.fromJson(response);
  }

  /// Unified Single Chat List API (WhatsApp Behavior)
  /// GET /api/chat-list
  /// Merges 1-to-1 private chats and group chats into a single unified list
  static Future<PrivateChatResponse> getChatList({
    int page = 1,
    int limit = 20,
    String? search,
    String type = "all", // "all" | "private" | "group"
    bool includeArchived = false,
  }) async {
    String endpoint = "/chat-list?page=$page&limit=$limit&type=$type&includeArchived=$includeArchived";
    if (search != null && search.trim().isNotEmpty) {
      endpoint += "&search=${Uri.encodeComponent(search.trim())}";
    }

    final response = await HttpUtil().get(endpoint);

    return PrivateChatResponse.fromJson(response);
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
    String? content,
    String? messageType,
    List<String>? images,
    List<Map<String, dynamic>>? videos,
    String? caption,
  }) async {
    final data = {
      "messageId": messageId,
      "sourceType": sourceType,
      "targets": targets.map((target) => target.toJson()).toList(),
      if (content != null && content.isNotEmpty) "content": content,
      if (messageType != null && messageType.isNotEmpty) "messageType": messageType,
      if (images != null && images.isNotEmpty) "images": images,
      if (videos != null && videos.isNotEmpty) "videos": videos,
      if (caption != null && caption.isNotEmpty) "caption": caption,
    };

    debugPrint("FORWARD REQUEST: $data");

    final response = await HttpUtil().Authpost(
      "/forward/message",
      data: data,
    );

    debugPrint("FORWARD RESPONSE: $response");

    return ForwardMessageResponse.fromJson(response);
  }

  static Future<dynamic> blockUser({
    required int blockedUserId,
  }) async {
    final data = {
      "blockedUserId": blockedUserId,
    };

    final response = await HttpUtil().Authpost(
      "/blockUser",
      data: data,
    );

    return response;
  }

  static Future<dynamic> unblockUser({
    required int blockedUserId,
  }) async {
    final data = {
      "blockedUserId": blockedUserId,
    };

    final response = await HttpUtil().Authpost(
      "/unblockUser",
      data: data,
    );

    return response;
  }

  static Future<ProfileDetailsModel> getProfileDetails({
    required int chatId,
  }) async {
    final response = await HttpUtil().get(
      "/chat/profile-details?type=private&chatId=$chatId",
    );

    return ProfileDetailsModel.fromJson(response);
  }


  static Future<GroupProfileDetailsModel> getGroupProfileDetails({
    required int groupId,
  }) async {
    final response = await HttpUtil().get(
      "/chat/profile-details?type=group&groupId=$groupId",
    );
    return GroupProfileDetailsModel.fromJson(response);
  }



  static Future<Map<String, dynamic>> clearGroupChat({
    required int groupId,
  }) async {
    final response = await HttpUtil().Authpost(
      "/clearGroupChat",
      data: {
        "groupId": groupId,
      },
    );

    return Map<String, dynamic>.from(response);
  }
}