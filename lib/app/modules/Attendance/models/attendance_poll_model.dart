import 'dart:convert';

import 'package:intl/intl.dart';

import '../../../Core/constant/const_res.dart';

int _toInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? "") ?? fallback;
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

String? _nonEmpty(dynamic value) {
  final str = value?.toString().trim();
  return (str == null || str.isEmpty || str == "null") ? null : str;
}

/// Builds a full URL from the relative paths the attendance API returns
/// (e.g. "uploads/Attendance/Photos/xxx.jpg"). Local file paths and absolute
/// URLs are returned unchanged.
String? attendanceMediaUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith("http://") || path.startsWith("https://")) return path;
  if (path.startsWith("/data/") || path.startsWith("/storage/") ||
      path.startsWith("/var/") || path.startsWith("/private/")) {
    return path;
  }
  final clean = path.startsWith("/") ? path.substring(1) : path;
  return "${ConstRes.aImageBaseUrl}$clean";
}

class AttendanceMemberResponse {
  final String userId;
  final String userName;
  final String? profileImage;

  /// "Present" / "Absent" (or another option label). Null when not responded.
  final String? response;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final DateTime? markedAt;
  final bool hasResponded;

  AttendanceMemberResponse({
    required this.userId,
    required this.userName,
    this.profileImage,
    this.response,
    this.photoUrl,
    this.latitude,
    this.longitude,
    this.locationName,
    this.markedAt,
    this.hasResponded = false,
  });

  /// Status label shown in the UI.
  String get status =>
      hasResponded ? (response ?? "Absent") : "Not responded";

  bool get isPresent => hasResponded && response?.toLowerCase() == "present";

  bool get hasLocation => latitude != null && longitude != null;

  String get time =>
      markedAt != null ? DateFormat("hh:mm a").format(markedAt!) : "";

  String? get location => locationName;

  String? get photoFullUrl => attendanceMediaUrl(photoUrl);

  String? get profileImageUrl => attendanceMediaUrl(profileImage);

  factory AttendanceMemberResponse.fromJson(Map<String, dynamic> json) {
    final response = _nonEmpty(json["response"]);
    return AttendanceMemberResponse(
      userId: json["userId"]?.toString() ?? "",
      userName: _nonEmpty(json["name"]) ?? _nonEmpty(json["userName"]) ?? "Member",
      profileImage: _nonEmpty(json["profileImage"]),
      response: response,
      photoUrl: _nonEmpty(json["photoUrl"]),
      latitude: _toDouble(json["latitude"]),
      longitude: _toDouble(json["longitude"]),
      locationName: _nonEmpty(json["locationName"]),
      markedAt: DateTime.tryParse(json["markedAt"]?.toString() ?? "")?.toLocal(),
      hasResponded: json["hasResponded"] is bool
          ? json["hasResponded"] as bool
          : json["markedAt"] != null,
    );
  }
}

class AttendancePollData {
  final int attendanceId;
  final int? groupId;
  final String question;

  /// ISO date "YYYY-MM-DD" as sent by the backend.
  final String date;
  final List<String> options;
  final bool isActive;
  final int totalMembers;
  final int presentCount;
  final int absentCount;
  final int respondedCount;

  /// Current user's response (null if not responded yet).
  final String? userResponse;

  /// Photo the current user submitted. Only known locally right after marking,
  /// since the message API does not return it.
  final String? userPhotoUrl;
  final List<AttendanceMemberResponse> responses;

  AttendancePollData({
    required this.attendanceId,
    this.groupId,
    this.question = "",
    this.date = "",
    this.options = const ["Present", "Absent"],
    this.isActive = true,
    this.totalMembers = 0,
    this.presentCount = 0,
    this.absentCount = 0,
    this.respondedCount = 0,
    this.userResponse,
    this.userPhotoUrl,
    this.responses = const [],
  });

  /// "11 Sep" style label for the card header.
  String get shortDate {
    final parsed = DateTime.tryParse(date);
    return parsed != null ? DateFormat("dd MMM").format(parsed) : date;
  }

