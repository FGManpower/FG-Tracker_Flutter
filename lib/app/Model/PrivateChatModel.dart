class PrivateChatResponse {
  bool? status;
  String? message;
  Pagination? pagination;
  List<PrivateChatModel>? data;

  PrivateChatResponse({
    this.status,
    this.message,
    this.pagination,
    this.data,
  });

  factory PrivateChatResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return PrivateChatResponse(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      pagination: json['pagination'] != null
          ? Pagination.fromJson(
              Map<String, dynamic>.from(
                json['pagination'],
              ),
            )
          : null,
      data: json['data'] != null
          ? List<PrivateChatModel>.from(
              (json['data'] as List).map(
                (x) => PrivateChatModel.fromJson(
                  Map<String, dynamic>.from(x),
                ),
              ),
            )
          : <PrivateChatModel>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'pagination': pagination?.toJson(),
      'data': data?.map((x) => x.toJson()).toList() ?? [],
    };
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

  factory Pagination.fromJson(
    Map<String, dynamic> json,
  ) {
    return Pagination(
      currentPage: _parseInt(json['currentPage']),
      perPage: _parseInt(json['perPage']),
      totalRecords: _parseInt(json['totalRecords']),
      totalPages: _parseInt(json['totalPages']),
      hasNextPage: _parseBool(json['hasNextPage']),
      hasPreviousPage: _parseBool(
        json['hasPreviousPage'],
      ),
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
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

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

  String? name;
  String? role;
  String? message;
  String? time;

  int? unreadCount;

  String? status;

  bool? isGroup;
  bool? isPinned;

  String? image;

  PrivateChatModel({
    this.id,
    this.name,
    this.role,
    this.message,
    this.time,
    this.unreadCount,
    this.status,
    this.isGroup,
    this.isPinned,
    this.image,
  });

  factory PrivateChatModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PrivateChatModel(
      id: _parseInt(
        json['id'] ?? json['chatId'] ?? json['chat_id'],
      ),
      name: _readString(
        json,
        [
          'name',
          'receiverName',
          'receiver_name',
          'userName',
          'user_name',
          'fullName',
          'full_name',
        ],
      ),
      role: _readString(
        json,
        [
          'role',
          'designation',
          'department',
          'teamName',
          'team_name',
        ],
      ),
      message: _readString(
        json,
        [
          'message',
          'lastMessage',
          'last_message',
          'latestMessage',
          'latest_message',
          'msg',
        ],
      ),
      time: _readString(
        json,
        [
          'time',
          'lastMessageTime',
          'last_message_time',
          'updatedAt',
          'updated_at',
          'createdAt',
          'created_at',
        ],
      ),
      unreadCount: _parseInt(
        json['unreadCount'] ?? json['unread_count'] ?? json['unread'],
      ),
      status: _readString(
        json,
        [
          'status',
          'userStatus',
          'user_status',
          'onlineStatus',
          'online_status',
        ],
      ),
      isGroup: _parseBool(
        json['isGroup'] ?? json['is_group'] ?? json['group'],
      ),
      isPinned: _parseBool(
        json['isPinned'] ?? json['is_pinned'] ?? json['pinned'],
      ),
      image: _readString(
        json,
        [
          'image',
          'profileImage',
          'profile_image',
          'avatar',
          'profilePic',
          'profile_pic',
          'profile_picture',
        ],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'message': message,
      'time': time,
      'unreadCount': unreadCount,
      'status': status,
      'isGroup': isGroup,
      'isPinned': isPinned,
      'image': image,
    };
  }

  static String? _readString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];

      if (value == null) {
        continue;
      }

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
        final nested = Map<String, dynamic>.from(parent);

        final result = _readString(
          nested,
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
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

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
