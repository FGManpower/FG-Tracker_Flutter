class WalkieChannelsResponse {
  bool? status;
  String? message;
  WalkieChannelsData? data;

  WalkieChannelsResponse({this.status, this.message, this.data});

  WalkieChannelsResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'] ?? json['success'] ?? false;
    message = json['message']?.toString();
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      data = WalkieChannelsData.fromJson(json['data']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class WalkieChannelsData {
  int? activeChannelId;
  int? activeNotificationGroupId;
  List<WalkieChannelItem> channels = [];

  WalkieChannelsData({
    this.activeChannelId,
    this.activeNotificationGroupId,
    this.channels = const [],
  });

  WalkieChannelsData.fromJson(Map<String, dynamic> json) {
    if (json['activeChannelId'] != null) {
      activeChannelId = int.tryParse(json['activeChannelId'].toString());
    }
    if (json['activeNotificationGroupId'] != null) {
      activeNotificationGroupId =
          int.tryParse(json['activeNotificationGroupId'].toString());
    }
    if (json['channels'] != null && json['channels'] is List) {
      channels = (json['channels'] as List)
          .map((item) => WalkieChannelItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['activeChannelId'] = activeChannelId;
    map['activeNotificationGroupId'] = activeNotificationGroupId;
    map['channels'] = channels.map((c) => c.toJson()).toList();
    return map;
  }
}

class WalkieChannelItem {
  int groupId;
  String groupName;
  String? groupDesc;
  String? groupProfile;
  String? groupImage;
  String? groupCode;
  int memberCount;
  bool isSelectedChannel;
  bool notificationsEnabled;
  bool isChannelSpeaking;
  int? activeSpeakerId;
  String? activeSpeakerName;
  String? activeSpeakerImage;
  bool isOnline;

  WalkieChannelItem({
    required this.groupId,
    required this.groupName,
    this.groupDesc,
    this.groupProfile,
    this.groupImage,
    this.groupCode,
    this.memberCount = 0,
    this.isSelectedChannel = false,
    this.notificationsEnabled = true,
    this.isChannelSpeaking = false,
    this.activeSpeakerId,
    this.activeSpeakerName,
    this.activeSpeakerImage,
    this.isOnline = true,
  });

  factory WalkieChannelItem.fromJson(Map<String, dynamic> json) {
    final rawGroupId = json['groupId'] ?? json['id'] ?? 0;
    final parsedGroupId = int.tryParse(rawGroupId.toString()) ?? 0;

    final rawSpeakerId = json['activeSpeakerId'] ?? json['speakerId'];
    final parsedSpeakerId = rawSpeakerId != null
        ? int.tryParse(rawSpeakerId.toString())
        : null;

    final profileStr = (json['groupProfile'] ??
            json['groupImage'] ??
            json['group_profile'] ??
            json['group_image'] ??
            json['profileImage'] ??
            json['image'] ??
            json['profile'] ??
            '')
        .toString()
        .trim();

    return WalkieChannelItem(
      groupId: parsedGroupId,
      groupName: (json['groupName'] ?? json['name'] ?? 'Unnamed Channel').toString(),
      groupDesc: json['groupDesc']?.toString(),
      groupProfile: profileStr.isNotEmpty ? profileStr : null,
      groupImage: profileStr.isNotEmpty ? profileStr : null,
      groupCode: json['groupCode']?.toString(),
      memberCount: int.tryParse((json['memberCount'] ?? 0).toString()) ?? 0,
      isSelectedChannel: json['isSelectedChannel'] == true ||
          json['isActiveChannel'] == true,
      notificationsEnabled: json['notificationsEnabled'] == true ||
          json['notifications_enabled'] == true ||
          json['notificationsEnabled'] == 1 ||
          json['notifications_enabled'] == 1 ||
          json['notificationsEnabled']?.toString().toLowerCase() == 'true',
      isChannelSpeaking: json['isChannelSpeaking'] == true ||
          json['isSpeaking'] == true,
      activeSpeakerId: parsedSpeakerId,
      activeSpeakerName: json['activeSpeakerName']?.toString() ??
          json['speakerName']?.toString(),
      activeSpeakerImage: json['activeSpeakerImage']?.toString() ??
          json['speakerImage']?.toString(),
      isOnline: json['isOnline'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'groupDesc': groupDesc,
      'groupProfile': groupProfile,
      'groupImage': groupImage,
      'groupCode': groupCode,
      'memberCount': memberCount,
      'isSelectedChannel': isSelectedChannel,
      'notificationsEnabled': notificationsEnabled,
      'isChannelSpeaking': isChannelSpeaking,
      'activeSpeakerId': activeSpeakerId,
      'activeSpeakerName': activeSpeakerName,
      'activeSpeakerImage': activeSpeakerImage,
      'isOnline': isOnline,
    };
  }

  WalkieChannelItem copyWith({
    int? groupId,
    String? groupName,
    String? groupDesc,
    String? groupProfile,
    String? groupImage,
    String? groupCode,
    int? memberCount,
    bool? isSelectedChannel,
    bool? notificationsEnabled,
    bool? isChannelSpeaking,
    int? activeSpeakerId,
    String? activeSpeakerName,
    String? activeSpeakerImage,
    bool? isOnline,
  }) {
    return WalkieChannelItem(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      groupDesc: groupDesc ?? this.groupDesc,
      groupProfile: groupProfile ?? this.groupProfile,
      groupImage: groupImage ?? this.groupImage,
      groupCode: groupCode ?? this.groupCode,
      memberCount: memberCount ?? this.memberCount,
      isSelectedChannel: isSelectedChannel ?? this.isSelectedChannel,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isChannelSpeaking: isChannelSpeaking ?? this.isChannelSpeaking,
      activeSpeakerId: activeSpeakerId ?? this.activeSpeakerId,
      activeSpeakerName: activeSpeakerName ?? this.activeSpeakerName,
      activeSpeakerImage: activeSpeakerImage ?? this.activeSpeakerImage,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
