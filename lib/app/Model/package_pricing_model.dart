/// Models for the Packages & Pricing screen (Attendance, Walkie-Talkie,
/// Safe Zone + Safe Route, Live Tracking).
///
/// JSON contract: docs/packages/02_backend_requirements.md
/// Every parser is tolerant: numbers/booleans may arrive as strings, unknown
/// keys are ignored, and missing lists become empty lists.
library;

int? _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.isFinite ? v.toInt() : null;
  return int.tryParse(v?.toString() ?? '');
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
// GET /api/packages
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

/// One module card on the Packages & Pricing screen.
class PackageItem {
  final int? id;
  final String moduleKey;
  final String title;
  final String? tagline;
  final String? iconUrl;

  /// Optional accent colour from backend, e.g. "#16A34A"
  final String? themeColor;

  /// Small label next to the title, e.g. "Popular"
  final String? badge;

  /// false = shown as "Coming soon" and not tappable
  final bool isAvailable;
  final List<String> highlights;
  final int sortOrder;

  const PackageItem({
    this.id,
    required this.moduleKey,
    required this.title,
    this.tagline,
    this.iconUrl,
    this.themeColor,
    this.badge,
    this.isAvailable = true,
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
      badge: _toStr(json['badge']),
      // Only Walkie-Talkie has an inner screen for now; every other module
      // shows "Coming soon" whatever the backend sends.
      isAvailable: moduleKey == PackageModuleKey.walkieTalkie &&
          _toBool(json['isAvailable'], fallback: true),
      highlights: highlights,
      sortOrder: _toInt(json['sortOrder']) ?? 0,
    );
  }

  /// Placeholder used only for loading skeletons
  factory PackageItem.placeholder() => const PackageItem(
        moduleKey: '',
        title: 'Package name here',
        tagline: 'Short description of what this module does',
        highlights: ['Feature one', 'Feature two'],
      );
}
