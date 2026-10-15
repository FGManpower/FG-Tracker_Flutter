class GroupProfileDetailsModel {
  bool? status;
  String? message;
  GroupProfileData? data;

  GroupProfileDetailsModel({this.status, this.message, this.data});

  factory GroupProfileDetailsModel.fromJson(Map<String, dynamic> json) {
    return GroupProfileDetailsModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? GroupProfileData.fromJson(json['data']) : null,
    );
  }
}

class GroupProfileData {
  String? chatType;
  GroupDetailsInfo? group;
  MyStatus? myStatus;
  GroupPermissions? permissions;
  GroupMembersSummary? membersSummary;
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

  factory GroupProfileData.fromJson(Map<String, dynamic> json) {
    return GroupProfileData(
      chatType: json['chatType'],
      group: json['group'] != null ? GroupDetailsInfo.fromJson(json['group']) : null,
      myStatus: json['myStatus'] != null ? MyStatus.fromJson(json['myStatus']) : null,
      permissions: json['permissions'] != null ? GroupPermissions.fromJson(json['permissions']) : null,
      membersSummary: json['membersSummary'] != null ? GroupMembersSummary.fromJson(json['membersSummary']) : null,
      members: json['members'] != null
          ? (json['members'] as List).map((i) => GroupMemberInfo.fromJson(i)).toList()
          : null,
      mediaSummary: json['mediaSummary'] != null ? GroupMediaSummary.fromJson(json['mediaSummary']) : null,
      media: json['media'] != null ? GroupMediaDetails.fromJson(json['media']) : null,
    );
  }
}

class GroupDetailsInfo {
  int? groupId;
  String? groupName;
  String? groupProfile;
  String? groupCode;
  String? description;
  int? createdBy;

  GroupDetailsInfo({
    this.groupId,
    this.groupName,
    this.groupProfile,
    this.groupCode,
    this.description,
    this.createdBy,
  });

  factory GroupDetailsInfo.fromJson(Map<String, dynamic> json) {
    return GroupDetailsInfo(
      groupId: json['groupId'] ?? json['id'],
      groupName: json['groupName'] ?? json['name'],
      groupProfile: json['groupProfile'] ?? json['image'],
      groupCode: json['groupCode'] ?? json['code'],
      description: json['description'],
      createdBy: json['createdBy'],
    );
  }
}

class MyStatus {
  bool? isMember;
  bool? isAdmin;
  bool? isCreator;

  MyStatus({this.isMember, this.isAdmin, this.isCreator});

  factory MyStatus.fromJson(Map<String, dynamic> json) {
    return MyStatus(
      isMember: json['isMember'],
      isAdmin: json['isAdmin'],
      isCreator: json['isCreator'],
    );
  }
}

class GroupPermissions {
  bool? canSendMessage;
  bool? canEditGroup;
  bool? canAddMember;
  bool? canLeaveGroup;

  GroupPermissions({
    this.canSendMessage,
    this.canEditGroup,
    this.canAddMember,
    this.canLeaveGroup,
  });

  factory GroupPermissions.fromJson(Map<String, dynamic> json) {
    return GroupPermissions(
      canSendMessage: json['canSendMessage'],
      canEditGroup: json['canEditGroup'],
      canAddMember: json['canAddMember'],
      canLeaveGroup: json['canLeaveGroup'],
    );
  }
}

class GroupMembersSummary {
  int? totalMembers;
  int? onlineMembersCount;

  GroupMembersSummary({this.totalMembers, this.onlineMembersCount});

  factory GroupMembersSummary.fromJson(Map<String, dynamic> json) {
    return GroupMembersSummary(
      totalMembers: json['totalMembers'],
      onlineMembersCount: json['onlineMembersCount'],
    );
  }
}

class GroupMemberInfo {
  int? userId;
  String? name;
  String? profileImage;
  bool? isAdmin;
  bool? isMe;
  bool? isOnline;
  dynamic rawLastSeen;
  String? lastSeen;
  bool? locationSharing;

  GroupMemberInfo({
    this.userId,
    this.name,
    this.profileImage,
    this.isAdmin,
    this.isMe,
    this.isOnline,
    this.rawLastSeen,
    this.lastSeen,
    this.locationSharing,
  });

