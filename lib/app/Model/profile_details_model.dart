class ProfileDetailsModel {
  bool? status;
  String? message;
  ProfileDetailsData? data;

  ProfileDetailsModel({this.status, this.message, this.data});

  factory ProfileDetailsModel.fromJson(Map<String, dynamic> json) =>
      ProfileDetailsModel(
        status: json['status'],
        message: json['message'],
        data: json['data'] != null
            ? ProfileDetailsData.fromJson(json['data'])
            : null,
      );
}

class ProfileDetailsData {
  String? chatType;
  int? chatId;
  UserDetails? user;
  BlockStatus? blockStatus;
  ChatSettings? chatSettings;
  MediaSummary? mediaSummary;
  MediaDetails? media;

  ProfileDetailsData({
    this.chatType,
    this.chatId,
    this.user,
    this.blockStatus,
    this.chatSettings,
    this.mediaSummary,
    this.media,
  });

  factory ProfileDetailsData.fromJson(Map<String, dynamic> json) =>
      ProfileDetailsData(
        chatType: json['chatType'],
        chatId: json['chatId'],
        user: json['user'] != null ? UserDetails.fromJson(json['user']) : null,
        blockStatus: json['blockStatus'] != null
            ? BlockStatus.fromJson(json['blockStatus'])
            : null,
        chatSettings: json['chatSettings'] != null
            ? ChatSettings.fromJson(json['chatSettings'])
            : null,
        mediaSummary: json['mediaSummary'] != null
            ? MediaSummary.fromJson(json['mediaSummary'])
            : null,
        media:
        json['media'] != null ? MediaDetails.fromJson(json['media']) : null,
      );
}

class UserDetails {
  int? userId;
  String? name;
  String? phone;
  String? mobileNo;
  String? profileImage;
  String? gender;
  bool? isOnline;
  String? lastSeen;
  String? rawLastSeen;
  bool? locationSharing;
  LocationData? location;

  UserDetails({
    this.userId,
    this.name,
    this.phone,
    this.mobileNo,
    this.profileImage,
    this.gender,
    this.isOnline,
    this.lastSeen,
    this.rawLastSeen,
    this.locationSharing,
    this.location,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
    userId: json['userId'],
    name: json['name'],
    phone: json['phone'],
    mobileNo: json['mobileNo'],
    profileImage: json['profileImage'],
    gender: json['gender'],
    isOnline: json['isOnline'],
    lastSeen: json['lastSeen'],
    rawLastSeen: json['rawLastSeen'],
    locationSharing: json['locationSharing'],
    location: json['location'] != null
        ? LocationData.fromJson(json['location'])
        : null,
  );
}

class LocationData {
  String? area;
  String? city;

  LocationData({this.area, this.city});

  factory LocationData.fromJson(Map<String, dynamic> json) => LocationData(
    area: json['area'],
    city: json['city'],
  );
}

class BlockStatus {
  bool? isBlocked;
  bool? blockedByMe;
  bool? canMessage;

  BlockStatus({this.isBlocked, this.blockedByMe, this.canMessage});

  factory BlockStatus.fromJson(Map<String, dynamic> json) => BlockStatus(
    isBlocked: json['isBlocked'],
    blockedByMe: json['blockedByMe'],
    canMessage: json['canMessage'],
  );
}

class ChatSettings {
  bool? isMuted;
  bool? isPinned;
  bool? isArchived;

  ChatSettings({this.isMuted, this.isPinned, this.isArchived});

  factory ChatSettings.fromJson(Map<String, dynamic> json) => ChatSettings(
    isMuted: json['isMuted'],
    isPinned: json['isPinned'],
    isArchived: json['isArchived'],
  );
}

class MediaSummary {
  int? totalMedia;
  int? photosCount;
  int? videosCount;
  int? audioCount;
  int? documentsCount;
  int? linksCount;

  MediaSummary({
    this.totalMedia,
    this.photosCount,
    this.videosCount,
    this.audioCount,
    this.documentsCount,
    this.linksCount,
  });

  factory MediaSummary.fromJson(Map<String, dynamic> json) => MediaSummary(
    totalMedia: json['totalMedia'],
    photosCount: json['photosCount'],
    videosCount: json['videosCount'],
    audioCount: json['audioCount'],
    documentsCount: json['documentsCount'],
    linksCount: json['linksCount'],
  );
}

class MediaDetails {
  String? filter;
  List<MediaItem>? photos;
  List<MediaItem>? videos;
  List<MediaItem>? audio;
  List<MediaItem>? documents;
  List<MediaItem>? links;
  List<MediaItem>? items;

  MediaDetails({
    this.filter,
    this.photos,
    this.videos,
    this.audio,
    this.documents,
    this.links,
    this.items,
  });

  factory MediaDetails.fromJson(Map<String, dynamic> json) => MediaDetails(
    filter: json['filter'],
    photos: json['photos'] != null
        ? List<MediaItem>.from(
        json['photos'].map((x) => MediaItem.fromJson(x, 'image')))
        : [],
    videos: json['videos'] != null
        ? List<MediaItem>.from(
        json['videos'].map((x) => MediaItem.fromJson(x, 'video')))
        : [],
    audio: json['audio'] != null
        ? List<MediaItem>.from(
        json['audio'].map((x) => MediaItem.fromJson(x, 'audio')))
        : [],
    documents: json['documents'] != null
        ? List<MediaItem>.from(json['documents']
        .map((x) => MediaItem.fromJson(x, 'document')))
        : [],
    links: json['links'] != null
        ? List<MediaItem>.from(
        json['links'].map((x) => MediaItem.fromJson(x, 'link')))
        : [],
    items: json['items'] != null
        ? List<MediaItem>.from(
        json['items'].map((x) => MediaItem.fromJson(x, x['type'] ?? '')))
        : [],
  );
}

class MediaItem {
  int? id;
  String? url;
  String? displayUrl;
  String? type;
  String? link;
  String? domain;
  String? text;
  String? caption;

  MediaItem({
    this.id,
    this.url,
    this.displayUrl,
    this.type,
    this.link,
    this.domain,
    this.text,
    this.caption,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json, [String? fallbackType]) {
    final type = (json['type'] ?? fallbackType ?? '').toString();

    return MediaItem(
      id: json['id'],
      url: json['url'] ??
          json['link'] ??
          json['mediaUrl'] ??
          json['fileUrl'] ??
          json['file_url'],
      displayUrl: json['displayUrl'] ??
          json['display_url'] ??
          json['thumbnail'] ??
          json['thumb'] ??
          json['poster'] ??
          json['cover'] ??
          json['preview'] ??
          json['imageUrl'],
      type: type,
      link: json['link'],
      domain: json['domain'],
      text: json['text'],
      caption: json['caption'],
    );
  }
}