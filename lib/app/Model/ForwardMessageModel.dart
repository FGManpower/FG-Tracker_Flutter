
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
          dataMap['users'] ??
              dataMap['people'] ??
              dataMap['private'],
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
  });

  factory ForwardDestination.fromJson(Map<String, dynamic> json) {
    final String type = (json['type'] ??
        json['chatType'] ??
        json['targetType'] ??
        json['sourceType'] ??
        '')
        .toString()
        .toLowerCase();

    final int? parsedUserId = _toInt(
      json['userId'] ?? json['user_id'],
    );

    final int? parsedGroupId = _toInt(
      json['groupId'] ?? json['group_id'],
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
          json['groupName'])
          ?.toString(),
      mobileNo: json['mobileNo']?.toString(),
      image: (json['image'] ?? json['avatar'])?.toString(),
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
      if (type == "private" && userId != null)
        "userId": userId,
      if (type == "group" && groupId != null)
        "groupId": groupId,
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