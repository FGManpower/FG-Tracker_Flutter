class ForwardListResponse {
  bool? status;
  String? message;
  List<ForwardDestination> destinations = [];

  ForwardListResponse({
    this.status,
    this.message,
    this.destinations = const [],
  });

  factory ForwardListResponse.fromJson(Map<String, dynamic> json) {
    final List<ForwardDestination> result = [];

    dynamic rawData = json['data'];

    if (rawData is List) {
      result.addAll(
        rawData
            .whereType<Map>()
            .map(
              (e) => ForwardDestination.fromJson(
            Map<String, dynamic>.from(e),
          ),
        ),
      );
    }

    if (rawData is Map) {
      final dataMap = Map<String, dynamic>.from(rawData);

      final users = dataMap['users'] ??
          dataMap['people'] ??
          dataMap['private'] ??
          [];

      final groups = dataMap['groups'] ?? [];

      if (users is List) {
        result.addAll(
          users
              .whereType<Map>()
              .map(
                (e) => ForwardDestination.fromJson(
              Map<String, dynamic>.from(e),
            ),
          ),
        );
      }

      if (groups is List) {
        result.addAll(
          groups
              .whereType<Map>()
              .map(
                (e) => ForwardDestination.fromJson(
              Map<String, dynamic>.from(e),
            ),
          ),
        );
      }
    }

    if (result.isEmpty) {
      final users = json['users'] ?? json['people'] ?? [];
      final groups = json['groups'] ?? [];

      if (users is List) {
        result.addAll(
          users
              .whereType<Map>()
              .map(
                (e) => ForwardDestination.fromJson(
              Map<String, dynamic>.from(e),
            ),
          ),
        );
      }

      if (groups is List) {
        result.addAll(
          groups
              .whereType<Map>()
              .map(
                (e) => ForwardDestination.fromJson(
              Map<String, dynamic>.from(e),
            ),
          ),
        );
      }
    }

    return ForwardListResponse(
      status: json['status'],
      message: json['message']?.toString(),
      destinations: result,
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
      profileImage: json['profileImage']?.toString(),
      groupProfile: json['groupProfile']?.toString(),
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
      return groupProfile ?? image ?? '';
    }

    return profileImage ?? image ?? '';
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(value.toString());
  }
}

class ForwardTarget {
  final String type;
  final int userId;

  ForwardTarget({
    required this.type,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "userId": userId,
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