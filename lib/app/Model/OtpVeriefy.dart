class VeriefyOtpResponse {
  bool? status;
  String? message;
  OtpveriefyData? data;

  VeriefyOtpResponse({this.status, this.message, this.data});

  VeriefyOtpResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? OtpveriefyData.fromJson(json['data']) : null;
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

class OtpveriefyData {
  String? token;
  String? userName;
  String? profileImage;
  int? userId;
  bool? isNewUser;
  bool? locationSharing;

  OtpveriefyData(
      {this.token,
      this.userId,
      this.isNewUser,
      this.userName,
      this.profileImage,
      this.locationSharing});

  OtpveriefyData.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    userId = json['userId'];
    isNewUser = json['isNewUser'];
    userName = json['userName'];
    profileImage = json['profileImage'];

    final rawLocSharing = json['locationSharing'] ??
        json['isLocationSharing'] ??
        json['location_sharing'] ??
        json['is_location_sharing'];
    if (rawLocSharing != null) {
      if (rawLocSharing is bool) {
        locationSharing = rawLocSharing;
      } else if (rawLocSharing is num) {
        locationSharing = rawLocSharing == 1;
      } else if (rawLocSharing is String) {
        final s = rawLocSharing.trim().toLowerCase();
        locationSharing = (s == 'true' || s == '1');
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['userId'] = userId;
    data['isNewUser'] = isNewUser;
    data['userName'] = userName;
    data['profileImage'] = profileImage;
    data['locationSharing'] = locationSharing;
    return data;
  }
}
