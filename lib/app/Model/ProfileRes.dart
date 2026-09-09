class ProfileRes {
  bool? status;
  String? message;
  UserData? data;

  ProfileRes({this.status, this.message, this.data});

  ProfileRes.fromJson(Map<String, dynamic> json) {
    status = json['status'] == true ||
        json['status'] == 1 ||
        json['status'] == "true" ||
        json['success'] == true;
    message = json['message']?.toString() ?? json['msg']?.toString();

    dynamic rawData = json['data'] ??
        json['userData'] ??
        json['UserData'] ??
        json['user'] ??
        json['profile'] ??
        json['result'];

    if (rawData is Map<String, dynamic>) {
      data = UserData.fromJson(rawData);
    } else if (rawData is Map) {
      data = UserData.fromJson(rawData.cast<String, dynamic>());
    } else if (rawData is List && rawData.isNotEmpty && rawData.first is Map) {
      data = UserData.fromJson((rawData.first as Map).cast<String, dynamic>());
    } else if (json.containsKey('UserId') ||
        json.containsKey('userId') ||
        json.containsKey('MobileNo') ||
        json.containsKey('mobileNo') ||
        json.containsKey('Email') ||
        json.containsKey('email')) {
      data = UserData.fromJson(json);
    } else {
      data = null;
    }
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
    userId = json['UserId'] ?? json['userId'] ?? json['id'] ?? json['Id'];
    profileImage = json['ProfileImage'] ??
        json['profileImage'] ??
        json['profile_image'] ??
        json['image'] ??
        json['avatar'];
    name = (json['Name'] ??
            json['name'] ??
            json['userName'] ??
            json['user_name'] ??
            json['fullName'] ??
            json['fullname'])
        ?.toString();
    email = (json['Email'] ??
            json['email'] ??
            json['email_id'] ??
            json['EmailId'] ??
            json['emailId'] ??
            json['email_address'] ??
            json['EmailAddress'] ??
            json['emailAddress'] ??
            json['userEmail'] ??
            json['UserEmail'] ??
            json['user_email'] ??
            json['User_Email'] ??
            json['mail'] ??
            json['Mail'] ??
            json['e_mail'] ??
            json['E_mail'])
        ?.toString();
    mobileNo = (json['MobileNo'] ??
            json['mobileNo'] ??
            json['phone'] ??
            json['phone_number'] ??
            json['phoneNumber'] ??
            json['mobile_no'] ??
            json['Mobile'] ??
            json['mobile'] ??
            json['contact'] ??
            json['Contact'])
        ?.toString();
    gender = (json['Gender'] ?? json['gender'])?.toString();
    isOnline = json['isOnline'] ??
        json['is_online'] ??
        json['online'] ??
        json['status'];
    lastSeen = (json['lastSeen'] ?? json['last_seen'] ?? json['LastSeen'])?.toString();
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
