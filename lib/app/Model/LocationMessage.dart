import 'dart:convert';
import 'package:intl/intl.dart';

class LocationMessage {
  final double latitude;
  final double longitude;
  final String locationName;
  final String? address;
  final bool isLive;
  final int? durationMinutes;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? comment;

  const LocationMessage({
    required this.latitude,
    required this.longitude,
    required this.locationName,
    this.address,
    this.isLive = false,
    this.durationMinutes,
    this.startTime,
    this.endTime,
    this.comment,
  });

  bool get isEnded {
    if (!isLive) return true;
    if (endTime != null && DateTime.now().isAfter(endTime!)) return true;
    return false;
  }

  String get liveUntilText {
    if (isEnded) return "Live location ended";
    if (endTime != null) {
      final formatter = DateFormat('hh:mm a');
      return "Live until ${formatter.format(endTime!.toLocal())}";
    }
    return "Live location";
  }

  LocationMessage copyWith({
    double? latitude,
    double? longitude,
    String? locationName,
    String? address,
    bool? isLive,
    int? durationMinutes,
    DateTime? startTime,
    DateTime? endTime,
    String? comment,
  }) {
    return LocationMessage(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      address: address ?? this.address,
      isLive: isLive ?? this.isLive,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      comment: comment ?? this.comment,
    );
  }

  factory LocationMessage.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int? parseDuration(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString());
    }

    final double lat = parseDouble(json["latitude"] ?? json["lat"]);
    final double lng = parseDouble(json["longitude"] ?? json["lng"]);

    final String name = (json["locationName"] ??
            json["name"] ??
            json["address"] ??
            "")
        .toString();

    final String? addr = json["address"]?.toString() ?? json["formattedAddress"]?.toString();

    final bool isLive = json["isLive"] == true || json["is_live"] == true;
    final int? duration = parseDuration(json["durationMinutes"] ?? json["duration_minutes"]);

    return LocationMessage(
      latitude: lat,
      longitude: lng,
      locationName: name,
      address: addr,
      isLive: isLive,
      durationMinutes: duration,
      startTime: parseDate(json["startTime"] ?? json["start_time"]),
      endTime: parseDate(json["endTime"] ?? json["end_time"]),
      comment: json["comment"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "latitude": latitude,
      "longitude": longitude,
      "locationName": locationName,
      if (address != null) "address": address,
      "isLive": isLive,
      if (durationMinutes != null) "durationMinutes": durationMinutes,
      if (startTime != null) "startTime": startTime!.toIso8601String(),
      if (endTime != null) "endTime": endTime!.toIso8601String(),
      if (comment != null && comment!.trim().isNotEmpty) "comment": comment,
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
