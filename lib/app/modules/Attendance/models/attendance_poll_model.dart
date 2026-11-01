import 'dart:convert';
import 'dart:ui';

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

DateTime? _toDate(dynamic value) =>
    DateTime.tryParse(value?.toString() ?? "")?.toLocal();

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is String && value.trim().startsWith("{")) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
  }
  return null;
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

Color? _parseHexColor(String? hex) {
  if (hex == null) return null;
  var value = hex.replaceFirst("#", "");
  if (value.length == 6) value = "FF$value";
  final parsed = int.tryParse(value, radix: 16);
  return parsed != null ? Color(parsed) : null;
}

class AttendanceOption {
  final String id;
  final String label;
  final int order;
  final String? color;
  final String? icon;

  const AttendanceOption({
    required this.id,
    required this.label,
    this.order = 0,
    this.color,
    this.icon,
  });

  /// Option color from the API, falling back to green/red for
  /// Present/Absent-style labels and the app accent otherwise.
  Color get displayColor {
    final parsed = _parseHexColor(color);
    if (parsed != null) return parsed;
    final l = label.toLowerCase();
    if (l == "present") return const Color(0xFF22C55E);
    if (l == "absent") return const Color(0xFFEF4444);
    return const Color(0xFF5A3EFE);
  }

  factory AttendanceOption.fromJson(Map<String, dynamic> json) =>
      AttendanceOption(
        id: json["id"]?.toString() ?? "",
        label: json["label"]?.toString() ?? "",
        order: _toInt(json["order"]),
        color: _nonEmpty(json["color"]),
        icon: _nonEmpty(json["icon"]),
      );
}

class AttendanceLocation {
  final double? lat;
  final double? lng;
  final String? name;
  final double? accuracy;

  const AttendanceLocation({this.lat, this.lng, this.name, this.accuracy});

  bool get hasCoordinates => lat != null && lng != null;

  static AttendanceLocation? fromJson(dynamic raw) {
    final json = _asMap(raw);
    if (json == null) return null;
    final loc = AttendanceLocation(
      lat: _toDouble(json["lat"] ?? json["latitude"]),
      lng: _toDouble(json["lng"] ?? json["longitude"]),
      name: _nonEmpty(json["name"] ?? json["locationName"]),
      accuracy: _toDouble(json["accuracy"]),
    );
    return (loc.hasCoordinates || loc.name != null) ? loc : null;
  }
}

/// The current user's vote (`myVote`).
class AttendanceVote {
  final String optionId;
  final DateTime? votedAt;
  final String? photoUrl;
  final AttendanceLocation? location;

  const AttendanceVote({
    required this.optionId,
    this.votedAt,
    this.photoUrl,
    this.location,
  });

  String? get photoFullUrl => attendanceMediaUrl(photoUrl);

  static AttendanceVote? fromJson(dynamic raw) {
    final json = _asMap(raw);
    final optionId = _nonEmpty(json?["optionId"]);
    if (json == null || optionId == null) return null;
    return AttendanceVote(
      optionId: optionId,
      votedAt: _toDate(json["votedAt"]),
      photoUrl: _nonEmpty(json["photoUrl"]),
      location: AttendanceLocation.fromJson(json["location"]),
    );
  }
}

/// A row in the voters list (admin detail screen).
class AttendanceVoter {
  final String userId;
  final String name;
  final String? profileImage;
  final String? optionId;
  final String? optionLabel;
  final DateTime? votedAt;
  final String? photoUrl;
  final AttendanceLocation? location;

  const AttendanceVoter({
    required this.userId,
    required this.name,
    this.profileImage,
    this.optionId,
    this.optionLabel,
    this.votedAt,
    this.photoUrl,
    this.location,
  });

  bool get hasVoted => optionId != null;

  String get time =>
      votedAt != null ? DateFormat("hh:mm a").format(votedAt!) : "";

  String? get photoFullUrl => attendanceMediaUrl(photoUrl);

  String? get profileImageUrl => attendanceMediaUrl(profileImage);

  factory AttendanceVoter.fromJson(Map<String, dynamic> json) =>
      AttendanceVoter(
        userId: json["userId"]?.toString() ?? "",
        name: _nonEmpty(json["name"]) ?? "Member",
        profileImage: _nonEmpty(json["profileImage"]),
        optionId: _nonEmpty(json["optionId"]),
        optionLabel: _nonEmpty(json["optionLabel"]),
        votedAt: _toDate(json["votedAt"]),
        photoUrl: _nonEmpty(json["photoUrl"]),
        location: AttendanceLocation.fromJson(json["location"]),
      );
}

class AttendancePoll {
  final int id;
  final int? groupId;
  final int? messageId;
  final String title;
  final String? description;

  /// "YYYY-MM-DD"
  final String? eventDate;
  final String? eventTime;
  final String? location;
  final List<AttendanceOption> options;
  final String? photoRequiredOptionId;
  final bool allowVoteChange;
  final String voterVisibility;
  final DateTime? deadlineAt;

  /// "open" | "closed"
  final String status;
  final int totalVotes;
  final Map<String, int> countsByOption;
  final int version;
  final String? createdBy;
  final DateTime? createdAt;
  final AttendanceVote? myVote;

