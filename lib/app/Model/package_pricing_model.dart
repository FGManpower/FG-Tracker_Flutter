/// Models for the Package Pricing module (Attendance, Walkie-Talkie,
/// Safe Zone + Safe Route, Live Tracking).
///
/// JSON contract: docs/package_pricing_api.md
/// Every parser is tolerant: numbers may arrive as strings, unknown keys are
/// ignored, and missing lists become empty lists.
library;

int? _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.isFinite ? v.toInt() : null;
  return int.tryParse(v?.toString() ?? '');
}

/// NaN / Infinity become null so .round() never throws during build
num? _toNum(dynamic v) {
  final n = v is num ? v : num.tryParse(v?.toString() ?? '');
  return (n != null && n.isFinite) ? n : null;
}

bool _toBool(dynamic v, {bool fallback = false}) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v?.toString().toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return fallback;
}

String? _toStr(dynamic v) {
  final s = v?.toString().trim();
  return (s == null || s.isEmpty || s == 'null') ? null : s;
}

Map<String, dynamic>? _asMap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : null;

List<Map<String, dynamic>> _asMapList(dynamic v) => v is List
    ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : <Map<String, dynamic>>[];

/// Module keys the app has built-in icons/colours for.
/// The backend can send new keys; they still render with a default style.
class PackageModuleKey {
  PackageModuleKey._();
  static const String attendance = 'attendance';
  static const String walkieTalkie = 'walkie_talkie';
  static const String safeZoneRoute = 'safe_zone_route';
  static const String liveTracking = 'live_tracking';
}

// ---------------------------------------------------------------------------
// GET packages
// ---------------------------------------------------------------------------

class PackageListResponse {
  final bool status;
  final String? message;
  final List<PackageItem> packages;

  const PackageListResponse({
    this.status = false,
    this.message,
    this.packages = const [],
  });

  factory PackageListResponse.fromJson(dynamic json) {
    final map = _asMap(json);
    if (map == null) return const PackageListResponse();
    final data = _asMap(map['data']);
    // Accept both {data: {packages: []}} and {data: []}
    final rawList = data != null ? data['packages'] : map['data'];
    return PackageListResponse(
      status: _toBool(map['status']),
      message: _toStr(map['message']),
      packages: _asMapList(rawList).map(PackageItem.fromJson).toList(),
    );
  }
}

/// One card on the Packages screen.
class PackageItem {
  final int? id;
  final String moduleKey;
  final String title;
  final String? tagline;
  final String? iconUrl;

  /// Optional accent colour from backend, e.g. "#16A34A"
  final String? themeColor;
  final num? startingPrice;
  final String currency;

  /// Shown after the price, e.g. "/ member / month"
  final String? priceUnit;

  /// Small label on the card, e.g. "Popular"
  final String? badge;

  /// false = shown as "Coming soon" and not tappable
  final bool isAvailable;
  final bool isSubscribed;

  /// ISO date (yyyy-MM-dd or full ISO) of the current subscription end
  final String? activeUntil;
  final List<String> highlights;
  final int sortOrder;

  const PackageItem({
    this.id,
    required this.moduleKey,
    required this.title,
    this.tagline,
    this.iconUrl,
    this.themeColor,
    this.startingPrice,
    this.currency = 'INR',
    this.priceUnit,
    this.badge,
    this.isAvailable = true,
    this.isSubscribed = false,
    this.activeUntil,
    this.highlights = const [],
    this.sortOrder = 0,
  });

