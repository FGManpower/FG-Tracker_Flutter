class GroupRes {
  bool? status;
  String? message;
  GroupData? data;

  GroupRes({this.status, this.message, this.data});

  GroupRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
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
    if (json['groups'] != null) {
      groupData = <GroupsResData>[];
      json['groups'].forEach((v) {
        groupData!.add(GroupsResData.fromJson(v));
      });
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
    id = json['id'];
    groupName = json['groupName'];
    groupDesc = json['groupDesc'];
    groupProfile = json['groupProfile'];
    groupCode = json['groupCode'];
    isActive = json['isActive'];
    isCreator = json['isCreator'];
    memberCount = json['memberCount'];
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
