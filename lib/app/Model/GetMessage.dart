class GetMessage {
  bool? status;
  String? message;
  List<MessageData>? messageData;
  bool? isCreator;
  int? pinnedMessageId;
  MessagePagination? pagination;

  GetMessage({
    this.status,
    this.message,
    this.messageData,
    this.isCreator,
    this.pinnedMessageId,
    this.pagination,
  });

  GetMessage.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    isCreator = json['isCreator'];
    pinnedMessageId = json['pinnedMessageId'];

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
          messageData!.add(
            MessageData.fromJson(item),
          );
        } else if (item is Map) {
          messageData!.add(
            MessageData.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['status'] = status;
    data['message'] = message;
    data['isCreator'] = isCreator;
    data['pinnedMessageId'] = pinnedMessageId;

    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }

    if (messageData != null) {
      data['MessageData'] =
          messageData!.map((v) => v.toJson()).toList();
    }

    return data;
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
  dynamic replyId;
  dynamic replyMessage;
  dynamic replyType;
  dynamic replySenderName;
  dynamic locationSharing;
  dynamic isForwarded;
  dynamic forwardedFromMessageId;

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
    this.replyId,
    this.replyMessage,
    this.replyType,
    this.replySenderName,
    this.thumbnail,
    this.locationSharing,
    this.isForwarded,
    this.forwardedFromMessageId,
  });

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

    replyId = json['replyId'] ?? json['reply_id'];

    replyMessage = json['replyMessage'] ?? json['reply_message'];

    replyType = json['replyType'] ?? json['reply_type'];

    replySenderName = json['replySender'] ??
        json['replySenderName'] ??
        json['reply_sender_name'];

    locationSharing =
        json['locationSharing'] ?? json['location_sharing'];

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
    data['reply_id'] = replyId;
    data['isEdited'] = isEdited;
    data['editedAt'] = editedAt;
    data['reply_message'] = replyMessage;
    data['reply_type'] = replyType;
    data['reply_sender_name'] = replySenderName;
    data['locationSharing'] = locationSharing;
    data['isForwarded'] = isForwarded;
    data['forwardedFromMessageId'] = forwardedFromMessageId;

    return data;
  }
}