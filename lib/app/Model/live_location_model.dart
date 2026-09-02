class LiveLocationModel {
  final int userId;
  final String firstName;
  final String lastName;
  final String profileImage;
  final double latitude;
  final double longitude;
  final bool isOnline;

  LiveLocationModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.profileImage,
    required this.latitude,
    required this.longitude,
    required this.isOnline,
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
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    return LiveLocationModel(
      userId: int.tryParse('${json['userId'] ?? 0}') ?? 0,
      firstName: '${json['firstName'] ?? ''}',
      lastName: '${json['lastName'] ?? ''}',
      profileImage: '${json['ProfileImage'] ?? ''}',
      latitude: parseDouble(location['lat']),
      longitude: parseDouble(location['lon']),
      isOnline: json['isOnline'] == true,
    );
  }
}