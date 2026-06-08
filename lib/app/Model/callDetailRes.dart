class callDetailRes {
  bool? status;
  String? message;
  CallDetail? callDetail;

  callDetailRes({this.status, this.message, this.callDetail});

  callDetailRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    callDetail = json['callDetail'] != null
        ? CallDetail.fromJson(json['callDetail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (callDetail != null) {
      data['callDetail'] = callDetail!.toJson();
    }
    return data;
  }
}

class CallDetail {
  int? id;
  String? callerId;
  String? receiverId;
  bool? isVideo;
  String? status;
  String? callerName;
  String? callerProfileImage;
  int? callDuration;
  String? startTime;
  String? endTime;

  CallDetail(
      {this.id,
        this.callerId,
        this.receiverId,
        this.isVideo,
        this.status,
        this.callerName,
        this.callerProfileImage,
        this.callDuration,
        this.startTime,
        this.endTime});

  CallDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    callerId = json['caller_id'];
    receiverId = json['receiver_id'];
    isVideo = json['is_video'];
    status = json['status'];
    callerName = json['caller_name'];
    callerProfileImage = json['caller_profile_image'];
    callDuration = json['callDuration'];
    startTime = json['start_time'];
    endTime = json['end_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['caller_id'] = callerId;
    data['receiver_id'] = receiverId;
    data['is_video'] = isVideo;
    data['status'] = status;
    data['caller_name'] = callerName;
    data['caller_profile_image'] = callerProfileImage;
    data['callDuration'] = callDuration;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    return data;
  }
}