  factory PackageItem.fromJson(Map<String, dynamic> json) {
    final highlights = json['highlights'] is List
        ? (json['highlights'] as List)
            .map((e) => _toStr(e))
            .whereType<String>()
            .toList()
        : <String>[];
    final moduleKey = _toStr(json['moduleKey']) ?? '';
    return PackageItem(
      id: _toInt(json['id']),
      moduleKey: moduleKey,
      title: _toStr(json['title']) ?? 'Package',
      tagline: _toStr(json['tagline']),
      iconUrl: _toStr(json['iconUrl']),
      themeColor: _toStr(json['themeColor']),
      startingPrice: _toNum(json['startingPrice']),
      currency: _toStr(json['currency']) ?? 'INR',
      priceUnit: _toStr(json['priceUnit']),
      badge: _toStr(json['badge']),
      // Only Walkie-Talkie is sold for now; every other module shows
      // "Coming soon" whatever the backend sends.
      isAvailable: moduleKey == PackageModuleKey.walkieTalkie &&
          _toBool(json['isAvailable'], fallback: true),
      isSubscribed: _toBool(json['isSubscribed']),
      activeUntil: _toStr(json['activeUntil']),
      highlights: highlights,
      sortOrder: _toInt(json['sortOrder']) ?? 0,
    );
  }

  /// Placeholder used only for loading skeletons
  factory PackageItem.placeholder() => const PackageItem(
        moduleKey: '',
        title: 'Package name here',
        tagline: 'Short description of what this module does',
        startingPrice: 999,
        priceUnit: '/ member / month',
        highlights: ['Feature one', 'Feature two'],
      );
}

// ---------------------------------------------------------------------------
// GET packages/{moduleKey}/plans
// ---------------------------------------------------------------------------

class PackagePlansResponse {
  final bool status;
  final String? message;
  final PackagePlanDetails? data;

  const PackagePlansResponse({this.status = false, this.message, this.data});

  factory PackagePlansResponse.fromJson(dynamic json) {
    final map = _asMap(json);
    if (map == null) return const PackagePlansResponse();
    final data = _asMap(map['data']);
    return PackagePlansResponse(
      status: _toBool(map['status']),
      message: _toStr(map['message']),
      data: data != null ? PackagePlanDetails.fromJson(data) : null,
    );
  }
}

class PackagePlanDetails {
  final String moduleKey;
  final String title;
  final String? description;
  final String currency;

  /// 18 = 18% GST. 0 hides the GST row.
  final num gstPercent;

  /// true = pricePerMember already includes GST
  final bool priceIncludesGst;

  /// Features common to every tier of this module
  final List<PackageFeature> features;
  final List<PackageTier> tiers;

  /// Small print under the price summary (refunds, auto-renew, etc.)
  final String? termsNote;

  const PackagePlanDetails({
    required this.moduleKey,
    required this.title,
    this.description,
    this.currency = 'INR',
    this.gstPercent = 0,
    this.priceIncludesGst = true,
    this.features = const [],
    this.tiers = const [],
    this.termsNote,
  });

  factory PackagePlanDetails.fromJson(Map<String, dynamic> json) {
    return PackagePlanDetails(
      moduleKey: _toStr(json['moduleKey']) ?? '',
      title: _toStr(json['title']) ?? 'Package',
      description: _toStr(json['description']),
      currency: _toStr(json['currency']) ?? 'INR',
      gstPercent: _toNum(json['gstPercent']) ?? 0,
      priceIncludesGst: _toBool(json['priceIncludesGst'], fallback: true),
      features: PackageFeature.listFromJson(json['features']),
      tiers: _asMapList(json['tiers'])
          .map(PackageTier.fromJson)
          // A tier with no durations cannot be bought
          .where((t) => t.durations.isNotEmpty)
          .toList(),
      termsNote: _toStr(json['termsNote']),
    );
  }
}

/// Basic / Standard / Premium, or Individual / Team
class PackageTier {
  final int? id;
  final String code;
  final String name;
  final String? description;
  final String? badge;
  final bool isRecommended;
  final int minMembers;
  final int maxMembers;
  final List<PackageFeature> features;
  final List<PackageDuration> durations;

  const PackageTier({
    this.id,
    required this.code,
    required this.name,
    this.description,
    this.badge,
    this.isRecommended = false,
    this.minMembers = 1,
    this.maxMembers = 1,
    this.features = const [],
    this.durations = const [],
  });