  /// "11 Sep 2026, Fri" style label for subtitles.
  String get longDate {
    final parsed = DateTime.tryParse(date);
    return parsed != null ? DateFormat("dd MMM yyyy, EEE").format(parsed) : date;
  }

  factory AttendancePollData.fromJson(Map<String, dynamic> json) {
    final rawOptions = json["options"];
    final options = rawOptions is List
        ? rawOptions.map((e) => e.toString()).toList()
        : const ["Present", "Absent"];

    final rawMembers = json["members"];
    final members = <AttendanceMemberResponse>[];
    if (rawMembers is List) {
      for (final m in rawMembers) {
        if (m is Map) {
          members.add(
            AttendanceMemberResponse.fromJson(Map<String, dynamic>.from(m)),
          );
        }
      }
    }

    return AttendancePollData(
      attendanceId: _toInt(json["attendanceId"] ?? json["id"]),
      groupId: json["groupId"] != null ? _toInt(json["groupId"]) : null,
      question: json["question"]?.toString() ?? "",
      date: json["date"]?.toString() ?? "",
      options: options.isEmpty ? const ["Present", "Absent"] : options,
      isActive: json["isActive"] is bool ? json["isActive"] as bool : true,
      totalMembers: _toInt(json["totalMembers"]),
      presentCount: _toInt(json["presentCount"]),
      absentCount: _toInt(json["absentCount"]),
      respondedCount: _toInt(json["respondedCount"]),
      userResponse: _nonEmpty(json["userResponse"]),
      responses: members,
    );
  }

  /// Parses the `content` of an attendance chat message:
  /// {"attendanceId":1,"question":"...","date":"2026-09-11","options":[...]}
  /// Returns null when the content has no attendance ID.
  static AttendancePollData? fromMessageContent(dynamic content) {
    try {
      final decoded = content is Map ? content : jsonDecode(content.toString());
      if (decoded is Map) {
        final data = AttendancePollData.fromJson(
          Map<String, dynamic>.from(decoded),
        );
        if (data.attendanceId > 0) return data;
      }
    } catch (_) {}
    return null;
  }

  AttendancePollData copyWith({
    String? question,
    String? date,
    List<String>? options,
    bool? isActive,
    int? totalMembers,
    int? presentCount,
    int? absentCount,
    int? respondedCount,
    String? userResponse,
    String? userPhotoUrl,
    List<AttendanceMemberResponse>? responses,
  }) {
    return AttendancePollData(
      attendanceId: attendanceId,
      groupId: groupId,
      question: question ?? this.question,
      date: date ?? this.date,
      options: options ?? this.options,
      isActive: isActive ?? this.isActive,
      totalMembers: totalMembers ?? this.totalMembers,
      presentCount: presentCount ?? this.presentCount,
      absentCount: absentCount ?? this.absentCount,
      respondedCount: respondedCount ?? this.respondedCount,
      userResponse: userResponse ?? this.userResponse,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      responses: responses ?? this.responses,
    );
  }

  /// Merges fresher data from the API while keeping fields only known locally
  /// (the user's own submitted photo, and question/date when the update
  /// payload omits them, e.g. `attendance_updated`).
  AttendancePollData mergeFrom(AttendancePollData other) {
    return AttendancePollData(
      attendanceId: attendanceId,
      groupId: other.groupId ?? groupId,
      question: other.question.isNotEmpty ? other.question : question,
      date: other.date.isNotEmpty ? other.date : date,
      options: other.options,
      isActive: other.isActive,
      totalMembers: other.totalMembers,
      presentCount: other.presentCount,
      absentCount: other.absentCount,
      respondedCount: other.respondedCount,
      userResponse: other.userResponse ?? userResponse,
      userPhotoUrl: other.userPhotoUrl ?? userPhotoUrl,
      responses: other.responses.isNotEmpty ? other.responses : responses,
    );
  }
}
