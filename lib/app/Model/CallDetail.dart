int? _toInt(dynamic val) {
  if (val == null) return null;
  if (val is int) return val;
  if (val is double) return val.toInt();
  return int.tryParse(val.toString());
}

class CallHistoryDetailRes {
  bool? status;
  String? message;
  CallHistoryDetailData? data;

  CallHistoryDetailRes({this.status, this.message, this.data});

  factory CallHistoryDetailRes.fromJson(Map<String, dynamic> json) {
    return CallHistoryDetailRes(
      status: json['status'] == true,
      message: json['message']?.toString(),
      data: json['data'] != null
          ? CallHistoryDetailData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class CallHistoryDetailData {
  String? id;
  int? callId;
  String? callType;
  int? groupId;
  GroupInfo? group;
  String? type;
  bool? isVideo;
  String? direction;
  bool? isCaller;
  String? status;
  String? rawStatus;
  String? startTime;
  String? endTime;
  String? calledAt;
  String? endedAt;
  String? date;
  String? time;
  String? formattedDate;
  int? duration;
  String? formattedDuration;
  CallUser? contact;
  CallUser? caller;
  CallUser? receiver;
  MyParticipant? myParticipant;
  int? participantsCount;
  int? joinedParticipantsCount;
  CallSummary? summary;
  List<CallParticipant>? participants;

  CallHistoryDetailData({
    this.id,
    this.callId,
    this.callType,
    this.groupId,
    this.group,
    this.type,
    this.isVideo,
    this.direction,
    this.isCaller,
    this.status,
    this.rawStatus,
    this.startTime,
    this.endTime,
    this.calledAt,
    this.endedAt,
    this.date,
    this.time,
    this.formattedDate,
    this.duration,
    this.formattedDuration,
    this.contact,
    this.caller,
    this.receiver,
    this.myParticipant,
    this.participantsCount,
    this.joinedParticipantsCount,
    this.summary,
    this.participants,
  });

  factory CallHistoryDetailData.fromJson(Map<String, dynamic> json) {
    return CallHistoryDetailData(
      id: json['id']?.toString(),
      callId: _toInt(json['callId'] ?? json['id']?.toString().replaceAll(RegExp(r'[^0-9]'), '')),
      callType: json['callType']?.toString(),
      groupId: _toInt(json['groupId']),
      group: json['group'] != null ? GroupInfo.fromJson(json['group']) : null,
      type: json['type']?.toString(),
      isVideo: json['isVideo'] ?? (json['type']?.toString().toLowerCase() == 'video'),
      direction: json['direction']?.toString(),
      isCaller: json['isCaller'] == true,
      status: json['status']?.toString(),
      rawStatus: json['rawStatus']?.toString(),
      startTime: json['startTime']?.toString() ?? json['called_at']?.toString(),
      endTime: json['endTime']?.toString() ?? json['ended_at']?.toString(),
      calledAt: json['called_at']?.toString(),
      endedAt: json['ended_at']?.toString(),
      date: json['date']?.toString(),
      time: json['time']?.toString(),
      formattedDate: json['formattedDate']?.toString(),
      duration: _toInt(json['duration']),
      formattedDuration: json['formattedDuration']?.toString(),
      contact: json['contact'] != null ? CallUser.fromJson(json['contact']) : null,
      caller: json['caller'] != null ? CallUser.fromJson(json['caller']) : null,
      receiver: json['receiver'] != null ? CallUser.fromJson(json['receiver']) : null,
      myParticipant: json['myParticipant'] != null
          ? MyParticipant.fromJson(json['myParticipant'])
          : null,
      participantsCount: _toInt(json['participantsCount']),
      joinedParticipantsCount: _toInt(json['joinedParticipantsCount']),
      summary: json['summary'] != null ? CallSummary.fromJson(json['summary']) : null,
      participants: json['participants'] != null
          ? List<CallParticipant>.from(
          json['participants'].map((x) => CallParticipant.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['callId'] = callId;
    map['callType'] = callType;
    map['groupId'] = groupId;
    if (group != null) map['group'] = group!.toJson();
    map['type'] = type;
    map['isVideo'] = isVideo;
    map['direction'] = direction;
    map['isCaller'] = isCaller;
    map['status'] = status;
    map['rawStatus'] = rawStatus;
    map['startTime'] = startTime;
    map['endTime'] = endTime;
    map['called_at'] = calledAt;
    map['ended_at'] = endedAt;
    map['date'] = date;
    map['time'] = time;
    map['formattedDate'] = formattedDate;
    map['duration'] = duration;
    map['formattedDuration'] = formattedDuration;
    if (contact != null) map['contact'] = contact!.toJson();
    if (caller != null) map['caller'] = caller!.toJson();
    if (receiver != null) map['receiver'] = receiver!.toJson();
    if (myParticipant != null) map['myParticipant'] = myParticipant!.toJson();
    map['participantsCount'] = participantsCount;
    map['joinedParticipantsCount'] = joinedParticipantsCount;
    if (summary != null) map['summary'] = summary!.toJson();
    if (participants != null) {
      map['participants'] = participants!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class GroupInfo {
  int? id;
  int? groupId;
  String? name;
  String? groupName;
  String? avatar;
  String? groupProfile;
  String? groupDesc;
  String? groupCode;
  int? createdBy;
  int? totalMembers;

  GroupInfo({
    this.id,
    this.groupId,
    this.name,
    this.groupName,
    this.avatar,
    this.groupProfile,
    this.groupDesc,
    this.groupCode,
    this.createdBy,
    this.totalMembers,
  });

  factory GroupInfo.fromJson(Map<String, dynamic> json) {
    return GroupInfo(
      id: _toInt(json['id']),
      groupId: _toInt(json['groupId'] ?? json['id']),
      name: json['name']?.toString() ?? json['groupName']?.toString(),
      groupName: json['groupName']?.toString() ?? json['name']?.toString(),
      avatar: json['avatar']?.toString() ?? json['groupProfile']?.toString(),
      groupProfile: json['groupProfile']?.toString() ?? json['avatar']?.toString(),
      groupDesc: json['groupDesc']?.toString(),
      groupCode: json['groupCode']?.toString(),
      createdBy: _toInt(json['createdBy']),
      totalMembers: _toInt(json['totalMembers']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['groupId'] = groupId;
    map['name'] = name;
    map['groupName'] = groupName;
    map['avatar'] = avatar;
    map['groupProfile'] = groupProfile;
    map['groupDesc'] = groupDesc;
    map['groupCode'] = groupCode;
    map['createdBy'] = createdBy;
    map['totalMembers'] = totalMembers;
    return map;
  }
}

class CallUser {
  String? id;
  String? userId;
  String? name;
  String? firstName;
  String? lastName;
  String? avatar;
  String? profileImage;
  String? phoneNumber;
  String? email;

  CallUser({
    this.id,
    this.userId,
    this.name,
    this.firstName,
    this.lastName,
    this.avatar,
    this.profileImage,
    this.phoneNumber,
    this.email,
  });

  factory CallUser.fromJson(Map<String, dynamic> json) {
    final fName = json['first_name']?.toString() ?? '';
    final lName = json['last_name']?.toString() ?? '';
    final fullName = json['name']?.toString() ??
        (fName.isNotEmpty ? '$fName $lName'.trim() : null);

    return CallUser(
      id: json['id']?.toString() ?? json['userId']?.toString(),
      userId: json['userId']?.toString() ?? json['id']?.toString(),
      name: fullName,
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      avatar: json['avatar']?.toString() ?? json['profileImage']?.toString(),
      profileImage: json['profileImage']?.toString() ?? json['avatar']?.toString(),
      phoneNumber: json['phoneNumber']?.toString() ?? json['mobileNo']?.toString(),
      email: json['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['userId'] = userId;
    map['name'] = name;
    map['first_name'] = firstName;
    map['last_name'] = lastName;
    map['avatar'] = avatar;
    map['profileImage'] = profileImage;
    map['phoneNumber'] = phoneNumber;
    map['email'] = email;
    return map;
  }
}

class MyParticipant {
  int? id;
  String? userId;
  String? status;
  String? joinedAt;
  String? leftAt;
  String? joinedTime;
  String? leftTime;
  int? duration;
  String? formattedDuration;

  MyParticipant({
    this.id,
    this.userId,
    this.status,
    this.joinedAt,
    this.leftAt,
    this.joinedTime,
    this.leftTime,
    this.duration,
    this.formattedDuration,
  });

  factory MyParticipant.fromJson(Map<String, dynamic> json) {
    return MyParticipant(
      id: _toInt(json['id']),
      userId: json['userId']?.toString(),
      status: json['status']?.toString(),
      joinedAt: json['joinedAt']?.toString(),
      leftAt: json['leftAt']?.toString(),
      joinedTime: json['joinedTime']?.toString(),
      leftTime: json['leftTime']?.toString(),
      duration: _toInt(json['duration']),
      formattedDuration: json['formattedDuration']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['userId'] = userId;
    map['status'] = status;
    map['joinedAt'] = joinedAt;
    map['leftAt'] = leftAt;
    map['joinedTime'] = joinedTime;
    map['leftTime'] = leftTime;
    map['duration'] = duration;
    map['formattedDuration'] = formattedDuration;
    return map;
  }
}

class CallSummary {
  int? totalParticipants;
  int? joinedCount;
  int? missedCount;
  int? rejectedCount;
  int? invitedCount;

  CallSummary({
    this.totalParticipants,
    this.joinedCount,
    this.missedCount,
    this.rejectedCount,
    this.invitedCount,
  });

  factory CallSummary.fromJson(Map<String, dynamic> json) {
    return CallSummary(
      totalParticipants: _toInt(json['totalParticipants']),
      joinedCount: _toInt(json['joinedCount']),
      missedCount: _toInt(json['missedCount']),
      rejectedCount: _toInt(json['rejectedCount']),
      invitedCount: _toInt(json['invitedCount']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['totalParticipants'] = totalParticipants;
    map['joinedCount'] = joinedCount;
    map['missedCount'] = missedCount;
    map['rejectedCount'] = rejectedCount;
    map['invitedCount'] = invitedCount;
    return map;
  }
}

class CallParticipant {
  int? id;
  String? userId;
  String? name;
  String? firstName;
  String? lastName;
  String? avatar;
  String? profileImage;
  String? phoneNumber;
  String? email;
  String? status;
  bool? isCaller;
  String? role;
  String? joinedAt;
  String? leftAt;
  String? joinedTime;
  String? leftTime;
  int? duration;
  String? formattedDuration;

  CallParticipant({
    this.id,
    this.userId,
    this.name,
    this.firstName,
    this.lastName,
    this.avatar,
    this.profileImage,
    this.phoneNumber,
    this.email,
    this.status,
    this.isCaller,
    this.role,
    this.joinedAt,
    this.leftAt,
    this.joinedTime,
    this.leftTime,
    this.duration,
    this.formattedDuration,
  });

  factory CallParticipant.fromJson(Map<String, dynamic> json) {
    final fName = json['first_name']?.toString() ?? '';
    final lName = json['last_name']?.toString() ?? '';
    final fullName = json['name']?.toString() ??
        (fName.isNotEmpty ? '$fName $lName'.trim() : null);

    return CallParticipant(
      id: _toInt(json['id']),
      userId: json['userId']?.toString() ?? json['id']?.toString(),
      name: fullName,
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      avatar: json['avatar']?.toString() ?? json['profileImage']?.toString(),
      profileImage: json['profileImage']?.toString() ?? json['avatar']?.toString(),
      phoneNumber: json['phoneNumber']?.toString() ?? json['mobileNo']?.toString(),
      email: json['email']?.toString(),
      status: json['status']?.toString(),
      isCaller: json['isCaller'] == true,
      role: json['role']?.toString(),
      joinedAt: json['joinedAt']?.toString(),
      leftAt: json['leftAt']?.toString(),
      joinedTime: json['joinedTime']?.toString(),
      leftTime: json['leftTime']?.toString(),
      duration: _toInt(json['duration']),
      formattedDuration: json['formattedDuration']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['userId'] = userId;
    map['name'] = name;
    map['first_name'] = firstName;
    map['last_name'] = lastName;
    map['avatar'] = avatar;
    map['profileImage'] = profileImage;
    map['phoneNumber'] = phoneNumber;
    map['email'] = email;
    map['status'] = status;
    map['isCaller'] = isCaller;
    map['role'] = role;
    map['joinedAt'] = joinedAt;
    map['leftAt'] = leftAt;
    map['joinedTime'] = joinedTime;
    map['leftTime'] = leftTime;
    map['duration'] = duration;
    map['formattedDuration'] = formattedDuration;
    return map;
  }
}