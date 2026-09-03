class LocationDataRes {
  bool? status;
  String? message;
  List<LocationData>? locations;

  LocationDataRes({this.status, this.message, this.locations});

  LocationDataRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    locations = <LocationData>[];

    if (json['locations'] != null) {
      json['locations'].forEach((v) {
        locations!.add(LocationData.fromJson(v));
      });
    }

    if (json['memberData'] != null) {
      json['memberData'].forEach((v) {
        locations!.add(LocationData.fromJson(v));
      });
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

  LocationData(
      {this.id,
      this.userId,
      this.groupId,
      this.latitude,
      this.longitude,
      this.lastSeen,
      this.isOnline,
      this.name,
      this.isCreator,
      this.profileImage});

  LocationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    groupId = json['groupId'];
    latitude = (json['latitude'] as num?)?.toDouble();
    longitude = (json['longitude'] as num?)?.toDouble();
    lastSeen = json['lastSeen'];
    isOnline = json['isOnline'];
    isCreator = json['isCreator'];
    name = json['name'] ?? json['Name'];
    locationSharing = json['locationSharing'];
    profileImage = json['ProfileImage'] ?? json['profileImage'];
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
