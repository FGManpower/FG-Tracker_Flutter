import 'dart:convert';

import 'package:fgtracker/app/Model/LocationMessage.dart';

enum SharePayloadKind {
  text,
  link,
  image,
  video,
  audio,
  file,
  location,
}

class ShareFileItem {
  const ShareFileItem({
    required this.path,
    this.name,
    this.mimeType,
    this.sizeBytes,
  });

  final String path;
  final String? name;
  final String? mimeType;
  final int? sizeBytes;

  String get displayName {
    final trimmed = name?.trim() ?? '';
    if (trimmed.isNotEmpty) return trimmed;
    final parts = path.split(RegExp(r'[\\/]'));
    return parts.isNotEmpty ? parts.last : 'file';
  }

  Map<String, dynamic> toJson() => {
        'path': path,
        if (name != null) 'name': name,
        if (mimeType != null) 'mimeType': mimeType,
        if (sizeBytes != null) 'sizeBytes': sizeBytes,
      };

  factory ShareFileItem.fromJson(Map<String, dynamic> json) {
    return ShareFileItem(
      path: json['path']?.toString() ?? '',
      name: json['name']?.toString(),
      mimeType: json['mimeType']?.toString(),
      sizeBytes: json['sizeBytes'] is int
          ? json['sizeBytes'] as int
          : int.tryParse(json['sizeBytes']?.toString() ?? ''),
    );
  }
}

class ShareLocationData {
  const ShareLocationData({
    required this.latitude,
    required this.longitude,
    this.locationName,
    this.address,
    this.groupId,
    this.groupName,
  });

  final double latitude;
  final double longitude;
  final String? locationName;
  final String? address;
  final String? groupId;
  final String? groupName;

  String get mapsUrl => 'https://maps.google.com/?q=$latitude,$longitude';

  LocationMessage toLocationMessage() {
    return LocationMessage(
      latitude: latitude,
      longitude: longitude,
      locationName: (locationName != null && locationName!.trim().isNotEmpty)
          ? locationName!.trim()
          : 'FG Tracker Location',
      address: (address != null && address!.trim().isNotEmpty)
          ? address!.trim()
          : mapsUrl,
      isLive: false,
      comment: (groupName != null && groupName!.trim().isNotEmpty)
          ? 'Group: ${groupName!.trim()}'
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        if (locationName != null) 'locationName': locationName,
        if (address != null) 'address': address,
        if (groupId != null) 'groupId': groupId,
        if (groupName != null) 'groupName': groupName,
      };

  factory ShareLocationData.fromJson(Map<String, dynamic> json) {
    return ShareLocationData(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      locationName: json['locationName']?.toString(),
      address: json['address']?.toString(),
      groupId: json['groupId']?.toString(),
      groupName: json['groupName']?.toString(),
    );
  }
}

class SharePayload {
  const SharePayload({
    required this.kind,
    this.text,
    this.url,
    this.files = const [],
    this.location,
    this.source = 'external',
    this.createdAtMs,
  });

  final SharePayloadKind kind;
  final String? text;
  final String? url;
  final List<ShareFileItem> files;
  final ShareLocationData? location;
  final String source;
  final int? createdAtMs;

  bool get isEmpty {
    final hasText = (text ?? '').trim().isNotEmpty;
    final hasUrl = (url ?? '').trim().isNotEmpty;
    final hasFiles = files.any((f) => f.path.trim().isNotEmpty);
    final hasLocation = location != null &&
        (location!.latitude != 0.0 || location!.longitude != 0.0);
    return !hasText && !hasUrl && !hasFiles && !hasLocation;
  }

  String get combinedText {
    final t = (text ?? '').trim();
    final u = (url ?? '').trim();
    if (t.isNotEmpty && u.isNotEmpty) {
      if (t.contains(u)) return t;
      return '$t\n$u';
    }
    if (u.isNotEmpty) return u;
    if (t.isNotEmpty) return t;
    if (location != null) {
      final parts = <String>[
        if ((location!.locationName ?? '').trim().isNotEmpty)
          location!.locationName!.trim(),
        if ((location!.address ?? '').trim().isNotEmpty)
          location!.address!.trim(),
        location!.mapsUrl,
      ];
      return parts.join('\n');
    }
    return '';
  }

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        if (text != null) 'text': text,
        if (url != null) 'url': url,
        'files': files.map((f) => f.toJson()).toList(),
        if (location != null) 'location': location!.toJson(),
        'source': source,
        'createdAtMs': createdAtMs ?? DateTime.now().millisecondsSinceEpoch,
      };

  String toJsonString() => jsonEncode(toJson());

  factory SharePayload.fromJsonString(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Invalid share payload JSON');
    }
    return SharePayload.fromJson(Map<String, dynamic>.from(decoded));
  }

  factory SharePayload.fromJson(Map<String, dynamic> json) {
    final kindRaw = json['kind']?.toString().toLowerCase() ?? 'text';
    final kind = SharePayloadKind.values.firstWhere(
      (k) => k.name == kindRaw,
      orElse: () => SharePayloadKind.text,
    );

    final rawFiles = json['files'];
    final parsedFiles = <ShareFileItem>[];
    if (rawFiles is List) {
      for (final item in rawFiles) {
        if (item is Map) {
          final parsed =
              ShareFileItem.fromJson(Map<String, dynamic>.from(item));
          if (parsed.path.trim().isNotEmpty) {
            parsedFiles.add(parsed);
          }
        }
      }
    }

    ShareLocationData? loc;
    if (json['location'] is Map) {
      loc = ShareLocationData.fromJson(
        Map<String, dynamic>.from(json['location'] as Map),
      );
    }

    return SharePayload(
      kind: kind,
      text: json['text']?.toString(),
      url: json['url']?.toString(),
      files: parsedFiles,
      location: loc,
      source: json['source']?.toString() ?? 'external',
      createdAtMs: json['createdAtMs'] is int
          ? json['createdAtMs'] as int
          : int.tryParse(json['createdAtMs']?.toString() ?? ''),
    );
  }

  /// Normalizes a raw map received from native Android/iOS share channels.
  factory SharePayload.fromNativeMap(Map<dynamic, dynamic> raw) {
    final normalized = Map<String, dynamic>.from(
      raw.map((k, v) => MapEntry(k.toString(), v)),
    );
    final payload = SharePayload.fromJson(normalized);
    if (payload.kind == SharePayloadKind.text &&
        (payload.url ?? '').trim().isEmpty &&
        (payload.text ?? '').trim().isNotEmpty) {
      final t = payload.text!.trim();
      final uri = Uri.tryParse(t);
      if (uri != null &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          !t.contains(' ')) {
        return SharePayload(
          kind: SharePayloadKind.link,
          text: t,
          url: t,
          files: payload.files,
          source: payload.source,
          createdAtMs: payload.createdAtMs,
        );
      }
    }
    return payload;
  }
}