  factory PackageTier.fromJson(Map<String, dynamic> json) {
    final min = _toInt(json['minMembers']) ?? 1;
    final max = _toInt(json['maxMembers']) ?? min;
    final safeMin = min < 1 ? 1 : min;
    final durations = _asMapList(json['durations'])
        .map(PackageDuration.fromJson)
        .where((d) => d.planId != null)
        .toList()
      ..sort((a, b) => a.durationMonths.compareTo(b.durationMonths));
    return PackageTier(
      id: _toInt(json['id']),
      code: _toStr(json['code']) ?? '',
      name: _toStr(json['name']) ?? 'Plan',
      description: _toStr(json['description']),
      badge: _toStr(json['badge']),
      isRecommended: _toBool(json['isRecommended']),
      minMembers: safeMin,
      maxMembers: max < safeMin ? safeMin : max,
      features: PackageFeature.listFromJson(json['features']),
      durations: durations,
    );
  }

  bool get allowsMultipleMembers => maxMembers > 1;

  String get memberRangeLabel {
    if (maxMembers <= 1) return '1 member';
    if (minMembers == maxMembers) return '$maxMembers members';
    return '$minMembers–$maxMembers members';
  }

  /// The 1-month option, used to work out savings on longer durations
  PackageDuration? get monthlyReference {
    for (final d in durations) {
      if (d.durationMonths == 1) return d;
    }
    return null;
  }
}

/// One purchasable plan (a row in the backend plans table).
class PackageDuration {
  /// Sent to create-order
  final int? planId;
  final String billingInterval;
  final int durationMonths;

  /// Price per member for the whole duration (not per month)
  final num pricePerMember;

  /// Optional strike-through price per member for the whole duration
  final num? mrpPerMember;
  final num? savingsPercent;
  final String? label;
  final bool isRecommended;

  const PackageDuration({
    this.planId,
    this.billingInterval = '',
    this.durationMonths = 1,
    this.pricePerMember = 0,
    this.mrpPerMember,
    this.savingsPercent,
    this.label,
    this.isRecommended = false,
  });

  factory PackageDuration.fromJson(Map<String, dynamic> json) {
    final interval = (_toStr(json['billingInterval']) ?? '').toLowerCase();
    var months = _toInt(json['durationMonths']) ?? 0;
    if (months <= 0) {
      months = switch (interval) {
        'quarterly' => 3,
        'half_yearly' || 'halfyearly' => 6,
        'yearly' || 'annual' => 12,
        _ => 1,
      };
    }
    return PackageDuration(
      planId: _toInt(json['planId'] ?? json['id']),
      billingInterval: interval,
      durationMonths: months,
      pricePerMember: _toNum(json['pricePerMember']) ?? 0,
      mrpPerMember: _toNum(json['mrpPerMember']),
      savingsPercent: _toNum(json['savingsPercent']),
      label: _toStr(json['label']),
      isRecommended: _toBool(json['isRecommended']),
    );
  }

  String get displayLabel {
    if (label != null) return label!;
    switch (durationMonths) {
      case 1:
        return 'Monthly';
      case 3:
        return 'Quarterly';
      case 6:
        return 'Half-yearly';
      case 12:
        return 'Yearly';
    }
    return '$durationMonths Months';
  }

  /// "1 month", "3 months", "1 year"
  String get periodLabel {
    if (durationMonths == 12) return '1 year';
    if (durationMonths % 12 == 0) return '${durationMonths ~/ 12} years';
    return durationMonths == 1 ? '1 month' : '$durationMonths months';
  }

  num get pricePerMemberPerMonth =>
      durationMonths > 0 ? pricePerMember / durationMonths : pricePerMember;

