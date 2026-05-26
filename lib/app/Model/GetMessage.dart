
class GetMessage {
  bool? status;
  String? message;
  List<MessageData>? messageData;

  GetMessage({this.status, this.message, this.messageData});

  GetMessage.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['MessageData'] != null) {
      messageData = <MessageData>[];
      json['MessageData'].forEach((v) {
        messageData!.add(new MessageData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.messageData != null) {
      data['MessageData'] = this.messageData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MessageData {
  int? id;
  dynamic? senderId;
  dynamic? receiverId;
  dynamic? messageType;
  dynamic? content;
  dynamic? timestamp;
  dynamic? seenCount;
  dynamic? senderName;
  dynamic? senderImage;

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['senderId'] = this.senderId;
    data['receiverId'] = this.receiverId;
    data['messageType'] = this.messageType;
    data['content'] = this.content;
    data['timestamp'] = this.timestamp;
    data['seenCount'] = this.seenCount;
    data['senderName'] = this.senderName;
    data['senderImage'] = this.senderImage;
    return data;
  }
}
