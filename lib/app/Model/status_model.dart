import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:flutter/material.dart';

String? _resolveFullUrl(String? path) {
  if (path == null || path.trim().isEmpty) return null;
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  final base = ConstRes.socketUrl.replaceAll(RegExp(r'/$'), '');
  final cleanPath = path.trim().replaceFirst(RegExp(r'^/+'), '');
  return '$base/$cleanPath';
}

String? _resolveProfileUrl(String? path) {
  if (path == null || path.trim().isEmpty) return null;
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  final cleanPath = path.trim().replaceFirst(RegExp(r'^/+'), '');
  if (cleanPath.startsWith('uploads/')) {
    return _resolveFullUrl(cleanPath);
  }
  return _resolveFullUrl('uploads/Auth/$cleanPath');
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
    final userObj = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : null;

    final viewerId = int.tryParse(
      (json['viewerId'] ?? json['userId'] ?? json['id'] ?? userObj?['id'])
          ?.toString() ??
          '',
    ) ??
        0;

    final name = (json['name'] ??
        json['userName'] ??
        json['Name'] ??
        userObj?['name'] ??
        userObj?['Name'])
        ?.toString() ??
        'User';

    final rawPic = (json['profileImage'] ??
        json['profilePic'] ??
        json['avatar'] ??
        userObj?['profilePic'] ??
        userObj?['profileImage'])
        ?.toString();

    final reaction = (json['reactionEmoji'] ??
        json['myReaction'] ??
        json['emoji'])
        ?.toString();

    final timeStr = (json['viewedAt'] ??
        json['createdAt'] ??
        json['updatedAt'])
        ?.toString();

    return StatusViewerModel(
      viewerId: viewerId,
      name: name,
      profileImage: _resolveProfileUrl(rawPic),
      reactionEmoji: reaction,
      viewedAt: timeStr != null ? DateTime.tryParse(timeStr) : null,
    );
  }
}

class StatusMetaModel {
  final int? statusId;
  final String type;
  final String? mediaUrl;
  final String? thumbnail;
  final String? ownerName;

  StatusMetaModel({
    this.statusId,
    this.type = 'text',
    this.mediaUrl,
    this.thumbnail,
    this.ownerName,
  });

