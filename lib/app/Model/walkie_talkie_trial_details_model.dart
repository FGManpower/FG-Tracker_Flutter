
class WalkieTalkieTrialDetailsModel {
  final bool? status;
  final String? message;
  final WalkieOverviewData? data;

  const WalkieTalkieTrialDetailsModel({
    this.status,
    this.message,
    this.data,
  });

  factory WalkieTalkieTrialDetailsModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return WalkieTalkieTrialDetailsModel(
      status: json['status'] as bool?,
      message: json['message']?.toString(),
      data: json['data'] is Map
          ? WalkieOverviewData.fromJson(
        Map<String, dynamic>.from(json['data']),
      )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.toJson(),
  };
}

class WalkieOverviewData {
  final DateTime? serverTime;
  final WalkieAccess? access;
  final WalkieTrial? trial;
  final WalkieSubscription? subscription;
  final WalkiePricing? pricing;
  final WalkieActions? actions;

  const WalkieOverviewData({
    this.serverTime,
    this.access,
    this.trial,
    this.subscription,
    this.pricing,
    this.actions,
  });

  factory WalkieOverviewData.fromJson(
      Map<String, dynamic> json,
      ) {
    return WalkieOverviewData(
      serverTime: DateTime.tryParse(
        json['serverTime']?.toString() ?? '',
      ),
      access: json['access'] is Map
          ? WalkieAccess.fromJson(
        Map<String, dynamic>.from(json['access']),
      )
          : null,
      trial: json['trial'] is Map
          ? WalkieTrial.fromJson(
        Map<String, dynamic>.from(json['trial']),
      )
          : null,
      subscription: json['subscription'] is Map
          ? WalkieSubscription.fromJson(
        Map<String, dynamic>.from(json['subscription']),
      )
          : null,
      pricing: json['pricing'] is Map
          ? WalkiePricing.fromJson(
        Map<String, dynamic>.from(json['pricing']),
      )
          : null,
      actions: json['actions'] is Map
          ? WalkieActions.fromJson(
        Map<String, dynamic>.from(json['actions']),
      )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'serverTime': serverTime?.toUtc().toIso8601String(),
    'access': access?.toJson(),
    'trial': trial?.toJson(),
    'subscription': subscription?.toJson(),
    'pricing': pricing?.toJson(),
    'actions': actions?.toJson(),
  };
}

class WalkieAccess {
  final bool canUseWalkie;
  final String accessType;

  const WalkieAccess({
    required this.canUseWalkie,
    required this.accessType,
  });

  factory WalkieAccess.fromJson(Map<String, dynamic> json) {
    return WalkieAccess(
      canUseWalkie: json['canUseWalkie'] == true,
      accessType: json['accessType']?.toString() ?? 'none',
    );
  }

  Map<String, dynamic> toJson() => {
    'canUseWalkie': canUseWalkie,
    'accessType': accessType,
  };
}

class WalkieTrial {
  final bool hasReceivedTrial;
  final bool isEligibleForTrial;
  final bool isActive;
  final bool isExpired;
  final String status;
  final int durationSeconds;
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final int remainingSeconds;
  final int remainingMinutes;
  final WalkieRemainingTime? remainingTime;
  final int totalSeconds;
  final int usedSeconds;
  final double usagePercentage;

  const WalkieTrial({
    required this.hasReceivedTrial,
    required this.isEligibleForTrial,
    required this.isActive,
    required this.isExpired,
    required this.status,
    required this.durationSeconds,
    required this.startedAt,
    required this.expiresAt,
    required this.remainingSeconds,
    required this.remainingMinutes,
    required this.remainingTime,
    required this.totalSeconds,
    required this.usedSeconds,
    required this.usagePercentage,
  });

  factory WalkieTrial.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value) =>
        value is num ? value.toInt() : int.tryParse('$value') ?? 0;

