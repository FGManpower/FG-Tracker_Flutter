import 'dart:convert';

class LocationMessage {
  final double latitude;
  final double longitude;
  final String address;
  final String title;

  const LocationMessage({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.title,
  });

  factory LocationMessage.fromJson(Map<String, dynamic> json) {
    return LocationMessage(
      latitude: (json["latitude"] as num?)?.toDouble() ?? 0.0,
      longitude: (json["longitude"] as num?)?.toDouble() ?? 0.0,
      address: json["address"] ?? "",
      title: json["title"] ?? "Shared Location",    );
  }

  Map<String, dynamic> toJson() {
    return {
      "latitude": latitude,
      "longitude": longitude,
      "address": address,
      "title": title,
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