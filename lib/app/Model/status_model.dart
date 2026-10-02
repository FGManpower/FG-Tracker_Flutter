import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:flutter/material.dart';

String? _resolveFullUrl(String? path) {
  if (path == null || path.trim().isEmpty) return null;
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  final base = ConstRes.socketUrl.replaceAll(RegExp(r'/$'), '');
  final normalizedPath = path.startsWith('/') ? path : '/$path';
  return '$base$normalizedPath';
}

class StatusCreateRes {
  final bool status;
  final String? message;
  final StatusItemModel? data;

  StatusCreateRes({
    required this.status,
    this.message,
    this.data,
  });

  factory StatusCreateRes.fromJson(Map<String, dynamic> json) {
    return StatusCreateRes(
      status: json['status'] == true,
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? StatusItemModel.fromJson(json['data'])
          : null,
    );
  }
}

class StatusFeedRes {
  final bool status;
  final String? message;
  final List<ContactStatusGroupModel> data;

  StatusFeedRes({
    required this.status,
    this.message,
    required this.data,
  });

  factory StatusFeedRes.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final rawList = json['data'] as List<dynamic>? ?? [];
      return StatusFeedRes(
        status: json['status'] == true,
        message: json['message']?.toString(),
        data: rawList
            .whereType<Map<String, dynamic>>()
            .map(ContactStatusGroupModel.fromJson)
            .toList(),
      );
    }
    return StatusFeedRes(status: false, data: []);
  }
}

class MyStatusRes {
  final bool status;
  final String? message;
  final List<StatusItemModel> data;

  MyStatusRes({
    required this.status,
    this.message,
    required this.data,
  });

  factory MyStatusRes.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final rawList = json['data'] as List<dynamic>? ?? [];
      return MyStatusRes(
        status: json['status'] == true,
        message: json['message']?.toString(),
        data: rawList
            .whereType<Map<String, dynamic>>()
            .map(StatusItemModel.fromJson)
            .toList(),
      );
    }
    return MyStatusRes(status: false, data: []);
  }
}

class StatusViewerModel {
  final int viewerId;
  final String name;
  final String? profileImage;
  final String? reactionEmoji;
  final DateTime? viewedAt;

  StatusViewerModel({
    required this.viewerId,
    required this.name,
    this.profileImage,
    this.reactionEmoji,
    this.viewedAt,
  });

  factory StatusViewerModel.fromJson(Map<String, dynamic> json) {
    return StatusViewerModel(
      viewerId: int.tryParse(json['viewerId']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? 'User',
      profileImage: _resolveFullUrl(json['profileImage']?.toString()),
      reactionEmoji: json['reactionEmoji']?.toString(),
      viewedAt: json['viewedAt'] != null
          ? DateTime.tryParse(json['viewedAt'].toString())
          : null,
    );
  }
}

class StatusItemModel {
  final int id;
  final int? userId;
  final String type;
  final String content;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String backgroundColor;
  final String fontStyle;
  final int durationSeconds;
  final String privacyType;
  final bool isViewed;
  final int viewsCount;
  final String? myReaction;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final List<StatusViewerModel> viewers;

  StatusItemModel({
    required this.id,
    this.userId,
    required this.type,
    required this.content,
    this.mediaUrl,
    this.thumbnailUrl,
    required this.backgroundColor,
    required this.fontStyle,
    required this.durationSeconds,
    required this.privacyType,
    required this.isViewed,
    required this.viewsCount,
    this.myReaction,
    this.expiresAt,
    required this.createdAt,
    required this.viewers,
  });