    return WalkieTrial(
      hasReceivedTrial: json['hasReceivedTrial'] == true,
      isEligibleForTrial: json['isEligibleForTrial'] == true,
      isActive: json['isActive'] == true,
      isExpired: json['isExpired'] == true,
      status: json['status']?.toString() ?? 'unknown',
      durationSeconds: asInt(json['durationSeconds']),
      startedAt: DateTime.tryParse(
        json['startedAt']?.toString() ?? '',
      ),
      expiresAt: DateTime.tryParse(
        json['expiresAt']?.toString() ?? '',
      ),
      remainingSeconds: asInt(json['remainingSeconds']),
      remainingMinutes: asInt(json['remainingMinutes']),
      remainingTime: json['remainingTime'] is Map
          ? WalkieRemainingTime.fromJson(
        Map<String, dynamic>.from(json['remainingTime']),
      )
          : null,
      totalSeconds: asInt(json['totalSeconds']),
      usedSeconds: asInt(json['usedSeconds']),
      usagePercentage:
      (json['usagePercentage'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'hasReceivedTrial': hasReceivedTrial,
    'isEligibleForTrial': isEligibleForTrial,
    'isActive': isActive,
    'isExpired': isExpired,
    'status': status,
    'durationSeconds': durationSeconds,
    'startedAt': startedAt?.toUtc().toIso8601String(),
    'expiresAt': expiresAt?.toUtc().toIso8601String(),
    'remainingSeconds': remainingSeconds,
    'remainingMinutes': remainingMinutes,
    'remainingTime': remainingTime?.toJson(),
    'totalSeconds': totalSeconds,
    'usedSeconds': usedSeconds,
    'usagePercentage': usagePercentage,
  };
}

class WalkieRemainingTime {
  final int hours;
  final int minutes;
  final int seconds;

  const WalkieRemainingTime({
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  factory WalkieRemainingTime.fromJson(
      Map<String, dynamic> json,
      ) {
    return WalkieRemainingTime(
      hours: (json['hours'] as num?)?.toInt() ?? 0,
      minutes: (json['minutes'] as num?)?.toInt() ?? 0,
      seconds: (json['seconds'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'hours': hours,
    'minutes': minutes,
    'seconds': seconds,
  };
}

class WalkieSubscription {
  final bool hasActiveSubscription;
  final Map<String, dynamic>? currentSubscription;
  final List<Map<String, dynamic>> activeSubscriptions;

  const WalkieSubscription({
    required this.hasActiveSubscription,
    required this.currentSubscription,
    required this.activeSubscriptions,
  });

  factory WalkieSubscription.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawSubscriptions = json['activeSubscriptions'];

    return WalkieSubscription(
      hasActiveSubscription:
      json['hasActiveSubscription'] == true,
      currentSubscription: json['currentSubscription'] is Map
          ? Map<String, dynamic>.from(
        json['currentSubscription'],
      )
          : null,
      activeSubscriptions: rawSubscriptions is List
          ? rawSubscriptions
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'hasActiveSubscription': hasActiveSubscription,
    'currentSubscription': currentSubscription,
    'activeSubscriptions': activeSubscriptions,
  };
}

class WalkiePricing {
  final bool available;
  final WalkieSelectedPlan? selectedPlan;
  final double? price;
  final String currency;
  final String priceType;

  const WalkiePricing({
    required this.available,
    required this.selectedPlan,
    required this.price,
    required this.currency,
    required this.priceType,
  });

  factory WalkiePricing.fromJson(Map<String, dynamic> json) {
    return WalkiePricing(
      available: json['available'] == true,
      selectedPlan: json['selectedPlan'] is Map
          ? WalkieSelectedPlan.fromJson(
        Map<String, dynamic>.from(json['selectedPlan']),
      )
          : null,
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse('${json['price']}'),
      currency: json['currency']?.toString() ?? 'INR',
      priceType: json['priceType']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'available': available,
    'selectedPlan': selectedPlan?.toJson(),
    'price': price,
    'currency': currency,
    'priceType': priceType,
  };
}

class WalkieSelectedPlan {
  final int id;
  final String name;
  final String planType;
  final String billingInterval;
  final int durationMonths;
  final double pricePerMember;
  final String currency;
  final int minMembers;
  final int maxMembers;

  const WalkieSelectedPlan({
    required this.id,
    required this.name,
    required this.planType,
    required this.billingInterval,
    required this.durationMonths,
    required this.pricePerMember,
    required this.currency,
    required this.minMembers,
    required this.maxMembers,
  });

  factory WalkieSelectedPlan.fromJson(
      Map<String, dynamic> json,
      ) {
    return WalkieSelectedPlan(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      planType: json['planType']?.toString() ?? '',
      billingInterval:
      json['billingInterval']?.toString() ?? '',
      durationMonths:
      (json['durationMonths'] as num?)?.toInt() ?? 0,
      pricePerMember:
      (json['pricePerMember'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      minMembers: (json['minMembers'] as num?)?.toInt() ?? 1,
      maxMembers: (json['maxMembers'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'planType': planType,
    'billingInterval': billingInterval,
    'durationMonths': durationMonths,
    'pricePerMember': pricePerMember,
    'currency': currency,
    'minMembers': minMembers,
    'maxMembers': maxMembers,
  };
}

class WalkieActions {
  final bool showTrialCountdown;
  final bool showSubscribe;
  final bool showTrialExpired;

  const WalkieActions({
    required this.showTrialCountdown,
    required this.showSubscribe,
    required this.showTrialExpired,
  });

  factory WalkieActions.fromJson(Map<String, dynamic> json) {
    return WalkieActions(
      showTrialCountdown: json['showTrialCountdown'] == true,
      showSubscribe: json['showSubscribe'] == true,
      showTrialExpired: json['showTrialExpired'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'showTrialCountdown': showTrialCountdown,
    'showSubscribe': showSubscribe,
    'showTrialExpired': showTrialExpired,
  };
}