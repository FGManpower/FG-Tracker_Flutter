class WalkieTalkieTrialDetailsModel {
  bool? status;
  String? message;
  Data? data;

  WalkieTalkieTrialDetailsModel({this.status, this.message, this.data});

  WalkieTalkieTrialDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? serverTime;
  Access? access;
  Trial? trial;
  Subscription? subscription;
  Pricing? pricing;
  Actions? actions;

  Data(
      {this.serverTime,
        this.access,
        this.trial,
        this.subscription,
        this.pricing,
        this.actions});

  Data.fromJson(Map<String, dynamic> json) {
    serverTime = json['serverTime'];
    access =
    json['access'] != null ? new Access.fromJson(json['access']) : null;
    trial = json['trial'] != null ? new Trial.fromJson(json['trial']) : null;
    subscription = json['subscription'] != null
        ? new Subscription.fromJson(json['subscription'])
        : null;
    pricing =
    json['pricing'] != null ? new Pricing.fromJson(json['pricing']) : null;
    actions =
    json['actions'] != null ? new Actions.fromJson(json['actions']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['serverTime'] = this.serverTime;
    if (this.access != null) {
      data['access'] = this.access!.toJson();
    }
    if (this.trial != null) {
      data['trial'] = this.trial!.toJson();
    }
    if (this.subscription != null) {
      data['subscription'] = this.subscription!.toJson();
    }
    if (this.pricing != null) {
      data['pricing'] = this.pricing!.toJson();
    }
    if (this.actions != null) {
      data['actions'] = this.actions!.toJson();
    }
    return data;
  }
}

class Access {
  bool? canUseWalkie;
  String? accessType;

  Access({this.canUseWalkie, this.accessType});

  Access.fromJson(Map<String, dynamic> json) {
    canUseWalkie = json['canUseWalkie'];
    accessType = json['accessType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['canUseWalkie'] = this.canUseWalkie;
    data['accessType'] = this.accessType;
    return data;
  }
}

class Trial {
  bool? hasReceivedTrial;
  bool? isEligibleForTrial;
  bool? isActive;
  bool? isExpired;
  String? status;
  int? durationSeconds;
  Null? startedAt;
  Null? expiresAt;
  int? remainingSeconds;
  int? remainingMinutes;
  RemainingTime? remainingTime;
  int? totalSeconds;
  int? usedSeconds;
  int? usagePercentage;

  Trial(
      {this.hasReceivedTrial,
        this.isEligibleForTrial,
        this.isActive,
        this.isExpired,
        this.status,
        this.durationSeconds,
        this.startedAt,
        this.expiresAt,
        this.remainingSeconds,
        this.remainingMinutes,
        this.remainingTime,
        this.totalSeconds,
        this.usedSeconds,
        this.usagePercentage});

  Trial.fromJson(Map<String, dynamic> json) {
    hasReceivedTrial = json['hasReceivedTrial'];
    isEligibleForTrial = json['isEligibleForTrial'];
    isActive = json['isActive'];
    isExpired = json['isExpired'];
    status = json['status'];
    durationSeconds = json['durationSeconds'];
    startedAt = json['startedAt'];
    expiresAt = json['expiresAt'];
    remainingSeconds = json['remainingSeconds'];
    remainingMinutes = json['remainingMinutes'];
    remainingTime = json['remainingTime'] != null
        ? new RemainingTime.fromJson(json['remainingTime'])
        : null;
    totalSeconds = json['totalSeconds'];
    usedSeconds = json['usedSeconds'];
    usagePercentage = json['usagePercentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hasReceivedTrial'] = this.hasReceivedTrial;
    data['isEligibleForTrial'] = this.isEligibleForTrial;
    data['isActive'] = this.isActive;
    data['isExpired'] = this.isExpired;
    data['status'] = this.status;
    data['durationSeconds'] = this.durationSeconds;
    data['startedAt'] = this.startedAt;
    data['expiresAt'] = this.expiresAt;
    data['remainingSeconds'] = this.remainingSeconds;
    data['remainingMinutes'] = this.remainingMinutes;
    if (this.remainingTime != null) {
      data['remainingTime'] = this.remainingTime!.toJson();
    }
    data['totalSeconds'] = this.totalSeconds;
    data['usedSeconds'] = this.usedSeconds;
    data['usagePercentage'] = this.usagePercentage;
    return data;
  }
}

class RemainingTime {
  int? hours;
  int? minutes;
  int? seconds;

  RemainingTime({this.hours, this.minutes, this.seconds});

  RemainingTime.fromJson(Map<String, dynamic> json) {
    hours = json['hours'];
    minutes = json['minutes'];
    seconds = json['seconds'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hours'] = this.hours;
    data['minutes'] = this.minutes;
    data['seconds'] = this.seconds;
    return data;
  }
}


class Subscription {
  bool? hasActiveSubscription;
  Map<String, dynamic>? currentSubscription;
  List<Map<String, dynamic>>? activeSubscriptions;

  Subscription({
    this.hasActiveSubscription,
    this.currentSubscription,
    this.activeSubscriptions,
  });

  Subscription.fromJson(Map<String, dynamic> json) {
    hasActiveSubscription = json['hasActiveSubscription'];

    currentSubscription =
    json['currentSubscription'] is Map
        ? Map<String, dynamic>.from(
      json['currentSubscription'],
    )
        : null;

    activeSubscriptions =
        (json['activeSubscriptions'] as List?)
            ?.map(
              (item) => Map<String, dynamic>.from(item),
        )
            .toList();
  }

  Map<String, dynamic> toJson() => {
    'hasActiveSubscription': hasActiveSubscription,
    'currentSubscription': currentSubscription,
    'activeSubscriptions': activeSubscriptions,
  };
}

class Pricing {
  bool? available;
  SelectedPlan? selectedPlan;
  int? price;
  String? currency;
  String? priceType;

  Pricing(
      {this.available,
        this.selectedPlan,
        this.price,
        this.currency,
        this.priceType});

  Pricing.fromJson(Map<String, dynamic> json) {
    available = json['available'];
    selectedPlan = json['selectedPlan'] != null
        ? new SelectedPlan.fromJson(json['selectedPlan'])
        : null;
    price = json['price'];
    currency = json['currency'];
    priceType = json['priceType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['available'] = this.available;
    if (this.selectedPlan != null) {
      data['selectedPlan'] = this.selectedPlan!.toJson();
    }
    data['price'] = this.price;
    data['currency'] = this.currency;
    data['priceType'] = this.priceType;
    return data;
  }
}

class SelectedPlan {
  int? id;
  String? name;
  String? planType;
  String? billingInterval;
  int? durationMonths;
  int? pricePerMember;
  String? currency;
  int? minMembers;
  int? maxMembers;

  SelectedPlan(
      {this.id,
        this.name,
        this.planType,
        this.billingInterval,
        this.durationMonths,
        this.pricePerMember,
        this.currency,
        this.minMembers,
        this.maxMembers});

  SelectedPlan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    planType = json['planType'];
    billingInterval = json['billingInterval'];
    durationMonths = json['durationMonths'];
    pricePerMember = json['pricePerMember'];
    currency = json['currency'];
    minMembers = json['minMembers'];
    maxMembers = json['maxMembers'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['planType'] = this.planType;
    data['billingInterval'] = this.billingInterval;
    data['durationMonths'] = this.durationMonths;
    data['pricePerMember'] = this.pricePerMember;
    data['currency'] = this.currency;
    data['minMembers'] = this.minMembers;
    data['maxMembers'] = this.maxMembers;
    return data;
  }
}

class Actions {
  bool? showTrialCountdown;
  bool? showSubscribe;
  bool? showTrialExpired;

  Actions({this.showTrialCountdown, this.showSubscribe, this.showTrialExpired});

  Actions.fromJson(Map<String, dynamic> json) {
    showTrialCountdown = json['showTrialCountdown'];
    showSubscribe = json['showSubscribe'];
    showTrialExpired = json['showTrialExpired'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['showTrialCountdown'] = this.showTrialCountdown;
    data['showSubscribe'] = this.showSubscribe;
    data['showTrialExpired'] = this.showTrialExpired;
    return data;
  }
}