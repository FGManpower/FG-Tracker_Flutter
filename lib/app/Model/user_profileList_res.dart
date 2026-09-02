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
        userData!.add(UserListData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (userData != null) {
      data['UserData'] = userData!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['UserId'] = userId;
    data['ProfileImage'] = profileImage;
    data['Name'] = name;
    data['MobileNo'] = mobileNo;
    return data;
  }
}
