class MemberDataRes {
  bool? status;
  String? message;
  List<MemberData>? memberData;

  MemberDataRes({this.status, this.message, this.memberData});

  MemberDataRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['memberData'] != null) {
      memberData = <MemberData>[];
      json['memberData'].forEach((v) {
        memberData!.add(MemberData.fromJson(v));
      });
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

  MemberData(
      {this.id,
      this.groupId,
      this.userId,
      this.name,
      this.mobileNo,
      this.profileImage,this.isCreator});

  MemberData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    groupId = json['groupId'];
    userId = json['userId'];
    name = json['Name'];
    mobileNo = json['MobileNo'];
    profileImage = json['ProfileImage'];
    isCreator = json['isCreator'];
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
    return data;
  }
}
