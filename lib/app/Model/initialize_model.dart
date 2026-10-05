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
  PaymentInitData? payment;
  WalkieInitData? walkie;
  dynamic calling;
  dynamic chat;
  dynamic tracking;
  dynamic safeRoute;
  dynamic notifications;

  InitializeData({
    this.initializedAt,
    this.serverTime,
    this.payment,
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
      payment: json['payment'] != null
          ? PaymentInitData.fromJson(
              Map<String, dynamic>.from(json['payment']))
          : null,
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
      'payment': payment?.toJson(),
      'walkie': walkie?.toJson(),
      'calling': calling,
      'chat': chat,
      'tracking': tracking,
      'safeRoute': safeRoute,
      'notifications': notifications,
    };
  }
}

class PaymentInitData {
  bool? isPaymentEnabled;
  String? activeGateway;
  String? environment;
  bool? isLiveMode;
  String? currency;
  RazorpayInitData? razorpay;

  PaymentInitData({
    this.isPaymentEnabled,
    this.activeGateway,
    this.environment,
    this.isLiveMode,
    this.currency,
    this.razorpay,
  });

  factory PaymentInitData.fromJson(Map<String, dynamic> json) {
    return PaymentInitData(
      isPaymentEnabled: json['isPaymentEnabled'] == true,
      activeGateway: json['activeGateway']?.toString(),
      environment: json['environment']?.toString(),
      isLiveMode: json['isLiveMode'] == true,
      currency: json['currency']?.toString(),
      razorpay: json['razorpay'] != null
          ? RazorpayInitData.fromJson(
              Map<String, dynamic>.from(json['razorpay']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPaymentEnabled': isPaymentEnabled,
      'activeGateway': activeGateway,
      'environment': environment,
      'isLiveMode': isLiveMode,
      'currency': currency,
      'razorpay': razorpay?.toJson(),
    };
  }
}

class RazorpayInitData {
  String? keyId;
  String? testKeyId;
  String? liveKeyId;
  String? mode;

  RazorpayInitData({
    this.keyId,
    this.testKeyId,
    this.liveKeyId,
    this.mode,
  });

  factory RazorpayInitData.fromJson(Map<String, dynamic> json) {
    return RazorpayInitData(
      keyId: json['keyId']?.toString(),
      testKeyId: json['testKeyId']?.toString(),
      liveKeyId: json['liveKeyId']?.toString(),
      mode: json['mode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyId': keyId,
      'testKeyId': testKeyId,
      'liveKeyId': liveKeyId,
      'mode': mode,
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
