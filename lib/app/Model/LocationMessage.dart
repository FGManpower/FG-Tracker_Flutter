import 'dart:convert';

class LocationMessage {
  final double latitude;
  final double longitude;
  final String locationName;

  const LocationMessage({
    required this.latitude,
    required this.longitude,
    required this.locationName,

  });

  factory LocationMessage.fromJson(Map<String, dynamic> json) {
    return LocationMessage(
      latitude: (json["latitude"] as num?)?.toDouble() ?? 0.0,
      longitude: (json["longitude"] as num?)?.toDouble() ?? 0.0,
      locationName: json["locationName"] ?? "",    );
  }

  Map<String, dynamic> toJson() {
    return {
      "latitude": latitude,
      "longitude": longitude,
      "locationName": locationName,
    };
  }

  String toContent() {
    return jsonEncode(toJson());
  }

  factory LocationMessage.fromContent(String content) {
    return LocationMessage.fromJson(
      jsonDecode(content) as Map<String, dynamic>,
    );
  }
}