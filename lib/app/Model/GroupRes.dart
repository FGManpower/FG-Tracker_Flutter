class GroupRes {
  bool? status;
  String? message;
  List<GroupData>? groupData;

  GroupRes({this.status, this.message, this.groupData});

  GroupRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['groupData'] != null) {
      groupData = <GroupData>[];
      json['groupData'].forEach((v) {
        groupData!.add(GroupData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (groupData != null) {
      data['groupData'] = groupData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GroupData {
  int? id;
  String? groupName;
  String? groupDesc;
  String? groupCode;
  bool? isActive;
  bool? isCreator;

  GroupData(
      {this.id, this.groupName, this.groupDesc, this.groupCode, this.isActive,this.isCreator});

  GroupData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    groupName = json['groupName'];
    groupDesc = json['groupDesc'];
    groupCode = json['groupCode'];
    isActive = json['isActive'];
    isCreator = json['isCreator'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['groupName'] = groupName;
    data['groupDesc'] = groupDesc;
    data['groupCode'] = groupCode;
    data['isActive'] = isActive;
    data['isCreator'] = isCreator;
    return data;
  }
}
