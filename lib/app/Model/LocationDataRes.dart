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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.locations != null) {
      data['locations'] = this.locations!.map((v) => v.toJson()).toList();
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

    profileImage = json['ProfileImage'] ?? json['profileImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['groupId'] = this.groupId;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['lastSeen'] = this.lastSeen;
    data['isOnline'] = this.isOnline;
    data['name'] = this.name;
    data['isCreator'] = isCreator;
    data['ProfileImage'] = this.profileImage;
    return data;
  }
}
