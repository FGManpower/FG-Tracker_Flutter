class OnlineMemberModel {
  bool? status;
  String? message;
  String? filter;
  OnlinePagination? pagination;
  List<OnlineMemberData>? data;

  OnlineMemberModel({
    this.status,
    this.message,
    this.filter,
    this.pagination,
    this.data,
  });

  OnlineMemberModel.fromJson(Map<String, dynamic> json) {
    status = json['status'] as bool?;
    message = json['message']?.toString();
    filter = json['filter']?.toString();

    pagination = json['pagination'] is Map
        ? OnlinePagination.fromJson(
            Map<String, dynamic>.from(json['pagination']),
          )
        : null;

    if (json['data'] is List) {
      data = (json['data'] as List)
          .whereType<Map>()
          .map(
            (item) => OnlineMemberData.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } else {
      data = <OnlineMemberData>[];
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

class OnlinePagination {
  int? totalRecords;
  int? currentPage;
  int? perPage;
  int? totalPages;
  bool? hasNextPage;
  bool? hasPreviousPage;

  OnlinePagination({
    this.totalRecords,
    this.currentPage,
    this.perPage,
    this.totalPages,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  OnlinePagination.fromJson(Map<String, dynamic> json) {
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

class OnlineMemberData {
  int? userId;
  String? name;
  String? mobileNo;
  String? profileImage;
  String? lastSeen;
  int? isOnline;
  int? locationSharing;
  String? department;

  OnlineMemberData({
    this.userId,
    this.name,
    this.mobileNo,
    this.profileImage,
    this.lastSeen,
    this.isOnline,
    this.locationSharing,
    this.department,
  });

  bool get online =>
      isOnline == 1 ||
      (lastSeen != null && lastSeen!.trim().toLowerCase() == 'online');

  OnlineMemberData.fromJson(Map<String, dynamic> json) {
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
    };
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is bool) return value ? 1 : 0;
    return int.tryParse(value?.toString() ?? '');
  }
}
