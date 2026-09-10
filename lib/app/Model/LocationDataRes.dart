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

  LocationDataRes.fromJson(Map<String, dynamic> json) {
    status = json['status'] == true || json['success'] == true;
    message = json['message']?.toString();
    locations = <LocationData>[];

    final dynamic list = json['locations'] ??
        json['data'] ??
        json['memberData'] ??
        json['members'] ??
        json['users'];

    if (list is List) {
      for (var v in list) {
        if (v is Map<String, dynamic>) {
          locations!.add(LocationData.fromJson(v));
        } else if (v is Map) {
          locations!.add(LocationData.fromJson(Map<String, dynamic>.from(v)));
        }
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
  });

  static double? _parseDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString());
  }

  LocationData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? json['_id'];
    userId = json['userId'] ?? json['UserId'] ?? json['id'] ?? json['_id'];
    groupId = json['groupId'];

    if (json['location'] is Map) {
      final loc = json['location'] as Map;
      latitude = _parseDouble(loc['lat'] ?? loc['latitude'] ?? loc['userLat']);
      longitude = _parseDouble(loc['lng'] ?? loc['lon'] ?? loc['longitude'] ?? loc['userLong']);
    } else {
      latitude = _parseDouble(json['latitude'] ?? json['lat'] ?? json['userLat']);
      longitude = _parseDouble(json['longitude'] ?? json['lng'] ?? json['lon'] ?? json['long'] ?? json['userLong']);
    }

    lastSeen = json['lastSeen'] ?? json['last_seen'];
    isOnline = json['isOnline'] ?? json['is_online'] ?? json['online'];
    isCreator = json['isCreator'];
    name = json['name'] ?? json['Name'] ?? json['fullName'];
    locationSharing = json['locationSharing'] is bool
        ? json['locationSharing']
        : (json['locationSharing'] == 1 || json['locationSharing'] == '1');
    profileImage = json['ProfileImage'] ?? json['profileImage'] ?? json['image'];
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
    return data;
  }
}
