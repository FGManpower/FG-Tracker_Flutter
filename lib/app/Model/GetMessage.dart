
class GetMessage {
  bool? status;
  String? message;
  List<MessageData>? messageData;
  bool? isCreator;

  GetMessage({this.status, this.message, this.messageData,this.isCreator});

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
  dynamic senderName;
  dynamic senderImage;

  MessageData(
      {this.id,
        this.senderId,
        this.receiverId,
        this.messageType,
        this.content,
        this.timestamp,this.seenCount,this.senderImage,this.senderName});

  MessageData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    senderId = json['senderId'];
    receiverId = json['receiverId'];
    messageType = json['messageType'];
    content = json['content'];
    timestamp = json['timestamp'];
    seenCount = json['seenCount'];
    senderName = json['senderName'];
    senderImage = json['senderImage'];
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
    data['senderName'] = senderName;
    data['senderImage'] = senderImage;
    return data;
  }
}