  factory GroupMemberInfo.fromJson(Map<String, dynamic> json) {
    return GroupMemberInfo(
      userId: json['userId'] ?? json['id'],
      name: json['name'],
      profileImage: json['profileImage'] ?? json['image'],
      isAdmin: json['isAdmin'],
      isMe: json['isMe'],
      isOnline: json['isOnline'],
      rawLastSeen: json['rawLastSeen'] ?? json['lastSeen'],
      lastSeen: json['lastSeen']?.toString(),
      locationSharing: json['locationSharing'],
    );
  }
}

class GroupMediaSummary {
  int? totalMedia;
  int? photosCount;
  int? videosCount;
  int? audioCount;
  int? documentsCount;
  int? linksCount;

  GroupMediaSummary({
    this.totalMedia,
    this.photosCount,
    this.videosCount,
    this.audioCount,
    this.documentsCount,
    this.linksCount,
  });

  factory GroupMediaSummary.fromJson(Map<String, dynamic> json) {
    return GroupMediaSummary(
      totalMedia: json['totalMedia'],
      photosCount: json['photosCount'],
      videosCount: json['videosCount'],
      audioCount: json['audioCount'],
      documentsCount: json['documentsCount'],
      linksCount: json['linksCount'],
    );
  }
}

class GroupMediaDetails {
  String? filter;
  List<GroupMediaItem>? photos;
  List<GroupMediaItem>? videos;
  List<GroupMediaItem>? audio;
  List<GroupMediaItem>? documents;
  List<GroupMediaItem>? links;
  List<GroupMediaItem>? items;

  GroupMediaDetails({
    this.filter,
    this.photos,
    this.videos,
    this.audio,
    this.documents,
    this.links,
    this.items,
  });

  factory GroupMediaDetails.fromJson(Map<String, dynamic> json) {
    return GroupMediaDetails(
      filter: json['filter'],
      photos: json['photos'] != null
          ? (json['photos'] as List).map((i) => GroupMediaItem.fromJson(i)).toList()
          : null,
      videos: json['videos'] != null
          ? (json['videos'] as List).map((i) => GroupMediaItem.fromJson(i)).toList()
          : null,
      audio: json['audio'] != null
          ? (json['audio'] as List).map((i) => GroupMediaItem.fromJson(i)).toList()
          : null,
      documents: json['documents'] != null
          ? (json['documents'] as List).map((i) => GroupMediaItem.fromJson(i)).toList()
          : null,
      links: json['links'] != null
          ? (json['links'] as List).map((i) => GroupMediaItem.fromJson(i)).toList()
          : null,
      items: json['items'] != null
          ? (json['items'] as List).map((i) => GroupMediaItem.fromJson(i)).toList()
          : null,
    );
  }
}

class GroupMediaItem {
  int? id;
  String? type;
  String? url;
  String? displayUrl;
  String? link;
  String? domain;
  String? text;
  String? caption;
  int? senderId;
  String? senderName;
  bool? isOutgoing;
  String? createdAt;
  String? timestamp;

  GroupMediaItem({
    this.id,
    this.type,
    this.url,
    this.displayUrl,
    this.link,
    this.domain,
    this.text,
    this.caption,
    this.senderId,
    this.senderName,
    this.isOutgoing,
    this.createdAt,
    this.timestamp,
  });

  factory GroupMediaItem.fromJson(Map<String, dynamic> json) {
    return GroupMediaItem(
      id: json['id'],
      type: json['type'],
      url: json['url'] ?? json['link'] ?? json['mediaUrl'] ?? json['fileUrl'] ?? json['file_url'],
      displayUrl: json['displayUrl'] ??
          json['display_url'] ??
          json['thumbnail'] ??
          json['thumb'] ??
          json['poster'] ??
          json['cover'] ??
          json['preview'],
      link: json['link'],
      domain: json['domain'],
      text: json['text'],
      caption: json['caption'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      isOutgoing: json['isOutgoing'],
      createdAt: json['createdAt'],
      timestamp: json['timestamp'],
    );
  }
}