class recent_Call_Res {
  bool? status;
  String? message;
  AppliedFilters? appliedFilters;
  Pagination? pagination;
  CallData? data;

  recent_Call_Res(
      {this.status,
      this.message,
      this.appliedFilters,
      this.pagination,
      this.data});

  recent_Call_Res.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    appliedFilters = json['appliedFilters'] != null
        ? AppliedFilters.fromJson(json['appliedFilters'])
        : null;
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
    data = json['data'] != null ? CallData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (appliedFilters != null) {
      data['appliedFilters'] = appliedFilters!.toJson();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class AppliedFilters {
  String? filter;
  String? type;

  AppliedFilters({this.filter, this.type});

  AppliedFilters.fromJson(Map<String, dynamic> json) {
    filter = json['filter'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['filter'] = filter;
    data['type'] = type;
    return data;
  }
}

class Pagination {
  int? totalRecords;
  int? currentPage;
  int? perPage;
  int? totalPages;
  bool? hasNextPage;
  bool? hasPreviousPage;

  Pagination(
      {this.totalRecords,
      this.currentPage,
      this.perPage,
      this.totalPages,
      this.hasNextPage,
      this.hasPreviousPage});

  Pagination.fromJson(Map<String, dynamic> json) {
    totalRecords = json['totalRecords'];
    currentPage = json['currentPage'];
    perPage = json['perPage'];
    totalPages = json['totalPages'];
    hasNextPage = json['hasNextPage'];
    hasPreviousPage = json['hasPreviousPage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalRecords'] = totalRecords;
    data['currentPage'] = currentPage;
    data['perPage'] = perPage;
    data['totalPages'] = totalPages;
    data['hasNextPage'] = hasNextPage;
    data['hasPreviousPage'] = hasPreviousPage;
    return data;
  }
}

class CallData {
  List<CallingDetail>? today;
  List<CallingDetail>? yesterday;
  List<CallingDetail>? older;
  Map<String, List<CallingDetail>> allSections = {};

  CallData({
    this.today,
    this.yesterday,
    this.older,
    Map<String, List<CallingDetail>>? allSections,
  }) {
    if (allSections != null) {
      this.allSections = allSections;
    }
  }

  CallData.fromJson(Map<String, dynamic> json) {
    allSections = {};

    json.forEach((key, value) {
      if (value is List) {
        final list = <CallingDetail>[];
        for (final v in value) {
          if (v is Map<String, dynamic>) {
            list.add(CallingDetail.fromJson(v));
          } else if (v is Map) {
            list.add(CallingDetail.fromJson(Map<String, dynamic>.from(v)));
          }
        }
        allSections[key] = list;

        final lower = key.toLowerCase();
        if (lower == 'today') {
          today = list;
        } else if (lower == 'yesterday') {
          yesterday = list;
        } else if (lower == 'older') {
          older = list;
        }
      }
    });

    today ??= allSections['today'];
    yesterday ??= allSections['yesterday'];
    older ??= allSections['older'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    allSections.forEach((key, list) {
      data[key] = list.map((v) => v.toJson()).toList();
    });
    if (today != null && !data.containsKey('today')) {
      data['today'] = today!.map((v) => v.toJson()).toList();
    }
    if (yesterday != null && !data.containsKey('yesterday')) {
      data['yesterday'] = yesterday!.map((v) => v.toJson()).toList();
    }
    if (older != null && !data.containsKey('older')) {
      data['older'] = older!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CallingDetail {
  String? id;
  RecentContact? contact;
  String? type;
  String? direction;
  String? status;
  String? calledAt;
  String? date;
  String? time;
  String? day;
  String? week;
  String? displayTime;
  String? duration;
  String? section;
  String? groupId;
  String? groupName;
  String? groupProfile;
  bool? isGroup;
  int? memberCount;
  String? callerId;
  String? receiverId;
  String? callerName;
  String? callerProfileImage;

  CallingDetail({
    this.id,
    this.contact,
    this.type,
    this.direction,
    this.status,
    this.calledAt,
    this.date,
    this.time,
    this.day,
    this.week,
    this.displayTime,
    this.duration,
    this.section,
    this.groupId,
    this.groupName,
    this.groupProfile,
    this.isGroup,
    this.memberCount,
    this.callerId,
    this.receiverId,
    this.callerName,
    this.callerProfileImage,
  });

  CallingDetail.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();

    // Group info extraction from possible keys or nested maps
    Map<String, dynamic>? groupObj;
    if (json['group'] is Map<String, dynamic>) {
      groupObj = json['group'];
    } else if (json['group_details'] is Map<String, dynamic>) {
      groupObj = json['group_details'];
    } else if (json['groupDetails'] is Map<String, dynamic>) {
      groupObj = json['groupDetails'];
    }

    final Map<String, dynamic>? contactMap =
        (json['contact'] is Map<String, dynamic>) ? json['contact'] : null;

    groupId = groupObj?['id']?.toString() ??
        groupObj?['groupId']?.toString() ??
        groupObj?['group_id']?.toString() ??
        json['groupId']?.toString() ??
        json['group_id']?.toString() ??
        json['group_Id']?.toString() ??
        contactMap?['group_id']?.toString() ??
        contactMap?['groupId']?.toString();

    groupName = groupObj?['name']?.toString() ??
        groupObj?['groupName']?.toString() ??
        groupObj?['group_name']?.toString() ??
        groupObj?['group_title']?.toString() ??
        json['groupName']?.toString() ??
        json['group_name']?.toString() ??
        json['group_title']?.toString() ??
        json['groupTitle']?.toString() ??
        contactMap?['group_name']?.toString() ??
        contactMap?['groupName']?.toString();

    groupProfile = groupObj?['profile']?.toString() ??
        groupObj?['groupProfile']?.toString() ??
        groupObj?['group_profile']?.toString() ??
        groupObj?['groupImage']?.toString() ??
        groupObj?['group_image']?.toString() ??
        groupObj?['image']?.toString() ??
        json['groupProfile']?.toString() ??
        json['group_profile']?.toString() ??
        json['groupImage']?.toString() ??
        json['group_image']?.toString() ??
        contactMap?['group_profile']?.toString() ??
        contactMap?['groupProfile']?.toString() ??
        contactMap?['group_image']?.toString();

    memberCount = groupObj?['memberCount'] ??
        groupObj?['totalMembers'] ??
        groupObj?['members_count'] ??
        json['memberCount'] ??
        json['totalMembers'] ??
        json['member_count'];

    callerId = json['caller_id']?.toString() ?? json['callerId']?.toString();
    receiverId = json['receiver_id']?.toString() ?? json['receiverId']?.toString();
    callerName = json['caller_name']?.toString() ?? json['callerName']?.toString();
    callerProfileImage = json['caller_profile_image']?.toString() ?? json['callerProfileImage']?.toString();

    final dynamic isGroupVal = json['is_group'] ??
        json['isGroup'] ??
        json['is_group_call'] ??
        json['isGroupCall'] ??
        (groupObj != null ? true : null);

    final String callTypeStr = (json['type'] ?? json['call_type'] ?? '').toString().toLowerCase();

    isGroup = isGroupVal == true ||
        isGroupVal == 1 ||
        isGroupVal == '1' ||
        isGroupVal == 'true' ||
        callTypeStr.contains('group') ||
        (groupId != null && groupId!.isNotEmpty && groupId != "0") ||
        (groupName != null && groupName!.trim().isNotEmpty);

    if (contactMap != null) {
      contact = RecentContact.fromJson(contactMap);
      if (contact != null) {
        if ((contact!.groupId == null || contact!.groupId!.isEmpty) && groupId != null) {
          contact!.groupId = groupId;
        }
        if ((contact!.groupName == null || contact!.groupName!.isEmpty) && groupName != null) {
          contact!.groupName = groupName;
        }
        if ((contact!.avatar == null || contact!.avatar!.isEmpty) && (groupProfile != null || callerProfileImage != null)) {
          contact!.avatar = groupProfile ?? callerProfileImage;
        }
        if ((contact!.firstName == null || contact!.firstName!.isEmpty) && (groupName != null || callerName != null)) {
          contact!.firstName = groupName ?? callerName;
        }
        if (isGroup == true) {
          contact!.isGroup = true;
        }
      }
    } else {
      contact = RecentContact(
        id: callerId ??
            receiverId ??
            groupId ??
            json['userId']?.toString() ??
            json['user_id']?.toString() ??
            json['id']?.toString(),
        firstName: groupName ??
            callerName ??
            json['receiver_name'] ??
            json['receiverName'] ??
            json['name'] ??
            json['first_name'] ??
            '',
        lastName: json['last_name'] ?? '',
        avatar: groupProfile ??
            callerProfileImage ??
            json['receiver_profile_image'] ??
            json['receiverProfileImage'] ??
            json['profile_image'] ??
            json['profileImage'] ??
            json['avatar'] ??
            '',
        groupId: groupId,
        groupName: groupName,
        isGroup: isGroup,
      );
    }

    type = json['type']?.toString();
    direction = json['direction']?.toString();
    status = json['status']?.toString();
    calledAt = json['called_at']?.toString() ??
        json['calledAt']?.toString() ??
        json['created_at']?.toString() ??
        json['createdAt']?.toString() ??
        json['start_time']?.toString() ??
        json['startTime']?.toString() ??
        json['timestamp']?.toString() ??
        json['date_time']?.toString() ??
        json['dateTime']?.toString();
    date = json['date']?.toString() ??
        json['call_date']?.toString() ??
        json['callDate']?.toString() ??
        json['formatted_date']?.toString() ??
        json['formattedDate']?.toString();
    time = json['time']?.toString() ??
        json['call_time']?.toString() ??
        json['callTime']?.toString() ??
        json['formatted_time']?.toString() ??
        json['formattedTime']?.toString();
    day = json['day']?.toString() ??
        json['weekday']?.toString() ??
        json['week_day']?.toString() ??
        json['day_name']?.toString() ??
        json['dayName']?.toString();
    week = json['week']?.toString() ??
        json['week_name']?.toString() ??
        json['weekName']?.toString() ??
        json['call_week']?.toString();
    displayTime = json['display_time']?.toString() ??
        json['displayTime']?.toString() ??
        json['timestamp_label']?.toString() ??
        json['time_label']?.toString();
    duration = json['duration']?.toString() ??
        json['call_duration']?.toString() ??
        json['callDuration']?.toString();
    section = json['section']?.toString() ??
        json['group_section']?.toString() ??
        json['category']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (contact != null) {
      data['contact'] = contact!.toJson();
    }
    data['type'] = type;
    data['direction'] = direction;
    data['status'] = status;
    data['called_at'] = calledAt;
    data['date'] = date;
    data['time'] = time;
    data['day'] = day;
    data['week'] = week;
    data['display_time'] = displayTime;
    data['duration'] = duration;
    data['section'] = section;
    data['groupId'] = groupId;
    data['groupName'] = groupName;
    data['groupProfile'] = groupProfile;
    data['isGroup'] = isGroup;
    data['memberCount'] = memberCount;
    data['callerId'] = callerId;
    data['receiverId'] = receiverId;
    data['callerName'] = callerName;
    data['callerProfileImage'] = callerProfileImage;
    return data;
  }
}

class RecentContact {
  String? id;
  String? firstName;
  String? lastName;
  String? avatar;
  String? groupId;
  String? groupName;
  bool? isGroup;

  RecentContact({
    this.id,
    this.firstName,
    this.lastName,
    this.avatar,
    this.groupId,
    this.groupName,
    this.isGroup,
  });

  RecentContact.fromJson(Map<String, dynamic> json) {
    groupId = json['group_id']?.toString() ?? json['groupId']?.toString();
    groupName = json['group_name']?.toString() ?? json['groupName']?.toString();
    isGroup = json['is_group'] == true ||
        json['isGroup'] == true ||
        json['is_group'] == 1 ||
        json['is_group'] == '1' ||
        (groupId != null && groupId!.isNotEmpty && groupId != "0");

    id = json['id']?.toString() ??
        json['userId']?.toString() ??
        json['user_id']?.toString() ??
        json['caller_id']?.toString() ??
        json['callerId']?.toString() ??
        json['receiver_id']?.toString() ??
        json['receiverId']?.toString() ??
        groupId;
    firstName = json['first_name'] ??
        json['firstName'] ??
        groupName ??
        json['group_name'] ??
        json['groupName'] ??
        json['caller_name'] ??
        json['callerName'] ??
        json['receiver_name'] ??
        json['receiverName'] ??
        json['name'] ??
        json['title'];
    lastName = json['last_name'] ?? json['lastName'] ?? '';
    avatar = json['avatar'] ??
        json['profile_image'] ??
        json['profileImage'] ??
        json['group_profile'] ??
        json['groupProfile'] ??
        json['group_image'] ??
        json['groupImage'] ??
        json['caller_profile_image'] ??
        json['callerProfileImage'] ??
        json['receiver_profile_image'] ??
        json['receiverProfileImage'] ??
        '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['avatar'] = avatar;
    data['groupId'] = groupId;
    data['groupName'] = groupName;
    data['isGroup'] = isGroup;
    return data;
  }
}
