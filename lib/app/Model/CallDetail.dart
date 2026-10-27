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
    final rawData = json['data'] ?? json['callDetail'] ?? json['detail'] ?? json['result'];
    return CallHistoryDetailRes(
      status: json['status'] == true || json['success'] == true,
      message: json['message']?.toString(),
      data: rawData is Map<String, dynamic>
          ? CallHistoryDetailData.fromJson(rawData)
          : (rawData is Map
              ? CallHistoryDetailData.fromJson(Map<String, dynamic>.from(rawData))
              : null),
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
  int? chatId;
  int? privateChatId;
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
  String? callerName;
  String? receiverName;
  String? callerProfileImage;
  String? receiverProfileImage;
  String? profileImage;
  MyParticipant? myParticipant;
  int? participantsCount;
  int? joinedParticipantsCount;
  CallSummary? summary;
  List<CallParticipant>? participants;
  List<CallParticipant>? joinedMembers;

  CallHistoryDetailData({
    this.id,
    this.callId,
    this.chatId,
    this.privateChatId,
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
    this.callerName,
    this.receiverName,
    this.callerProfileImage,
    this.receiverProfileImage,
    this.profileImage,
    this.myParticipant,
    this.participantsCount,
    this.joinedParticipantsCount,
    this.summary,
    this.participants,
    this.joinedMembers,
  });

  static List<CallParticipant>? _parseParticipants(dynamic raw) {
    if (raw is! List) return null;
    final List<CallParticipant> list = [];
    for (final x in raw) {
      if (x is Map) {
        list.add(CallParticipant.fromJson(Map<String, dynamic>.from(x)));
      }
    }
    return list;
  }

  factory CallHistoryDetailData.fromJson(Map<String, dynamic> json) {
    CallUser? parseUser(dynamic raw, String prefix) {
      if (raw is Map<String, dynamic>) {
        return CallUser.fromJson(raw);
      } else if (raw is Map) {
        return CallUser.fromJson(Map<String, dynamic>.from(raw));
      }
      final name = json['${prefix}_name'] ?? json['${prefix}Name'] ?? json['${prefix}_username'];
      final id = json['${prefix}_id'] ?? json['${prefix}Id'] ?? json['${prefix}_userId'];
      final phone = json['${prefix}_phone'] ?? json['${prefix}_mobile'] ?? json['${prefix}Phone'] ?? json['${prefix}Mobile'];
      final avatar = json['${prefix}_profile_image'] ?? json['${prefix}_avatar'] ?? json['${prefix}Avatar'] ?? json['${prefix}ProfileImage'];
      final email = json['${prefix}_email'] ?? json['${prefix}Email'];
      if (name != null || id != null || phone != null || avatar != null || email != null) {
        return CallUser(
          id: id?.toString(),
          userId: id?.toString(),
          name: name?.toString(),
          avatar: avatar?.toString(),
          profileImage: avatar?.toString(),
          phoneNumber: phone?.toString(),
          email: email?.toString(),
        );
      }
      return null;
    }

    final parsedCaller = parseUser(json['caller'], 'caller');
    final parsedReceiver = parseUser(json['receiver'], 'receiver');
    final parsedContact = parseUser(json['contact'], 'contact');

    final bool isVideoVal = json['isVideo'] == true ||
        json['is_video'] == true ||
        json['isVideo'] == 1 ||
        json['is_video'] == 1 ||
        (json['type']?.toString().toLowerCase() == 'video') ||
        (json['callType']?.toString().toLowerCase() == 'video');

    final int dur = _toInt(json['duration'] ?? json['callDuration'] ?? json['call_duration']) ?? 0;
    String? fmtDur = json['formattedDuration']?.toString() ?? json['duration_formatted']?.toString();
    if ((fmtDur == null || fmtDur.isEmpty) && dur > 0) {
      final m = dur ~/ 60;
      final s = dur % 60;
      fmtDur = "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    }

    return CallHistoryDetailData(
      id: json['id']?.toString() ?? json['callId']?.toString() ?? json['call_id']?.toString(),
      callId: _toInt(json['callId'] ?? json['call_id'] ?? json['id']?.toString().replaceAll(RegExp(r'[^0-9]'), '')),
      chatId: _toInt(json['chatId']),
      privateChatId: _toInt(json['privateChatId']),
      callType: json['callType']?.toString() ?? (json['group_id'] != null || json['groupId'] != null ? 'group' : 'one_to_one'),
      groupId: _toInt(json['groupId'] ?? json['group_id']),
      group: json['group'] is Map
          ? GroupInfo.fromJson(Map<String, dynamic>.from(json['group']))
          : (json['group_name'] != null || json['groupName'] != null
              ? GroupInfo(
                  groupId: _toInt(json['groupId'] ?? json['group_id']),
                  groupName: json['group_name']?.toString() ?? json['groupName']?.toString(),
                  avatar: json['group_image']?.toString() ?? json['groupImage']?.toString(),
                  totalMembers: _toInt(json['total_members'] ?? json['totalMembers']),
                )
              : null),
      type: json['type']?.toString() ?? (isVideoVal ? 'video' : 'audio'),
      isVideo: isVideoVal,
      direction: json['direction']?.toString(),
      isCaller: json['isCaller'] == true || json['is_caller'] == true,
      status: json['status']?.toString() ?? json['call_status']?.toString(),
      rawStatus: json['rawStatus']?.toString() ?? json['status']?.toString(),
      startTime: json['startTime']?.toString() ?? json['start_time']?.toString() ?? json['called_at']?.toString(),
      endTime: json['endTime']?.toString() ?? json['end_time']?.toString() ?? json['ended_at']?.toString(),
      calledAt: json['called_at']?.toString() ?? json['startTime']?.toString() ?? json['start_time']?.toString(),
      endedAt: json['ended_at']?.toString() ?? json['endTime']?.toString() ?? json['end_time']?.toString(),
      date: json['date']?.toString(),
      time: json['time']?.toString(),
      formattedDate: json['formattedDate']?.toString(),
      duration: dur,
      formattedDuration: fmtDur,
      contact: parsedContact ?? parsedCaller,
      caller: parsedCaller,
      receiver: parsedReceiver,
      callerName: json['caller_name']?.toString() ??
          json['callerName']?.toString() ??
          json['caller_username']?.toString() ??
          parsedCaller?.name,
      receiverName: json['receiver_name']?.toString() ??
          json['receiverName']?.toString() ??
          json['receiver_username']?.toString() ??
          parsedReceiver?.name,
      callerProfileImage: json['caller_profile_image']?.toString() ??
          json['callerProfileImage']?.toString() ??
          json['caller_image']?.toString() ??
          json['callerImage']?.toString() ??
          json['caller_avatar']?.toString() ??
          parsedCaller?.avatar ??
          parsedCaller?.profileImage,
      receiverProfileImage: json['receiver_profile_image']?.toString() ??
          json['receiverProfileImage']?.toString() ??
          json['receiver_image']?.toString() ??
          json['receiverImage']?.toString() ??
          json['receiver_avatar']?.toString() ??
          parsedReceiver?.avatar ??
          parsedReceiver?.profileImage,
      profileImage: json['profile_image']?.toString() ??
          json['profileImage']?.toString() ??
          json['avatar']?.toString() ??
          json['image']?.toString(),
      myParticipant: json['myParticipant'] is Map
          ? MyParticipant.fromJson(Map<String, dynamic>.from(json['myParticipant']))
          : null,
      participantsCount: _toInt(json['participantsCount'] ?? json['participants_count']),
      joinedParticipantsCount: _toInt(json['joinedParticipantsCount'] ?? json['joined_participants_count']),
      summary: json['summary'] is Map
          ? CallSummary.fromJson(Map<String, dynamic>.from(json['summary']))
          : null,
      participants: _parseParticipants(json['participants']),
      joinedMembers: _parseParticipants(json['joinedMembers'] ??
          json['joinedParticipants'] ??
          json['joinedCallMembers']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['callId'] = callId;
    map['chatId'] = chatId;
    map['privateChatId'] = privateChatId;
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
    if (joinedMembers != null) {
      map['joinedMembers'] = joinedMembers!.map((v) => v.toJson()).toList();
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
      avatar: (json['avatar'] ??
              json['profile_image'] ??
              json['profileImage'] ??
              json['caller_profile_image'] ??
              json['callerProfileImage'] ??
              json['receiver_profile_image'] ??
              json['receiverProfileImage'] ??
              json['image'])
          ?.toString(),
      profileImage: (json['profileImage'] ??
              json['profile_image'] ??
              json['caller_profile_image'] ??
              json['callerProfileImage'] ??
              json['receiver_profile_image'] ??
              json['receiverProfileImage'] ??
              json['avatar'] ??
              json['image'])
          ?.toString(),
      phoneNumber: json['phoneNumber']?.toString() ??
          json['mobileNo']?.toString() ??
          json['phone']?.toString(),
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