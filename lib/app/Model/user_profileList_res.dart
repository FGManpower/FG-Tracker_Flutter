class UserProfileListRes {
  bool? status;
  String? message;
  List<UserListData>? userData;

  UserProfileListRes({this.status, this.message, this.userData});

  UserProfileListRes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['UserData'] != null) {
      userData = <UserListData>[];
      json['UserData'].forEach((v) {
        userData!.add(UserListData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (userData != null) {
      data['UserData'] = userData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


class UserListData {
  int? userId;
  String? profileImage;
  String? name;
  String? mobileNo;
  bool? isOnline;

  int? chatId;
  int? conversationId;
  int? privateChatId;

  UserListData({
    this.userId,
    this.profileImage,
    this.name,
    this.mobileNo,
    this.isOnline,
    this.chatId,
    this.conversationId,
    this.privateChatId,
  });

  int? _parseId(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return null;
    }
    return int.tryParse(value.toString());
  }

  UserListData.fromJson(Map<String, dynamic> json) {
    userId = _parseId(
      json['UserId'] ?? json['userId'] ?? json['id'],
    );

    profileImage =
        json['ProfileImage'] ?? json['profileImage'] ?? json['image'];

    name = json['Name'] ?? json['name'];

    mobileNo =
        json['MobileNo'] ?? json['mobileNo'] ?? json['phone'];

    isOnline = json['isOnline'] == true ||
        json['is_online'] == true ||
        json['online'] == true ||
        json['isOnline']?.toString() == '1' ||
        json['is_online']?.toString() == '1';

    chatId = _parseId(
      json['chatId'] ?? json['chat_id'],
    );

    conversationId = _parseId(
      json['conversationId'] ?? json['conversation_id'],
    );

    privateChatId = _parseId(
      json['privateChatId'] ?? json['private_chat_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['UserId'] = userId;
    data['ProfileImage'] = profileImage;
    data['Name'] = name;
    data['MobileNo'] = mobileNo;
    data['isOnline'] = isOnline;

    data['chatId'] = chatId;
    data['conversationId'] = conversationId;
    data['privateChatId'] = privateChatId;

    return data;
  }
}
