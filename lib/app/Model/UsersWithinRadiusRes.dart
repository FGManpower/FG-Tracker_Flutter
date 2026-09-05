import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Model/MemberModel.dart';

class UsersWithinRadiusRes {
  bool? status;
  String? message;
  List<UsersWithinRadiusData>? data;

  UsersWithinRadiusRes({this.status, this.message, this.data});

  UsersWithinRadiusRes.fromJson(Map<String, dynamic> json) {
    status = json['status'] as bool?;
    message = json['message']?.toString();
    if (json['data'] != null) {
      data = <UsersWithinRadiusData>[];
      if (json['data'] is List) {
        json['data'].forEach((v) {
          data!.add(UsersWithinRadiusData.fromJson(v));
        });
      } else if (json['data'] is Map && json['data']['users'] != null) {
        json['data']['users'].forEach((v) {
          data!.add(UsersWithinRadiusData.fromJson(v));
        });
      }
    } else if (json['users'] != null && json['users'] is List) {
      data = <UsersWithinRadiusData>[];
      json['users'].forEach((v) {
        data!.add(UsersWithinRadiusData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UsersWithinRadiusData {
  dynamic userId;
  String? name;
  String? mobileNo;
  String? profileImage;
  dynamic latitude;
  dynamic longitude;
  dynamic distance;
  dynamic battery;
  String? team;
  String? location;
  String? lastSeen;
  dynamic isOnline;

  UsersWithinRadiusData({
    this.userId,
    this.name,
    this.mobileNo,
    this.profileImage,
    this.latitude,
    this.longitude,
    this.distance,
    this.battery,
    this.team,
    this.location,
    this.lastSeen,
    this.isOnline,
  });

  UsersWithinRadiusData.fromJson(Map<String, dynamic> json) {
    userId = json['userId'] ?? json['UserId'] ?? json['id'];
    name = (json['name'] ?? json['Name'] ?? json['fullname'] ?? json['fullName'])?.toString();
    mobileNo = (json['mobileNo'] ?? json['MobileNo'])?.toString();
    profileImage = (json['profileImage'] ?? json['ProfileImage'])?.toString();
    latitude = json['latitude'] ?? json['userLat'] ?? json['lat'];
    longitude = json['longitude'] ?? json['userLong'] ?? json['long'];
    distance = json['distance'];
    battery = json['battery'];
    team = (json['team'] ?? json['teamName'] ?? json['groupName'])?.toString();
    location = (json['location'] ?? json['address'])?.toString();
    lastSeen = json['lastSeen']?.toString();
    isOnline = json['isOnline'] ?? json['online'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['name'] = name;
    data['mobileNo'] = mobileNo;
    data['profileImage'] = profileImage;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['distance'] = distance;
    data['battery'] = battery;
    data['team'] = team;
    data['location'] = location;
    data['lastSeen'] = lastSeen;
    data['isOnline'] = isOnline;
    return data;
  }

  MemberModel toMemberModel() {
    String formattedDistance = "0.0";
    if (distance != null) {
      double? d = double.tryParse(distance.toString());
      if (d != null) {
        formattedDistance = d.toStringAsFixed(1);
      } else {
        formattedDistance = distance.toString();
      }
    }

    int parsedBattery = 80;
    if (battery != null) {
      parsedBattery = int.tryParse(battery.toString()) ?? 80;
    }

    String avatar = "https://i.pravatar.cc/150?img=11";
    if (profileImage != null && profileImage!.isNotEmpty) {
      if (profileImage!.startsWith("http")) {
        avatar = profileImage!;
      } else {
        avatar = "${ConstRes.aImageBaseUrl}$profileImage";
      }
    }

    return MemberModel(
      name: (name != null && name!.isNotEmpty) ? name! : "User ${userId ?? ''}",
      team: (team != null && team!.isNotEmpty) ? team! : "FG Manpower Team",
      location: (location != null && location!.isNotEmpty) ? location! : "Nearby",
      distance: formattedDistance,
      battery: parsedBattery,
      avatarUrl: avatar,
    );
  }
}
