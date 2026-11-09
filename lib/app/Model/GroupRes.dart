class GroupRes {
  bool? status;
  String? message;
  GroupData? data;

  GroupRes({this.status, this.message, this.data});

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final s = value.toLowerCase().trim();
      if (s == 'true' || s == 'yes' || s == '1' || s == 'active' || s == 'success' || s == 'ok') {
        return true;
      }
      if (s == 'false' || s == 'no' || s == '0' || s == 'deactivated' || s == 'inactive' || s == 'error' || s == 'failed') {
        return false;
      }
    }
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  GroupRes.fromJson(dynamic input) {
    if (input is! Map) {
      status = input == true;
      message = input?.toString();
      return;
    }
    final json = Map<String, dynamic>.from(input);
    status = _parseBool(json['status'] ?? json['success'] ?? json['ok']) ?? true;
    message = json['message']?.toString();
    data = json['data'] != null ? GroupData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class GroupData {
  List<GroupsResData>? groupData;

  GroupData({this.groupData});

  GroupData.fromJson(Map<String, dynamic> json) {
    if (json['groups'] != null && json['groups'] is List) {
      groupData = <GroupsResData>[];
      for (final v in json['groups']) {
        if (v is Map) {
          groupData!.add(GroupsResData.fromJson(Map<String, dynamic>.from(v)));
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (groupData != null) {
      data['groups'] = groupData!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class GroupsResData {
  int? id;
  String? groupName;
  String? groupDesc;
  String? groupProfile;
  String? groupCode;
  bool? isActive;
  bool? isCreator;
  int? memberCount;

  GroupsResData(
      {this.id,
      this.groupName,
      this.groupDesc,
      this.groupProfile,
      this.groupCode,
      this.isActive,
      this.isCreator,
      this.memberCount});

  GroupsResData.fromJson(Map<String, dynamic> json) {
    id = GroupRes._parseInt(json['id']);
    groupName = json['groupName']?.toString();
    groupDesc = json['groupDesc']?.toString();
    groupProfile = json['groupProfile']?.toString() ??
        json['group_profile']?.toString() ??
        json['groupImage']?.toString() ??
        json['group_image']?.toString() ??
        json['profileImage']?.toString() ??
        json['image']?.toString() ??
        json['profile']?.toString();
    groupCode = json['groupCode']?.toString();
    isActive = GroupRes._parseBool(
      json['isActive'] ?? json['is_active'] ?? json['status'] ?? json['groupStatus'],
    );
    isCreator = GroupRes._parseBool(json['isCreator'] ?? json['is_creator']);
    memberCount = GroupRes._parseInt(json['memberCount'] ?? json['member_count']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['groupName'] = groupName;
    data['groupDesc'] = groupDesc;
    data['groupProfile'] = groupProfile;
    data['groupCode'] = groupCode;
    data['isActive'] = isActive;
    data['isCreator'] = isCreator;
    data['memberCount'] = memberCount;
    return data;
  }
}
