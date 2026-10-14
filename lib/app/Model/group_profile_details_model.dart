class GroupProfileDetailsModel {
  bool? status;
  String? message;
  GroupProfileData? data;

  GroupProfileDetailsModel({this.status, this.message, this.data});

  factory GroupProfileDetailsModel.fromJson(Map<String, dynamic> json) =>
      GroupProfileDetailsModel(
        status: json['status'],
        message: json['message'],
        data: json['data'] != null ? GroupProfileData.fromJson(json['data']) : null,
      );
}

class GroupProfileData {
  String? chatType;
  GroupInfo? group;
  MyStatus? myStatus;
  Permissions? permissions;
  MembersSummary? membersSummary;
  List<GroupMemberInfo>? members;
  GroupMediaSummary? mediaSummary;
  GroupMediaDetails? media;

  GroupProfileData({
    this.chatType,
    this.group,
    this.myStatus,
    this.permissions,
    this.membersSummary,
    this.members,
    this.mediaSummary,
    this.media,
  });

  factory GroupProfileData.fromJson(Map<String, dynamic> json) => GroupProfileData(
    chatType: json['chatType'],
    group: json['group'] != null ? GroupInfo.fromJson(json['group']) : null,
    myStatus: json['myStatus'] != null ? MyStatus.fromJson(json['myStatus']) : null,
    permissions: json['permissions'] != null ? Permissions.fromJson(json['permissions']) : null,
    membersSummary: json['membersSummary'] != null ? MembersSummary.fromJson(json['membersSummary']) : null,
    members: json['members'] != null ? List<GroupMemberInfo>.from(json['members'].map((x) => GroupMemberInfo.fromJson(x))) : [],
    mediaSummary: json['mediaSummary'] != null ? GroupMediaSummary.fromJson(json['mediaSummary']) : null,
    media: json['media'] != null ? GroupMediaDetails.fromJson(json['media']) : null,
  );
}

class GroupInfo {
  int? groupId;
  String? groupName;
  String? groupDesc;
  String? groupProfile;
  String? groupCode;
  bool? isActive;

  GroupInfo({this.groupId, this.groupName, this.groupDesc, this.groupProfile, this.groupCode, this.isActive});

  factory GroupInfo.fromJson(Map<String, dynamic> json) => GroupInfo(
    groupId: json['groupId'],
    groupName: json['groupName'],
    groupDesc: json['groupDesc'],
    groupProfile: json['groupProfile'],
    groupCode: json['groupCode'],
    isActive: json['isActive'],
  );
}

class MyStatus {
  bool? isMember;
  bool? isAdmin;
  bool? isCreator;

  MyStatus({this.isMember, this.isAdmin, this.isCreator});

  factory MyStatus.fromJson(Map<String, dynamic> json) => MyStatus(
    isMember: json['isMember'],
    isAdmin: json['isAdmin'],
    isCreator: json['isCreator'],
  );
}

class Permissions {
  bool? canEditGroup;
  bool? canDeleteGroup;
  bool? canAddMember;
  bool? canLeaveGroup;

  Permissions({this.canEditGroup, this.canDeleteGroup, this.canAddMember, this.canLeaveGroup});

  factory Permissions.fromJson(Map<String, dynamic> json) => Permissions(
    canEditGroup: json['canEditGroup'],
    canDeleteGroup: json['canDeleteGroup'],
    canAddMember: json['canAddMember'],
    canLeaveGroup: json['canLeaveGroup'],
  );
}

class MembersSummary {
  int? totalMembers;
  int? onlineMembersCount;

  MembersSummary({this.totalMembers, this.onlineMembersCount});

  factory MembersSummary.fromJson(Map<String, dynamic> json) => MembersSummary(
    totalMembers: json['totalMembers'],
    onlineMembersCount: json['onlineMembersCount'],
  );
}

class GroupMemberInfo {
  int? userId;
  int? memberId;
  String? name;
  String? profileImage;
  bool? isAdmin;
  bool? isCreator;
  bool? isOnline;
  String? lastSeen;
  String? rawLastSeen;
  bool? locationSharing;
  bool? isMe;

  GroupMemberInfo({
    this.userId,
    this.memberId,
    this.name,
    this.profileImage,
    this.isAdmin,
    this.isCreator,
    this.isOnline,
    this.lastSeen,
    this.rawLastSeen,
    this.locationSharing,
    this.isMe,
  });

  factory GroupMemberInfo.fromJson(Map<String, dynamic> json) => GroupMemberInfo(
    userId: json['userId'],
    memberId: json['memberId'],
    name: json['name'],
    profileImage: json['profileImage'],
    isAdmin: json['isAdmin'],
    isCreator: json['isCreator'],
    isOnline: json['isOnline'],
    lastSeen: json['lastSeen'],
    rawLastSeen: json['rawLastSeen'],
    locationSharing: json['locationSharing'],
    isMe: json['isMe'],
  );
}

class GroupMediaSummary {
  int? totalMedia;

  GroupMediaSummary({this.totalMedia});

  factory GroupMediaSummary.fromJson(Map<String, dynamic> json) => GroupMediaSummary(
    totalMedia: json['totalMedia'],
  );
}

class GroupMediaDetails {
  List<GroupMediaItem>? photos;
  List<GroupMediaItem>? videos;

  GroupMediaDetails({this.photos, this.videos});

  factory GroupMediaDetails.fromJson(Map<String, dynamic> json) => GroupMediaDetails(
    photos: json['photos'] != null ? List<GroupMediaItem>.from(json['photos'].map((x) => GroupMediaItem.fromJson(x, 'image'))) : [],
    videos: json['videos'] != null ? List<GroupMediaItem>.from(json['videos'].map((x) => GroupMediaItem.fromJson(x, 'video'))) : [],
  );
}

class GroupMediaItem {
  int? id;
  String? url;
  String? displayUrl;
  String? type;

  GroupMediaItem({this.id, this.url, this.displayUrl, this.type});

  factory GroupMediaItem.fromJson(Map<String, dynamic> json, String type) => GroupMediaItem(
    id: json['id'],
    url: json['url'],
    displayUrl: type == 'video' ? json['thumbnail'] : json['imageUrl'],
    type: type,
  );
}