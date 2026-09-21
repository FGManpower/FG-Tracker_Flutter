import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Data/Services/Tracking.dart';
import 'package:fgtracker/app/Model/MemberModel.dart';
import 'package:geocoding/geocoding.dart' hide Location;

class UsersWithinRadiusRes {
  bool? status;
  String? message;
  int? totalMembers;
  List<UsersWithinRadiusData>? data;

  UsersWithinRadiusRes({this.status, this.message, this.totalMembers, this.data});

  UsersWithinRadiusRes.fromJson(Map<String, dynamic> json) {
    final s = json['status'] ?? json['success'];
    status = s == true || s == 1 || s == 'true' || s == '1';
    message = json['message']?.toString();

    totalMembers = int.tryParse((json['totalMembers'] ??
            json['total_members'] ??
            json['totalUsers'] ??
            json['total_users'] ??
            json['totalCount'] ??
            json['total_count'] ??
            json['totalRecords'] ??
            json['total_records'] ??
            json['total'] ??
            json['count'] ??
            (json['pagination'] is Map ? json['pagination']['totalRecords'] : null) ??
            (json['meta'] is Map ? json['meta']['total'] : null))
        ?.toString() ?? '');

    dynamic listData = json['data'];
    if (listData == null || (listData is List && listData.isEmpty)) {
      listData = json['locations'] ?? json['memberData'] ?? json['users'] ?? json['members'];
    }

    data = <UsersWithinRadiusData>[];

    if (listData is List) {
      for (var v in listData) {
        if (v is Map<String, dynamic>) {
          data!.add(UsersWithinRadiusData.fromJson(v));
        } else if (v is Map) {
          data!.add(UsersWithinRadiusData.fromJson(Map<String, dynamic>.from(v)));
        }
      }
    } else if (listData is Map) {
      final mapData = listData;
      final innerList = mapData['users'] ??
          mapData['locations'] ??
          mapData['members'] ??
          mapData['data'] ??
          mapData['memberData'];
      if (innerList is List) {
        for (var v in innerList) {
          if (v is Map) {
            data!.add(UsersWithinRadiusData.fromJson(Map<String, dynamic>.from(v)));
          }
        }
      }
    }

    // If data is present, consider status true even if omitted by backend
    if (data != null && data!.isNotEmpty && status != false) {
      status = true;
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
  double? latitude;
  double? longitude;
  dynamic distance;
  dynamic battery;
  String? team;
  String? location;
  String? lastSeen;
  bool isOnline = false;

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
    this.isOnline = false,
  });

