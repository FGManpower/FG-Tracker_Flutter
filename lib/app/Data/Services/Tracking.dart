

class Tracking {
  /// Safely parse a date-time string, automatically handling UTC timestamps without trailing 'Z'.
  static DateTime? parseDateTime(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw.isUtc ? raw.toLocal() : raw;
    final str = raw.toString().trim();
    if (str.isEmpty || str == 'null') return null;

    try {
      DateTime dt = DateTime.parse(str);
      // If the string does not specify a timezone offset or Z, backend might have stored in UTC
      if (!str.endsWith('Z') && !str.contains('+')) {
        final utcDt = DateTime.tryParse('${str.replaceAll(' ', 'T')}Z');
        if (utcDt != null) {
          final now = DateTime.now();
          final diffNormal = now.difference(dt).abs();
          final diffUtc = now.difference(utcDt.toLocal()).abs();
          if (diffUtc < diffNormal) {
            return utcDt.toLocal();
          }
        }
      }
      return dt.isUtc ? dt.toLocal() : dt;
    } catch (_) {
      return null;
    }
  }

  /// Check if a user is considered online/live based on explicit status or recency of lastSeen.
  bool isOnline({dynamic rawIsOnline, dynamic lastSeen, int thresholdMinutes = 5}) {
    if (rawIsOnline != null) {
      if (rawIsOnline == true || rawIsOnline == 1 || rawIsOnline == '1') return true;
      if (rawIsOnline is String) {
        final lower = rawIsOnline.trim().toLowerCase();
        if (lower == 'true' || lower == '1' || lower == 'online') return true;
        if (lower == 'false' || lower == '0' || lower == 'offline') return false;
      }
      if (rawIsOnline == false || rawIsOnline == 0) return false;
    }

    if (lastSeen != null) {
      final dt = parseDateTime(lastSeen);
      if (dt != null) {
        final now = DateTime.now();
        final diff = now.difference(dt);
        if (diff.isNegative || diff.inMinutes < thresholdMinutes) {
          return true;
        }
      }
    }
    return false;
  }

  String getTimeAgo(DateTime lastSeen) {
    final now = DateTime.now();
    final dt = lastSeen.isUtc ? lastSeen.toLocal() : lastSeen;
    final diff = now.difference(dt);

    if (diff.isNegative || diff.inSeconds < 180) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    }
    return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
  }
}

