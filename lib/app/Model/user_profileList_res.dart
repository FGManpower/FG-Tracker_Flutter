class UserProfileListRes {
  bool? status;
  String? message;
  List<UserListData>? userData;

  UserProfileListRes({this.status, this.message, this.userData});

  UserProfileListRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['UserData'] != null) {
      userData = <UserListData>[];
      json['UserData'].forEach((v) {
        userData!.add(new UserListData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.userData != null) {
      data['UserData'] = this.userData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserListData {
  int? userId;
  String? profileImage;
  String? name;
  String? mobileNo;

  UserListData({this.userId, this.profileImage, this.name, this.mobileNo});

  UserListData.fromJson(Map<String, dynamic> json) {
    userId = json['UserId'];
    profileImage = json['ProfileImage'];
    name = json['Name'];
    mobileNo = json['MobileNo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['UserId'] = this.userId;
    data['ProfileImage'] = this.profileImage;
    data['Name'] = this.name;
    data['MobileNo'] = this.mobileNo;
    return data;
  }
}
