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
      status: json['status'] == true,
      message: json['message']?.toString(),
      data: json['data'] is Map
          ? WalkieOverviewData.fromJson(
        Map<String, dynamic>.from(json['data']),
      )
          : null,
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

// =====================================================
// OVERVIEW
// =====================================================

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
      serverTime: _parseDateTime(json['serverTime']),
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

  Map<String, dynamic> toJson() {
    return {
      'serverTime': serverTime?.toUtc().toIso8601String(),
      'access': access?.toJson(),
      'trial': trial?.toJson(),
      'subscription': subscription?.toJson(),
      'pricing': pricing?.toJson(),
      'actions': actions?.toJson(),
    };
  }
}

// =====================================================
// ACCESS
// =====================================================

class WalkieAccess {
  final bool canUseWalkie;
  final String accessType;

  const WalkieAccess({
    required this.canUseWalkie,
    required this.accessType,
  });

  factory WalkieAccess.fromJson(
      Map<String, dynamic> json,
      ) {
    return WalkieAccess(
      canUseWalkie: json['canUseWalkie'] == true,
      accessType: json['accessType']?.toString() ?? 'none',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'canUseWalkie': canUseWalkie,
      'accessType': accessType,
    };
  }
}

// =====================================================
// TRIAL
// =====================================================

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

  factory WalkieTrial.fromJson(
      Map<String, dynamic> json,
      ) {
    return WalkieTrial(
      hasReceivedTrial: json['hasReceivedTrial'] == true,
      isEligibleForTrial: json['isEligibleForTrial'] == true,
      isActive: json['isActive'] == true,
      isExpired: json['isExpired'] == true,
      status: json['status']?.toString() ?? 'not_started',
      durationSeconds: _toInt(
        json['durationSeconds'],
        fallback: 3600,
      ),
      startedAt: _parseDateTime(json['startedAt']),
      expiresAt: _parseDateTime(json['expiresAt']),
      remainingSeconds: _toInt(
        json['remainingSeconds'],
      ),
      remainingMinutes: _toInt(
        json['remainingMinutes'],
      ),
      remainingTime: json['remainingTime'] is Map
          ? WalkieRemainingTime.fromJson(
        Map<String, dynamic>.from(
          json['remainingTime'],
        ),
      )
          : null,
      totalSeconds: _toInt(
        json['totalSeconds'],
        fallback: 3600,
      ),
      usedSeconds: _toInt(
        json['usedSeconds'],
      ),
      usagePercentage: _toDouble(
        json['usagePercentage'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      hours: _toInt(json['hours']),
      minutes: _toInt(json['minutes']),
      seconds: _toInt(json['seconds']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
    };
  }
}

// =====================================================
// SUBSCRIPTION
// =====================================================

class WalkieSubscription {
  final bool hasActiveSubscription;
  final WalkieCurrentSubscription? currentSubscription;
  final List<WalkieCurrentSubscription> activeSubscriptions;

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
          ? WalkieCurrentSubscription.fromJson(
        Map<String, dynamic>.from(
          json['currentSubscription'],
        ),
      )
          : null,
      activeSubscriptions: rawSubscriptions is List
          ? rawSubscriptions
          .whereType<Map>()
          .map(
            (item) => WalkieCurrentSubscription.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : <WalkieCurrentSubscription>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasActiveSubscription': hasActiveSubscription,
      'currentSubscription': currentSubscription?.toJson(),
      'activeSubscriptions':
      activeSubscriptions.map((e) => e.toJson()).toList(),
    };
  }
}

class WalkieCurrentSubscription {
  final int id;
  final int ownerUserId;

  /// Individual subscription can legitimately have null groupId.
  final int? groupId;

  final int purchasedSeats;

  final String status;
  final String source;

  final DateTime? startsAt;
  final DateTime? expiresAt;

  final int remainingSeconds;

  final WalkieSubscriptionPlan? plan;

  const WalkieCurrentSubscription({
    required this.id,
    required this.ownerUserId,
    required this.groupId,
    required this.purchasedSeats,
    required this.status,
    required this.source,
    required this.startsAt,
    required this.expiresAt,
    required this.remainingSeconds,
    required this.plan,
  });

  factory WalkieCurrentSubscription.fromJson(
      Map<String, dynamic> json,
      ) {
    return WalkieCurrentSubscription(
      id: _toInt(json['id']),
      ownerUserId: _toInt(json['ownerUserId']),
      groupId: json['groupId'] == null
          ? null
          : _toInt(json['groupId']),
      purchasedSeats: _toInt(
        json['purchasedSeats'],
        fallback: 1,
      ),
      status: json['status']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      startsAt: _parseDateTime(json['startsAt']),
      expiresAt: _parseDateTime(json['expiresAt']),
      remainingSeconds: _toInt(
        json['remainingSeconds'],
      ),
      plan: json['plan'] is Map
          ? WalkieSubscriptionPlan.fromJson(
        Map<String, dynamic>.from(
          json['plan'],
        ),
      )
          : null,
    );
  }

  bool get isActive =>
      status.toLowerCase() == 'active';

  bool get isIndividual =>
      plan?.planType.toLowerCase() == 'individual';

  bool get isGroup =>
      plan?.planType.toLowerCase() == 'group';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerUserId': ownerUserId,
      'groupId': groupId,
      'purchasedSeats': purchasedSeats,
      'status': status,
      'source': source,
      'startsAt': startsAt?.toUtc().toIso8601String(),
      'expiresAt': expiresAt?.toUtc().toIso8601String(),
      'remainingSeconds': remainingSeconds,
      'plan': plan?.toJson(),
    };
  }
}

