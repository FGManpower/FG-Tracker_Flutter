class WalkiePlansResponseModel {
  bool? status;
  String? message;
  WalkiePlansData? data;

  WalkiePlansResponseModel({this.status, this.message, this.data});

  WalkiePlansResponseModel.fromJson(dynamic json) {
    if (json is Map) {
      final map = Map<String, dynamic>.from(json);
      status = map['status'] is bool ? map['status'] : null;
      message = map['message']?.toString();
      data = map['data'] != null && map['data'] is Map
          ? WalkiePlansData.fromJson(Map<String, dynamic>.from(map['data']))
          : null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class WalkiePlansData {
  String? planType;
  int? totalPlans;
  List<WalkiePlanItem>? plans;

  WalkiePlansData({this.planType, this.totalPlans, this.plans});

  WalkiePlansData.fromJson(Map<String, dynamic> json) {
    planType = json['planType']?.toString();
    totalPlans = json['totalPlans'] is int
        ? json['totalPlans']
        : int.tryParse(json['totalPlans']?.toString() ?? '');
    if (json['plans'] != null && json['plans'] is List) {
      plans = <WalkiePlanItem>[];
      for (var v in (json['plans'] as List)) {
        if (v is Map) {
          plans!.add(WalkiePlanItem.fromJson(Map<String, dynamic>.from(v)));
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['planType'] = planType;
    data['totalPlans'] = totalPlans;
    if (plans != null) {
      data['plans'] = plans!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class WalkiePlanItem {
  int? id;
  String? name;
  String? planType;
  String? billingInterval;
  int? durationMonths;
  int? pricePerMember;
  String? currency;
  int? minMembers;
  int? maxMembers;
  bool? isActive;
  String? createdAt;
  String? updatedAt;

  WalkiePlanItem({
    this.id,
    this.name,
    this.planType,
    this.billingInterval,
    this.durationMonths,
    this.pricePerMember,
    this.currency,
    this.minMembers,
    this.maxMembers,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  WalkiePlanItem.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    name = json['name']?.toString();
    planType = json['planType']?.toString();
    billingInterval = json['billingInterval']?.toString();
    durationMonths = json['durationMonths'] is int
        ? json['durationMonths']
        : int.tryParse(json['durationMonths']?.toString() ?? '');
    pricePerMember = json['pricePerMember'] is int
        ? json['pricePerMember']
        : (json['pricePerMember'] is num
            ? (json['pricePerMember'] as num).toInt()
            : int.tryParse(json['pricePerMember']?.toString() ?? ''));
    currency = json['currency']?.toString() ?? 'INR';
    minMembers = json['minMembers'] is int
        ? json['minMembers']
        : int.tryParse(json['minMembers']?.toString() ?? '');
    maxMembers = json['maxMembers'] is int
        ? json['maxMembers']
        : int.tryParse(json['maxMembers']?.toString() ?? '');
    isActive = json['isActive'] is bool ? json['isActive'] : true;
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['planType'] = planType;
    data['billingInterval'] = billingInterval;
    data['durationMonths'] = durationMonths;
    data['pricePerMember'] = pricePerMember;
    data['currency'] = currency;
    data['minMembers'] = minMembers;
    data['maxMembers'] = maxMembers;
    data['isActive'] = isActive;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }

  // Helper getters
  String get displayTitle {
    if (name != null && name!.trim().isNotEmpty) {
      return name!.trim();
    }
    if (billingInterval != null && billingInterval!.isNotEmpty) {
      return "${billingInterval![0].toUpperCase()}${billingInterval!.substring(1).toLowerCase()} Plan";
    }
    return "Plan";
  }

  String get durationLabel {
    final interval = (billingInterval ?? '').toLowerCase();
    if (interval == 'monthly' || durationMonths == 1) return "Monthly";
    if (interval == 'quarterly' || durationMonths == 3) return "Quarterly";
    if (interval == 'yearly' || interval == 'annual' || durationMonths == 12) {
      return "Yearly";
    }
    if (durationMonths != null && durationMonths! > 0) {
      return "$durationMonths ${durationMonths == 1 ? 'Month' : 'Months'}";
    }
    return "Duration";
  }

  String get formattedPrice => "₹${pricePerMember ?? 0}";

  int get safePrice => pricePerMember ?? 0;

  int get safeMinMembers => (minMembers != null && minMembers! > 0) ? minMembers! : 1;

  int get safeMaxMembers => (maxMembers != null && maxMembers! > 0) ? maxMembers! : 99;
}
