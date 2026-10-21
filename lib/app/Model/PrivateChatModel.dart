class PrivateChatResponse {
  bool? status;
  String? message;
  int? unreadTotalCount;
  Pagination? pagination;
  List<PrivateChatModel>? data;
  bool? isOnline;

  PrivateChatResponse({
    this.status,
    this.message,
    this.unreadTotalCount,
    this.pagination,
    this.data,
    this.isOnline,
  });

  factory PrivateChatResponse.fromJson(Map<String, dynamic> json) {
    return PrivateChatResponse(
      status: _parseBool(json['status']),
      message: json['message']?.toString(),
      unreadTotalCount: _parseInt(
        json['unreadTotalCount'] ?? json['unread_total_count'],
      ),
      pagination: json['pagination'] is Map
          ? Pagination.fromJson(
        Map<String, dynamic>.from(json['pagination']),
      )
          : null,
      data: json['data'] is List
          ? (json['data'] as List)
          .whereType<Map>()
          .map(
            (x) => PrivateChatModel.fromJson(
          Map<String, dynamic>.from(x),
        ),
      )
          .toList()
          : <PrivateChatModel>[],
      isOnline: _parseBool(json['isOnline']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'unreadTotalCount': unreadTotalCount,
      'pagination': pagination?.toJson(),
      'data': data?.map((x) => x.toJson()).toList() ?? [],
      'isOnline': isOnline,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;

    if (value is String) {
      final normalized = value.toLowerCase().trim();
      if (normalized == 'true' || normalized == 'yes' || normalized == '1') {
        return true;
      }
      if (normalized == 'false' || normalized == 'no' || normalized == '0') {
        return false;
      }
    }

    return null;
  }
}

class Pagination {
  int? currentPage;
  int? perPage;
  int? totalRecords;
  int? totalPages;
  bool? hasNextPage;
  bool? hasPreviousPage;

  Pagination({
    this.currentPage,
    this.perPage,
    this.totalRecords,
    this.totalPages,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: _parseInt(json['currentPage'] ?? json['current_page']),
      perPage: _parseInt(json['perPage'] ?? json['per_page']),
      totalRecords: _parseInt(json['totalRecords'] ?? json['total_records']),
      totalPages: _parseInt(json['totalPages'] ?? json['total_pages']),
      hasNextPage: _parseBool(json['hasNextPage'] ?? json['has_next_page']),
      hasPreviousPage:
      _parseBool(json['hasPreviousPage'] ?? json['has_previous_page']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'perPage': perPage,
      'totalRecords': totalRecords,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;

    if (value is String) {
      final normalized = value.toLowerCase().trim();
      if (normalized == 'true' || normalized == 'yes' || normalized == '1') {
        return true;
      }
      if (normalized == 'false' || normalized == 'no' || normalized == '0') {
        return false;
      }
    }

    return null;
  }
}

class PrivateChatModel {
  int? id;
  int? chatId;
  int? conversationId;
  int? groupId;
  String? chatType;
  int? userId;
  String? name;
  String? groupName;
  int? memberCount;
  String? role;
  String? message;
  String? preview;
  bool? isDeletedForEveryone;
  String? time;
  String? timestamp;
  String? messageType;
  String? mutedUntil;
  int? unreadCount;
  String? status;
  bool? isOnline;
  String? lastSeen;
  bool? isBlocked;
  bool? blockedByMe;
  bool? isGroup;
  bool? isPinned;
  String? pinnedAt;
  bool? isMuted;
  bool? isArchived;
  bool? moveToTop;
  String? image;
  bool? isForwarded;
  String? forwardedLabel;
  int? forwardedFromMessageId;

  PrivateChatModel({
    this.id,
    this.chatId,
    this.conversationId,
    this.groupId,
    this.chatType,
    this.userId,
    this.name,
    this.groupName,
    this.memberCount,
    this.role,
    this.message,
    this.preview,
    this.isDeletedForEveryone,
    this.time,
    this.timestamp,
    this.messageType,
    this.mutedUntil,
    this.unreadCount,
    this.status,
    this.isOnline,
    this.lastSeen,
    this.isBlocked,
    this.blockedByMe,
    this.isGroup,
    this.isPinned,
    this.pinnedAt,
    this.isMuted,
    this.isArchived,
    this.moveToTop,
    this.image,
    this.isForwarded,
    this.forwardedLabel,
    this.forwardedFromMessageId,
  });

  factory PrivateChatModel.fromJson(Map<String, dynamic> json) {
    final user =
    json['user'] is Map ? Map<String, dynamic>.from(json['user']) : null;

    final group =
    json['group'] is Map ? Map<String, dynamic>.from(json['group']) : null;

    final lastMessage = json['lastMessage'] is Map
        ? Map<String, dynamic>.from(json['lastMessage'])
        : null;

    final lastActivity = json['lastActivity'] is Map
        ? Map<String, dynamic>.from(json['lastActivity'])
        : null;

    final activity = lastMessage ?? lastActivity;

    final rawChatType = _readString(json, ['chatType', 'chat_type', 'type']);
    final isGroupParsed = _parseBool(
      json['isGroup'] ?? json['is_group'] ?? json['group'],
    );
    final isGroupChat = isGroupParsed ??
        (rawChatType == 'group' ||
            json['groupId'] != null ||
            json['group_id'] != null ||
            group != null);

    final online = isGroupChat
        ? false
        : _parseBool(
      json['isOnline'] ??
          json['is_online'] ??
          user?['isOnline'] ??
          user?['is_online'],
    );

    final resolvedId = _parseInt(
      json['id'] ??
          json['chatId'] ??
          json['chat_id'] ??
          json['conversationId'] ??
          json['conversation_id'],
    );

    final resolvedGroupId = _parseInt(
      json['groupId'] ??
          json['group_id'] ??
          group?['id'] ??
          group?['groupId'] ??
          group?['group_id'],
    );

    final resolvedUserId = _parseInt(
      json['userId'] ??
          json['user_id'] ??
          user?['id'] ??
          user?['userId'] ??
          user?['user_id'],
    );

    final resolvedName = _readString(json, [
      'name',
      'groupName',
      'group_name',
      'receiverName',
      'receiver_name',
      'userName',
      'user_name',
      'fullName',
      'full_name',
    ]) ??
        _readString(group ?? {}, ['groupName', 'group_name', 'name']) ??
        _readString(user ?? {}, ['name', 'fullName', 'full_name']) ??
        (isGroupChat ? 'Group' : 'Unknown User');

    final messageDeleted = _parseBool(
      lastMessage?['isDeletedForEveryone'] ??
          activity?['isDeletedForEveryone'] ??
          json['isDeletedForEveryone'] ??
          json['is_deleted_for_everyone'],
    ) ??
        false;

    final messageContent = _readString(
      activity ?? {},
      [
        'preview',
        'message',
        'lastMessage',
        'last_message',
        'latestMessage',
        'latest_message',
        'msg',
        'content',
      ],
    ) ??
        _readString(json, [
          'preview',
          'message',
          'lastMessage',
          'last_message',
          'latestMessage',
          'latest_message',
          'msg',
          'content',
        ]) ??
        '';

    final messagePreview = _readString(
      activity ?? {},
      ['preview', 'message', 'content'],
    ) ??
        _readString(json, ['preview', 'message', 'content']) ??
        messageContent;

    final timeString = _readString(
      activity ?? {},
      [
        'timestamp',
        'time',
        'createdAt',
        'created_at',
        'updatedAt',
        'updated_at',
      ],
    ) ??
        _readString(json, [
          'timestamp',
          'lastMessageAt',
          'last_message_at',
          'time',
          'createdAt',
          'created_at',
          'updatedAt',
          'updated_at',
        ]) ??
        '';

    return PrivateChatModel(
      id: resolvedId,
      chatId: _parseInt(json['chatId'] ?? json['chat_id'] ?? resolvedId),
      conversationId: _parseInt(
        json['conversationId'] ?? json['conversation_id'] ?? resolvedId,
      ),
      groupId: resolvedGroupId,
      chatType: rawChatType ?? (isGroupChat ? 'group' : 'private'),
      userId: resolvedUserId,
      name: resolvedName,
      groupName: _readString(json, ['groupName', 'group_name']) ??
          _readString(group ?? {}, ['groupName', 'group_name', 'name']),
      memberCount: _parseInt(
        json['memberCount'] ??
            json['member_count'] ??
            group?['memberCount'] ??
            group?['member_count'],
      ),
      role: _readString(json, [
        'role',
        'designation',
        'department',
        'teamName',
        'team_name',
      ]),
      message: messageContent,
      preview: messagePreview,
      isDeletedForEveryone: messageDeleted,
      time: timeString,
      timestamp: timeString,
      messageType: _readString(
        activity ?? {},
        ['messageType', 'message_type', 'type'],
      ) ??
          _readString(json, ['messageType', 'message_type']) ??
          'text',
      mutedUntil: _readString(json, ['mutedUntil', 'muted_until']),
      unreadCount: _parseInt(
        json['unreadCount'] ?? json['unread_count'] ?? json['unread'],
      ) ??
          0,
      status: online != null
          ? (online ? 'Online' : 'Offline')
          : _readString(json, [
        'status',
        'userStatus',
        'user_status',
        'onlineStatus',
        'online_status',
      ]),
      isOnline: online,
      lastSeen: _readString(json, ['lastSeen', 'last_seen']) ??
          _readString(user ?? {}, ['lastSeen', 'last_seen']),
      isBlocked: _parseBool(json['isBlocked'] ?? json['is_blocked']) ?? false,
      blockedByMe:
      _parseBool(json['blockedByMe'] ?? json['blocked_by_me']) ?? false,
      isGroup: isGroupChat,
      isPinned: _parseBool(
        json['isPinned'] ?? json['is_pinned'] ?? json['pinned'],
      ) ??
          false,
      pinnedAt: _readString(json, ['pinnedAt', 'pinned_at']),
      isMuted: _parseBool(
        json['isMuted'] ?? json['is_muted'],
      ),
      isArchived: _parseBool(
        json['isArchived'] ?? json['is_archived'] ?? json['archived'],
      ),
      moveToTop: _parseBool(
        json['moveToTop'] ?? json['move_to_top'],
      ),
      image: _readString(json, [
        'profileImage',
        'profile_image',
        'avatar',
        'image',
        'profilePic',
        'profile_pic',
        'profile_picture',
      ]) ??
          _readString(user ?? {}, ['avatar', 'profileImage', 'profile_image']) ??
          _readString(group ?? {}, [
            'profileImage',
            'profile_image',
            'groupProfile',
            'group_profile',
            'image',
          ]),
      isForwarded: _parseBool(
            json['isForwarded'] ??
                json['is_forwarded'] ??
                lastMessage?['isForwarded'] ??
                lastMessage?['is_forwarded'] ??
                activity?['isForwarded'] ??
                activity?['is_forwarded'],
          ) ??
          false,
      forwardedLabel: _readString(json, ['forwardedLabel', 'forwarded_label']) ??
          _readString(lastMessage ?? {}, ['forwardedLabel', 'forwarded_label']) ??
          _readString(activity ?? {}, ['forwardedLabel', 'forwarded_label']) ??
          ((_parseBool(
                    json['isForwarded'] ??
                        json['is_forwarded'] ??
                        lastMessage?['isForwarded'] ??
                        lastMessage?['is_forwarded'] ??
                        activity?['isForwarded'] ??
                        activity?['is_forwarded'],
                  ) ??
                  false)
              ? 'Forwarded'
              : null),
      forwardedFromMessageId: _parseInt(
        json['forwardedFromMessageId'] ??
            json['forwarded_from_message_id'] ??
            lastMessage?['forwardedFromMessageId'] ??
            lastMessage?['forwarded_from_message_id'] ??
            activity?['forwardedFromMessageId'] ??
            activity?['forwarded_from_message_id'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'conversationId': conversationId,
      'groupId': groupId,
      'chatType': chatType,
      'userId': userId,
      'name': name,
      'groupName': groupName,
      'memberCount': memberCount,
      'role': role,
      'message': message,
      'preview': preview,
      'isDeletedForEveryone': isDeletedForEveryone,
      'time': time,
      'timestamp': timestamp,
      'messageType': messageType,
      'mutedUntil': mutedUntil,
      'unreadCount': unreadCount,
      'status': status,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'isBlocked': isBlocked,
      'blockedByMe': blockedByMe,
      'isGroup': isGroup,
      'isPinned': isPinned,
      'pinnedAt': pinnedAt,
      'isMuted': isMuted,
      'isArchived': isArchived,
      'moveToTop': moveToTop,
      'image': image,
      'isForwarded': isForwarded,
      'forwardedLabel': forwardedLabel,
      'forwardedFromMessageId': forwardedFromMessageId,
    };
  }

  static String? _readString(
      Map<String, dynamic> json,
      List<String> keys,
      ) {
    for (final key in keys) {
      final value = json[key];

      if (value == null) continue;

      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }

      if (value is num || value is bool) {
        return value.toString();
      }
    }

    const nestedKeys = [
      'user',
      'member',
      'receiver',
      'recipient',
      'profile',
    ];

    for (final parentKey in nestedKeys) {
      final parent = json[parentKey];

      if (parent is Map) {
        final result = _readString(
          Map<String, dynamic>.from(parent),
          keys,
        );

        if (result != null && result.isNotEmpty) {
          return result;
        }
      }
    }

    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;

    if (value is String) {
      final normalized = value.toLowerCase().trim();

      if (normalized == 'true' || normalized == 'yes' || normalized == '1') {
        return true;
      }

      if (normalized == 'false' || normalized == 'no' || normalized == '0') {
        return false;
      }
    }

    return null;
  }
}