class InitializeModel {
  bool? status;
  String? message;
  InitializeData? data;

  InitializeModel({this.status, this.message, this.data});

  factory InitializeModel.fromJson(Map<String, dynamic> json) {
    return InitializeModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? InitializeData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class InitializeData {
  String? initializedAt;
  String? serverTime;
  WalkieInitData? walkie;
  dynamic calling;
  dynamic chat;
  dynamic tracking;
  dynamic safeRoute;
  dynamic notifications;

  InitializeData({
    this.initializedAt,
    this.serverTime,
    this.walkie,
    this.calling,
    this.chat,
    this.tracking,
    this.safeRoute,
    this.notifications,
  });

  factory InitializeData.fromJson(Map<String, dynamic> json) {
    return InitializeData(
      initializedAt: json['initializedAt']?.toString(),
      serverTime: json['serverTime']?.toString(),
      walkie: json['walkie'] != null
          ? WalkieInitData.fromJson(json['walkie'])
          : null,
      calling: json['calling'],
      chat: json['chat'],
      tracking: json['tracking'],
      safeRoute: json['safeRoute'],
      notifications: json['notifications'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'initializedAt': initializedAt,
      'serverTime': serverTime,
      'walkie': walkie?.toJson(),
      'calling': calling,
      'chat': chat,
      'tracking': tracking,
      'safeRoute': safeRoute,
      'notifications': notifications,
    };
  }
}

class WalkieInitData {
  WalkieAccess? access;
  dynamic currentSubscription;
  List<dynamic>? subscriptions;
  dynamic trial;
  List<WalkieAlert>? alerts;
  WalkieActions? actions;

  WalkieInitData({
    this.access,
    this.currentSubscription,
    this.subscriptions,
    this.trial,
    this.alerts,
    this.actions,
  });

  factory WalkieInitData.fromJson(Map<String, dynamic> json) {
    return WalkieInitData(
      access: json['access'] != null
          ? WalkieAccess.fromJson(json['access'])
          : null,
      currentSubscription: json['currentSubscription'],
      subscriptions: json['subscriptions'] != null
          ? List<dynamic>.from(json['subscriptions'])
          : [],
      trial: json['trial'],
      alerts: json['alerts'] != null
          ? (json['alerts'] as List)
              .map((e) => WalkieAlert.fromJson(e))
              .toList()
          : [],
      actions: json['actions'] != null
          ? WalkieActions.fromJson(json['actions'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': access?.toJson(),
      'currentSubscription': currentSubscription,
      'subscriptions': subscriptions,
      'trial': trial,
      'alerts': alerts?.map((e) => e.toJson()).toList(),
      'actions': actions?.toJson(),
    };
  }
}

class WalkieAccess {
  bool? canUseWalkie;
  String? accessType;

  WalkieAccess({this.canUseWalkie, this.accessType});

  factory WalkieAccess.fromJson(Map<String, dynamic> json) {
    return WalkieAccess(
      canUseWalkie: json['canUseWalkie'] == true,
      accessType: json['accessType']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'canUseWalkie': canUseWalkie,
      'accessType': accessType,
    };
  }
}

class WalkieAlert {
  String? type;
  String? severity;
  String? title;
  String? message;

  WalkieAlert({this.type, this.severity, this.title, this.message});

  factory WalkieAlert.fromJson(Map<String, dynamic> json) {
    return WalkieAlert(
      type: json['type']?.toString(),
      severity: json['severity']?.toString(),
      title: json['title']?.toString(),
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'severity': severity,
      'title': title,
      'message': message,
    };
  }
}

class WalkieActions {
  bool? showSubscribe;
  bool? showRenew;

  WalkieActions({this.showSubscribe, this.showRenew});

  factory WalkieActions.fromJson(Map<String, dynamic> json) {
    return WalkieActions(
      showSubscribe: json['showSubscribe'] == true,
      showRenew: json['showRenew'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showSubscribe': showSubscribe,
      'showRenew': showRenew,
    };
  }
}
