class MemberLiveStatus {
  bool? status;
  String? message;
  String? filter;
  Pagination? pagination;
  List<UserMemberData>? data;

  MemberLiveStatus({
    this.status,
    this.message,
    this.filter,
    this.pagination,
    this.data,
  });

  MemberLiveStatus.fromJson(Map<String, dynamic> json) {
    status = json['status'] as bool?;
    message = json['message']?.toString();
    filter = json['filter']?.toString();

    pagination = json['pagination'] is Map
        ? Pagination.fromJson(
            Map<String, dynamic>.from(json['pagination']),
          )
        : null;

    if (json['data'] is List) {
      data = (json['data'] as List)
          .whereType<Map>()
          .map(
            (item) => UserMemberData.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } else {
      data = <UserMemberData>[];
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

class Pagination {
  int? totalRecords;
  int? currentPage;
  int? perPage;
  int? totalPages;
  bool? hasNextPage;
  bool? hasPreviousPage;

  Pagination({
    this.totalRecords,
    this.currentPage,
    this.perPage,
    this.totalPages,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  Pagination.fromJson(Map<String, dynamic> json) {
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
    return int.tryParse(value?.toString() ?? '');
  }
}

class UserMemberData {
  int? userId;
  String? name;
  String? mobileNo;
  String? profileImage;
  String? lastSeen;
  int? isOnline;
  int? locationSharing;

  UserMemberData({
    this.userId,
    this.name,
    this.mobileNo,
    this.profileImage,
    this.lastSeen,
    this.isOnline,
    this.locationSharing,
  });

  bool get online => isOnline == 1 || isOnline == true;

  UserMemberData.fromJson(Map<String, dynamic> json) {
    userId = _toInt(json['userId']);

    name = (json['Name'] ??
            json['name'] ??
            '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}')
        .toString()
        .trim();

    mobileNo = (json['MobileNo'] ?? json['mobileNo'])?.toString();

    profileImage = (json['ProfileImage'] ?? json['profileImage'])?.toString();

    lastSeen = json['lastSeen']?.toString();

    isOnline = _toInt(json['isOnline']);
    locationSharing = _toInt(json['locationSharing']);
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
    };
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is bool) return value ? 1 : 0;

    return int.tryParse(value?.toString() ?? '');
  }
}