  static double? _parseDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString());
  }

  UsersWithinRadiusData.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? (json['user'] as Map)
        : (json['userData'] is Map
            ? (json['userData'] as Map)
            : (json['member'] is Map
                ? (json['member'] as Map)
                : (json['userDetails'] is Map
                    ? (json['userDetails'] as Map)
                    : (json['User'] is Map ? (json['User'] as Map) : null))));

    userId = json['userId'] ??
        json['UserId'] ??
        json['id'] ??
        json['user_id'] ??
        json['_id'] ??
        user?['userId'] ??
        user?['UserId'] ??
        user?['id'] ??
        user?['user_id'] ??
        user?['_id'];

    // Resolve name
    String? resolvedName = (json['name'] ??
            json['Name'] ??
            json['fullname'] ??
            json['fullName'] ??
            user?['name'] ??
            user?['Name'] ??
            user?['fullName'] ??
            user?['fullname'])
        ?.toString();
    if (resolvedName == null || resolvedName.trim().isEmpty || resolvedName.trim().toLowerCase() == 'null') {
      final fn = (json['firstName'] ??
              json['first_name'] ??
              user?['firstName'] ??
              user?['first_name'] ??
              '')
          ?.toString()
          .trim() ??
          '';
      final ln = (json['lastName'] ??
              json['last_name'] ??
              user?['lastName'] ??
              user?['last_name'] ??
              '')
          ?.toString()
          .trim() ??
          '';
      final fCap = fn.isNotEmpty ? (fn[0].toUpperCase() + fn.substring(1)) : '';
      final lCap = ln.isNotEmpty ? (ln[0].toUpperCase() + ln.substring(1)) : '';
      final combined = '$fCap $lCap'.trim();
      if (combined.isNotEmpty) {
        resolvedName = combined;
      }
    }
    name = resolvedName;

    mobileNo = (json['mobileNumber'] ??
            json['mobile_number'] ??
            json['MobileNumber'] ??
            json['mobileNo'] ??
            json['MobileNo'] ??
            json['mobile'] ??
            json['phone'] ??
            user?['mobileNumber'] ??
            user?['mobile_number'] ??
            user?['mobileNo'] ??
            user?['phone'])
        ?.toString();
    profileImage = (json['ProfileImage'] ??
            json['profileImage'] ??
            json['image'] ??
            json['avatar'] ??
            json['profile_image'] ??
            user?['ProfileImage'] ??
            user?['profileImage'] ??
            user?['image'] ??
            user?['avatar'] ??
            user?['profile_image'])
        ?.toString()
        .trim();

    // Support nested location object or flat coordinates
    if (json['location'] is Map) {
      final locMap = json['location'] as Map;
      latitude = _parseDouble(
          locMap['lat'] ?? locMap['latitude'] ?? locMap['userLat']);
      longitude = _parseDouble(locMap['lon'] ??
          locMap['lng'] ??
          locMap['longitude'] ??
          locMap['userLong']);
      location = (locMap['address'] ??
              locMap['name'] ??
              locMap['location'] ??
              locMap['area'] ??
              locMap['city'] ??
              locMap['formattedAddress'] ??
              locMap['formatted_address'])
          ?.toString();
    } else {
      latitude = _parseDouble(
          json['latitude'] ?? json['userLat'] ?? json['lat']);
      longitude = _parseDouble(json['longitude'] ??
          json['userLong'] ??
          json['long'] ??
          json['lng'] ??
          json['lon']);
      if (json['location'] != null && json['location'].toString().trim().isNotEmpty) {
        location = json['location'].toString().trim();
      } else {
        location = (json['address'] ??
                json['location_name'] ??
                json['locationName'] ??
                json['currentLocation'] ??
                json['current_location'] ??
                json['userAddress'] ??
                json['user_address'] ??
                json['lastLocation'] ??
                json['last_location'])
            ?.toString();
      }
    }

    final areaVal = (json['area'] ??
            json['subLocality'] ??
            (json['location'] is Map ? json['location']['area'] : null))
        ?.toString()
        .trim();
    final cityVal = (json['city'] ??
            json['locality'] ??
            (json['location'] is Map ? json['location']['city'] : null))
        ?.toString()
        .trim();

    if (location == null ||
        location!.trim().isEmpty ||
        location == "null" ||
        location == "Active now" ||
        location == "Location" ||
        RegExp(r'^\d+\.\d+,\s*\d+\.\d+$').hasMatch(location!)) {
      if (areaVal != null && cityVal != null && areaVal.isNotEmpty && cityVal.isNotEmpty) {
        location = areaVal.toLowerCase() == cityVal.toLowerCase()
            ? cityVal
            : "$areaVal, $cityVal";
      } else if (areaVal != null && areaVal.isNotEmpty) {
        location = areaVal;
      } else if (cityVal != null && cityVal.isNotEmpty) {
        location = cityVal;
      }
    }

    final rawDistance = (json['distance'] ??
            json['Distance'] ??
            json['distanceInKm'] ??
            json['distance_km'] ??
            json['dist'])
        ?.toString();
    if (rawDistance != null && !rawDistance.toLowerCase().contains("nan")) {
      distance = rawDistance;
    } else {
      distance = null;
    }

    battery = json['battery'] ??
        json['Battery'] ??
        json['batteryLevel'] ??
        json['battery_level'] ??
        json['batteryPercentage'] ??
        json['percentage'];

    dynamic groupField = json['groups'] ??
        json['group'] ??
        json['team'] ??
        json['teamName'] ??
        json['groupName'] ??
        json['group_name'] ??
        json['team_name'];
    if (groupField is List && groupField.isNotEmpty) {
      team = groupField.first.toString();
    } else if (groupField != null) {
      team = groupField.toString();
    }

    lastSeen = json['lastSeen']?.toString();

    final onlineVal = json['isOnline'] ?? json['online'] ?? json['is_online'];
    isOnline = Tracking().isOnline(
      rawIsOnline: onlineVal,
      lastSeen: lastSeen,
      thresholdMinutes: 5,
    );
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

  static final Map<String, String> addressCache = {};

  Future<String> resolveAddressFromCoordinates() async {
    if (latitude == null ||
        longitude == null ||
        (latitude == 0.0 && longitude == 0.0)) {
      return location ?? "";
    }
    final cacheKey =
        "${latitude!.toStringAsFixed(4)},${longitude!.toStringAsFixed(4)}";
    if (addressCache.containsKey(cacheKey)) {
      location = addressCache[cacheKey]!;
      return location!;
    }
    try {
      final placemarks = await placemarkFromCoordinates(latitude!, longitude!);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        String area = place.subLocality?.trim() ?? '';
        if (area.isEmpty) {
          area = place.locality?.trim() ?? '';
        }
        if (area.isEmpty) {
          area = place.subAdministrativeArea?.trim() ?? '';
        }

        String city = place.locality?.trim() ?? '';
        if (city.isEmpty) {
          city = place.subAdministrativeArea?.trim() ?? '';
        }
        if (city.isEmpty) {
          city = place.administrativeArea?.trim() ?? '';
        }

        String formatted = '';
        if (area.isNotEmpty && city.isNotEmpty) {
          formatted = area.toLowerCase() == city.toLowerCase()
              ? city
              : "$area, $city";
        } else if (area.isNotEmpty) {
          formatted = area;
        } else if (city.isNotEmpty) {
          formatted = city;
        } else {
          formatted = place.name?.trim() ?? "";
        }

        if (formatted.isNotEmpty) {
          addressCache[cacheKey] = formatted;
          location = formatted;
          return formatted;
        }
      }
    } catch (_) {}
    return location ?? "";
  }

  MemberModel toMemberModel({
    double? currentUserLat,
    double? currentUserLong,
    String? fallbackTeam,
  }) {
    String formattedDistance = "Nearby";

    // Strictly use backend calculated distance without local calculation
    if (distance != null &&
        distance.toString().trim().isNotEmpty &&
        !distance.toString().toLowerCase().contains("nan")) {
      final str = distance.toString().trim();
      if (str.contains("away")) {
        formattedDistance = str;
      } else if (str.contains("km") || str.contains("m")) {
        formattedDistance = "$str away";
      } else {
        formattedDistance = "$str km away";
      }
    } else {
      formattedDistance = "Nearby";
    }

    int? finalBattery;
    if (battery != null) {
      final parsed =
          int.tryParse(battery.toString().replaceAll(RegExp(r'[^\d]'), ''));
      if (parsed != null && parsed >= 0 && parsed <= 100) {
        finalBattery = parsed;
      }
    }

    String avatar = "";
    if (profileImage != null &&
        profileImage!.trim().isNotEmpty &&
        profileImage != "null") {
      final img = profileImage!.trim().replaceAll(r'\', '/');
      if (img.startsWith("http://") || img.startsWith("https://")) {
        avatar = img;
      } else {
        final cleanBase = ConstRes.aImageBaseUrl.endsWith('/')
            ? ConstRes.aImageBaseUrl
            : '${ConstRes.aImageBaseUrl}/';
        final cleanPath = img.startsWith('/') ? img.substring(1) : img;
        avatar = "$cleanBase$cleanPath";
      }
    }

    String resolvedLocation = (location != null &&
            location!.trim().isNotEmpty &&
            !location!.contains("Lat:") &&
            !location!.contains("Active now") &&
            location != "Location" &&
            location != "Locating..." &&
            !RegExp(r'^\d+\.\d+,\s*\d+\.\d+$').hasMatch(location!))
        ? location!.trim()
        : "";

    if (resolvedLocation.isEmpty &&
        latitude != null &&
        longitude != null &&
        latitude != 0.0 &&
        longitude != 0.0) {
      final cacheKey =
          "${latitude!.toStringAsFixed(4)},${longitude!.toStringAsFixed(4)}";
      if (addressCache.containsKey(cacheKey)) {
        resolvedLocation = addressCache[cacheKey]!;
        location = resolvedLocation;
      }
    }

    return MemberModel(
      userId: userId,
      latitude: latitude,
      longitude: longitude,
      isOnline: isOnline,
      name: (name != null && name!.trim().isNotEmpty)
          ? name!.trim()
          : (mobileNo != null && mobileNo!.trim().isNotEmpty
              ? mobileNo!.trim()
              : "User ${userId ?? ''}"),
      team: (team != null && team!.trim().isNotEmpty)
          ? team!.trim()
          : (fallbackTeam ?? ""),
      location: resolvedLocation.isNotEmpty ? resolvedLocation : "Location unavailable",
      distance: formattedDistance,
      battery: finalBattery,
      avatarUrl: avatar,
    );
  }
}
