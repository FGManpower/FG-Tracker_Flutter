class PrivateChatResponse {
  bool? status;
  String? message;
  Pagination? pagination;
  List<PrivateChatModel>? data;
  bool? isOnline;

  PrivateChatResponse({
    this.status,
    this.message,
    this.pagination,
    this.data,
    this.isOnline,
  });

  factory PrivateChatResponse.fromJson(Map<String, dynamic> json) {
    return PrivateChatResponse(
      status: _parseBool(json['status']),
      message: json['message']?.toString(),
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
      'pagination': pagination?.toJson(),
      'data': data?.map((x) => x.toJson()).toList() ?? [],
      'isOnline': isOnline,
    };
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
  int? userId;
  String? name;
  String? role;
  String? message;
  String? time;
  String? messageType;
  String? mutedUntil;
  int? unreadCount;
  String? status;
  bool? isOnline;
  String? lastSeen;
  bool? isGroup;
  bool? isPinned;
  bool? isMuted;
  bool? isArchived;
  bool? moveToTop;
  String? image;

  PrivateChatModel({
    this.id,
    this.userId,
    this.name,
    this.role,
    this.message,
    this.time,
    this.messageType,
    this.mutedUntil,
    this.unreadCount,
    this.status,
    this.isOnline,
    this.lastSeen,
    this.isGroup,
    this.isPinned,
    this.isMuted,
    this.isArchived,
    this.moveToTop,
    this.image,
  });

  factory PrivateChatModel.fromJson(Map<String, dynamic> json) {
    final user =
        json['user'] is Map ? Map<String, dynamic>.from(json['user']) : null;

    final lastMessage = json['lastMessage'] is Map
        ? Map<String, dynamic>.from(json['lastMessage'])
        : null;

    final lastActivity = json['lastActivity'] is Map
        ? Map<String, dynamic>.from(json['lastActivity'])
        : null;

    final activity = lastMessage ?? lastActivity;

    final online = _parseBool(
      json['isOnline'] ??
          json['is_online'] ??
          user?['isOnline'] ??
          user?['is_online'],
    );

    return PrivateChatModel(
      id: _parseInt(
        json['id'] ??
            json['chatId'] ??
            json['chat_id'] ??
            json['conversationId'] ??
            json['conversation_id'],
      ),
      userId: _parseInt(
        json['userId'] ??
            json['user_id'] ??
            user?['id'] ??
            user?['userId'] ??
            user?['user_id'],
      ),
      name: _readString(json, [
        'name',
        'receiverName',
        'receiver_name',
        'userName',
        'user_name',
        'fullName',
        'full_name',
      ]),
      role: _readString(json, [
        'role',
        'designation',
        'department',
        'teamName',
        'team_name',
      ]),
      message: _readString(
            activity ?? {},
            [
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
            'message',
            'lastMessage',
            'last_message',
            'latestMessage',
            'latest_message',
            'msg',
            'content',
          ]) ??
          '',
      messageType: _readString(
            activity ?? {},
            ['messageType', 'message_type', 'type'],
          ) ??
          _readString(json, ['messageType', 'message_type']),
      mutedUntil: _readString(json, ['mutedUntil', 'muted_until']),
      time: _readString(
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
            'time',
            'createdAt',
            'created_at',
            'updatedAt',
            'updated_at',
          ]) ??
          '',
      unreadCount: _parseInt(
        json['unreadCount'] ?? json['unread_count'] ?? json['unread'],
      ),
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
      lastSeen: _readString(json, ['lastSeen', 'last_seen']),
      isGroup: _parseBool(
        json['isGroup'] ?? json['is_group'] ?? json['group'],
      ),
      isPinned: _parseBool(
        json['isPinned'] ?? json['is_pinned'] ?? json['pinned'],
      ),
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
        'image',
        'profileImage',
        'profile_image',
        'avatar',
        'profilePic',
        'profile_pic',
        'profile_picture',
      ]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'role': role,
      'message': message,
      'time': time,
      'messageType': messageType,
      'mutedUntil': mutedUntil,
      'unreadCount': unreadCount,
      'status': status,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'isGroup': isGroup,
      'isPinned': isPinned,
      'isMuted': isMuted,
      'isArchived': isArchived,
      'moveToTop': moveToTop,
      'image': image,
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
