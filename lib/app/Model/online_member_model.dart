class OnlineMemberModel {
  bool? status;
  String? message;
  String? filter;
  OnlinePagination? pagination;
  OnlineMetaData? metaData;
  OnlineMemberResponseData? data;

  OnlineMemberModel({
    this.status,
    this.message,
    this.filter,
    this.pagination,
    this.metaData,
    this.data,
  });

  OnlineMemberModel.fromJson(dynamic json) {
    if (json is! Map) {
      status = false;
      data = OnlineMemberResponseData(
        currentOnline: [],
        recentOnline: [],
      );
      return;
    }

    final Map<String, dynamic> map =
    Map<String, dynamic>.from(json);

    status =
        map['status'] as bool? ??
            (map['success'] == true);

    message = map['message']?.toString();
    filter = map['filter']?.toString();

    pagination = map['pagination'] is Map
        ? OnlinePagination.fromJson(
      Map<String, dynamic>.from(
        map['pagination'],
      ),
    )
        : null;

    metaData = map['metaData'] is Map
        ? OnlineMetaData.fromJson(
      Map<String, dynamic>.from(
        map['metaData'],
      ),
    )
        : null;

    final dynamic rawData = map['data'];

    if (rawData is Map) {
      data = OnlineMemberResponseData.fromJson(
        Map<String, dynamic>.from(rawData),
      );
    } else if (rawData is List) {
      data = OnlineMemberResponseData(
        currentOnline: rawData
            .whereType<Map>()
            .map(
              (item) => OnlineMemberData.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList(),
        recentOnline: [],
      );
    } else {
      data = OnlineMemberResponseData(
        currentOnline: [],
        recentOnline: [],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'filter': filter,
      'pagination': pagination?.toJson(),
      'metaData': metaData?.toJson(),
      'data': data?.toJson(),
    };
  }
}

class OnlineMemberResponseData {
  List<OnlineMemberData> currentOnline;
  List<OnlineMemberData> recentOnline;

  OnlineMemberResponseData({
    required this.currentOnline,
    required this.recentOnline,
  });

  OnlineMemberResponseData.fromJson(
      Map<String, dynamic> json,
      )   : currentOnline = _parseList(
    json['currentOnline'],
  ),
        recentOnline = _parseList(
          json['recentOnline'],
        );

  Map<String, dynamic> toJson() {
    return {
      'currentOnline':
      currentOnline.map((e) => e.toJson()).toList(),
      'recentOnline':
      recentOnline.map((e) => e.toJson()).toList(),
    };
  }

  static List<OnlineMemberData> _parseList(
      dynamic value,
      ) {
    if (value is! List) {
      return <OnlineMemberData>[];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => OnlineMemberData.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }
}

class OnlineMetaData {
  int? totalMembers;
  int? totalOnlineMembers;
  int? totalOfflineMembers;
  int? totalPrivateMembers;
  int? totalNewMembers;

  OnlineMetaData({
    this.totalMembers,
    this.totalOnlineMembers,
    this.totalOfflineMembers,
    this.totalPrivateMembers,
    this.totalNewMembers,
  });

  OnlineMetaData.fromJson(
      Map<String, dynamic> json,
      ) {
    totalMembers =
        _toInt(json['totalMembers']);

    totalOnlineMembers =
        _toInt(json['totalOnlineMembers']);

    totalOfflineMembers =
        _toInt(json['totalOfflineMembers']);

    totalPrivateMembers =
        _toInt(json['totalPrivateMembers']);

    totalNewMembers =
        _toInt(json['totalNewMembers']);
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMembers': totalMembers,
      'totalOnlineMembers': totalOnlineMembers,
      'totalOfflineMembers': totalOfflineMembers,
      'totalPrivateMembers': totalPrivateMembers,
      'totalNewMembers': totalNewMembers,
    };
  }

  static int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
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

  OnlinePagination.fromJson(
      Map<String, dynamic> json,
      ) {
    totalRecords =
        _toInt(json['totalRecords']);

    currentPage =
        _toInt(json['currentPage']);

    perPage =
        _toInt(json['perPage']);

    totalPages =
        _toInt(json['totalPages']);

    hasNextPage =
        json['hasNextPage'] == true;

    hasPreviousPage =
        json['hasPreviousPage'] == true;
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
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is bool) {
      return value ? 1 : 0;
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
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
  double? latitude;
  double? longitude;

  OnlineMemberData({
    this.userId,
    this.name,
    this.mobileNo,
    this.profileImage,
    this.lastSeen,
    this.isOnline,
    this.locationSharing,
    this.department,
    this.latitude,
    this.longitude,
  });

  bool get online {
    return isOnline == 1 ||
        (lastSeen != null &&
            lastSeen!.trim().toLowerCase() ==
                'online');
  }

  OnlineMemberData.fromJson(
      Map<String, dynamic> json,
      ) {
    userId = _toInt(
      json['userId'] ??
          json['user_id'] ??
          json['id'] ??
          json['_id'],
    );

    name = (
        json['Name'] ??
            json['name'] ??
            json['fullName'] ??
            json['userName'] ??
            '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'
    ).toString().trim();

    mobileNo = (
        json['MobileNo'] ??
            json['mobileNo'] ??
            json['mobile'] ??
            json['phone']
    )?.toString();

    profileImage = (
        json['ProfileImage'] ??
            json['profileImage'] ??
            json['image'] ??
            json['avatar']
    )?.toString();

    lastSeen = (
        json['lastSeen'] ??
            json['last_seen'] ??
            json['lastActive']
    )?.toString();

    isOnline = _toInt(
      json['isOnline'] ??
          json['is_online'] ??
          json['online'],
    );

    locationSharing = _toInt(
      json['locationSharing'] ??
          json['location_sharing'] ??
          json['isLocationSharing'],
    );

    department = (
        json['department'] ??
            json['Department'] ??
            json['department_name'] ??
            json['designation'] ??
            json['role'] ??
            json['groupName']
    )?.toString();

    if (json['location'] is Map) {
      final Map<String, dynamic> location =
      Map<String, dynamic>.from(
        json['location'],
      );

      latitude = _toDouble(
        location['lat'] ??
            location['latitude'] ??
            location['userLat'],
      );

      longitude = _toDouble(
        location['lng'] ??
            location['lon'] ??
            location['longitude'] ??
            location['userLong'],
      );
    } else {
      latitude = _toDouble(
        json['latitude'] ??
            json['lat'] ??
            json['userLat'],
      );

      longitude = _toDouble(
        json['longitude'] ??
            json['lng'] ??
            json['lon'] ??
            json['long'] ??
            json['userLong'],
      );
    }
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
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is bool) {
      return value ? 1 : 0;
    }

    return int.tryParse(
      value.toString(),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }
}