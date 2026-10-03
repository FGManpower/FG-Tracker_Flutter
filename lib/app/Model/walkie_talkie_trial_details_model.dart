class WalkieTalkieTrialDetailsModel {
  final bool? status;
  final bool? success;
  final String? message;
  final WalkieOverviewData? data;

  const WalkieTalkieTrialDetailsModel({
    this.status,
    this.success,
    this.message,
    this.data,
  });

  bool get isSuccessful => status == true || success == true;

  factory WalkieTalkieTrialDetailsModel.fromJson(Map<String, dynamic> json) {
    return WalkieTalkieTrialDetailsModel(
      status: json['status'] == true || json['success'] == true,
      success: json['success'] == true || json['status'] == true,
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
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

// =====================================================
// OVERVIEW DATA
// =====================================================

class WalkieOverviewData {
  final DateTime? serverTime;
  final WalkieAccess? access;
  final WalkieTrial? trial;
  final WalkieSubscriptionsState? subscriptions;
  final WalkieAvailablePlans? availablePlans;

  // Legacy fallback fields for backward compatibility
  final WalkiePricing? pricing;
  final WalkieActions? actions;

  const WalkieOverviewData({
    this.serverTime,
    this.access,
    this.trial,
    this.subscriptions,
    this.availablePlans,
    this.pricing,
    this.actions,
  });

  /// Backward-compatible getter for legacy callers
  WalkieSubscriptionBridge? get subscription {
    if (subscriptions != null) {
      return WalkieSubscriptionBridge(subscriptions: subscriptions!);
    }
    return null;
  }

  factory WalkieOverviewData.fromJson(Map<String, dynamic> json) {
    WalkieSubscriptionsState? parsedSubs;
    if (json['subscriptions'] is Map) {
      parsedSubs = WalkieSubscriptionsState.fromJson(
        Map<String, dynamic>.from(json['subscriptions']),
      );
    } else if (json['subscriptions'] is List) {
      parsedSubs = WalkieSubscriptionsState.fromList(
        json['subscriptions'] as List,
      );
    } else if (json['subscription'] is Map) {
      // Dual-support for previous schema variant
      parsedSubs = WalkieSubscriptionsState.fromLegacyJson(
        Map<String, dynamic>.from(json['subscription']),
      );
    } else if (json['subscription'] is List) {
      parsedSubs = WalkieSubscriptionsState.fromList(
        json['subscription'] as List,
      );
    }

    // Also merge any root-level plan arrays if present
    final List<dynamic>? rootTeamList = json['teamPlans'] is List
        ? json['teamPlans'] as List
        : (json['activeSubscriptions'] is List
            ? json['activeSubscriptions'] as List
            : (json['teamSubscriptions'] is List
                ? json['teamSubscriptions'] as List
                : (json['mySubscriptions'] is List
                    ? json['mySubscriptions'] as List
                    : null)));

    if (rootTeamList != null && rootTeamList.isNotEmpty) {
      final List<WalkieTeamSubscriptionDetails> extraTeamSubs = [];
      for (final item in rootTeamList) {
        if (item is Map) {
          extraTeamSubs.add(
            WalkieTeamSubscriptionDetails.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
      if (extraTeamSubs.isNotEmpty) {
        if (parsedSubs == null) {
          parsedSubs = WalkieSubscriptionsState(
            individual: const WalkieIndividualSubscriptionState(
              hasPurchasedBefore: false,
              hasActiveSubscription: false,
              currentSubscription: null,
            ),
            team: WalkieTeamSubscriptionState(
              hasPurchasedBefore: true,
              hasActiveSubscription: extraTeamSubs.any((s) => s.isActive),
              currentSubscription: extraTeamSubs.first,
              subscriptions: extraTeamSubs,
            ),
          );
        } else {
          final merged = [...parsedSubs.team.subscriptions];
          for (final item in extraTeamSubs) {
            if (!merged.any((e) =>
                e.subscriptionId == item.subscriptionId &&
                item.subscriptionId != 0)) {
              merged.add(item);
            }
          }
          parsedSubs = WalkieSubscriptionsState(
            individual: parsedSubs.individual,
            team: WalkieTeamSubscriptionState(
              hasPurchasedBefore:
                  parsedSubs.team.hasPurchasedBefore || merged.isNotEmpty,
              hasActiveSubscription:
                  parsedSubs.team.hasActiveSubscription ||
                      merged.any((s) => s.isActive),
              currentSubscription: parsedSubs.team.currentSubscription ??
                  (merged.isNotEmpty ? merged.first : null),
              subscriptions: merged,
            ),
          );
        }
      }
    }

    WalkieAvailablePlans? parsedAvailable;
    if (json['availablePlans'] is Map) {
      parsedAvailable = WalkieAvailablePlans.fromJson(
        Map<String, dynamic>.from(json['availablePlans']),
      );
    }

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
      subscriptions: parsedSubs,
      availablePlans: parsedAvailable,
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
      'subscriptions': subscriptions?.toJson(),
      'availablePlans': availablePlans?.toJson(),
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
  final bool hasIndividualAccess;
  final bool hasTeamAccess;
  final bool hasTrialAccess;

  const WalkieAccess({
    required this.canUseWalkie,
    required this.accessType,
    this.hasIndividualAccess = false,
    this.hasTeamAccess = false,
    this.hasTrialAccess = false,
  });

  bool get canUseWalkieTalkie => canUseWalkie;

  factory WalkieAccess.fromJson(Map<String, dynamic> json) {
    final canUse = json['canUseWalkie'] == true ||
        json['canUseWalkieTalkie'] == true ||
        json['hasAccess'] == true;

    final accType = json['accessType']?.toString() ?? 'none';
    final hasIndiv = json['hasIndividualAccess'] == true || accType == 'individual';
    final hasTeam = json['hasTeamAccess'] == true || accType == 'team' || accType == 'team_seat' || accType == 'team_member';
    final hasTrial = json['hasTrialAccess'] == true || accType == 'trial';

    return WalkieAccess(
      canUseWalkie: canUse,
      accessType: accType,
      hasIndividualAccess: hasIndiv,
      hasTeamAccess: hasTeam,
      hasTrialAccess: hasTrial,
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
  final int usedSeconds;
  final int remainingSeconds;
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final int remainingMinutes;
  final WalkieRemainingTime? remainingTime;
  final int totalSeconds;
  final double usagePercentage;

  const WalkieTrial({
    required this.hasReceivedTrial,
    required this.isEligibleForTrial,
    required this.isActive,
    required this.isExpired,
    required this.status,
    required this.durationSeconds,
    required this.usedSeconds,
    required this.remainingSeconds,
    required this.startedAt,
    required this.expiresAt,
    required this.remainingMinutes,
    required this.remainingTime,
    required this.totalSeconds,
    required this.usagePercentage,
  });

  factory WalkieTrial.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status']?.toString() ?? 'not_started';
    final duration = _toInt(json['durationSeconds'], fallback: 3600);
    final used = _toInt(json['usedSeconds'], fallback: 0);
    final remaining = _toInt(
      json['remainingSeconds'],
      fallback: (duration - used).clamp(0, duration),
    );

    final isExp = json['isExpired'] == true ||
        statusStr.toLowerCase() == 'expired' ||
        statusStr.toLowerCase() == 'consumed' ||
        (remaining <= 0 && json['isActive'] != true && statusStr.toLowerCase() != 'not_started');

    final total = _toInt(json['totalSeconds'], fallback: duration);
    final calcPercentage = total > 0
        ? ((used / total) * 100).clamp(0.0, 100.0)
        : 0.0;

    return WalkieTrial(
      hasReceivedTrial: json['hasReceivedTrial'] == true,
      isEligibleForTrial: json['isEligibleForTrial'] == true,
      isActive: json['isActive'] == true,
      isExpired: isExp,
      status: statusStr,
      durationSeconds: duration,
      usedSeconds: used,
      remainingSeconds: remaining,
      startedAt: _parseDateTime(json['startedAt']),
      expiresAt: _parseDateTime(json['expiresAt']),
      remainingMinutes: _toInt(json['remainingMinutes'], fallback: remaining ~/ 60),
      remainingTime: json['remainingTime'] is Map
          ? WalkieRemainingTime.fromJson(
              Map<String, dynamic>.from(json['remainingTime']),
            )
          : WalkieRemainingTime(
              hours: remaining ~/ 3600,
              minutes: (remaining % 3600) ~/ 60,
              seconds: remaining % 60,
            ),
      totalSeconds: total,
      usagePercentage: json['usagePercentage'] != null
          ? _toDouble(json['usagePercentage'])
          : calcPercentage,
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
      'usedSeconds': usedSeconds,
      'remainingSeconds': remainingSeconds,
      'startedAt': startedAt?.toUtc().toIso8601String(),
      'expiresAt': expiresAt?.toUtc().toIso8601String(),
      'remainingMinutes': remainingMinutes,
      'remainingTime': remainingTime?.toJson(),
      'totalSeconds': totalSeconds,
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

  factory WalkieRemainingTime.fromJson(Map<String, dynamic> json) {
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
// INDEPENDENT SUBSCRIPTIONS STATE
// =====================================================

class WalkieSubscriptionsState {
  final WalkieIndividualSubscriptionState individual;
  final WalkieTeamSubscriptionState team;

  const WalkieSubscriptionsState({
    required this.individual,
    required this.team,
  });

  bool get hasAnyActiveSubscription =>
      individual.hasActiveSubscription || team.hasActiveSubscription;

  factory WalkieSubscriptionsState.fromJson(Map<String, dynamic> json) {
    WalkieIndividualSubscriptionState parsedIndiv;
    if (json['individual'] is Map) {
      parsedIndiv = WalkieIndividualSubscriptionState.fromJson(
        Map<String, dynamic>.from(json['individual']),
      );
    } else {
      parsedIndiv = const WalkieIndividualSubscriptionState(
        hasPurchasedBefore: false,
        hasActiveSubscription: false,
        currentSubscription: null,
      );
    }

    WalkieTeamSubscriptionState parsedTeam;
    if (json['team'] is Map) {
      parsedTeam = WalkieTeamSubscriptionState.fromJson(
        Map<String, dynamic>.from(json['team']),
      );
    } else if (json['teamPlans'] is List) {
      final List<WalkieTeamSubscriptionDetails> list = [];
      for (final item in json['teamPlans'] as List) {
        if (item is Map) {
          list.add(
            WalkieTeamSubscriptionDetails.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
      parsedTeam = WalkieTeamSubscriptionState(
        hasPurchasedBefore: list.isNotEmpty,
        hasActiveSubscription: list.any((s) => s.isActive),
        currentSubscription: list.isNotEmpty ? list.first : null,
        subscriptions: list,
      );
    } else {
      parsedTeam = const WalkieTeamSubscriptionState(
        hasPurchasedBefore: false,
        hasActiveSubscription: false,
        currentSubscription: null,
      );
    }

    if (json['teamPlans'] is List && (json['teamPlans'] as List).isNotEmpty) {
      final List<WalkieTeamSubscriptionDetails> extraList = [];
      for (final item in json['teamPlans'] as List) {
        if (item is Map) {
          extraList.add(
            WalkieTeamSubscriptionDetails.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
      final merged = [...parsedTeam.subscriptions];
      for (final item in extraList) {
        if (!merged.any((e) =>
            e.subscriptionId == item.subscriptionId &&
            item.subscriptionId != 0)) {
          merged.add(item);
        }
      }
      parsedTeam = WalkieTeamSubscriptionState(
        hasPurchasedBefore: parsedTeam.hasPurchasedBefore || merged.isNotEmpty,
        hasActiveSubscription:
            parsedTeam.hasActiveSubscription || merged.any((s) => s.isActive),
        currentSubscription: parsedTeam.currentSubscription ??
            (merged.isNotEmpty ? merged.first : null),
        subscriptions: merged,
      );
    }

    return WalkieSubscriptionsState(
      individual: parsedIndiv,
      team: parsedTeam,
    );
  }

  factory WalkieSubscriptionsState.fromLegacyJson(Map<String, dynamic> json) {
    WalkieIndividualSubscriptionDetails? indivSub;
    WalkieTeamSubscriptionDetails? teamSub;
    final List<WalkieTeamSubscriptionDetails> teamSubs = [];

    if (json['individual'] is Map) {
      indivSub = WalkieIndividualSubscriptionDetails.fromJson(
        Map<String, dynamic>.from(json['individual']),
      );
    }

    if (json['teamPlans'] is List && (json['teamPlans'] as List).isNotEmpty) {
      for (final item in json['teamPlans'] as List) {
        if (item is Map) {
          teamSubs.add(
            WalkieTeamSubscriptionDetails.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
      if (teamSubs.isNotEmpty) {
        teamSub = teamSubs.first;
      }
    }

    return WalkieSubscriptionsState(
      individual: WalkieIndividualSubscriptionState(
        hasPurchasedBefore: indivSub != null,
        hasActiveSubscription: indivSub?.isActive == true,
        currentSubscription: indivSub,
      ),
      team: WalkieTeamSubscriptionState(
        hasPurchasedBefore: teamSub != null || teamSubs.isNotEmpty,
        hasActiveSubscription:
            teamSub?.isActive == true || teamSubs.any((s) => s.isActive),
        currentSubscription: teamSub,
        subscriptions: teamSubs,
      ),
    );
  }

  factory WalkieSubscriptionsState.fromList(List list) {
    WalkieIndividualSubscriptionDetails? indivSub;
    final List<WalkieTeamSubscriptionDetails> teamSubs = [];

    for (final item in list) {
      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        final pType = (map['planType'] ??
                (map['plan'] is Map ? map['plan']['planType'] : null) ??
                '')
            .toString()
            .toLowerCase();

        if (pType == 'individual') {
          indivSub ??= WalkieIndividualSubscriptionDetails.fromJson(map);
        } else {
          teamSubs.add(WalkieTeamSubscriptionDetails.fromJson(map));
        }
      }
    }

    return WalkieSubscriptionsState(
      individual: WalkieIndividualSubscriptionState(
        hasPurchasedBefore: indivSub != null,
        hasActiveSubscription: indivSub?.isActive == true,
        currentSubscription: indivSub,
      ),
      team: WalkieTeamSubscriptionState(
        hasPurchasedBefore: teamSubs.isNotEmpty,
        hasActiveSubscription: teamSubs.any((s) => s.isActive),
        currentSubscription: teamSubs.isNotEmpty ? teamSubs.first : null,
        subscriptions: teamSubs,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'individual': individual.toJson(),
      'team': team.toJson(),
    };
  }
}

// =====================================================
// INDIVIDUAL SUBSCRIPTION STATE
// =====================================================

class WalkieIndividualSubscriptionState {
  final bool hasPurchasedBefore;
  final bool hasActiveSubscription;
  final WalkieIndividualSubscriptionDetails? currentSubscription;

  const WalkieIndividualSubscriptionState({
    required this.hasPurchasedBefore,
    required this.hasActiveSubscription,
    this.currentSubscription,
  });

  factory WalkieIndividualSubscriptionState.fromJson(Map<String, dynamic> json) {
    WalkieIndividualSubscriptionDetails? sub;
    if (json['currentSubscription'] is Map) {
      sub = WalkieIndividualSubscriptionDetails.fromJson(
        Map<String, dynamic>.from(json['currentSubscription']),
      );
    }

    return WalkieIndividualSubscriptionState(
      hasPurchasedBefore: json['hasPurchasedBefore'] == true,
      hasActiveSubscription: json['hasActiveSubscription'] == true ||
          (sub != null && sub.isActive),
      currentSubscription: sub,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasPurchasedBefore': hasPurchasedBefore,
      'hasActiveSubscription': hasActiveSubscription,
      'currentSubscription': currentSubscription?.toJson(),
    };
  }
}

class WalkieIndividualSubscriptionDetails {
  final int subscriptionId;
  final int planId;
  final String planName;
  final String planType;
  final String billingInterval;
  final String status;
  final double? price;
  final String currency;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final bool autoRenew;
  final bool isSelfPurchased;
  final int? paidByUserId;
  final int? beneficiaryUserId;
  final WalkieSubscriptionPlan? plan;

  const WalkieIndividualSubscriptionDetails({
    required this.subscriptionId,
    required this.planId,
    required this.planName,
    required this.planType,
    required this.billingInterval,
    required this.status,
    this.price,
    this.currency = 'INR',
    this.startsAt,
    this.expiresAt,
    this.autoRenew = false,
    this.isSelfPurchased = true,
    this.paidByUserId,
    this.beneficiaryUserId,
    this.plan,
  });

  bool get isActive => status.toLowerCase() == 'active';

  factory WalkieIndividualSubscriptionDetails.fromJson(Map<String, dynamic> json) {
    final subId = _toInt(json['subscriptionId'] ?? json['id']);
    final pId = _toInt(json['planId'] ?? (json['plan'] is Map ? json['plan']['id'] : 0));
    final pName = json['planName']?.toString() ??
        (json['plan'] is Map ? json['plan']['name']?.toString() : null) ??
        'Individual Plan';
    final pType = json['planType']?.toString() ??
        (json['plan'] is Map ? json['plan']['planType']?.toString() : null) ??
        'individual';
    final interval = json['billingInterval']?.toString() ??
        (json['plan'] is Map ? json['plan']['billingInterval']?.toString() : null) ??
        'monthly';

    WalkieSubscriptionPlan? nestedPlan;
    if (json['plan'] is Map) {
      nestedPlan = WalkieSubscriptionPlan.fromJson(
        Map<String, dynamic>.from(json['plan']),
      );
    }

    return WalkieIndividualSubscriptionDetails(
      subscriptionId: subId,
      planId: pId,
      planName: pName,
      planType: pType,
      billingInterval: interval,
      status: json['status']?.toString() ?? 'active',
      price: json['price'] != null
          ? _toDouble(json['price'])
          : (json['pricePerMember'] != null ? _toDouble(json['pricePerMember']) : null),
      currency: json['currency']?.toString() ?? 'INR',
      startsAt: _parseDateTime(json['startsAt']),
      expiresAt: _parseDateTime(json['expiresAt']),
      autoRenew: json['autoRenew'] == true,
      isSelfPurchased: json['isSelfPurchased'] == true ||
          json['source']?.toString().toLowerCase() != 'admin_assigned',
      paidByUserId: json['paidByUserId'] != null ? _toInt(json['paidByUserId']) : null,
      beneficiaryUserId: json['beneficiaryUserId'] != null ? _toInt(json['beneficiaryUserId']) : null,
      plan: nestedPlan,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptionId': subscriptionId,
      'planId': planId,
      'planName': planName,
      'planType': planType,
      'billingInterval': billingInterval,
      'status': status,
      'price': price,
      'currency': currency,
      'startsAt': startsAt?.toUtc().toIso8601String(),
      'expiresAt': expiresAt?.toUtc().toIso8601String(),
      'autoRenew': autoRenew,
      'isSelfPurchased': isSelfPurchased,
      'paidByUserId': paidByUserId,
      'beneficiaryUserId': beneficiaryUserId,
      'plan': plan?.toJson(),
    };
  }
}

// =====================================================
// TEAM SUBSCRIPTION STATE
// =====================================================

class WalkieTeamSubscriptionState {
  final bool hasPurchasedBefore;
  final bool hasActiveSubscription;
  final WalkieTeamSubscriptionDetails? currentSubscription;
  final List<WalkieTeamSubscriptionDetails> subscriptions;

  const WalkieTeamSubscriptionState({
    required this.hasPurchasedBefore,
    required this.hasActiveSubscription,
    this.currentSubscription,
    this.subscriptions = const [],
  });

  factory WalkieTeamSubscriptionState.fromJson(Map<String, dynamic> json) {
    WalkieTeamSubscriptionDetails? sub;
    if (json['currentSubscription'] is Map) {
      sub = WalkieTeamSubscriptionDetails.fromJson(
        Map<String, dynamic>.from(json['currentSubscription']),
      );
    }

    final List<WalkieTeamSubscriptionDetails> list = [];
    final rawList = json['subscriptions'] ??
        json['activeSubscriptions'] ??
        json['currentSubscriptions'] ??
        json['teamPlans'] ??
        json['plans'];

    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map) {
          list.add(
            WalkieTeamSubscriptionDetails.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    if (sub != null &&
        !list.any((s) =>
            s.subscriptionId == sub!.subscriptionId && s.subscriptionId != 0)) {
      list.insert(0, sub);
    }

    if (sub == null && list.isNotEmpty) {
      sub = list.first;
    }

    return WalkieTeamSubscriptionState(
      hasPurchasedBefore: json['hasPurchasedBefore'] == true ||
          sub != null ||
          list.isNotEmpty,
      hasActiveSubscription: json['hasActiveSubscription'] == true ||
          (sub != null && sub.isActive) ||
          list.any((s) => s.isActive),
      currentSubscription: sub,
      subscriptions: list,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasPurchasedBefore': hasPurchasedBefore,
      'hasActiveSubscription': hasActiveSubscription,
      'currentSubscription': currentSubscription?.toJson(),
      'subscriptions': subscriptions.map((s) => s.toJson()).toList(),
    };
  }
}

class WalkieTeamSubscriptionDetails {
  final int subscriptionId;
  final int planId;
  final String planName;
  final String planType;
  final String billingInterval;
  final String status;
  final int purchasedSeats;
  final int assignedSeats;
  final int availableSeats;
  final bool isOwner;
  final bool isAssignedMember;
  final bool canAssignMember;
  final double? price;
  final String currency;
  final DateTime? purchasedAt;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final String assignedBy;
  final WalkieSubscriptionPlan? plan;

  const WalkieTeamSubscriptionDetails({
    required this.subscriptionId,
    required this.planId,
    required this.planName,
    required this.planType,
    required this.billingInterval,
    required this.status,
    required this.purchasedSeats,
    required this.assignedSeats,
    required this.availableSeats,
    this.isOwner = true,
    this.isAssignedMember = false,
    this.canAssignMember = true,
    this.price,
    this.currency = 'INR',
    this.purchasedAt,
    this.startsAt,
    this.expiresAt,
    this.assignedBy = 'Team Administrator',
    this.plan,
  });

  bool get isActive => status.toLowerCase() == 'active';

  factory WalkieTeamSubscriptionDetails.fromJson(Map<String, dynamic> json) {
    final subId = _toInt(json['subscriptionId'] ?? json['id']);
    final pId = _toInt(json['planId'] ?? (json['plan'] is Map ? json['plan']['id'] : 0));
    final pName = json['planName']?.toString() ??
        (json['plan'] is Map ? json['plan']['name']?.toString() : null) ??
        'Team Plan';
    final pType = json['planType']?.toString() ??
        (json['plan'] is Map ? json['plan']['planType']?.toString() : null) ??
        'team';
    final interval = json['billingInterval']?.toString() ??
        (json['plan'] is Map ? json['plan']['billingInterval']?.toString() : null) ??
        'monthly';

    final purchased = _toInt(json['purchasedSeats'], fallback: 1);
    final assigned = _toInt(json['assignedSeats'] ?? json['assignedMembers'], fallback: 0);
    final available = json['availableSeats'] != null
        ? _toInt(json['availableSeats'])
        : (purchased - assigned).clamp(0, purchased);

    WalkieSubscriptionPlan? nestedPlan;
    if (json['plan'] is Map) {
      nestedPlan = WalkieSubscriptionPlan.fromJson(
        Map<String, dynamic>.from(json['plan']),
      );
    }

    final isOwn = json['isOwner'] == true ||
        (json['isAssignedMember'] != true && json['source']?.toString().toLowerCase() != 'admin_assigned');

    return WalkieTeamSubscriptionDetails(
      subscriptionId: subId,
      planId: pId,
      planName: pName,
      planType: pType,
      billingInterval: interval,
      status: json['status']?.toString() ?? 'active',
      purchasedSeats: purchased,
      assignedSeats: assigned,
      availableSeats: available,
      isOwner: isOwn,
      isAssignedMember: json['isAssignedMember'] == true,
      canAssignMember: json['canAssignMember'] == true || (isOwn && available > 0),
      price: json['price'] != null
          ? _toDouble(json['price'])
          : (json['pricePerMember'] != null ? _toDouble(json['pricePerMember']) : null),
      currency: json['currency']?.toString() ?? 'INR',
      purchasedAt: _parseDateTime(json['purchasedAt']),
      startsAt: _parseDateTime(json['startsAt']),
      expiresAt: _parseDateTime(json['expiresAt']),
      assignedBy: json['assignedBy']?.toString() ?? 'Team Administrator',
      plan: nestedPlan,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptionId': subscriptionId,
      'planId': planId,
      'planName': planName,
      'planType': planType,
      'billingInterval': billingInterval,
      'status': status,
      'purchasedSeats': purchasedSeats,
      'assignedSeats': assignedSeats,
      'availableSeats': availableSeats,
      'isOwner': isOwner,
      'isAssignedMember': isAssignedMember,
      'canAssignMember': canAssignMember,
      'price': price,
      'currency': currency,
      'purchasedAt': purchasedAt?.toUtc().toIso8601String(),
      'startsAt': startsAt?.toUtc().toIso8601String(),
      'expiresAt': expiresAt?.toUtc().toIso8601String(),
      'assignedBy': assignedBy,
      'plan': plan?.toJson(),
    };
  }
}

// =====================================================
// AVAILABLE PLANS (CATALOG)
// =====================================================

class WalkieAvailablePlans {
  final List<WalkieSubscriptionPlan> individual;
  final List<WalkieSubscriptionPlan> team;

  const WalkieAvailablePlans({
    this.individual = const [],
    this.team = const [],
  });

  factory WalkieAvailablePlans.fromJson(Map<String, dynamic> json) {
    final List<WalkieSubscriptionPlan> indivList = [];
    if (json['individual'] is List) {
      for (final item in json['individual']) {
        if (item is Map) {
          indivList.add(
            WalkieSubscriptionPlan.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final List<WalkieSubscriptionPlan> teamList = [];
    if (json['team'] is List) {
      for (final item in json['team']) {
        if (item is Map) {
          teamList.add(
            WalkieSubscriptionPlan.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return WalkieAvailablePlans(
      individual: indivList,
      team: teamList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'individual': individual.map((e) => e.toJson()).toList(),
      'team': team.map((e) => e.toJson()).toList(),
    };
  }
}

// =====================================================
// SUBSCRIPTION PLAN MODEL
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
  final List<String> features;
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
    this.features = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory WalkieSubscriptionPlan.fromJson(Map<String, dynamic> json) {
    final List<String> parsedFeatures = [];
    if (json['features'] is List) {
      for (final f in json['features']) {
        if (f != null) parsedFeatures.add(f.toString());
      }
    }

    return WalkieSubscriptionPlan(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      planType: json['planType']?.toString() ?? '',
      billingInterval: json['billingInterval']?.toString() ?? 'monthly',
      durationMonths: _toInt(json['durationMonths'], fallback: 1),
      pricePerMember: _toDouble(json['pricePerMember'] ?? json['price']),
      currency: json['currency']?.toString() ?? 'INR',
      minMembers: _toInt(json['minMembers'], fallback: 1),
      maxMembers: _toInt(json['maxMembers'], fallback: 1),
      isActive: json['isActive'] != false,
      features: parsedFeatures,
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
      'features': features,
      'createdAt': createdAt?.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
    };
  }
}

// Backward-compatible type aliases
typedef WalkieTeamSeat = WalkieTeamSubscriptionDetails;
typedef WalkieTeamPlan = WalkieTeamSubscriptionDetails;
typedef WalkieIndividualSubscription = WalkieIndividualSubscriptionDetails;

// =====================================================
// BACKWARD COMPATIBILITY BRIDGE
// =====================================================

class WalkieSubscriptionBridge {
  final WalkieSubscriptionsState subscriptions;

  const WalkieSubscriptionBridge({required this.subscriptions});

  bool get hasActiveSubscription => subscriptions.hasAnyActiveSubscription;

  WalkieIndividualSubscriptionDetails? get individual =>
      subscriptions.individual.currentSubscription;

  List<WalkieTeamSubscriptionDetails> get teamPlans =>
      subscriptions.team.subscriptions.isNotEmpty
          ? subscriptions.team.subscriptions
          : (subscriptions.team.currentSubscription != null
              ? [subscriptions.team.currentSubscription!]
              : const []);

  List<WalkieCurrentSubscription> get activeSubscriptions {
    final list = <WalkieCurrentSubscription>[];
    final ind = subscriptions.individual.currentSubscription;
    if (ind != null && ind.isActive) {
      list.add(
        WalkieCurrentSubscription(
          id: ind.subscriptionId,
          ownerUserId: ind.paidByUserId ?? 0,
          groupId: null,
          purchasedSeats: 1,
          status: ind.status,
          source: ind.isSelfPurchased ? 'direct' : 'admin_assigned',
          startsAt: ind.startsAt,
          expiresAt: ind.expiresAt,
          remainingSeconds: ind.expiresAt != null
              ? ind.expiresAt!.difference(DateTime.now()).inSeconds
              : 0,
          plan: ind.plan,
        ),
      );
    }
    final tmList = subscriptions.team.subscriptions.isNotEmpty
        ? subscriptions.team.subscriptions
        : (subscriptions.team.currentSubscription != null
            ? [subscriptions.team.currentSubscription!]
            : <WalkieTeamSubscriptionDetails>[]);
    for (final tm in tmList) {
      if (tm.isActive) {
        list.add(
          WalkieCurrentSubscription(
            id: tm.subscriptionId,
            ownerUserId: 0,
            groupId: null,
            purchasedSeats: tm.purchasedSeats,
            status: tm.status,
            source: tm.isOwner ? 'owner' : 'admin_assigned',
            startsAt: tm.startsAt ?? tm.purchasedAt,
            expiresAt: tm.expiresAt,
            remainingSeconds: tm.expiresAt != null
                ? tm.expiresAt!.difference(DateTime.now()).inSeconds
                : 0,
            plan: tm.plan,
          ),
        );
      }
    }
    return list;
  }

  WalkieCurrentSubscription? get currentSubscription =>
      activeSubscriptions.isNotEmpty ? activeSubscriptions.first : null;
}

class WalkieCurrentSubscription {
  final int id;
  final int ownerUserId;
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

  bool get isActive => status.toLowerCase() == 'active';
  bool get isIndividual => plan?.planType.toLowerCase() == 'individual';
  bool get isGroup =>
      plan?.planType.toLowerCase() == 'group' || plan?.planType.toLowerCase() == 'team';
}

// =====================================================
// PRICING (FALLBACK)
// =====================================================

class WalkiePricing {
  final bool available;
  final WalkieSubscriptionPlan? selectedPlan;
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
          ? WalkieSubscriptionPlan.fromJson(
              Map<String, dynamic>.from(json['selectedPlan']),
            )
          : null,
      price: json['price'] == null ? null : _toDouble(json['price']),
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

// =====================================================
// ACTIONS (FALLBACK)
// =====================================================

class WalkieActions {
  final bool canUseWalkieTalkie;
  final bool canPurchaseIndividual;
  final bool canPurchaseTeam;
  final bool canChangePlan;
  final bool canManageTeam;

  const WalkieActions({
    required this.canUseWalkieTalkie,
    required this.canPurchaseIndividual,
    required this.canPurchaseTeam,
    required this.canChangePlan,
    required this.canManageTeam,
  });

  factory WalkieActions.fromJson(Map<String, dynamic> json) {
    return WalkieActions(
      canUseWalkieTalkie: json['canUseWalkieTalkie'] == true || json['canUseWalkie'] == true,
      canPurchaseIndividual: json['canPurchaseIndividual'] != false,
      canPurchaseTeam: json['canPurchaseTeam'] != false,
      canChangePlan: json['canChangePlan'] != false,
      canManageTeam: json['canManageTeam'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'canUseWalkieTalkie': canUseWalkieTalkie,
      'canPurchaseIndividual': canPurchaseIndividual,
      'canPurchaseTeam': canPurchaseTeam,
      'canChangePlan': canChangePlan,
      'canManageTeam': canManageTeam,
    };
  }
}

// =====================================================
// HELPERS
// =====================================================

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final parsedInt = int.tryParse(value.toString());
  if (parsedInt != null) return parsedInt;
  final parsedDouble = double.tryParse(value.toString());
  return parsedDouble?.toInt() ?? fallback;
}

double _toDouble(dynamic value, {double fallback = 0.0}) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? fallback;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return DateTime.tryParse(text);
}