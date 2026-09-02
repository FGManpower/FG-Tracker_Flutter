class IncomingCallModel {
  final String callerId;
  final String receiverId;
  final bool isVideo;
  final String callerName;
  final String callerProfileImage;
  final String? sdpOfferCompressed;
  final int? callId; 

  IncomingCallModel({
    required this.callerId,
    required this.receiverId,
    required this.isVideo,
    required this.callerName,
    required this.callerProfileImage,
    required this.sdpOfferCompressed,
    required this.callId,
  });

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'receiverId': receiverId,
      'isVideo': isVideo,
      'callerName': callerName,
      'callerProfileImage': callerProfileImage,
      'sdpOfferCompressed': sdpOfferCompressed,
      'callId': callId,

    };
  }

  factory IncomingCallModel.fromMap(Map<String, dynamic> map) {
    return IncomingCallModel(
      callerId: map['callerId'].toString(),
      receiverId: map['receiverId'].toString(),
      isVideo: map['isVideo'] == true || map['is_video'] == true,
      callerName: map['callerName'] ?? map['caller_name'] ?? "",
      callerProfileImage: map['callerProfileImage'] ?? map['caller_profile_image'] ?? "",
      sdpOfferCompressed: map['sdpOfferCompressed'] ,
      callId: map['callId'] ,
    );
  }
}
