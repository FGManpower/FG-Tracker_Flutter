class LiveLocationModel {
  final int userId;
  final String firstName;
  final String lastName;
  final String profileImage;
  final double latitude;
  final double longitude;
  final bool isOnline;
  final dynamic battery;
  final String? address;
  final String? area;
  final String? city;
  final String? phone;
  final String? team;

  LiveLocationModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.profileImage,
    required this.latitude,
    required this.longitude,
    dynamic isOnline = false,
    this.battery,
    this.address,
    this.area,
    this.city,
    this.phone,
    this.team,
  }) : isOnline = _parseBool(isOnline, defaultValue: false);

  static bool _parseBool(dynamic val, {bool defaultValue = false}) {
    if (val == null) return defaultValue;
    if (val is bool) return val;
    if (val is num) return val == 1;
    final s = val.toString().trim().toLowerCase();
    if (s == 'false' || s == '0' || s == 'offline') return false;
    if (s == 'true' || s == '1' || s == 'online') return true;
    return defaultValue;
  }

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? 'Member' : name;
  }

  factory LiveLocationModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] is Map
        ? Map<String, dynamic>.from(json['location'])
        : <String, dynamic>{};

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    // Latitude: check root first, then location map
    double lat = parseDouble(
      json['latitude'] ??
          json['userLat'] ??
          json['lat'] ??
          location['lat'] ??
          location['latitude'] ??
          location['userLat'],
    );

    // Longitude: check root first, then location map
    double lng = parseDouble(
      json['longitude'] ??
          json['userLong'] ??
          json['lng'] ??
          json['lon'] ??
          json['long'] ??
          location['lon'] ??
          location['lng'] ??
          location['longitude'] ??
          location['userLong'],
    );

    // If still 0.0, check GeoJSON coordinates array: [lng, lat]
    if (lat == 0.0 && lng == 0.0 && json['coordinates'] is List) {
      final coords = json['coordinates'] as List;
      if (coords.length >= 2) {
        lng = parseDouble(coords[0]);
        lat = parseDouble(coords[1]);
      }
    }

    final user = json['user'] is Map
        ? (json['user'] as Map)
        : (json['userData'] is Map
            ? (json['userData'] as Map)
            : (json['member'] is Map
                ? (json['member'] as Map)
                : (json['userDetails'] is Map
                    ? (json['userDetails'] as Map)
                    : (json['User'] is Map ? (json['User'] as Map) : null))));

    // User ID
    final uId = int.tryParse(
            '${json['userId'] ?? json['UserId'] ?? json['id'] ?? json['user_id'] ?? json['_id'] ?? user?['userId'] ?? user?['UserId'] ?? user?['id'] ?? user?['user_id'] ?? user?['_id'] ?? 0}') ??
        0;

    // Names
    String fn = '${json['firstName'] ?? json['first_name'] ?? user?['firstName'] ?? user?['first_name'] ?? ''}'.trim();
    String ln = '${json['lastName'] ?? json['last_name'] ?? user?['lastName'] ?? user?['last_name'] ?? ''}'.trim();
    if (fn.isEmpty && ln.isEmpty) {
      final rawName =
          '${json['name'] ?? json['Name'] ?? json['fullName'] ?? json['fullname'] ?? user?['name'] ?? user?['Name'] ?? user?['fullName'] ?? user?['fullname'] ?? ''}'
              .trim();
      if (rawName.isNotEmpty && rawName.toLowerCase() != 'null') {
        final parts = rawName.split(' ');
        fn = parts[0];
        if (parts.length > 1) {
          ln = parts.sublist(1).join(' ');
        }
      }
    }

    // Profile image
    final pImg =
        '${json['ProfileImage'] ?? json['profileImage'] ?? json['image'] ?? json['avatar'] ?? json['profile_image'] ?? user?['ProfileImage'] ?? user?['profileImage'] ?? user?['image'] ?? user?['avatar'] ?? user?['profile_image'] ?? ''}'
            .trim();

    // Address, Area, City
    String? addr;
    if (json['location'] is String && (json['location'] as String).trim().isNotEmpty) {
      addr = (json['location'] as String).trim();
    } else {
      addr = (json['address'] ??
              json['location_name'] ??
              json['locationName'] ??
              json['currentLocation'] ??
              json['current_location'] ??
              json['userAddress'] ??
              location['address'] ??
              location['name'] ??
              location['location'] ??
              location['formattedAddress'] ??
              user?['address'] ??
              user?['location'])
          ?.toString();
    }

    final area =
        (json['area'] ?? json['subLocality'] ?? location['area'])?.toString();
    final city =
        (json['city'] ?? json['locality'] ?? location['city'])?.toString();

    if (addr == null || addr.isEmpty) {
      if (area != null && city != null && area.isNotEmpty && city.isNotEmpty) {
        addr = area.toLowerCase() == city.toLowerCase() ? city : "$area, $city";
      } else if (area != null && area.isNotEmpty) {
        addr = area;
      } else if (city != null && city.isNotEmpty) {
        addr = city;
      }
    }

    // Online status - liveLocationStream is actively broadcasting, so default to true unless explicitly offline
    final onlineVal = json['isOnline'] ?? json['online'] ?? json['is_online'] ?? user?['isOnline'] ?? user?['online'];
    final bool online = _parseBool(onlineVal, defaultValue: true);

    final battery = json['battery'] ??
        json['Battery'] ??
        json['batteryLevel'] ??
        json['battery_level'] ??
        json['batteryPercentage'] ??
        json['percentage'] ??
        user?['battery'];

    final phone = (json['mobileNumber'] ??
            json['mobileNo'] ??
            json['phone'] ??
            json['mobile'] ??
            user?['mobileNumber'] ??
            user?['mobileNo'] ??
            user?['phone'] ??
            user?['mobile'])
        ?.toString();
    final team = (json['team'] ??
            json['department'] ??
            json['groupName'] ??
            json['group_name'] ??
            user?['team'] ??
            user?['department'] ??
            user?['groupName'])
        ?.toString();

    return LiveLocationModel(
      userId: uId,
      firstName: fn,
      lastName: ln,
      profileImage: pImg,
      latitude: lat,
      longitude: lng,
      isOnline: online,
      battery: battery,
      address: addr,
      area: area,
      city: city,
      phone: phone,
      team: team,
    );
  }
}