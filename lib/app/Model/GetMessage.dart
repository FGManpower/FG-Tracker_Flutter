class GetMessage {
  bool? status;
  String? message;
  List<MessageData>? messageData;
  bool? isCreator;

  GetMessage({this.status, this.message, this.messageData, this.isCreator});

  GetMessage.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    isCreator = json['isCreator'];
    if (json['MessageData'] != null) {
      messageData = <MessageData>[];
      json['MessageData'].forEach((v) {
        messageData!.add(MessageData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['isCreator'] = isCreator;
    if (messageData != null) {
      data['MessageData'] = messageData!.map((v) => v.toJson()).toList();
    }
    return data;
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

  MessageData(
      {this.id,
      this.senderId,
      this.receiverId,
      this.messageType,
      this.content,
      this.timestamp,
      this.seenCount,
      this.senderImage,
        this.seenBy,
        this.edited,
        this.senderName,
      this.caption,
      this.replyId,
      this.replyMessage,
      this.replyType,
      this.replySenderName,
      this.thumbnail,
      this.locationSharing});

  MessageData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    senderId = json['senderId'];
    receiverId = json['receiverId'];
    messageType = json['messageType'];
    content = json['content'];
    timestamp = json['timestamp'];
    seenCount = json['seenCount'];
    seenBy = json['seenBy'];
    edited = json['edited'];
    senderName = json['senderName'];
    senderImage = json['senderImage'];
    thumbnail = json['thumbnail'];
    caption = json["caption"];
    replyId = json["replyId"] ?? json["reply_id"];
    replyMessage = json["replyMessage"] ?? json["reply_message"];
    replyType = json["replyType"] ?? json["reply_type"];
    locationSharing = json["locationSharing"] ?? json["locationSharing"];
    replySenderName = json["replySender"] ??
        json["replySenderName"] ??
        json["reply_sender_name"];
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
    data['reply_message'] = replyMessage;
    data['reply_type'] = replyType;
    data['reply_sender_name'] = replySenderName;
    data['locationSharing'] = locationSharing;

    return data;
  }
}