  /// Whole-number savings %, or null when there is nothing to show.
  /// Order: backend value → MRP → compared with the monthly plan.
  int? savingsAgainst(PackageDuration? monthly) {
    num? pct = savingsPercent;
    if (pct == null && mrpPerMember != null && mrpPerMember! > pricePerMember) {
      pct = (mrpPerMember! - pricePerMember) / mrpPerMember! * 100;
    }
    if (pct == null &&
        monthly != null &&
        monthly.planId != planId &&
        durationMonths > 1) {
      final full = monthly.pricePerMember * durationMonths;
      if (full > pricePerMember) pct = (full - pricePerMember) / full * 100;
    }
    if (pct == null) return null;
    final rounded = pct.round();
    return rounded >= 1 ? rounded : null;
  }
}

class PackageFeature {
  final String title;
  final String? subtitle;
  final bool included;

  const PackageFeature({
    required this.title,
    this.subtitle,
    this.included = true,
  });

  /// Accepts ["Text", ...] or [{title, subtitle, included}, ...]
  static List<PackageFeature> listFromJson(dynamic v) {
    if (v is! List) return const [];
    final out = <PackageFeature>[];
    for (final e in v) {
      if (e is Map) {
        final m = Map<String, dynamic>.from(e);
        final title = _toStr(m['title']);
        if (title == null) continue;
        out.add(PackageFeature(
          title: title,
          subtitle: _toStr(m['subtitle']),
          included: _toBool(m['included'], fallback: true),
        ));
      } else {
        final title = _toStr(e);
        if (title != null) out.add(PackageFeature(title: title));
      }
    }
    return out;
  }
}

// ---------------------------------------------------------------------------
// POST packages/payment/create-order
// Same shape as walkie/payment/create-order so the backend can reuse it.
// ---------------------------------------------------------------------------

class PackageCreateOrderResponse {
  final bool status;
  final String? message;

  /// Backend payment row id, sent back to verify
  final int? paymentId;
  final String? razorpayKeyId;
  final String? razorpayOrderId;

  /// In paise
  final int? amount;
  final String currency;

  const PackageCreateOrderResponse({
    this.status = false,
    this.message,
    this.paymentId,
    this.razorpayKeyId,
    this.razorpayOrderId,
    this.amount,
    this.currency = 'INR',
  });

  factory PackageCreateOrderResponse.fromJson(dynamic json) {
    final map = _asMap(json);
    if (map == null) return const PackageCreateOrderResponse();
    final data = _asMap(map['data']) ?? const <String, dynamic>{};
    final payment = _asMap(data['payment']) ?? const <String, dynamic>{};
    final rzp = _asMap(data['razorpay']) ?? const <String, dynamic>{};
    return PackageCreateOrderResponse(
      status: _toBool(map['status']),
      message: _toStr(map['message']),
      paymentId: _toInt(payment['id']),
      razorpayKeyId: _toStr(rzp['keyId']),
      razorpayOrderId: _toStr(rzp['orderId']),
      amount: _toNum(rzp['amount'])?.round(),
      currency: _toStr(rzp['currency']) ?? 'INR',
    );
  }

  bool get canOpenCheckout =>
      status &&
      paymentId != null &&
      (razorpayOrderId?.isNotEmpty ?? false) &&
      (amount ?? 0) > 0;
}

// ---------------------------------------------------------------------------
// POST packages/payment/verify
// ---------------------------------------------------------------------------

class PackageVerifyPaymentResponse {
  final bool status;
  final String? message;
  final int? subscriptionId;
  final String? activeUntil;

  const PackageVerifyPaymentResponse({
    this.status = false,
    this.message,
    this.subscriptionId,
    this.activeUntil,
  });

  factory PackageVerifyPaymentResponse.fromJson(dynamic json) {
    final map = _asMap(json);
    if (map == null) return const PackageVerifyPaymentResponse();
    final data = _asMap(map['data']) ?? const <String, dynamic>{};
    final sub = _asMap(data['subscription']) ?? data;
    return PackageVerifyPaymentResponse(
      status: _toBool(map['status']),
      message: _toStr(map['message']),
      subscriptionId: _toInt(sub['id'] ?? sub['subscriptionId']),
      activeUntil: _toStr(sub['activeUntil'] ?? sub['endDate']),
    );
  }
}
