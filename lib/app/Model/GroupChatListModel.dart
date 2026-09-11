class GroupChatListResponse {
  bool? status;
  String? message;
  GroupChatPagination? pagination;
  List<GroupChatData>? data;

  GroupChatListResponse({
    this.status,
    this.message,
    this.pagination,
    this.data,
  });

  GroupChatListResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];

    pagination = json['pagination'] != null
        ? GroupChatPagination.fromJson(json['pagination'])
        : null;

    if (json['data'] != null) {
      data = <GroupChatData>[];
      for (var item in json['data']) {
        data!.add(GroupChatData.fromJson(item));
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'pagination': pagination?.toJson(),
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class GroupChatPagination {
  int? currentPage;
  int? perPage;
  int? totalRecords;
  int? totalPages;
  bool? hasNextPage;
  bool? hasPreviousPage;

  GroupChatPagination({
    this.currentPage,
    this.perPage,
    this.totalRecords,
    this.totalPages,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  GroupChatPagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    perPage = json['perPage'];
    totalRecords = json['totalRecords'];
    totalPages = json['totalPages'];
    hasNextPage = json['hasNextPage'];
    hasPreviousPage = json['hasPreviousPage'];
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'perPage': perPage,
      'totalRecords': totalRecords,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }
}

class GroupChatData {
  int? groupId;
  String? groupName;
  String? groupProfile;
  GroupLastMessage? lastMessage;
  bool? isOnline;
  int? unreadCount;

  GroupChatData({
    this.groupId,
    this.groupName,
    this.groupProfile,
    this.lastMessage,
    this.isOnline,
    this.unreadCount,
  });

  GroupChatData.fromJson(Map<String, dynamic> json) {
    groupId = json['groupId'];
    groupName = json['groupName'];
    groupProfile = json['groupProfile'];

    lastMessage = json['lastMessage'] != null
        ? GroupLastMessage.fromJson(json['lastMessage'])
        : null;

    isOnline = json['isOnline'];
    unreadCount = json['unreadCount'];
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'groupProfile': groupProfile,
      'lastMessage': lastMessage?.toJson(),
      'isOnline': isOnline,
      'unreadCount': unreadCount,
    };
  }
}

class GroupLastMessage {
  int? id;
  int? senderId;
  String? senderName;
  String? senderImage;
  String? messageType;
  String? content;
  String? caption;
  String? timestamp;
  int? isDeletedForEveryone;
  int? isEdited;
  String? editedAt;

  GroupLastMessage({
    this.id,
    this.senderId,
    this.senderName,
    this.senderImage,
    this.messageType,
    this.content,
    this.caption,
    this.timestamp,
    this.isDeletedForEveryone,
    this.isEdited,
    this.editedAt,
  });

  GroupLastMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    senderId = json['senderId'];
    senderName = json['senderName'];
    senderImage = json['senderImage'];
    messageType = json['messageType'];
    content = json['content'];
    caption = json['caption'];
    timestamp = json['timestamp'];
    isDeletedForEveryone = json['isDeletedForEveryone'];
    isEdited = json['isEdited'];
    editedAt = json['editedAt'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderImage': senderImage,
      'messageType': messageType,
      'content': content,
      'caption': caption,
      'timestamp': timestamp,
      'isDeletedForEveryone': isDeletedForEveryone,
      'isEdited': isEdited,
      'editedAt': editedAt,
    };
  }
}