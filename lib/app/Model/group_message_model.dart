class GroupMessageModel {
  int? id;
  int? senderId;
  String? senderName;
  String? senderImage;

  int? groupId;

  String? content;

  String? messageType;

  String? chatType;

  String? timestamp;

  GroupMessageModel({
    this.id,
    this.senderId,
    this.senderName,
    this.senderImage,
    this.groupId,
    this.content,
    this.messageType,
    this.chatType,
    this.timestamp,
  });

  factory GroupMessageModel.fromJson(Map<String, dynamic> json) {
    return GroupMessageModel(
      id: json['id'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderImage: json['senderImage'],
      groupId: json['groupId'],
      content: json['content'],
      messageType: json['messageType'],
      chatType: json['chatType'],
      timestamp: json['timestamp'].toString(),
    );
  }
}