  const AttendancePoll({
    required this.id,
    this.groupId,
    this.messageId,
    this.title = "",
    this.description,
    this.eventDate,
    this.eventTime,
    this.location,
    this.options = const [],
    this.photoRequiredOptionId,
    this.allowVoteChange = true,
    this.voterVisibility = "admin",
    this.deadlineAt,
    this.status = "open",
    this.totalVotes = 0,
    this.countsByOption = const {},
    this.version = 0,
    this.createdBy,
    this.createdAt,
    this.myVote,
  });

  bool get isOpen => status == "open";

  bool get isClosed => !isOpen;

  int countFor(String optionId) => countsByOption[optionId] ?? 0;

  AttendanceOption? optionById(String? optionId) {
    for (final o in options) {
      if (o.id == optionId) return o;
    }
    return null;
  }

  bool requiresPhoto(String? optionId) =>
      optionId != null && optionId == photoRequiredOptionId;

  /// "11 Sep" style label.
  String get shortDate {
    final parsed = DateTime.tryParse(eventDate ?? "");
    return parsed != null ? DateFormat("dd MMM").format(parsed) : "";
  }

  /// "11 Sep 2026" style label.
  String get longDate {
    final parsed = DateTime.tryParse(eventDate ?? "");
    return parsed != null ? DateFormat("dd MMM yyyy").format(parsed) : "";
  }

  /// Parses a poll summary. Accepts `{poll, myVote}` envelopes or a bare poll.
  static AttendancePoll? fromJson(dynamic raw) {
    final outer = _asMap(raw);
    if (outer == null) return null;
    final json = _asMap(outer["poll"]) ?? outer;
    final id = _toInt(json["id"] ?? json["pollId"]);
    if (id <= 0) return null;

    final rawOptions = json["options"];
    final options = <AttendanceOption>[];
    if (rawOptions is List) {
      for (final o in rawOptions) {
        final m = _asMap(o);
        if (m != null) options.add(AttendanceOption.fromJson(m));
      }
    }
    options.sort((a, b) => a.order.compareTo(b.order));

    final counts = _asMap(json["counts"]) ?? const {};
    final byOption = <String, int>{};
    final rawByOption = _asMap(counts["byOption"]);
    rawByOption?.forEach((k, v) => byOption[k] = _toInt(v));

    return AttendancePoll(
      id: id,
      groupId: json["groupId"] != null ? _toInt(json["groupId"]) : null,
      messageId: json["messageId"] != null ? _toInt(json["messageId"]) : null,
      title: json["title"]?.toString() ?? "",
      description: _nonEmpty(json["description"]),
      eventDate: _nonEmpty(json["eventDate"]),
      eventTime: _nonEmpty(json["eventTime"]),
      location: _nonEmpty(json["location"]),
      options: options,
      photoRequiredOptionId: _nonEmpty(json["photoRequiredOptionId"]),
      allowVoteChange: json["allowVoteChange"] is bool
          ? json["allowVoteChange"] as bool
          : true,
      voterVisibility: json["voterVisibility"]?.toString() ?? "admin",
      deadlineAt: _toDate(json["deadlineAt"]),
      status: json["status"]?.toString() ?? "open",
      totalVotes: _toInt(counts["total"]),
      countsByOption: byOption,
      version: _toInt(json["version"]),
      createdBy: _nonEmpty(json["createdBy"]),
      createdAt: _toDate(json["createdAt"]),
      myVote: AttendanceVote.fromJson(outer["myVote"] ?? json["myVote"]),
    );
  }

  AttendancePoll copyWith({
    String? status,
    int? totalVotes,
    Map<String, int>? countsByOption,
    int? version,
    AttendanceVote? myVote,
    bool clearMyVote = false,
  }) {
    return AttendancePoll(
      id: id,
      groupId: groupId,
      messageId: messageId,
      title: title,
      description: description,
      eventDate: eventDate,
      eventTime: eventTime,
      location: location,
      options: options,
      photoRequiredOptionId: photoRequiredOptionId,
      allowVoteChange: allowVoteChange,
      voterVisibility: voterVisibility,
      deadlineAt: deadlineAt,
      status: status ?? this.status,
      totalVotes: totalVotes ?? this.totalVotes,
      countsByOption: countsByOption ?? this.countsByOption,
      version: version ?? this.version,
      createdBy: createdBy,
      createdAt: createdAt,
      myVote: clearMyVote ? null : (myVote ?? this.myVote),
    );
  }

  /// Applies a server snapshot. Group broadcasts don't carry `myVote`, so the
  /// local one is kept unless the snapshot has its own.
  AttendancePoll mergeServer(AttendancePoll server, {bool hasMyVoteField = false}) {
    return AttendancePoll(
      id: id,
      groupId: server.groupId ?? groupId,
      messageId: server.messageId ?? messageId,
      title: server.title.isNotEmpty ? server.title : title,
      description: server.description ?? description,
      eventDate: server.eventDate ?? eventDate,
      eventTime: server.eventTime ?? eventTime,
      location: server.location ?? location,
      options: server.options.isNotEmpty ? server.options : options,
      photoRequiredOptionId:
          server.photoRequiredOptionId ?? photoRequiredOptionId,
      allowVoteChange: server.allowVoteChange,
      voterVisibility: server.voterVisibility,
      deadlineAt: server.deadlineAt ?? deadlineAt,
      status: server.status,
      totalVotes: server.totalVotes,
      countsByOption: server.countsByOption,
      version: server.version,
      createdBy: server.createdBy ?? createdBy,
      createdAt: server.createdAt ?? createdAt,
      myVote: hasMyVoteField ? server.myVote : (server.myVote ?? myVote),
    );
  }
}