// =====================================================
// SUBSCRIPTION PLAN
// =====================================================

class WalkieSubscriptionPlan {
  final int id;
  final String name;
  final String planType;
  final String billingInterval;

  final int durationMonths;
  final double pricePerMember;

  final String currency;

  final int minMembers;
  final int maxMembers;

  final bool isActive;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WalkieSubscriptionPlan({
    required this.id,
    required this.name,
    required this.planType,
    required this.billingInterval,
    required this.durationMonths,
    required this.pricePerMember,
    required this.currency,
    required this.minMembers,
    required this.maxMembers,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalkieSubscriptionPlan.fromJson(
      Map<String, dynamic> json,
      ) {
    return WalkieSubscriptionPlan(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      planType: json['planType']?.toString() ?? '',
      billingInterval:
      json['billingInterval']?.toString() ?? '',
      durationMonths: _toInt(
        json['durationMonths'],
      ),
      pricePerMember: _toDouble(
        json['pricePerMember'],
      ),
      currency: json['currency']?.toString() ?? 'INR',
      minMembers: _toInt(
        json['minMembers'],
        fallback: 1,
      ),
      maxMembers: _toInt(
        json['maxMembers'],
        fallback: 1,
      ),
      isActive: json['isActive'] == true,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'planType': planType,
      'billingInterval': billingInterval,
      'durationMonths': durationMonths,
      'pricePerMember': pricePerMember,
      'currency': currency,
      'minMembers': minMembers,
      'maxMembers': maxMembers,
      'isActive': isActive,
      'createdAt': createdAt?.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
    };
  }
}

// =====================================================
// PRICING
// =====================================================

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

  factory WalkiePricing.fromJson(
      Map<String, dynamic> json,
      ) {
    return WalkiePricing(
      available: json['available'] == true,
      selectedPlan: json['selectedPlan'] is Map
          ? WalkieSelectedPlan.fromJson(
        Map<String, dynamic>.from(
          json['selectedPlan'],
        ),
      )
          : null,
      price: json['price'] == null
          ? null
          : _toDouble(json['price']),
      currency: json['currency']?.toString() ?? 'INR',
      priceType: json['priceType']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'available': available,
      'selectedPlan': selectedPlan?.toJson(),
      'price': price,
      'currency': currency,
      'priceType': priceType,
    };
  }
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
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      planType: json['planType']?.toString() ?? '',
      billingInterval:
      json['billingInterval']?.toString() ?? '',
      durationMonths: _toInt(
        json['durationMonths'],
      ),
      pricePerMember: _toDouble(
        json['pricePerMember'],
      ),
      currency: json['currency']?.toString() ?? 'INR',
      minMembers: _toInt(
        json['minMembers'],
        fallback: 1,
      ),
      maxMembers: _toInt(
        json['maxMembers'],
        fallback: 1,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
}

// =====================================================
// ACTIONS
// =====================================================

class WalkieActions {
  final bool showTrialCountdown;
  final bool showSubscribe;
  final bool showTrialExpired;

  const WalkieActions({
    required this.showTrialCountdown,
    required this.showSubscribe,
    required this.showTrialExpired,
  });

  factory WalkieActions.fromJson(
      Map<String, dynamic> json,
      ) {
    return WalkieActions(
      showTrialCountdown:
      json['showTrialCountdown'] == true,
      showSubscribe: json['showSubscribe'] == true,
      showTrialExpired:
      json['showTrialExpired'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showTrialCountdown': showTrialCountdown,
      'showSubscribe': showSubscribe,
      'showTrialExpired': showTrialExpired,
    };
  }
}

// =====================================================
// HELPERS
// =====================================================

int _toInt(
    dynamic value, {
      int fallback = 0,
    }) {
  if (value == null) {
    return fallback;
  }

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  final parsedInt = int.tryParse(
    value.toString(),
  );

  if (parsedInt != null) {
    return parsedInt;
  }

  final parsedDouble = double.tryParse(
    value.toString(),
  );

  return parsedDouble?.toInt() ?? fallback;
}

double _toDouble(
    dynamic value, {
      double fallback = 0.0,
    }) {
  if (value == null) {
    return fallback;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
    value.toString(),
  ) ??
      fallback;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) {
    return null;
  }

  final text = value.toString().trim();

  if (text.isEmpty ||
      text.toLowerCase() == 'null') {
    return null;
  }

  return DateTime.tryParse(text);
}