  factory StatusItemModel.fromJson(Map<String, dynamic> json) {
    final rawViewers = json['viewers'] as List<dynamic>? ?? [];
    return StatusItemModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['userId']?.toString() ?? ''),
      type: (json['type'] ?? 'image').toString().toLowerCase(),
      content: json['content']?.toString() ?? '',
      mediaUrl: _resolveFullUrl(json['mediaUrl']?.toString()),
      thumbnailUrl: _resolveFullUrl(json['thumbnailUrl']?.toString()),
      backgroundColor: json['backgroundColor']?.toString() ?? '#6B4DFF',
      fontStyle: json['fontStyle']?.toString() ?? 'default',
      durationSeconds:
      int.tryParse(json['durationSeconds']?.toString() ?? '') ?? 5,
      privacyType: json['privacyType']?.toString() ?? 'ALL_CONTACTS',
      isViewed: json['isViewed'] == true,
      viewsCount: int.tryParse(json['viewsCount']?.toString() ?? '') ??
          rawViewers.length,
      myReaction: json['reactionEmoji']?.toString(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())?.toLocal() ??
          DateTime.now()
          : DateTime.now(),
      viewers: rawViewers
          .whereType<Map<String, dynamic>>()
          .map(StatusViewerModel.fromJson)
          .toList(),
    );
  }

  StatusItemModel copyWith({
    bool? isViewed,
    int? viewsCount,
    String? myReaction,
    List<StatusViewerModel>? viewers,
  }) {
    return StatusItemModel(
      id: id,
      userId: userId,
      type: type,
      content: content,
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      backgroundColor: backgroundColor,
      fontStyle: fontStyle,
      durationSeconds: durationSeconds,
      privacyType: privacyType,
      isViewed: isViewed ?? this.isViewed,
      viewsCount: viewsCount ?? this.viewsCount,
      myReaction: myReaction ?? this.myReaction,
      expiresAt: expiresAt,
      createdAt: createdAt,
      viewers: viewers ?? this.viewers,
    );
  }

  Color get parsedBgColor {
    if (backgroundColor.isEmpty) return const Color(0xFF6B4DFF);
    final cleaned = backgroundColor.replaceFirst('#', '');
    final hex = cleaned.length == 6 ? 'FF$cleaned' : cleaned;
    final value = int.tryParse(hex, radix: 16);
    return value != null ? Color(value) : const Color(0xFF6B4DFF);
  }

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    final hour = createdAt.hour > 12
        ? createdAt.hour - 12
        : (createdAt.hour == 0 ? 12 : createdAt.hour);
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final period = createdAt.hour >= 12 ? 'PM' : 'AM';
    final dayPrefix =
    (now.day == createdAt.day && now.month == createdAt.month)
        ? 'Today'
        : 'Yesterday';
    return '$dayPrefix, $hour:$minute $period';
  }
}

class StatusCreatorUser {
  final int id;
  final String name;
  final String? profilePic;

  StatusCreatorUser({
    required this.id,
    required this.name,
    this.profilePic,
  });

  factory StatusCreatorUser.fromJson(Map<String, dynamic> json) {
    return StatusCreatorUser(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? 'User',
      profilePic: _resolveFullUrl(json['profilePic']?.toString()),
    );
  }
}

class ContactStatusGroupModel {
  final StatusCreatorUser user;
  final bool isAllViewed;
  final DateTime latestTimestamp;
  final List<StatusItemModel> statuses;

  ContactStatusGroupModel({
    required this.user,
    required this.isAllViewed,
    required this.latestTimestamp,
    required this.statuses,
  });

  factory ContactStatusGroupModel.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : <String, dynamic>{};
    final rawStatuses = json['statuses'] as List<dynamic>? ?? [];

    return ContactStatusGroupModel(
      user: StatusCreatorUser.fromJson(userMap),
      isAllViewed: json['isAllViewed'] == true,
      latestTimestamp: json['latestTimestamp'] != null
          ? DateTime.tryParse(json['latestTimestamp'].toString())?.toLocal() ??
          DateTime.now()
          : DateTime.now(),
      statuses: rawStatuses
          .whereType<Map<String, dynamic>>()
          .map(StatusItemModel.fromJson)
          .toList(),
    );
  }

  Color get ringColor =>
      isAllViewed ? const Color(0xFF9CA3AF) : const Color(0xFF22C55E);
}