class VeriefyOtpResponse {
  bool? status;
  String? message;
  OtpveriefyData? data;

  VeriefyOtpResponse({this.status, this.message, this.data});

  VeriefyOtpResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new OtpveriefyData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class OtpveriefyData {
  String? token;
  String? userName;
  String? profileImage;
  int? userId;
  bool? isNewUser;

  OtpveriefyData({this.token, this.userId, this.isNewUser,this.userName,this.profileImage});

  OtpveriefyData.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    userId = json['userId'];
    isNewUser = json['isNewUser'];
    userName = json['userName'];
    profileImage = json['profileImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    data['userId'] = this.userId;
    data['isNewUser'] = this.isNewUser;
    data['userName'] = this.userName;
    data['profileImage'] = this.profileImage;
    return data;
  }
}