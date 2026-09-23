import 'dart:convert';

class MemberDataRes {
  bool? status;
  String? message;
  List<MemberData>? memberData;

  MemberDataRes({this.status, this.message, this.memberData});

  MemberDataRes.fromJson(dynamic json) {
    if (json is String) {
      try {
        json = jsonDecode(json);
      } catch (_) {}
    }

    memberData = <MemberData>[];

    if (json is List) {
      status = true;
      for (var v in json) {
        if (v is Map) {
          memberData!.add(MemberData.fromJson(Map<String, dynamic>.from(v)));
        }
      }
      return;
    }

    if (json is! Map) {
      status = false;
      return;
    }

    final rawStatus =
        json['status'] ?? json['success'] ?? json['statusCode'] ?? json['code'];
    status = rawStatus == true ||
        rawStatus == 1 ||
        rawStatus == '1' ||
        rawStatus == 200 ||
        rawStatus == '200' ||
        rawStatus.toString().toLowerCase() == 'true' ||
        rawStatus.toString().toLowerCase() == 'success';
    message = json['message']?.toString();

    dynamic list = json['memberData'] ??
        json['data'] ??
        json['members'] ??
        json['groupMembers'] ??
        json['group_members'] ??
        json['locations'] ??
        json['users'] ??
        json['result'] ??
        json['results'];

    if (list is Map) {
      final mapData = list;
      list = mapData['members'] ??
          mapData['groupMembers'] ??
          mapData['group_members'] ??
          mapData['memberData'] ??
          mapData['locations'] ??
          mapData['users'] ??
          mapData['data'] ??
          mapData['result'];
      if (list is! List) {
        for (var v in mapData.values) {
          if (v is List) {
            list = v;
            break;
          }
        }
      }
    }

    if (list is List) {
      for (var v in list) {
        if (v is Map<String, dynamic>) {
          memberData!.add(MemberData.fromJson(v));
        } else if (v is Map) {
          memberData!.add(MemberData.fromJson(Map<String, dynamic>.from(v)));
        }
      }
      if (memberData!.isNotEmpty) {
        status = true;
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (memberData != null) {
      data['memberData'] = memberData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MemberData {
  int? id;
  int? groupId;
  int? userId;
  String? name;
  String? mobileNo;
  String? profileImage;
  bool? isCreator;
  bool? isOnline;
  String? lastSeen;
  bool? locationSharing;
  String? location;
  String? department;
  String? team;

  MemberData({
    this.id,
    this.groupId,
    this.userId,
    this.name,
    this.mobileNo,
    this.profileImage,
    this.isCreator,
    this.isOnline,
    this.lastSeen,
    this.locationSharing,
    this.location,
    this.department,
    this.team,
  });

  static int? _parseInt(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString());
  }

  static bool? _parseBool(dynamic val) {
    if (val == null) return null;
    if (val is bool) return val;
    if (val is num) return val == 1;
    final s = val.toString().toLowerCase().trim();
    if (s == 'true' || s == '1' || s == 'online' || s == 'admin') return true;
    if (s == 'false' || s == '0' || s == 'offline') return false;
    return null;
  }

  MemberData.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map ? json['user'] as Map : null;

    id = _parseInt(json['id'] ?? json['_id'] ?? user?['id']);
    groupId = _parseInt(json['groupId'] ?? json['group_id']);
    userId = _parseInt(json['userId'] ??
        json['UserId'] ??
        json['user_id'] ??
        json['id'] ??
        json['_id'] ??
        user?['userId'] ??
        user?['id']);
    name = (json['Name'] ??
            json['name'] ??
            json['fullName'] ??
            json['full_name'] ??
            json['userName'] ??
            user?['Name'] ??
            user?['name'] ??
            user?['fullName'])
        ?.toString();
    mobileNo = (json['MobileNo'] ??
            json['mobileNo'] ??
            json['mobile_no'] ??
            json['mobile'] ??
            json['phone'] ??
            user?['MobileNo'] ??
            user?['mobileNo'] ??
            user?['phone'])
        ?.toString();
    profileImage = (json['ProfileImage'] ??
            json['profileImage'] ??
            json['image'] ??
            json['avatar'] ??
            user?['ProfileImage'] ??
            user?['profileImage'] ??
            user?['image'])
        ?.toString();

    final rawCreator = json['isCreator'] ??
        json['is_creator'] ??
        json['isAdmin'] ??
        json['is_admin'] ??
        user?['isCreator'] ??
        (json['role'] == 'admin');
    isCreator = _parseBool(rawCreator) ?? false;

    final rawOnline = json['isOnline'] ??
        json['is_online'] ??
        json['online'] ??
        user?['isOnline'];
    isOnline = _parseBool(rawOnline);

    lastSeen = (json['lastSeen'] ??
            json['last_seen'] ??
            json['lastActive'] ??
            user?['lastSeen'])
        ?.toString();

    final rawLocSharing = json['locationSharing'] ??
        json['location_sharing'] ??
        json['isLocationSharing'] ??
        user?['locationSharing'];
    locationSharing = _parseBool(rawLocSharing) ?? true;

    location =
        (json['location'] ?? json['address'] ?? user?['location'])?.toString();
    department =
        (json['department'] ?? json['dept'] ?? user?['department'])?.toString();
    team = (json['team'] ??
            json['groupName'] ??
            json['group_name'] ??
            user?['team'])
        ?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['groupId'] = groupId;
    data['userId'] = userId;
    data['Name'] = name;
    data['MobileNo'] = mobileNo;
    data['ProfileImage'] = profileImage;
    data['isCreator'] = isCreator;
    data['isOnline'] = isOnline;
    data['lastSeen'] = lastSeen;
    data['locationSharing'] = locationSharing;
    data['location'] = location;
    data['department'] = department;
    data['team'] = team;
    return data;
  }
}
