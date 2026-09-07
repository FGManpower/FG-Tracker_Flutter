class LiveLocationModel {
  final int userId;
  final String firstName;
  final String lastName;
  final String profileImage;
  final double latitude;
  final double longitude;
  final bool isOnline;
  final String? address;
  final String? area;
  final String? city;

  LiveLocationModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.profileImage,
    required this.latitude,
    required this.longitude,
    required this.isOnline,
    this.address,
    this.area,
    this.city,
  });

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

    // User ID
    final uId = int.tryParse(
            '${json['userId'] ?? json['UserId'] ?? json['id'] ?? json['user_id'] ?? 0}') ??
        0;

    // Names
    String fn = '${json['firstName'] ?? json['first_name'] ?? ''}'.trim();
    String ln = '${json['lastName'] ?? json['last_name'] ?? ''}'.trim();
    if (fn.isEmpty && ln.isEmpty) {
      final rawName =
          '${json['name'] ?? json['Name'] ?? json['fullName'] ?? json['fullname'] ?? ''}'
              .trim();
      if (rawName.isNotEmpty) {
        final parts = rawName.split(' ');
        fn = parts[0];
        if (parts.length > 1) {
          ln = parts.sublist(1).join(' ');
        }
      }
    }

    // Profile image
    final pImg =
        '${json['ProfileImage'] ?? json['profileImage'] ?? json['image'] ?? json['avatar'] ?? json['profile_image'] ?? ''}';

    // Address, Area, City
    final addr =
        (json['address'] ?? json['location_name'] ?? location['address'])
            ?.toString();
    final area =
        (json['area'] ?? json['subLocality'] ?? location['area'])?.toString();
    final city =
        (json['city'] ?? json['locality'] ?? location['city'])?.toString();

    // Online status
    final onlineVal = json['isOnline'] ?? json['online'] ?? json['is_online'];
    bool online = false;
    if (onlineVal is bool) {
      online = onlineVal;
    } else if (onlineVal is num) {
      online = onlineVal == 1;
    } else if (onlineVal is String) {
      online = onlineVal.toLowerCase() == 'true' || onlineVal == '1';
    }

    return LiveLocationModel(
      userId: uId,
      firstName: fn,
      lastName: ln,
      profileImage: pImg,
      latitude: lat,
      longitude: lng,
      isOnline: online,
      address: addr,
      area: area,
      city: city,
    );
  }
}