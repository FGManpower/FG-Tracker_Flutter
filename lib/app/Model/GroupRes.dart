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
  List<GroupsResData>? newlyCreatedGroups;
  List<GroupsResData>? createdGroups;

  GroupData({this.newlyCreatedGroups, this.createdGroups});

  GroupData.fromJson(Map<String, dynamic> json) {
    if (json['newlyCreatedGroups'] != null) {
      newlyCreatedGroups = <GroupsResData>[];
      json['newlyCreatedGroups'].forEach((v) {
        newlyCreatedGroups!.add(GroupsResData.fromJson(v));
      });
    }
    if (json['createdGroups'] != null) {
      createdGroups = <GroupsResData>[];
      json['createdGroups'].forEach((v) {
        createdGroups!.add(GroupsResData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (newlyCreatedGroups != null) {
      data['newlyCreatedGroups'] =
          newlyCreatedGroups!.map((v) => v.toJson()).toList();
    }
    if (createdGroups != null) {
      data['createdGroups'] =
          createdGroups!.map((v) => v.toJson()).toList();
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
