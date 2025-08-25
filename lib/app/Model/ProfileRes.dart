class ProfileRes {
  bool? status;
  String? message;
  UserData? data;

  ProfileRes({this.status, this.message, this.data});

  ProfileRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? UserData.fromJson(json['data']) : null;
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

class UserData {
  int? userId;
  String? profileImage;
  String? name;
  String? email;
  String? mobileNo;
  String? gender;

  UserData(
      {this.userId,
      this.profileImage,
      this.name,
      this.email,
      this.mobileNo,
      this.gender});

  UserData.fromJson(Map<String, dynamic> json) {
    userId = json['UserId'];
    profileImage = json['ProfileImage'];
    name = json['Name'];
    email = json['Email'];
    mobileNo = json['MobileNo'];
    gender = json['Gender'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['UserId'] = userId;
    data['ProfileImage'] = profileImage;
    data['Name'] = name;
    data['Email'] = email;
    data['MobileNo'] = mobileNo;
    data['Gender'] = gender;
    return data;
  }
}
