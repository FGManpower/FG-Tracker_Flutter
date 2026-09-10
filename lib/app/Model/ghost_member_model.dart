class GhostMemberModel {
  bool? status;
  String? message;
  String? filter;
  GhostPagination? pagination;
  List<GhostMemberData>? data;

  GhostMemberModel({
    this.status,
    this.message,
    this.filter,
    this.pagination,
    this.data,
  });

  GhostMemberModel.fromJson(dynamic json) {
    if (json is List) {
      status = true;
      data = json
          .whereType<Map>()
          .map(
            (item) => GhostMemberData.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
      return;
    }

    if (json is! Map) {
      status = false;
      data = <GhostMemberData>[];
      return;
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(json);

    status = map['status'] as bool? ?? (map['success'] == true);
    message = map['message']?.toString();
    filter = map['filter']?.toString();

    pagination = map['pagination'] is Map
        ? GhostPagination.fromJson(
            Map<String, dynamic>.from(map['pagination']),
          )
        : null;

    final rawList =
        map['data'] ?? map['members'] ?? map['memberData'] ?? map['users'];
    if (rawList is List) {
      data = rawList
          .whereType<Map>()
          .map(
            (item) => GhostMemberData.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } else {
      data = <GhostMemberData>[];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'filter': filter,
      'pagination': pagination?.toJson(),
      'data': data?.map((item) => item.toJson()).toList(),
    };
  }
}

class GhostPagination {
  int? totalRecords;
  int? currentPage;
  int? perPage;
  int? totalPages;
  bool? hasNextPage;
  bool? hasPreviousPage;

  GhostPagination({
    this.totalRecords,
    this.currentPage,
    this.perPage,
    this.totalPages,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  GhostPagination.fromJson(Map<String, dynamic> json) {
    totalRecords = _toInt(json['totalRecords']);
    currentPage = _toInt(json['currentPage']);
    perPage = _toInt(json['perPage']);
    totalPages = _toInt(json['totalPages']);

    hasNextPage = json['hasNextPage'] == true;
    hasPreviousPage = json['hasPreviousPage'] == true;
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRecords': totalRecords,
      'currentPage': currentPage,
      'perPage': perPage,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is bool) return value ? 1 : 0;
    return int.tryParse(value?.toString() ?? '');
  }
}

class GhostMemberData {
  int? userId;
  String? name;
  String? mobileNo;
  String? profileImage;
  String? lastSeen;
  int? isOnline;
  int? locationSharing;
  String? department;
  String? startedAt;

  GhostMemberData({
    this.userId,
    this.name,
    this.mobileNo,
    this.profileImage,
    this.lastSeen,
    this.isOnline,
    this.locationSharing,
    this.department,
    this.startedAt,
  });

  GhostMemberData.fromJson(Map<String, dynamic> json) {
    userId = _toInt(json['userId'] ?? json['user_id'] ?? json['id']);

    name = (json['Name'] ??
            json['name'] ??
            json['fullName'] ??
            json['userName'] ??
            '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}')
        .toString()
        .trim();

    mobileNo = (json['MobileNo'] ??
            json['mobileNo'] ??
            json['mobile'] ??
            json['phone'])
        ?.toString();

    profileImage = (json['ProfileImage'] ??
            json['profileImage'] ??
            json['image'] ??
            json['avatar'])
        ?.toString();

    lastSeen = (json['lastSeen'] ??
            json['last_seen'] ??
            json['lastActive'])
        ?.toString();

    isOnline = _toInt(
      json['isOnline'] ?? json['is_online'] ?? json['online'],
    );
    locationSharing = _toInt(
      json['locationSharing'] ?? json['location_sharing'],
    );
    department = (json['department'] ??
            json['Department'] ??
            json['department_name'] ??
            json['designation'] ??
            json['role'] ??
            json['groupName'])
        ?.toString();

    startedAt = (json['startedAt'] ??
            json['started_at'] ??
            json['startTime'] ??
            json['start_time'] ??
            json['createdAt'] ??
            json['created_at'] ??
            json['lastSeen'] ??
            json['updatedAt'])
        ?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'Name': name,
      'MobileNo': mobileNo,
      'ProfileImage': profileImage,
      'lastSeen': lastSeen,
      'isOnline': isOnline,
      'locationSharing': locationSharing,
      'department': department,
      'startedAt': startedAt,
    };
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is bool) return value ? 1 : 0;
    return int.tryParse(value?.toString() ?? '');
  }
}
