import 'package:fgtracker/app/Model/status_model.dart';

class GetMessage {
  bool? status;
  String? message;
  List<MessageData>? messageData;
  bool? isCreator;
  int? pinnedMessageId;
  MessagePagination? pagination;
  BlockStatus? blockStatus;
  bool? isOnline;
  String? lastSeen;
  Map<String, dynamic>? otherUser;
  List<String>? images;

  GetMessage({
    this.status,
    this.message,
    this.messageData,
    this.isCreator,
    this.pinnedMessageId,
    this.pagination,
    this.blockStatus,
    this.isOnline,
    this.lastSeen,
    this.otherUser,
    this.images,
  });

  GetMessage.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    isCreator = json['isCreator'];
    pinnedMessageId = json['pinnedMessageId'];

    final user = json['otherUser'] is Map
        ? Map<String, dynamic>.from(json['otherUser'])
        : null;

    otherUser = user;

    isOnline = _parseBool(json['isOnline'] ?? user?['isOnline']);
    lastSeen = (json['lastSeen'] ?? user?['lastSeen'])?.toString();

    if (json['images'] is List) {
      images = (json['images'] as List).map((e) => e.toString()).toList();
    }

    if (json['blockStatus'] is Map) {
      blockStatus = BlockStatus.fromJson(
        Map<String, dynamic>.from(json['blockStatus']),
      );
    }

    if (json['pagination'] is Map) {
      pagination = MessagePagination.fromJson(
        Map<String, dynamic>.from(json['pagination']),
      );
    }

    final messages = json['MessageData'] ??
        json['messageData'] ??
        json['messages'] ??
        json['data'];

