import 'dart:io';

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
  NotificationMarkers? notificationMarkers;
  AppVersionData? appVersion;
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
    this.notificationMarkers,
    this.appVersion,
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
      notificationMarkers: json['notificationMarkers'] != null
          ? NotificationMarkers.fromJson(
              Map<String, dynamic>.from(json['notificationMarkers']))
          : null,
      appVersion: json['appVersion'] != null
          ? AppVersionData.fromJson(
              Map<String, dynamic>.from(json['appVersion']))
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
      'notificationMarkers': notificationMarkers?.toJson(),
      'appVersion': appVersion?.toJson(),
      'calling': calling,
      'chat': chat,
      'tracking': tracking,
      'safeRoute': safeRoute,
      'notifications': notifications,
    };
  }
}

class NotificationMarkers {
  final bool calling;
  final bool chatting;
  final bool walkie;
  final bool? groupChat;
  final bool? privateChat;

  NotificationMarkers({
    this.calling = false,
    this.chatting = false,
    this.walkie = false,
    this.groupChat,
    this.privateChat,
  });

  static bool parseMarkerBool(dynamic val) {
    if (val == null) return false;
    if (val is bool) return val;
    if (val is num) return val > 0;
    if (val is String) {
      final s = val.toLowerCase().trim();
      if (s == 'true' || s == '1') return true;
      final parsedNum = int.tryParse(s);
      if (parsedNum != null) return parsedNum > 0;
      return false;
    }
    if (val is Map) {
      if (val['hasUnread'] == true || val['hasNotification'] == true || val['hasMissedCall'] == true) {
        return true;
      }
      final count = val['unreadCount'] ??
          val['unread_count'] ??
          val['count'] ??
          val['unread'] ??
          val['totalUnread'] ??
          val['total_unread'];
      if (count is num && count > 0) return true;
      if (count is String && (int.tryParse(count.trim()) ?? 0) > 0) return true;
    }
    return false;
  }

