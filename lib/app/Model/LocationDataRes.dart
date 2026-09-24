import 'dart:convert';
import 'package:get/get.dart';

class LocationDataRes {
  bool? status;
  String? message;
  List<LocationData>? locations;

  LocationDataRes({this.status, this.message, this.locations});

  static double? _parseDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString());
  }

  LocationDataRes.fromJson(dynamic json) {
    if (json is String) {
      try {
        json = jsonDecode(json);
      } catch (_) {}
    }

    locations = <LocationData>[];

    if (json is List) {
      status = true;
      for (var v in json) {
        if (v is Map) {
          locations!.add(LocationData.fromJson(Map<String, dynamic>.from(v)));
        }
      }
      return;
    }

    if (json is! Map) {
      status = false;
      return;
    }

    final rawStatus = json['status'] ?? json['success'] ?? json['statusCode'] ?? json['code'];
    status = rawStatus == true ||
        rawStatus == 1 ||
        rawStatus == '1' ||
        rawStatus == 200 ||
        rawStatus == '200' ||
        rawStatus.toString().toLowerCase() == 'true' ||
        rawStatus.toString().toLowerCase() == 'success';
    message = json['message']?.toString();

    dynamic list = json['locations'] ??
        json['data'] ??
        json['memberData'] ??
        json['members'] ??
        json['groupMembers'] ??
        json['group_members'] ??
        json['users'] ??
        json['result'] ??
        json['results'];

    if (list is Map) {
      final mapData = list as Map;
      list = mapData['members'] ??
          mapData['groupMembers'] ??
          mapData['group_members'] ??
          mapData['memberData'] ??
          mapData['locations'] ??
          mapData['users'] ??
          mapData['data'] ??
          mapData['result'];
      if (list is! List) {
        for (var v in mapData.values) {
          if (v is List) {
            list = v;
            break;
          }
        }
      }
    }

    if (list is List) {
      for (var v in list) {
        if (v is Map<String, dynamic>) {
          locations!.add(LocationData.fromJson(v));
        } else if (v is Map) {
          locations!.add(LocationData.fromJson(Map<String, dynamic>.from(v)));
        }
      }
      if (locations!.isNotEmpty) {
        status = true;
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (locations != null) {
      data['locations'] = locations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LocationData {
  dynamic id;
  dynamic userId;
  dynamic groupId;
  dynamic latitude;
  dynamic longitude;
  dynamic lastSeen;
  dynamic isOnline;
  dynamic name;
  dynamic profileImage;
  dynamic isCreator;
  bool? locationSharing;
  dynamic mobileNo;
  dynamic role;
  dynamic location;
  dynamic team;
  dynamic battery;

  LocationData({
    this.id,
    this.userId,
    this.groupId,
    this.latitude,
    this.longitude,
    this.lastSeen,
    this.isOnline,
    this.name,
    this.isCreator,
    this.profileImage,
    this.locationSharing,
    this.mobileNo,
    this.role,
    this.location,
    this.team,
    this.battery,
  });

  static double? _parseDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString());
  }

  LocationData.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? (json['user'] as Map)
        : (json['userData'] is Map
            ? (json['userData'] as Map)
            : (json['member'] is Map
                ? (json['member'] as Map)
                : (json['userDetails'] is Map
                    ? (json['userDetails'] as Map)
                    : (json['User'] is Map ? (json['User'] as Map) : null))));

    id = json['id'] ?? json['_id'] ?? user?['id'] ?? user?['_id'];
    userId = json['userId'] ??
        json['UserId'] ??
        json['user_id'] ??
        json['id'] ??
        json['_id'] ??
        user?['userId'] ??
        user?['user_id'] ??
        user?['id'];
    groupId = json['groupId'] ?? json['group_id'] ?? json['GroupId'] ?? user?['groupId'];

    if (json['location'] is Map) {
      final loc = json['location'] as Map;
      latitude = _parseDouble(loc['lat'] ?? loc['latitude'] ?? loc['userLat']);
      longitude = _parseDouble(
          loc['lng'] ?? loc['lon'] ?? loc['longitude'] ?? loc['userLong']);
    } else {
      latitude =
          _parseDouble(json['latitude'] ?? json['lat'] ?? json['userLat']);
      longitude = _parseDouble(json['longitude'] ??
          json['lng'] ??
          json['lon'] ??
          json['long'] ??
          json['userLong']);
    }

    lastSeen = json['lastSeen'] ??
        json['last_seen'] ??
        json['lastActive'] ??
        user?['lastSeen'] ??
        user?['last_seen'];
    isOnline = json['isOnline'] ??
        json['is_online'] ??
        json['online'] ??
        json['online_status'] ??
        user?['isOnline'] ??
        user?['is_online'] ??
        user?['online'];

    final rawCreator = json['isCreator'] ??
        json['is_creator'] ??
        json['isAdmin'] ??
        json['is_admin'] ??
        user?['isCreator'] ??
        user?['isAdmin'];
    final rawRole = (json['role'] ?? user?['role'] ?? json['designation'])
        ?.toString()
        .toLowerCase();
    isCreator = rawCreator == true ||
        rawCreator == 1 ||
        rawCreator == '1' ||
        rawRole == 'admin' ||
        rawRole == 'creator';

    name = json['name'] ??
        json['Name'] ??
        json['fullName'] ??
        json['full_name'] ??
        json['userName'] ??
        json['user_name'] ??
        user?['name'] ??
        user?['Name'] ??
        user?['fullName'] ??
        user?['userName'];

    final rawLocSharing = json['locationSharing'] ??
        json['location_sharing'] ??
        json['isLocationSharing'] ??
        user?['locationSharing'] ??
        user?['location_sharing'];
    locationSharing = rawLocSharing is bool
        ? rawLocSharing
        : (rawLocSharing == null
            ? true
            : (rawLocSharing == 1 ||
                rawLocSharing == '1' ||
                rawLocSharing.toString().toLowerCase() == 'true'));

    profileImage = json['ProfileImage'] ??
        json['profileImage'] ??
        json['image'] ??
        json['avatar'] ??
        user?['ProfileImage'] ??
        user?['profileImage'] ??
        user?['image'] ??
        user?['avatar'];

    mobileNo = json['MobileNo'] ??
        json['mobileNo'] ??
        json['mobile_no'] ??
        json['mobile'] ??
        json['phone'] ??
        user?['MobileNo'] ??
        user?['mobileNo'] ??
        user?['phone'];

    role = json['role'] ?? user?['role'] ?? json['designation'];
    if (json['location'] is String) {
      location = json['location'];
    } else if (json['address'] is String) {
      location = json['address'];
    }
    team = json['team'] ?? json['groupName'] ?? json['group_name'];
    battery = json['battery'] ??
        json['batteryLevel'] ??
        json['battery_level'] ??
        json['batteryPercentage'] ??
        user?['battery'] ??
        user?['batteryLevel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['groupId'] = groupId;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['lastSeen'] = lastSeen;
    data['isOnline'] = isOnline;
    data['name'] = name;
    data['isCreator'] = isCreator;
    data['ProfileImage'] = profileImage;
    data['locationSharing'] = locationSharing;
    data['mobileNo'] = mobileNo;
    data['role'] = role;
    data['battery'] = battery;
    return data;
  }
}
