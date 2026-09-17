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
      data = _parseList(json);
      return;
    }

    if (json is! Map) {
      status = false;
      data = <GhostMemberData>[];
      return;
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(json);

    status = map['status'] as bool? ??
        (map['success'] == true) ??
        true;
    message = map['message']?.toString();
    filter = map['filter']?.toString();

    final dynamic rawPagination = map['pagination'] ??
        (map['data'] is Map ? (map['data'] as Map)['pagination'] : null);

    if (rawPagination is Map) {
      pagination = GhostPagination.fromJson(
        Map<String, dynamic>.from(rawPagination),
      );
    }

    final dynamic rawData = map['data'];
    List<GhostMemberData> members = [];

    if (rawData is List) {
      members = _parseList(rawData);
    } else if (rawData is Map) {
      final Map<String, dynamic> dataMap = Map<String, dynamic>.from(rawData);

      final dynamic listCandidate = dataMap['members'] ??
          dataMap['privateMembers'] ??
          dataMap['currentOnline'] ??
          dataMap['recentOnline'] ??
          dataMap['rows'] ??
          dataMap['list'] ??
          dataMap['users'] ??
          dataMap['data'];

      if (listCandidate is List) {
        members = _parseList(listCandidate);
      } else {
        final dynamic current =
            dataMap['currentOnline'] ?? dataMap['onlineMembers'];
        final dynamic recent = dataMap['recentOnline'] ??
            dataMap['recentMembers'] ??
            dataMap['offlineMembers'];

        if (current is List) {
          members.addAll(_parseList(current));
        }
        if (recent is List) {
          members.addAll(_parseList(recent));
        }
      }
    }

    if (members.isEmpty) {
      final dynamic rootCandidate = map['members'] ??
          map['memberData'] ??
          map['users'] ??
          map['privateMembers'] ??
          map['rows'] ??
          map['list'];
      if (rootCandidate is List) {
        members = _parseList(rootCandidate);
      }
    }

    data = members;
  }

  static List<GhostMemberData> _parseList(List list) {
    return list
        .whereType<Map>()
        .map(
          (item) => GhostMemberData.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
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
    totalRecords = _toInt(
      json['totalRecords'] ??
          json['total_records'] ??
          json['total'] ??
          json['count'],
    );
    currentPage = _toInt(
      json['currentPage'] ?? json['current_page'] ?? json['page'],
    );
    perPage = _toInt(
      json['perPage'] ?? json['per_page'] ?? json['limit'],
    );
    totalPages = _toInt(
      json['totalPages'] ?? json['total_pages'] ?? json['pages'],
    );

    if (json.containsKey('hasNextPage') || json.containsKey('has_next_page')) {
      hasNextPage =
          json['hasNextPage'] == true || json['has_next_page'] == true;
    } else if (currentPage != null && totalPages != null) {
      hasNextPage = currentPage! < totalPages!;
    }

    if (json.containsKey('hasPreviousPage') ||
        json.containsKey('has_previous_page')) {
      hasPreviousPage =
          json['hasPreviousPage'] == true || json['has_previous_page'] == true;
    } else if (currentPage != null) {
      hasPreviousPage = currentPage! > 1;
    }
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
    if (value is num) return value.toInt();
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

  bool get online {
    return isOnline == 1 ||
        (lastSeen != null && lastSeen!.trim().toLowerCase() == 'online');
  }

  GhostMemberData.fromJson(Map<String, dynamic> json) {
    userId = _toInt(
      json['userId'] ??
          json['user_id'] ??
          json['id'] ??
          json['_id'],
    );

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
            json['phone'] ??
            json['phoneNumber'])
        ?.toString();

    profileImage = (json['ProfileImage'] ??
            json['profileImage'] ??
            json['image'] ??
            json['avatar'] ??
            json['profile_image'])
        ?.toString();

    lastSeen = (json['lastSeen'] ??
            json['last_seen'] ??
            json['lastActive'] ??
            json['last_active'] ??
            json['updatedAt'] ??
            json['updated_at'])
        ?.toString();

    isOnline = _toInt(
      json['isOnline'] ?? json['is_online'] ?? json['online'],
    );
    locationSharing = _toInt(
      json['locationSharing'] ??
          json['location_sharing'] ??
          json['isLocationSharing'],
    );
    department = (json['department'] ??
            json['Department'] ??
            json['department_name'] ??
            json['designation'] ??
            json['role'] ??
            json['groupName'] ??
            json['group_name'])
        ?.toString();

    if (department == null ||
        department!.trim().isEmpty ||
        department == 'null') {
      if (json['groupList'] is List && (json['groupList'] as List).isNotEmpty) {
        final firstGroup = (json['groupList'] as List).first;
        if (firstGroup is Map && firstGroup['groupName'] != null) {
          department = firstGroup['groupName'].toString();
        }
      } else if (json['groups'] is List &&
          (json['groups'] as List).isNotEmpty) {
        department = (json['groups'] as List).first.toString();
      }
    }

    startedAt = (json['startedAt'] ??
            json['started_at'] ??
            json['startTime'] ??
            json['start_time'] ??
            json['createdAt'] ??
            json['created_at'] ??
            json['lastSeen'] ??
            json['last_seen'] ??
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
    if (value is num) return value.toInt();
    if (value is bool) return value ? 1 : 0;
    return int.tryParse(value?.toString() ?? '');
  }
}
