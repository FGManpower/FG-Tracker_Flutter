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
  dynamic isOnline;
  String? lastSeen;

  UserData(
      {this.userId,
      this.profileImage,
      this.name,
      this.email,
      this.mobileNo,
      this.gender,
      this.isOnline,
      this.lastSeen});

  UserData.fromJson(Map<String, dynamic> json) {
    userId = json['UserId'] ?? json['userId'];
    profileImage = json['ProfileImage'] ?? json['profileImage'];
    name = json['Name'] ?? json['name'];
    email = json['Email'] ?? json['email'];
    mobileNo = json['MobileNo'] ?? json['mobileNo'];
    gender = json['Gender'] ?? json['gender'];
    isOnline = json['isOnline'] ??
        json['is_online'] ??
        json['online'] ??
        json['status'];
    lastSeen = json['lastSeen'] ?? json['last_seen'] ?? json['LastSeen'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['UserId'] = userId;
    data['ProfileImage'] = profileImage;
    data['Name'] = name;
    data['Email'] = email;
    data['MobileNo'] = mobileNo;
    data['Gender'] = gender;
    data['isOnline'] = isOnline;
    data['lastSeen'] = lastSeen;
    return data;
  }
}