  factory StatusMetaModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return StatusMetaModel();
    }
    return StatusMetaModel(
      statusId: int.tryParse(json['statusId']?.toString() ?? ''),
      type: (json['type'] ?? 'text').toString().toLowerCase(),
      mediaUrl: _resolveFullUrl(json['mediaUrl']?.toString()),
      thumbnail: _resolveFullUrl(
        (json['thumbnail'] ?? json['thumbnailUrl'])?.toString(),
      ),
      ownerName: json['ownerName']?.toString(),
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
  final bool isDeleted;
  final List<StatusViewerModel> viewers;
  final StatusCreatorUser? creator;

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
    this.isDeleted = false,
    required this.viewers,
    this.creator,
  });

  bool get isExpired {
    if (isDeleted) return true;
    if (expiresAt == null) return false;
    return DateTime.now().toUtc().isAfter(expiresAt!.toUtc());
  }

  bool get isVideo {
    final lowerType = type.toLowerCase();
    final lowerUrl = (mediaUrl ?? '').toLowerCase();
    return lowerType == 'video' ||
        lowerUrl.endsWith('.mp4') ||
        lowerUrl.endsWith('.mov') ||
        lowerUrl.endsWith('.mkv') ||
        lowerUrl.endsWith('.webm');
  }

  bool get isImage {
    final lowerType = type.toLowerCase();
    return lowerType == 'image' || lowerType == 'photo';
  }

  bool get isText => type.toLowerCase() == 'text';

  factory StatusItemModel.fromJson(Map<String, dynamic> json) {
    final rawViewers = json['viewers'] as List<dynamic>? ?? [];

    StatusCreatorUser? creator;
    if (json['creator'] is Map<String, dynamic>) {
      creator = StatusCreatorUser.fromJson(json['creator']);
    } else if (json['user'] is Map<String, dynamic>) {
      creator = StatusCreatorUser.fromJson(json['user']);
    }

    final resolvedUserId = int.tryParse(json['userId']?.toString() ?? '') ??
        creator?.id;

    return StatusItemModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: resolvedUserId,
      type: (json['type'] ?? 'image').toString().toLowerCase(),
      content: json['content']?.toString() ?? '',
      mediaUrl: _resolveFullUrl(json['mediaUrl']?.toString()),
      thumbnailUrl: _resolveFullUrl(
        (json['thumbnailUrl'] ?? json['thumbnail'])?.toString(),
      ),
      backgroundColor: json['backgroundColor']?.toString() ?? '#6B4DFF',
      fontStyle: json['fontStyle']?.toString() ?? 'default',
      durationSeconds:
      int.tryParse(json['durationSeconds']?.toString() ?? '') ?? 5,
      privacyType: json['privacyType']?.toString() ?? 'ALL_CONTACTS',
      isViewed: json['isViewed'] == true,
      viewsCount: int.tryParse(json['viewsCount']?.toString() ?? '') ??
          rawViewers.length,
      myReaction: (json['reactionEmoji'] ?? json['myReaction'])?.toString(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())?.toLocal() ??
          DateTime.now()
          : DateTime.now(),
      isDeleted: json['isDeleted'] == true,
      viewers: rawViewers
          .whereType<Map<String, dynamic>>()
          .map(StatusViewerModel.fromJson)
          .toList(),
      creator: creator,
    );
  }

  factory StatusItemModel.fromReplyStatus(
      Map<String, dynamic> json, {
        StatusMetaModel? meta,
      }) {
    final item = StatusItemModel.fromJson(json);
    if (item.creator != null || meta?.ownerName == null) return item;

    return StatusItemModel(
      id: item.id,
      userId: item.userId,
      type: item.type,
      content: item.content,
      mediaUrl: item.mediaUrl ?? meta?.mediaUrl,
      thumbnailUrl: item.thumbnailUrl ?? meta?.thumbnail,
      backgroundColor: item.backgroundColor,
      fontStyle: item.fontStyle,
      durationSeconds: item.durationSeconds,
      privacyType: item.privacyType,
      isViewed: item.isViewed,
      viewsCount: item.viewsCount,
      myReaction: item.myReaction,
      expiresAt: item.expiresAt,
      createdAt: item.createdAt,
      isDeleted: item.isDeleted,
      viewers: item.viewers,
      creator: StatusCreatorUser(
        id: item.userId ?? meta?.statusId ?? 0,
        name: meta?.ownerName ?? 'User',
        profilePic: null,
      ),
    );
  }

  factory StatusItemModel.fromStatusMeta(
      StatusMetaModel meta, {
        String? content,
        String? backgroundColor,
      }) {
    return StatusItemModel(
      id: meta.statusId ?? 0,
      userId: null,
      type: meta.type,
      content: content ?? '',
      mediaUrl: meta.mediaUrl,
      thumbnailUrl: meta.thumbnail,
      backgroundColor: backgroundColor ?? '#6B4DFF',
      fontStyle: 'default',
      durationSeconds: 5,
      privacyType: 'ALL_CONTACTS',
      isViewed: true,
      viewsCount: 0,
      createdAt: DateTime.now(),
      isDeleted: false,
      viewers: const [],
      creator: meta.ownerName != null
          ? StatusCreatorUser(id: 0, name: meta.ownerName!)
          : null,
    );
  }

  StatusItemModel copyWith({
    bool? isViewed,
    int? viewsCount,
    String? myReaction,
    List<StatusViewerModel>? viewers,
    bool? isDeleted,
    StatusCreatorUser? creator,
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
      isDeleted: isDeleted ?? this.isDeleted,
      viewers: viewers ?? this.viewers,
      creator: creator ?? this.creator,
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

  String get previewLabel {
    if (isVideo) return 'Video';
    if (isImage) return 'Photo';
    if (content.trim().isNotEmpty) return content.trim();
    return 'Status';
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
    final id = int.tryParse(
      (json['id'] ?? json['UserId'] ?? json['userId'])?.toString() ?? '',
    ) ??
        0;
    final name =
        (json['name'] ?? json['Name'] ?? json['userName'])?.toString() ?? 'User';
    final rawPic = (json['profilePic'] ??
        json['ProfileImage'] ??
        json['profileImage'] ??
        json['avatar'])
        ?.toString();

    return StatusCreatorUser(
      id: id,
      name: name,
      profilePic: _resolveProfileUrl(rawPic),
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