    if (messages is List) {
      messageData = <MessageData>[];

      for (final item in messages) {
        if (item is Map<String, dynamic>) {
          messageData!.add(MessageData.fromJson(item));
        } else if (item is Map) {
          messageData!.add(
            MessageData.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
  }

  static bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    if (value is String) {
      final normalized = value.trim().toLowerCase();

      if (normalized == 'true' || normalized == '1') {
        return true;
      }

      if (normalized == 'false' || normalized == '0') {
        return false;
      }
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['status'] = status;
    data['message'] = message;
    data['isCreator'] = isCreator;
    data['pinnedMessageId'] = pinnedMessageId;
    data['isOnline'] = isOnline;
    data['lastSeen'] = lastSeen;
    data['otherUser'] = otherUser;
    data['images'] = images;

    if (blockStatus != null) {
      data['blockStatus'] = blockStatus!.toJson();
    }

    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }

    if (messageData != null) {
      data['MessageData'] = messageData!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class BlockStatus {
  bool? isBlocked;
  bool? blockedByMe;
  int? otherUserId;

  BlockStatus({
    this.isBlocked,
    this.blockedByMe,
    this.otherUserId,
  });

  BlockStatus.fromJson(Map<String, dynamic> json) {
    isBlocked = json['isBlocked'];
    blockedByMe = json['blockedByMe'];
    otherUserId = json['otherUserId'];
  }

  Map<String, dynamic> toJson() {
    return {
      'isBlocked': isBlocked,
      'blockedByMe': blockedByMe,
      'otherUserId': otherUserId,
    };
  }
}

class MessagePagination {
  int? currentPage;
  int? perPage;
  int? totalRecords;
  int? totalPages;
  bool? hasNextPage;
  bool? hasPreviousPage;

  MessagePagination({
    this.currentPage,
    this.perPage,
    this.totalRecords,
    this.totalPages,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  MessagePagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    perPage = json['perPage'];
    totalRecords = json['totalRecords'];
    totalPages = json['totalPages'];
    hasNextPage = json['hasNextPage'];
    hasPreviousPage = json['hasPreviousPage'];
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'perPage': perPage,
      'totalRecords': totalRecords,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }
}

class MessageVideo {
  String? videoUrl;
  String? thumbnail;
  String? duration;

  MessageVideo({
    this.videoUrl,
    this.thumbnail,
    this.duration,
  });

  MessageVideo.fromJson(Map<String, dynamic> json) {
    videoUrl = json['videoUrl']?.toString();
    thumbnail = json['thumbnail']?.toString();
    duration = json['duration']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'videoUrl': videoUrl,
      'thumbnail': thumbnail,
      'duration': duration,
    };
  }
}

class MessageData {
  int? id;
  dynamic senderId;
  dynamic receiverId;
  dynamic messageType;
  dynamic content;
  dynamic timestamp;
  dynamic seenCount;
  dynamic seenBy;
  dynamic isEdited;
  dynamic editedAt;
  dynamic edited;
  dynamic senderName;
  dynamic senderImage;
  dynamic thumbnail;
  dynamic caption;
  List<String>? images;
  List<MessageVideo>? videos;
  dynamic replyId;
  dynamic replyMessage;
  dynamic replyType;
  dynamic replySenderName;
  dynamic locationSharing;
  dynamic isForwarded;
  dynamic forwardedFromMessageId;
  dynamic replyStatusId;
  dynamic statusType;
  dynamic replyMessageContent;
  StatusMetaModel? statusMeta;
  StatusItemModel? replyStatus;
  bool isDeleted = false;

  MessageData({
    this.id,
    this.senderId,
    this.receiverId,
    this.messageType,
    this.content,
    this.timestamp,
    this.seenCount,
    this.seenBy,
    this.senderImage,
    this.edited,
    this.isEdited,
    this.editedAt,
    this.senderName,
    this.caption,
    this.images,
    this.videos,
    this.replyId,
    this.replyMessage,
    this.replyType,
    this.replySenderName,
    this.thumbnail,
    this.locationSharing,
    this.isForwarded,
    this.forwardedFromMessageId,
    this.replyStatusId,
    this.statusType,
    this.replyMessageContent,
    this.statusMeta,
    this.replyStatus,
    this.isDeleted = false,
  });

  bool get isStatusReply {
    final mType = messageType?.toString().toLowerCase();
    final rType = replyType?.toString().toLowerCase();
    return mType == 'status_reply' || rType == 'status';
  }

  int? get resolvedStatusId {
    if (replyStatus != null && replyStatus!.id > 0) {
      return replyStatus!.id;
    }

    if (statusMeta?.statusId != null && statusMeta!.statusId! > 0) {
      return statusMeta!.statusId;
    }

    final rawId = replyStatusId ?? replyId;
    return int.tryParse(rawId?.toString() ?? '');
  }

  MessageData.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? nestedSource;
    if (json['forwardedMessage'] is Map) {
      nestedSource = Map<String, dynamic>.from(json['forwardedMessage']);
    } else if (json['forwarded_message'] is Map) {
      nestedSource = Map<String, dynamic>.from(json['forwarded_message']);
    } else if (json['originalMessage'] is Map) {
      nestedSource = Map<String, dynamic>.from(json['originalMessage']);
    } else if (json['original_message'] is Map) {
      nestedSource = Map<String, dynamic>.from(json['original_message']);
    } else if (json['forwardedFrom'] is Map) {
      nestedSource = Map<String, dynamic>.from(json['forwardedFrom']);
    } else if (json['forwarded_from'] is Map) {
      nestedSource = Map<String, dynamic>.from(json['forwarded_from']);
    } else if (json['sourceMessage'] is Map) {
      nestedSource = Map<String, dynamic>.from(json['sourceMessage']);
    } else if (json['source_message'] is Map) {
      nestedSource = Map<String, dynamic>.from(json['source_message']);
    } else if (json['forwardMessage'] is Map) {
      nestedSource = Map<String, dynamic>.from(json['forwardMessage']);
    } else if (json['forward_message'] is Map) {
      nestedSource = Map<String, dynamic>.from(json['forward_message']);
    } else if (json['forwardData'] is Map) {
      nestedSource = Map<String, dynamic>.from(json['forwardData']);
    } else if (json['forward_data'] is Map) {
      nestedSource = Map<String, dynamic>.from(json['forward_data']);
    } else if (json['message'] is Map) {
      nestedSource = Map<String, dynamic>.from(json['message']);
    } else if (json['data'] is Map) {
      final dataMap = Map<String, dynamic>.from(json['data']);
      if (dataMap['forwardedMessage'] is Map) {
        nestedSource = Map<String, dynamic>.from(dataMap['forwardedMessage']);
      } else if (dataMap['forwarded_message'] is Map) {
        nestedSource = Map<String, dynamic>.from(dataMap['forwarded_message']);
      } else if (dataMap['originalMessage'] is Map) {
        nestedSource = Map<String, dynamic>.from(dataMap['originalMessage']);
      } else if (dataMap['original_message'] is Map) {
        nestedSource = Map<String, dynamic>.from(dataMap['original_message']);
      } else {
        nestedSource = dataMap;
      }
    }

    id = json['id'] ?? nestedSource?['id'];
    senderId = json['senderId'] ??
        json['sender_id'] ??
        json['userId'] ??
        json['user_id'] ??
        nestedSource?['senderId'] ??
        nestedSource?['sender_id'] ??
        nestedSource?['userId'] ??
        nestedSource?['user_id'];
    receiverId = json['receiverId'] ??
        json['receiver_id'] ??
        json['targetId'] ??
        json['target_id'] ??
        nestedSource?['receiverId'] ??
        nestedSource?['receiver_id'];

    final rawType = json['messageType'] ??
        json['message_type'] ??
        json['type'] ??
        nestedSource?['messageType'] ??
        nestedSource?['message_type'] ??
        nestedSource?['type'];
    messageType = rawType?.toString();

    final rawContent = json['content'] ??
        (json['message'] is String ? json['message'] : null) ??
        json['text'] ??
        json['msg'] ??
        json['body'] ??
        json['caption'] ??
        json['forwarded_content'] ??
        json['forwardedContent'] ??
        json['original_content'] ??
        json['originalContent'] ??
        json['source_content'] ??
        json['sourceContent'] ??
        json['forward_content'] ??
        json['forwardContent'] ??
        json['message_content'] ??
        json['messageContent'] ??
        nestedSource?['content'] ??
        (nestedSource?['message'] is String ? nestedSource!['message'] : null) ??
        nestedSource?['text'] ??
        nestedSource?['msg'] ??
        nestedSource?['body'] ??
        nestedSource?['caption'] ??
        nestedSource?['forwarded_content'] ??
        nestedSource?['original_content'];
    content = rawContent?.toString();

    timestamp = json['timestamp'] ??
        json['createdAt'] ??
        json['created_at'] ??
        nestedSource?['timestamp'] ??
        nestedSource?['createdAt'];
    seenCount = json['seenCount'] ?? json['seen_count'];
    seenBy = json['seenBy'] ?? json['seen_by'];
    edited = json['edited'] ?? json['isEdited'] ?? json['is_edited'];
    isEdited = json['isEdited'] ?? json['is_edited'] ?? json['edited'];
    editedAt = json['editedAt'] ?? json['edited_at'];
    senderName = json['senderName'] ??
        json['sender_name'] ??
        nestedSource?['senderName'] ??
        nestedSource?['sender_name'];
    senderImage = json['senderImage'] ??
        json['sender_image'] ??
        nestedSource?['senderImage'] ??
        nestedSource?['sender_image'];
    thumbnail = json['thumbnail'] ?? nestedSource?['thumbnail'];
    caption = json['caption'] ??
        json['forwarded_caption'] ??
        json['forwardedCaption'] ??
        json['original_caption'] ??
        json['originalCaption'] ??
        nestedSource?['caption'];

    final rawImages = json['images'] ??
        json['forwarded_images'] ??
        json['forwardedImages'] ??
        json['original_images'] ??
        json['originalImages'] ??
        nestedSource?['images'];
    if (rawImages is List) {
      images = rawImages.map((e) => e.toString()).toList();
    } else if (json['image'] != null || nestedSource?['image'] != null) {
      final singleImg = json['image'] ?? nestedSource?['image'];
      if (singleImg is String && singleImg.isNotEmpty) {
        images = [singleImg];
      } else if (singleImg is List) {
        images = singleImg.map((e) => e.toString()).toList();
      } else {
        images = null;
      }
    } else {
      images = null;
    }

    final rawVideos = json['videos'] ??
        json['forwarded_videos'] ??
        json['forwardedVideos'] ??
        json['original_videos'] ??
        json['originalVideos'] ??
        nestedSource?['videos'];
    if (rawVideos is List) {
      videos = rawVideos
          .where((item) => item is Map)
          .map(
            (item) => MessageVideo.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList();
    } else if (json['video'] != null || nestedSource?['video'] != null) {
      final singleVid = json['video'] ?? nestedSource?['video'];
      if (singleVid is Map) {
        videos = [MessageVideo.fromJson(Map<String, dynamic>.from(singleVid))];
      } else if (singleVid is String && singleVid.isNotEmpty) {
        videos = [MessageVideo(videoUrl: singleVid)];
      } else {
        videos = null;
      }
    } else {
      videos = null;
    }

    final lowerType = messageType?.toLowerCase().trim() ?? '';
    if (lowerType.isEmpty ||
        lowerType == 'forward' ||
        lowerType == 'forwarded' ||
        lowerType == 'forward_message') {
      final nestedType = (nestedSource?['messageType'] ??
              nestedSource?['message_type'] ??
              nestedSource?['type'])
          ?.toString()
          .toLowerCase()
          .trim();
      if (nestedType != null &&
          nestedType.isNotEmpty &&
          nestedType != 'forward' &&
          nestedType != 'forwarded' &&
          nestedType != 'forward_message') {
        messageType = nestedType;
      } else if (images != null && images!.isNotEmpty) {
        messageType = 'media';
      } else if (videos != null && videos!.isNotEmpty) {
        messageType = 'video';
      } else if (content != null &&
          content.toString().contains("||") &&
          (content.toString().contains(".pdf") ||
              content.toString().contains(".doc") ||
              content.toString().contains(".xls") ||
              content.toString().contains(".ppt"))) {
        messageType = 'document';
      } else {
        messageType = 'text';
      }
    }

    replyId = json['replyId'] ??
        json['reply_id'] ??
        nestedSource?['replyId'] ??
        nestedSource?['reply_id'];
    replyMessage = json['replyMessage'] ??
        json['reply_message'] ??
        nestedSource?['replyMessage'] ??
        nestedSource?['reply_message'];
    replyType = json['replyType'] ??
        json['reply_type'] ??
        nestedSource?['replyType'] ??
        nestedSource?['reply_type'];
    replySenderName = json['replySender'] ??
        json['replySenderName'] ??
        json['reply_sender_name'] ??
        nestedSource?['replySenderName'];

    replyStatusId = json['replyStatusId'] ?? json['reply_status_id'];
    statusType = json['statusType'] ?? json['status_type'];
    replyMessageContent =
        json['replyMessageContent'] ?? json['reply_message_content'];

    if (json['statusMeta'] is Map) {
      statusMeta = StatusMetaModel.fromJson(
        Map<String, dynamic>.from(json['statusMeta']),
      );
    } else if (nestedSource?['statusMeta'] is Map) {
      statusMeta = StatusMetaModel.fromJson(
        Map<String, dynamic>.from(nestedSource!['statusMeta']),
      );
    }

    if (json['replyStatus'] is Map) {
      final replyMap = Map<String, dynamic>.from(json['replyStatus']);
      replyStatus = StatusItemModel.fromReplyStatus(
        replyMap,
        meta: statusMeta,
      );
    } else if (statusMeta != null) {
      replyStatus = StatusItemModel.fromStatusMeta(
        statusMeta!,
        content:
        replyMessageContent?.toString() ?? replyMessage?.toString() ?? '',
      );
    }

    locationSharing = json['locationSharing'] ??
        json['location_sharing'] ??
        nestedSource?['locationSharing'];

    final rawForwarded = json['isForwarded'] ??
        json['is_forwarded'] ??
        json['forwarded'] ??
        json['is_forward'] ??
        json['isForward'] ??
        nestedSource?['isForwarded'] ??
        nestedSource?['is_forwarded'];

    isForwarded = rawForwarded == true ||
        rawForwarded == 1 ||
        rawForwarded?.toString().toLowerCase() == 'true' ||
        rawForwarded?.toString() == '1' ||
        json['forwardedFromMessageId'] != null ||
        json['forwarded_from_message_id'] != null ||
        json['forwardedMessageId'] != null ||
        json['forwarded_message_id'] != null ||
        json['forwardedMessage'] != null ||
        json['forwarded_message'] != null ||
        json['originalMessage'] != null ||
        json['original_message'] != null ||
        json['forwardMessage'] != null ||
        json['forward_message'] != null ||
        rawType?.toString().toLowerCase() == 'forward' ||
        rawType?.toString().toLowerCase() == 'forwarded' ||
        rawType?.toString().toLowerCase() == 'forward_message';

    forwardedFromMessageId = json['forwardedFromMessageId'] ??
        json['forwarded_from_message_id'] ??
        json['forwardedMessageId'] ??
        json['forwarded_message_id'] ??
        json['originalMessageId'] ??
        json['original_message_id'] ??
        json['sourceMessageId'] ??
        json['source_message_id'] ??
        nestedSource?['forwardedFromMessageId'] ??
        nestedSource?['forwarded_from_message_id'] ??
        nestedSource?['id'];

    isDeleted = json['isDeleted'] == true ||
        json['is_deleted'] == true ||
        json['deletedForEveryone'] == true ||
        json['deleted_for_everyone'] == true ||
        json['isDeleted']?.toString() == '1' ||
        json['is_deleted']?.toString() == '1';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['senderId'] = senderId;
    data['receiverId'] = receiverId;
    data['messageType'] = messageType;
    data['content'] = content;
    data['timestamp'] = timestamp;
    data['seenCount'] = seenCount;
    data['seenBy'] = seenBy;
    data['edited'] = edited;
    data['senderName'] = senderName;
    data['senderImage'] = senderImage;
    data['thumbnail'] = thumbnail;
    data['caption'] = caption;
    data['images'] = images;
    data['videos'] = videos?.map((video) => video.toJson()).toList();
    data['reply_id'] = replyId;
    data['isEdited'] = isEdited;
    data['editedAt'] = editedAt;
    data['reply_message'] = replyMessage;
    data['reply_type'] = replyType;
    data['reply_sender_name'] = replySenderName;
    data['replyStatusId'] = replyStatusId;
    data['statusType'] = statusType;
    data['replyMessageContent'] = replyMessageContent;

    if (statusMeta != null) {
      data['statusMeta'] = {
        'statusId': statusMeta!.statusId,
        'type': statusMeta!.type,
        'mediaUrl': statusMeta!.mediaUrl,
        'thumbnail': statusMeta!.thumbnail,
        'ownerName': statusMeta!.ownerName,
      };
    }

    data['locationSharing'] = locationSharing;
    data['isForwarded'] = isForwarded;
    data['forwardedFromMessageId'] = forwardedFromMessageId;
    data['isDeleted'] = isDeleted;

    return data;
  }
}