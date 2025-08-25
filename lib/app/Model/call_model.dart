class CallModel {
  final String callerId;
  final String receiverId;
  final String channelId;
  final bool isVideo;
  final String status;
  final String callerName;
  final String callerProfileImage; // 'ringing', 'accepted', 'rejected', 'cancelled'

  CallModel({
    required this.callerId,
    required this.receiverId,
    required this.channelId,
    required this.isVideo,
    required this.status,
    required this.callerName,
    required this.callerProfileImage,

  });

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'receiverId': receiverId,
      'channelId': channelId,
      'isVideo': isVideo,
      'status': status,
      'callerName': callerName,
      'callerProfileImage': callerProfileImage,
    };
  }

  factory CallModel.fromMap(Map<String, dynamic> map) {
    return CallModel(
      callerId: map['callerId'],
      receiverId: map['receiverId'],
      channelId: map['channelId'],
      isVideo: map['isVideo'],
      status: map['status'],
      callerName: map['callerName'],
      callerProfileImage: map['callerProfileImage'],

    );
  }
}