  factory NotificationMarkers.fromJson(Map<String, dynamic> json) {
    final bool hasCalling = parseMarkerBool(json['calling']);
    final bool hasWalkie = parseMarkerBool(json['walkie']);

    final bool isPrivateUnread = parseMarkerBool(json['privateChat']) ||
        parseMarkerBool(json['private_chat']) ||
        parseMarkerBool(json['private']);
    final bool isGroupUnread = parseMarkerBool(json['groupChat']) ||
        parseMarkerBool(json['group_chat']) ||
        parseMarkerBool(json['group']);

    final bool isChatting = parseMarkerBool(json['chatting']) ||
        parseMarkerBool(json['chat']) ||
        isPrivateUnread ||
        isGroupUnread;

    return NotificationMarkers(
      calling: hasCalling,
      chatting: isChatting,
      walkie: hasWalkie,
      groupChat: isGroupUnread ? true : (json.containsKey('groupChat') ? false : null),
      privateChat: isPrivateUnread ? true : (json.containsKey('privateChat') ? false : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calling': calling,
      'chatting': chatting,
      'walkie': walkie,
      if (groupChat != null) 'groupChat': groupChat,
      if (privateChat != null) 'privateChat': privateChat,
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
      subscriptions: json['subscriptions'] is List
          ? List<dynamic>.from(json['subscriptions'])
          : (json['subscriptions'] != null ? [json['subscriptions']] : []),
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

  bool get isSubscribed {
    final accType = access?.accessType?.toLowerCase().trim() ?? '';
    if (accType.contains('expired')) {
      return false;
    }

    if (access?.hasIndividualAccess == true ||
        access?.hasTeamAccess == true) {
      return true;
    }

    if (accType == 'individual' ||
        accType == 'team' ||
        accType == 'team_seat' ||
        accType == 'team_member' ||
        accType == 'subscription' ||
        accType == 'subscribed' ||
        accType == 'both') {
      return true;
    }

    if (access?.canUseWalkie == true &&
        accType != 'trial' &&
        accType != 'none' &&
        accType.isNotEmpty) {
      return true;
    }

    if (currentSubscription != null) {
      if (currentSubscription is Map) {
        final status =
            currentSubscription['status']?.toString().toLowerCase().trim();
        final isActive = currentSubscription['isActive'] == true;
        final isExp = currentSubscription['isExpired'] == true;
        if (!isExp && (isActive || status == 'active')) {
          return true;
        }
      } else if (currentSubscription is bool && currentSubscription == true) {
        return true;
      }
    }

    if (subscriptions != null) {
      if (subscriptions is List) {
        for (var sub in subscriptions!) {
          if (sub is Map) {
            final status = sub['status']?.toString().toLowerCase().trim();
            final isActive = sub['isActive'] == true;
            final isExp = sub['isExpired'] == true;
            if (!isExp && (isActive || status == 'active')) {
              return true;
            }
          }
        }
      } else if (subscriptions is Map) {
        final subMap = subscriptions as Map;
        if (subMap['hasActiveSubscription'] == true) return true;
        for (var val in subMap.values) {
          if (val is Map) {
            final status = val['status']?.toString().toLowerCase().trim();
            final isActive = val['isActive'] == true;
            final isExp = val['isExpired'] == true;
            if (!isExp && (isActive ||
                status == 'active' ||
                val['hasActiveSubscription'] == true)) {
              return true;
            }
          }
        }
      }
    }

    return false;
  }

  /// True when the user had an individual or team subscription that has expired.
  bool get isSubscriptionExpired {
    if (isSubscribed) return false;

    final accType = access?.accessType?.toLowerCase().trim() ?? '';
    if (accType == 'expired_subscription' ||
        accType == 'subscription_expired') {
      return true;
    }

    if (actions?.showRenew == true) {
      return true;
    }

    if (currentSubscription is Map) {
      final status =
          currentSubscription['status']?.toString().toLowerCase().trim();
      final isExp = currentSubscription['isExpired'] == true;
      if (status == 'expired' || isExp) return true;
    }

    if (subscriptions != null) {
      if (subscriptions is List && subscriptions!.isNotEmpty) {
        return true;
      } else if (subscriptions is Map) {
        final subMap = subscriptions as Map;
        if (subMap['hasActiveSubscription'] == false &&
            (subMap['individual'] != null || subMap['team'] != null)) {
          return true;
        }
      }
    }

    if (alerts != null) {
      for (var alert in alerts!) {
        final t = alert.type?.toLowerCase().trim() ?? '';
        if (t == 'subscription_expired') return true;
      }
    }

    return false;
  }

  /// True when the user's 1-hour free trial has ended/consumed.
  bool get isTrialExpired {
    if (isSubscribed || isSubscriptionExpired) return false;

    final accType = access?.accessType?.toLowerCase().trim() ?? '';
    if (accType == 'expired' ||
        accType == 'expired_trial' ||
        accType == 'trial_expired') {
      return true;
    }

    if (trial != null && trial is Map) {
      final trialMap = trial as Map;
      if (trialMap['isExpired'] == true) return true;

      final status = trialMap['status']?.toString().toLowerCase().trim();
      if (status == 'expired' || status == 'consumed') return true;

      final remaining = trialMap['remainingSeconds'];
      final hasReceived = trialMap['hasReceivedTrial'] == true;
      final isActive = trialMap['isActive'] == true;

      if (hasReceived && !isActive) {
        return true;
      }

      if (remaining is num &&
          remaining <= 0 &&
          (hasReceived || status != 'not_started') &&
          !isActive) {
        return true;
      }
    }

    if (alerts != null) {
      for (var alert in alerts!) {
        final t = alert.type?.toLowerCase().trim() ?? '';
        if (t == 'trial_expired') return true;
      }
    }

    if (access?.canUseWalkie == false) {
      if (trial is Map &&
          trial['isEligibleForTrial'] == false &&
          trial['hasReceivedTrial'] == true) {
        return true;
      }
    }

    return false;
  }

  /// True when user is actively using an unexpired free trial.
  bool get isTrialActive {
    if (isSubscribed || isSubscriptionExpired || isTrialExpired) return false;

    final accType = access?.accessType?.toLowerCase().trim() ?? '';
    if (access?.hasTrialAccess == true || accType == 'trial') {
      return true;
    }

    if (trial is Map) {
      final trialMap = trial as Map;
      if (trialMap['isActive'] == true && trialMap['isExpired'] != true) {
        return true;
      }
      final remaining = trialMap['remainingSeconds'];
      if (remaining is num && remaining > 0 && trialMap['hasReceivedTrial'] == true) {
        return true;
      }
    }

    return false;
  }

  /// Label shown in Quick Action tile on Home Screen:
  /// - Actively Subscribed ➔ "Subscribed"
  /// - Subscription Expired ➔ "Renew"
  /// - Trial Expired ➔ "Expired"
  /// - Fresh user / Active Trial ➔ "1 hr free"
  String get statusSubtitle {
    if (isSubscribed) {
      return "Subscribed";
    }
    if (isSubscriptionExpired) {
      return "Renew";
    }
    if (isTrialExpired) {
      return "Expired";
    }
    return "1 hr free";
  }
}

class WalkieAccess {
  bool? canUseWalkie;
  String? accessType;
  bool? hasIndividualAccess;
  bool? hasTeamAccess;
  bool? hasTrialAccess;

  WalkieAccess({
    this.canUseWalkie,
    this.accessType,
    this.hasIndividualAccess,
    this.hasTeamAccess,
    this.hasTrialAccess,
  });

  factory WalkieAccess.fromJson(Map<String, dynamic> json) {
    final canUse = json['canUseWalkie'] == true ||
        json['canUseWalkieTalkie'] == true ||
        json['hasAccess'] == true;
    final accType = json['accessType']?.toString();
    return WalkieAccess(
      canUseWalkie: canUse,
      accessType: accType,
      hasIndividualAccess:
          json['hasIndividualAccess'] == true || accType == 'individual',
      hasTeamAccess: json['hasTeamAccess'] == true ||
          accType == 'team' ||
          accType == 'team_seat' ||
          accType == 'team_member',
      hasTrialAccess: json['hasTrialAccess'] == true || accType == 'trial',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'canUseWalkie': canUseWalkie,
      'accessType': accessType,
      'hasIndividualAccess': hasIndividualAccess,
      'hasTeamAccess': hasTeamAccess,
      'hasTrialAccess': hasTrialAccess,
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


class AppVersionData {
  final PlatformVersionData android;
  final PlatformVersionData ios;
  final String title;
  final String message;

  AppVersionData({
    required this.android,
    required this.ios,
    this.title = 'Update Required',
    this.message =
        'A new version of FG Tracker is available. Please update to continue.',
  });

  factory AppVersionData.fromJson(Map<String, dynamic> json) {
    return AppVersionData(
      android: json['android'] != null
          ? PlatformVersionData.fromJson(
              Map<String, dynamic>.from(json['android']))
          : PlatformVersionData.empty(),
      ios: json['ios'] != null
          ? PlatformVersionData.fromJson(
              Map<String, dynamic>.from(json['ios']))
          : PlatformVersionData.empty(),
      title: json['title']?.toString() ?? 'Update Required',
      message: json['message']?.toString() ??
          'A new version of FG Tracker is available. Please update to continue.',
    );
  }

  PlatformVersionData get currentPlatformData {
    if (Platform.isIOS) {
      return ios;
    }
    return android;
  }

  Map<String, dynamic> toJson() {
    return {
      'android': android.toJson(),
      'ios': ios.toJson(),
      'title': title,
      'message': message,
    };
  }
}

class PlatformVersionData {
  final String minVersion;
  final String latestVersion;
  final bool forceUpdate;
  final String storeUrl;

  PlatformVersionData({
    required this.minVersion,
    required this.latestVersion,
    required this.forceUpdate,
    required this.storeUrl,
  });

  factory PlatformVersionData.fromJson(Map<String, dynamic> json) {
    return PlatformVersionData(
      minVersion: json['minVersion']?.toString() ?? '1.0.0',
      latestVersion: json['latestVersion']?.toString() ?? '1.0.0',
      forceUpdate: json['forceUpdate'] == true ||
          json['forceUpdate']?.toString().toLowerCase() == 'true',
      storeUrl: json['storeUrl']?.toString() ?? '',
    );
  }

  factory PlatformVersionData.empty() {
    return PlatformVersionData(
      minVersion: '1.0.0',
      latestVersion: '1.0.0',
      forceUpdate: false,
      storeUrl: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minVersion': minVersion,
      'latestVersion': latestVersion,
      'forceUpdate': forceUpdate,
      'storeUrl': storeUrl,
    };
  }
}
