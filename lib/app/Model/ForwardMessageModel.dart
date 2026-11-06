class ForwardListResponse {
  bool? status;
  String? message;

  List<ForwardDestination> recentChats;
  List<ForwardDestination> destinations;

  ForwardListResponse({
    this.status,
    this.message,
    this.recentChats = const [],
    this.destinations = const [],
  });

  factory ForwardListResponse.fromJson(Map<String, dynamic> json) {
    final dynamic rawData = json['data'];

    final Map<String, dynamic> dataMap = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : <String, dynamic>{};

    List<ForwardDestination> parseList(dynamic value) {
      if (value is! List) return <ForwardDestination>[];

      return value
          .whereType<Map>()
          .map(
            (item) => ForwardDestination.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    final recent = parseList(dataMap['recentChats']);

    final List<ForwardDestination> all = [];

    if (rawData is List) {
      all.addAll(parseList(rawData));
    } else {
      all.addAll(
        parseList(
          dataMap['users'] ?? dataMap['people'] ?? dataMap['private'],
        ),
      );

      all.addAll(parseList(dataMap['groups']));
    }

    if (all.isEmpty) {
      all.addAll(parseList(json['users'] ?? json['people']));
      all.addAll(parseList(json['groups']));
    }

    return ForwardListResponse(
      status: json['status'] as bool?,
      message: json['message']?.toString(),
      recentChats: recent,
      destinations: all,
    );
  }
}

class ForwardDestination {
  int? id;
  int? userId;
  int? groupId;
  String? type;
  String? name;
  String? mobileNo;
  String? image;
  String? profileImage;
  String? groupProfile;

  ForwardDestination({
    this.id,
    this.userId,
    this.groupId,
    this.type,
    this.name,
    this.mobileNo,
    this.image,
    this.profileImage,
    this.groupProfile,
    this.isPinned = false,
    this.lastActivityAt,
  });

  /// Pinned in the chat list (recent chats sort pinned first).
  bool isPinned;

  /// Last message time (recent chats sort newest first), if sent.
  String? lastActivityAt;

  factory ForwardDestination.fromJson(Map<String, dynamic> json) {
    // Recent chats may come in the /chat-list shape: the person / group is
    // nested under `user` / `group` and the top-level `id` is the CHAT id.
    // Read the nested values as fallbacks so a private row gets the real
    // user id (forward target) and mobile number.
    final Map<String, dynamic>? user =
        json['user'] is Map ? Map<String, dynamic>.from(json['user']) : null;
    final Map<String, dynamic>? group =
        json['group'] is Map ? Map<String, dynamic>.from(json['group']) : null;

    final String rawType = (json['type'] ??
            json['chatType'] ??
            json['targetType'] ??
            json['sourceType'] ??
            '')
        .toString()
        .toLowerCase();
    final bool isGroupRow = rawType == 'group' ||
        json['isGroup'] == true ||
        (rawType.isEmpty && group != null);
    final String type = isGroupRow ? 'group' : rawType;

    final int? parsedUserId = _toInt(
      json['userId'] ??
          json['user_id'] ??
          (isGroupRow ? null : (user?['id'] ?? user?['userId'])),
    );

    final int? parsedGroupId = _toInt(
      json['groupId'] ??
          json['group_id'] ??
          group?['id'] ??
          group?['groupId'],
    );

    final int? parsedId = _toInt(
      json['id'],
    );

    return ForwardDestination(
      id: parsedId,
      userId: parsedUserId,
      groupId: parsedGroupId,
      type: type == 'group' ? 'group' : 'private',
      name: (json['name'] ??
              json['userName'] ??
              json['username'] ??
              json['groupName'] ??
              user?['name'] ??
              user?['fullName'] ??
              group?['groupName'] ??
              group?['name'])
          ?.toString(),
      mobileNo: (json['mobileNo'] ?? user?['mobileNo'])?.toString(),
      image: (json['image'] ??
              json['avatar'] ??
              user?['avatar'] ??
              user?['profileImage'] ??
              group?['groupProfile'])
          ?.toString(),
      isPinned: json['isPinned'] == true,
      lastActivityAt: (json['lastMessageAt'] ??
              json['timestamp'] ??
              json['updatedAt'] ??
              (json['lastMessage'] is Map
                  ? (json['lastMessage']['createdAt'] ??
                      json['lastMessage']['timestamp'])
                  : null))
          ?.toString(),
      profileImage: (json['profileImage'] ??
              json['profile_image'] ??
              json['groupProfile'] ??
              json['group_profile'])
          ?.toString(),
      groupProfile: (json['groupProfile'] ??
              json['group_profile'] ??
              json['profileImage'] ??
              json['profile_image'])
          ?.toString(),
    );
  }

  bool get isGroup => type == 'group';

  int? get targetId => isGroup ? groupId ?? id : userId ?? id;

  String get displayName {
    final userName = name?.trim();

    if (userName != null && userName.isNotEmpty) {
      return userName;
    }

    final mobile = mobileNo?.trim();

    if (mobile != null && mobile.isNotEmpty) {
      return mobile;
    }

    return "Unknown User";
  }

  String get displayImage {
    if (isGroup) {
      return (groupProfile != null && groupProfile!.isNotEmpty)
          ? groupProfile!
          : ((profileImage != null && profileImage!.isNotEmpty)
              ? profileImage!
              : (image ?? ''));
    }

    return (profileImage != null && profileImage!.isNotEmpty)
        ? profileImage!
        : ((groupProfile != null && groupProfile!.isNotEmpty)
            ? groupProfile!
            : (image ?? ''));
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(value.toString());
  }
}

class ForwardTarget {
  final String type;
  final int? userId;
  final int? groupId;

  ForwardTarget({
    required this.type,
    this.userId,
    this.groupId,
  });

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      if (type == "private" && userId != null) "userId": userId,
      if (type == "group" && groupId != null) "groupId": groupId,
    };
  }
}

class ForwardMessageResponse {
  bool? status;
  String? message;
  dynamic data;

  ForwardMessageResponse({
    this.status,
    this.message,
    this.data,
  });

  factory ForwardMessageResponse.fromJson(Map<String, dynamic> json) {
    return ForwardMessageResponse(
      status: json['status'],
      message: json['message']?.toString(),
      data: json['data'],
    );
  }
}
