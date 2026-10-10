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
    id = json['id'];
    senderId = json['senderId'];
    receiverId = json['receiverId'];
    messageType = json['messageType'];
    content = json['content'];
    timestamp = json['timestamp'] ?? json['createdAt'];
    seenCount = json['seenCount'];
    seenBy = json['seenBy'];
    edited = json['edited'];
    isEdited = json['isEdited'];
    editedAt = json['editedAt'];
    senderName = json['senderName'];
    senderImage = json['senderImage'];
    thumbnail = json['thumbnail'];
    caption = json['caption'];

    if (json['images'] is List) {
      images = (json['images'] as List).map((e) => e.toString()).toList();
    } else {
      images = null;
    }

    replyId = json['replyId'] ?? json['reply_id'];
    replyMessage = json['replyMessage'] ?? json['reply_message'];
    replyType = json['replyType'] ?? json['reply_type'];
    replySenderName = json['replySender'] ??
        json['replySenderName'] ??
        json['reply_sender_name'];

    replyStatusId = json['replyStatusId'] ?? json['reply_status_id'];
    statusType = json['statusType'] ?? json['status_type'];
    replyMessageContent =
        json['replyMessageContent'] ?? json['reply_message_content'];

    if (json['statusMeta'] is Map) {
      statusMeta = StatusMetaModel.fromJson(
        Map<String, dynamic>.from(json['statusMeta']),
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

    locationSharing = json['locationSharing'] ?? json['location_sharing'];
    isForwarded = json['isForwarded'];
    forwardedFromMessageId = json['forwardedFromMessageId'];
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

    return data;
  }
}
