import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:intl/intl.dart';

class GroupMemberModel {
  bool? status;
  String? message;
  String? filter;
  Pagination? pagination;
  User? user;
  Data? data;

  GroupMemberModel({
    this.status,
    this.message,
    this.filter,
    this.pagination,
    this.user,
    this.data,
  });

  GroupMemberModel.fromJson(dynamic json) {
    if (json is! Map) {
      status = false;
      message = 'Invalid format';
      return;
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(json);

    status = map['status'] as bool? ?? (map['success'] == true);
    message = map['message']?.toString();
    filter = map['filter']?.toString();

    final dynamic rawPagination = map['pagination'] ??
        (map['data'] is Map ? (map['data'] as Map)['pagination'] : null);
    if (rawPagination is Map) {
      pagination = Pagination.fromJson(Map<String, dynamic>.from(rawPagination));
    }

    final dynamic rawUser = map['user'];
    if (rawUser is Map) {
      user = User.fromJson(Map<String, dynamic>.from(rawUser));
    }

    final dynamic rawData = map['data'];
    if (rawData is Map) {
      data = Data.fromJson(Map<String, dynamic>.from(rawData));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['status'] = status;
    json['message'] = message;
    json['filter'] = filter;
    if (pagination != null) {
      json['pagination'] = pagination!.toJson();
    }
    if (user != null) {
      json['user'] = user!.toJson();
    }
    if (data != null) {
      json['data'] = data!.toJson();
    }
    return json;
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
    totalRecords = _toInt(json['totalRecords'] ?? json['total'] ?? json['totalCount']);
    currentPage = _toInt(json['currentPage'] ?? json['page']);
    perPage = _toInt(json['perPage'] ?? json['limit']);
    totalPages = _toInt(json['totalPages'] ?? json['pages']);
    hasNextPage = json['hasNextPage'] as bool? ??
        (currentPage != null && totalPages != null && currentPage! < totalPages!);
    hasPreviousPage = json['hasPreviousPage'] as bool? ??
        (currentPage != null && currentPage! > 1);
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
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class IndividualPlanDetails {
  int? subscriptionId;
  int? planId;
  String? planName;
  String? planType;
  String? billingInterval;
  String? startsAt;
  String? expiresAt;

  IndividualPlanDetails({
    this.subscriptionId,
    this.planId,
    this.planName,
    this.planType,
    this.billingInterval,
    this.startsAt,
    this.expiresAt,
  });

  IndividualPlanDetails.fromJson(Map<String, dynamic> json) {
    subscriptionId = _toInt(json['subscriptionId'] ?? json['id']);
    planId = _toInt(json['planId'] ?? json['plan_id']);
    planName = json['planName']?.toString() ?? json['name']?.toString();
    planType = json['planType']?.toString();
    billingInterval = json['billingInterval']?.toString();
    startsAt = json['startsAt']?.toString();
    expiresAt = json['expiresAt']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptionId': subscriptionId,
      'planId': planId,
      'planName': planName,
      'planType': planType,
      'billingInterval': billingInterval,
      'startsAt': startsAt,
      'expiresAt': expiresAt,
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class TeamPlanDetails {
  int? subscriptionId;
  int? planId;
  String? planName;
  String? planType;
  String? billingInterval;
  int? purchasedSeats;
  int? assignedSeats;
  int? availableSeats;
  bool? canAssignMember;
  String? startsAt;
  String? expiresAt;

  TeamPlanDetails({
    this.subscriptionId,
    this.planId,
    this.planName,
    this.planType,
    this.billingInterval,
    this.purchasedSeats,
    this.assignedSeats,
    this.availableSeats,
    this.canAssignMember,
    this.startsAt,
    this.expiresAt,
  });

  TeamPlanDetails.fromJson(Map<String, dynamic> json) {
    subscriptionId = _toInt(json['subscriptionId'] ?? json['id']);
    planId = _toInt(json['planId'] ?? json['plan_id']);
    planName = json['planName']?.toString() ?? json['name']?.toString();
    planType = json['planType']?.toString();
    billingInterval = json['billingInterval']?.toString();
    purchasedSeats = _toInt(json['purchasedSeats'] ??
        json['seats'] ??
        json['memberCount'] ??
        json['seatsCount']);
    assignedSeats = _toInt(json['assignedSeats']);
    availableSeats = _toInt(json['availableSeats']);
    canAssignMember = json['canAssignMember'] == true ||
        (purchasedSeats != null && purchasedSeats! > 1);
    startsAt = json['startsAt']?.toString();
    expiresAt = json['expiresAt']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptionId': subscriptionId,
      'planId': planId,
      'planName': planName,
      'planType': planType,
      'billingInterval': billingInterval,
      'purchasedSeats': purchasedSeats,
      'assignedSeats': assignedSeats,
      'availableSeats': availableSeats,
      'canAssignMember': canAssignMember,
      'startsAt': startsAt,
      'expiresAt': expiresAt,
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class UserSubscription {
  int? subscriptionId;
  int? planId;
  String? planName;
  String? planType;
  String? billingInterval;
  String? accessType;
  int? purchasedSeats;
  int? assignedSeats;
  int? availableSeats;
  bool? canAssignMember;
  String? startsAt;
  String? expiresAt;
  IndividualPlanDetails? individual;
  TeamPlanDetails? teamPlan;

  UserSubscription({
    this.subscriptionId,
    this.planId,
    this.planName,
    this.planType,
    this.billingInterval,
    this.accessType,
    this.purchasedSeats,
    this.assignedSeats,
    this.availableSeats,
    this.canAssignMember,
    this.startsAt,
    this.expiresAt,
    this.individual,
    this.teamPlan,
  });

  UserSubscription.fromJson(Map<String, dynamic> json) {
    if (json['individual'] is Map) {
      individual = IndividualPlanDetails.fromJson(
          Map<String, dynamic>.from(json['individual']));
    }
    if (json['teamPlan'] is Map) {
      teamPlan = TeamPlanDetails.fromJson(
          Map<String, dynamic>.from(json['teamPlan']));
    }

    subscriptionId = _toInt(json['subscriptionId'] ??
        json['id'] ??
        teamPlan?.subscriptionId ??
        individual?.subscriptionId);
    planId = _toInt(json['planId'] ??
        json['plan_id'] ??
        teamPlan?.planId ??
        individual?.planId);
    planName = json['planName']?.toString() ??
        json['name']?.toString() ??
        teamPlan?.planName ??
        individual?.planName;
    planType = json['planType']?.toString() ??
        teamPlan?.planType ??
        individual?.planType;
    billingInterval = json['billingInterval']?.toString() ??
        teamPlan?.billingInterval ??
        individual?.billingInterval;
    accessType = json['accessType']?.toString();
    purchasedSeats = _toInt(json['purchasedSeats'] ??
        json['seats'] ??
        json['memberCount'] ??
        teamPlan?.purchasedSeats);
    assignedSeats = _toInt(json['assignedSeats'] ?? teamPlan?.assignedSeats);
    availableSeats = _toInt(json['availableSeats'] ?? teamPlan?.availableSeats);
    canAssignMember = json['canAssignMember'] == true ||
        (teamPlan?.canAssignMember == true) ||
        (purchasedSeats != null && purchasedSeats! > 1);
    startsAt = json['startsAt']?.toString() ??
        teamPlan?.startsAt ??
        individual?.startsAt;
    expiresAt = json['expiresAt']?.toString() ??
        teamPlan?.expiresAt ??
        individual?.expiresAt;
  }

  bool get isTeamPlanActive =>
      teamPlan != null ||
      planType == 'group' ||
      (purchasedSeats != null && purchasedSeats! > 1);

  bool get isIndividualOnly =>
      !isTeamPlanActive &&
      (individual != null || planType == 'individual');

  bool get allowAssign =>
      canAssignMember == true ||
      (isTeamPlanActive && (purchasedSeats ?? 0) > 1);

  Map<String, dynamic> toJson() {
    return {
      'subscriptionId': subscriptionId,
      'planId': planId,
      'planName': planName,
      'planType': planType,
      'billingInterval': billingInterval,
      'accessType': accessType,
      'purchasedSeats': purchasedSeats,
      'assignedSeats': assignedSeats,
      'availableSeats': availableSeats,
      'canAssignMember': canAssignMember,
      'startsAt': startsAt,
      'expiresAt': expiresAt,
      if (individual != null) 'individual': individual!.toJson(),
      if (teamPlan != null) 'teamPlan': teamPlan!.toJson(),
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class User {
  int? userId;
  String? name;
  String? phone;
  String? profileImage;
  bool? isLocationSharing;
  bool? isOnline;
  String? lastSeen;
  bool? isSubscribed;
  String? subscriptionStatus;
  UserSubscription? subscription;

  User({
    this.userId,
    this.name,
    this.phone,
    this.profileImage,
    this.isLocationSharing,
    this.isOnline,
    this.lastSeen,
    this.isSubscribed,
    this.subscriptionStatus,
    this.subscription,
  });

  User.fromJson(Map<String, dynamic> json) {
    userId = _toInt(json['userId'] ?? json['id']);
    name = json['name']?.toString();
    phone = json['phone']?.toString();
    profileImage = json['profileImage']?.toString();
    isLocationSharing = _toBool(json['isLocationSharing'] ?? json['locationSharing']);
    isOnline = _toBool(json['isOnline'] ?? json['online']);
    lastSeen = json['lastSeen']?.toString();
    isSubscribed = _toBool(json['isSubscribed']);
    subscriptionStatus = json['subscriptionStatus']?.toString();
    if (json['subscription'] != null && json['subscription'] is Map) {
      subscription = UserSubscription.fromJson(
          Map<String, dynamic>.from(json['subscription']));
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'profileImage': profileImage,
      'isLocationSharing': isLocationSharing,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      if (isSubscribed != null) 'isSubscribed': isSubscribed,
      if (subscriptionStatus != null) 'subscriptionStatus': subscriptionStatus,
      if (subscription != null) 'subscription': subscription!.toJson(),
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value == 1 || value == '1' || value.toString().toLowerCase() == 'true') return true;
    if (value == 0 || value == '0' || value.toString().toLowerCase() == 'false') return false;
    return null;
  }
}

class SubscriptionGroupData {
  List<GroupMemberData>? subscribed;
  List<GroupMemberData>? expired;

  SubscriptionGroupData({this.subscribed, this.expired});

  SubscriptionGroupData.fromJson(Map<String, dynamic> json) {
    if (json['subscribed'] != null && json['subscribed'] is List) {
      subscribed = (json['subscribed'] as List)
          .whereType<Map>()
          .map((v) => GroupMemberData.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    }
    if (json['expired'] != null && json['expired'] is List) {
      expired = (json['expired'] as List)
          .whereType<Map>()
          .map((v) => GroupMemberData.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (subscribed != null) {
      data['subscribed'] = subscribed!.map((v) => v.toJson()).toList();
    }
    if (expired != null) {
      data['expired'] = expired!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  List<GroupMemberData> get allMembers => [
        if (subscribed != null) ...subscribed!,
        if (expired != null) ...expired!,
      ];
}

class Data {
  List<GroupMemberData>? private;
  List<GroupMemberData>? active;
  List<GroupMemberData>? recentActive;
  SubscriptionGroupData? subscriptionData;
  List<GroupMemberData>? subscription;
  List<GroupMemberData>? members;
  AllMember? allMember;

  Data({
    this.private,
    this.active,
    this.recentActive,
    this.subscriptionData,
    this.subscription,
    this.members,
    this.allMember,
  });

  List<GroupMemberData> get currentOnline => active ?? [];
  List<GroupMemberData> get recentOnline => recentActive ?? [];
  List<GroupMemberData> get allMemberList =>
      subscription ??
      subscriptionData?.allMembers ??
      members ??
      allMember?.memberList ??
      active ??
      recentActive ??
      private ??
      [];

  Data.fromJson(Map<String, dynamic> json) {
    if (json['subscription'] != null) {
      if (json['subscription'] is Map) {
        subscriptionData = SubscriptionGroupData.fromJson(
            Map<String, dynamic>.from(json['subscription']));
        subscription = subscriptionData?.allMembers;
      } else if (json['subscription'] is List) {
        subscription = (json['subscription'] as List)
            .whereType<Map>()
            .map((v) => GroupMemberData.fromJson(Map<String, dynamic>.from(v)))
            .toList();
      }
    }
    if (json['subscribed'] != null && json['subscribed'] is List) {
      subscription = (json['subscribed'] as List)
          .whereType<Map>()
          .map((v) => GroupMemberData.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    }
    if (json['members'] != null && json['members'] is List) {
      members = (json['members'] as List)
          .whereType<Map>()
          .map((v) => GroupMemberData.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    }
    if (json['memberList'] != null && json['memberList'] is List) {
      members = (json['memberList'] as List)
          .whereType<Map>()
          .map((v) => GroupMemberData.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    }
    if (json['list'] != null && json['list'] is List) {
      members = (json['list'] as List)
          .whereType<Map>()
          .map((v) => GroupMemberData.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    }
    if (json['private'] != null && json['private'] is List) {
      private = (json['private'] as List)
          .whereType<Map>()
          .map((v) => GroupMemberData.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    }
    if (json['active'] != null && json['active'] is List) {
      active = (json['active'] as List)
          .whereType<Map>()
          .map((v) => GroupMemberData.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    }
    if (json['recentActive'] != null && json['recentActive'] is List) {
      recentActive = (json['recentActive'] as List)
          .whereType<Map>()
          .map((v) => GroupMemberData.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    }
    if (json['allMember'] != null && json['allMember'] is Map) {
      allMember = AllMember.fromJson(Map<String, dynamic>.from(json['allMember']));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (subscriptionData != null) {
      data['subscription'] = subscriptionData!.toJson();
    } else if (subscription != null) {
      data['subscription'] = subscription!.map((v) => v.toJson()).toList();
    }
    if (members != null) {
      data['members'] = members!.map((v) => v.toJson()).toList();
    }
    if (private != null) {
      data['private'] = private!.map((v) => v.toJson()).toList();
    }
    if (active != null) {
      data['active'] = active!.map((v) => v.toJson()).toList();
    }
    if (recentActive != null) {
      data['recentActive'] = recentActive!.map((v) => v.toJson()).toList();
    }
    if (allMember != null) {
      data['allMember'] = allMember!.toJson();
    }
    return data;
  }
}

class AllMember {
  MemberMetaData? metaData;
  List<GroupMemberData>? memberList;

  AllMember({this.metaData, this.memberList});

  AllMember.fromJson(Map<String, dynamic> json) {
    if (json['metaData'] != null && json['metaData'] is Map) {
      metaData = MemberMetaData.fromJson(Map<String, dynamic>.from(json['metaData']));
    } else if (json['metadata'] != null && json['metadata'] is Map) {
      metaData = MemberMetaData.fromJson(Map<String, dynamic>.from(json['metadata']));
    }

    final dynamic rawList = json['memberList'] ?? json['members'] ?? json['list'];
    if (rawList != null && rawList is List) {
      memberList = rawList
          .whereType<Map>()
          .map((v) => GroupMemberData.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (metaData != null) {
      data['metaData'] = metaData!.toJson();
    }
    if (memberList != null) {
      data['memberList'] = memberList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MemberMetaData {
  int? totalMembers;
  int? totalOnlineMembers;
  int? totalOfflineMembers;
  int? totalPrivateMembers;
  int? totalNewMembers;

  MemberMetaData({
    this.totalMembers,
    this.totalOnlineMembers,
    this.totalOfflineMembers,
    this.totalPrivateMembers,
    this.totalNewMembers,
  });

  MemberMetaData.fromJson(Map<String, dynamic> json) {
    totalMembers = _toInt(json['totalMembers'] ?? json['total_members']);
    totalOnlineMembers = _toInt(json['totalOnlineMembers'] ?? json['onlineMembers'] ?? json['activeMembers']);
    totalOfflineMembers = _toInt(json['totalOfflineMembers'] ?? json['offlineMembers'] ?? json['inactiveMembers']);
    totalPrivateMembers = _toInt(json['totalPrivateMembers'] ?? json['privateMembers']);
    totalNewMembers = _toInt(json['totalNewMembers'] ?? json['newMembers'] ?? json['newThisMonth']);
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
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class GroupMemberData {
  int? userId;
  String? name;
  String? phone;
  String? profileImage;
  Location? location;
  bool? isLocationSharing;
  dynamic isOnline;
  String? lastSeen;
  String? department;
  String? role;
  String? joinedAt;
  String? startedAt;
  String? createdAt;
  String? subscriptionStatus;
  UserSubscription? subscription;
  List<GroupList>? groupList;

  GroupMemberData({
    this.userId,
    this.name,
    this.phone,
    dynamic mobileNo,
    this.profileImage,
    this.location,
    this.isLocationSharing,
    dynamic locationSharing,
    this.isOnline,
    this.lastSeen,
    this.department,
    this.role,
    this.joinedAt,
    this.startedAt,
    this.createdAt,
    this.subscriptionStatus,
    this.subscription,
    this.groupList,
  }) {
    if (mobileNo != null && (phone == null || phone!.isEmpty)) {
      phone = mobileNo.toString();
    }
    if (locationSharing != null && isLocationSharing == null) {
      isLocationSharing = _toBool(locationSharing);
    }
  }

  String? get mobileNo => phone;
  set mobileNo(String? val) => phone = val;

  bool? get locationSharing => isLocationSharing;
  set locationSharing(dynamic val) => isLocationSharing = _toBool(val);

  double? get latitude => location?.latitude;
  set latitude(double? val) {
    location ??= Location();
    location!.latitude = val;
  }

  double? get longitude => location?.longitude;
  set longitude(double? val) {
    location ??= Location();
    location!.longitude = val;
  }

  bool get online => _toBool(isOnline) ?? false;


  GroupMemberData.fromJson(Map<String, dynamic> json) {
    userId = _toInt(json['userId'] ?? json['id'] ?? json['user_id']);
    name = json['name']?.toString() ?? json['userName']?.toString();
    phone = json['phone']?.toString() ?? json['mobileNo']?.toString();
    profileImage = json['profileImage']?.toString() ?? json['ProfileImage']?.toString() ?? json['image']?.toString();
    if (json['location'] != null && json['location'] is Map) {
      location = Location.fromJson(Map<String, dynamic>.from(json['location']));
    }
    isLocationSharing = _toBool(json['isLocationSharing'] ?? json['locationSharing']);
    isOnline = _toBool(json['isOnline'] ?? json['online']);
    lastSeen = json['lastSeen']?.toString() ?? json['lastActive']?.toString();
    department = json['department']?.toString() ?? json['team']?.toString() ?? json['designation']?.toString();
    role = json['role']?.toString();
    joinedAt = json['joinedAt']?.toString() ?? json['joined_at']?.toString() ?? json['joiningDate']?.toString();
    startedAt = json['startedAt']?.toString() ?? json['started_at']?.toString();
    createdAt = json['createdAt']?.toString() ?? json['created_at']?.toString();
    subscriptionStatus = json['subscriptionStatus']?.toString() ?? json['subscription_status']?.toString();
    if (json['subscription'] != null && json['subscription'] is Map) {
      subscription = UserSubscription.fromJson(
          Map<String, dynamic>.from(json['subscription']));
    }

    final dynamic rawGroupList = json['groupList'] ?? json['groups'];
    if (rawGroupList != null && rawGroupList is List) {
      groupList = rawGroupList
          .whereType<Map>()
          .map((v) => GroupList.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['name'] = name;
    data['phone'] = phone;
    data['profileImage'] = profileImage;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['isLocationSharing'] = isLocationSharing;
    data['isOnline'] = isOnline;
    data['lastSeen'] = lastSeen;
    data['department'] = department;
    data['role'] = role;
    data['joinedAt'] = joinedAt;
    data['startedAt'] = startedAt;
    data['createdAt'] = createdAt;
    if (subscriptionStatus != null) {
      data['subscriptionStatus'] = subscriptionStatus;
    }
    if (subscription != null) {
      data['subscription'] = subscription!.toJson();
    }
    if (groupList != null) {
      data['groupList'] = groupList!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  // --- Display Helpers ---
  String get displayName {
    if (name != null && name!.trim().isNotEmpty && name!.trim().toLowerCase() != 'null') {
      return name!.trim();
    }
    return 'Member';
  }

  String get displayDepartment {
    if (department != null && department!.trim().isNotEmpty && department!.trim().toLowerCase() != 'null') {
      return department!.trim();
    }
    if (role != null && role!.trim().isNotEmpty && role!.trim().toLowerCase() != 'null') {
      return role!.trim();
    }
    if (groupList != null && groupList!.isNotEmpty && groupList!.first.groupName != null) {
      return groupList!.first.groupName!;
    }
    return 'FG Manpower';
  }

  String get resolvedImageUrl {
    if (profileImage == null || profileImage!.trim().isEmpty || profileImage!.trim().toLowerCase() == 'null') {
      return '';
    }
    final clean = profileImage!.trim();
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return clean;
    }
    return '${ConstRes.aImageBaseUrl}$clean';
  }

  bool get effectiveIsOnline => isOnline == true;

  bool get isGhostMode => isLocationSharing == false;

  String get formattedJoinedAt {
    final raw = joinedAt ?? createdAt;
    if (raw == null || raw.trim().isEmpty) return 'Recent';
    try {
      final dt = DateTime.parse(raw.trim());
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return raw.trim();
    }
  }

  String get formattedStartedAt {
    final raw = startedAt ?? createdAt ?? lastSeen;
    if (raw == null || raw.trim().isEmpty) return 'Just now';
    try {
      final dt = DateTime.parse(raw.trim());
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return raw.trim();
    }
  }

  String get formattedLastSeen {
    if (lastSeen == null || lastSeen!.trim().isEmpty) return 'Offline';
    try {
      final dt = DateTime.parse(lastSeen!.trim());
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('dd MMM').format(dt);
    } catch (_) {
      return lastSeen!.trim();
    }
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value == 1 || value == '1' || value.toString().toLowerCase() == 'true') return true;
    if (value == 0 || value == '0' || value.toString().toLowerCase() == 'false') return false;
    return null;
  }
}

// Typedef aliases for direct compatibility
typedef Private = GroupMemberData;
typedef Active = GroupMemberData;
typedef RecentActive = GroupMemberData;
typedef MemberList = GroupMemberData;
typedef OnlineMemberData = GroupMemberData;
typedef GhostMemberData = GroupMemberData;
typedef UserMemberData = GroupMemberData;
typedef GhostMemberModel = GroupMemberModel;
typedef OnlineMemberModel = GroupMemberModel;
typedef MemberLiveStatus = GroupMemberModel;
typedef GroupMemberMetaData = MemberMetaData;


class Location {
  double? latitude;
  double? longitude;
  String? area;
  String? city;

  Location({this.latitude, this.longitude, this.area, this.city});

  Location.fromJson(Map<String, dynamic> json) {
    latitude = _toDouble(json['latitude'] ?? json['lat']);
    longitude = _toDouble(json['longitude'] ?? json['lng'] ?? json['lon']);
    area = json['area']?.toString();
    city = json['city']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'area': area,
      'city': city,
    };
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class GroupList {
  int? groupId;
  String? groupName;
  String? groupProfile;
  int? isActive;

  GroupList({
    this.groupId,
    this.groupName,
    this.groupProfile,
    this.isActive,
  });

  GroupList.fromJson(Map<String, dynamic> json) {
    groupId = _toInt(json['groupId'] ?? json['id']);
    groupName = json['groupName']?.toString();
    groupProfile = json['groupProfile']?.toString();
    isActive = _toInt(json['isActive']);
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'groupProfile': groupProfile,
      'isActive': isActive,
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
